local _, addon = ...
local fsEnumerable = addon.Enumerable
local fsUnit = addon.Unit
local M = {}

addon.Frame = M
addon.FrameProviders = {
    All = {},
}

local function EmptyUnit(_)
    return "none"
end

local function PartyFramesProvider()
    return fsEnumerable
        :From(addon.FrameProviders.All)
        :OrderBy(function(x, y)
            return x:Priority() <= y:Priority()
        end)
        :First(function(provider)
            return provider:Enabled() and provider:PartyFramesEnabled()
        end)
end

local function RaidFramesProvider()
    return fsEnumerable
        :From(addon.FrameProviders.All)
        :OrderBy(function(x, y)
            return x:Priority() < y:Priority()
        end)
        :First(function(provider)
            return provider:Enabled() and provider:RaidFramesEnabled()
        end)
end

local function EnemyArenaFramesProvider()
    return fsEnumerable
        :From(addon.FrameProviders.All)
        :OrderBy(function(x, y)
            return x:Priority() < y:Priority()
        end)
        :First(function(provider)
            return provider:Enabled() and provider:EnemyArenaFramesEnabled()
        end)
end

---Returns the set of party frames.
---@return table[] frames, fun(frame: table): string a function to extract the unit token from a given frame.
function M:PartyFrames()
    local provider = PartyFramesProvider()

    if not provider then
        return {}, EmptyUnit
    end

    return provider:PartyFrames(), function(x)
        return provider:GetUnit(x)
    end
end

---Returns the set of non-grouped raid frames.
---@return table[] frames, fun(frame: table): string a function to extract the unit token from a given frame.
function M:RaidFrames()
    local provider = RaidFramesProvider()

    if not provider then
        return {}, EmptyUnit
    end

    return provider:RaidFrames(), function(x)
        return provider:GetUnit(x)
    end
end

---Returns the set of member frames within a raid group frame.
---@return table[] frames, fun(frame: table): string a function to extract the unit token from a given frame.
function M:RaidGroupMembers(group)
    local provider = RaidFramesProvider()

    if not provider then
        return {}, EmptyUnit
    end

    return provider:RaidGroupMembers(group), function(x)
        return provider:GetUnit(x)
    end
end

---Returns the set of raid frame group frames.
---@return table[] groups
function M:RaidGroups()
    local provider = RaidFramesProvider()

    if not provider then
        return {}
    end

    return provider:RaidGroups()
end

---Returns the set of enemy arena frames.
---@return table[] players, fun(frame: table): string
function M:EnemyArenaFrames()
    local provider = EnemyArenaFramesProvider()

    if not provider then
        return {}, EmptyUnit
    end

    return provider:EnemyArenaFrames(), function(x)
        return provider:GetUnit(x)
    end
end

---Returns the player raid frame.
---@return table? playerFrame
function M:PlayerRaidFrame()
    local frames = M:AllFriendlyFrames()
    local found = fsEnumerable:From(frames):First(function(frameWithUnit)
        -- a player can have more than one frame if they occupy a vehicle
        -- as both the player and vehicle pet frame are shown
        return (frameWithUnit.Unit == "player" or UnitIsUnit(frameWithUnit.Unit, "player")) and not fsUnit:IsPet(frameWithUnit.Unit)
    end)

    return found and found.Frame
end

---Returns both party and raid frames.
---@return FrameWithUnit[]
function M:AllFriendlyFrames()
    local party, partyGetUnit = M:PartyFrames()
    local raid, raidGetUnit = M:RaidFrames()

    local partyWithUnit = fsEnumerable
        :From(party)
        :Map(function(frame)
            return {
                Frame = frame,
                Unit = partyGetUnit(frame),
            }
        end)
        :ToTable()

    local raidWithUnit = fsEnumerable
        :From(raid)
        :Map(function(frame)
            return {
                Frame = frame,
                Unit = raidGetUnit(frame),
            }
        end)
        :ToTable()

    return fsEnumerable:From(partyWithUnit):Concat(raidWithUnit):ToTable()
end

---Returns true if pets are shown in party frames.
---@return boolean
function M:ShowPartyPets()
    local provider = PartyFramesProvider()

    if not provider then
        return false
    end

    return provider:ShowPartyPets()
end

---Returns true if pets are shown in raid frames.
---@return boolean
function M:ShowRaidPets()
    local provider = RaidFramesProvider()

    if not provider then
        return false
    end

    return provider:ShowRaidPets()
end

---Returns true if frames are grouped.
---@return boolean
function M:PartyGrouped()
    local provider = PartyFramesProvider()

    if not provider then
        return false
    end

    return provider:PartyGrouped()
end

---Returns true if frames are grouped.
---@return boolean
function M:RaidGrouped()
    local provider = RaidFramesProvider()

    if not provider then
        return false
    end

    return provider:RaidGrouped()
end

---Returns true if the frames are using horizontal layout.
---@return boolean
function M:PartyHorizontalLayout()
    local provider = PartyFramesProvider()

    if not provider then
        return false
    end

    return provider:PartyHorizontalLayout()
end

---Returns true if the frames are using horizontal layout.
---@return boolean
function M:RaidHorizontalLayout()
    local provider = RaidFramesProvider()

    if not provider then
        return false
    end

    return provider:RaidHorizontalLayout()
end

---Returns the frames in order of their relative positioning to each other.
---@param frames table[] frames in any particular order
---@return LinkedListNode root in order of parent -> child -> child -> child
function M:ToFrameChain(frames)
    local invalid = { Valid = false }

    if #frames == 0 then
        return invalid
    end

    local nodesByFrame = fsEnumerable:From(frames):ToLookup(function(frame)
        return frame
    end, function(frame)
        return {
            Next = nil,
            Previous = nil,
            Value = frame,
        }
    end)

    local root = nil
    for _, child in pairs(nodesByFrame) do
        local _, relativeTo, _, _, _ = child.Value:GetPoint()
        local parent = nodesByFrame[relativeTo]

        if parent then
            if parent.Next then
                return invalid
            end

            parent.Next = child
            child.Previous = parent
        else
            root = child
        end
    end

    -- assert we have a complete chain
    local count = 0
    local current = root

    while current do
        count = count + 1
        current = current.Next
    end

    if count ~= #frames then
        return invalid
    end

    root.Valid = true
    return root
end

---Returns an ordered set of frames from the given chain
---@param chain LinkedListNode root
function M:FramesFromChain(chain)
    local frames = {}
    local next = chain

    while next do
        frames[#frames + 1] = next.Value

        next = next.Next
    end

    return frames
end

---Returns true if all the frames have the same anchor.
---@param frames table[] frames in any particular order
---@return boolean
function M:IsFlat(frames)
    if #frames == 0 then
        return false
    end

    local _, anchor, _, _, _ = frames[1]:GetPoint()
    for i = 2, #frames do
        local _, relativeTo, _, _, _ = frames[i]:GetPoint()

        if relativeTo ~= anchor then
            return false
        end
    end

    return true
end

---Returns true if the specified frame is a valid unit frame.
---@param frame table
---@param getUnit fun(frame: table): string
---@return boolean
function M:IsValidUnitFrame(frame, getUnit)
    if not frame then
        return false
    end

    if frame:IsForbidden() then
        return false
    end

    if frame:GetTop() == nil or frame:GetLeft() == nil then
        return false
    end

    local unit = getUnit(frame)

    if unit == nil then
        return false
    end

    -- we may have hidden the player frame, but for other frames we don't want them
    if unit ~= "player" and not frame:IsVisible() then
        return false
    end

    return true
end

---Returns a collection of unit frames from the specified container.
---@param container table
---@param getUnit fun(frame: table): string
---@return table
function M:ChildUnitFrames(container, getUnit)
    if not container or container:IsForbidden() or not container:IsVisible() then
        return {}
    end

    return fsEnumerable
        :From({ container:GetChildren() })
        :Where(function(frame)
            return M:IsValidUnitFrame(frame, getUnit)
        end)
        :ToTable()
end
