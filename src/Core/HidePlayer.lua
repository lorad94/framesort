local _, addon = ...
local fsUnit = addon.Unit
local fsSort = addon.Sorting
local fsFrame = addon.Frame
local fsCompare = addon.Compare
local fsEnumerable = addon.Enumerable
local fsLog = addon.Log
local M = {}
addon.HidePlayer = M

local function CanUpdate()
    if InCombatLockdown() then
        return false
    end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if EditModeManagerFrame.editModeActive then
            return false
        end
    end

    return true
end

function FindPlayer(provider)
    local isPlayer = function(frame)
        local unit = provider:GetUnit(frame)
        -- a player can have more than one frame if they occupy a vehicle
        -- as both the player and vehicle pet frame are shown
        return (unit == "player" or UnitIsUnit(unit, "player")) and not fsUnit:IsPet(unit)
    end

    local party = provider:PartyFrames()
    local found = fsEnumerable:From(party):First(function(frame)
        return isPlayer(frame)
    end)

    if found then
        return found
    end

    if provider:IsRaidGrouped() then
        local groups = provider:RaidGroups()
        for _, group in ipairs(groups) do
            local members = provider:RaidGroupMembers(group)
            found = fsEnumerable:From(members):First(function(frame)
                return isPlayer(frame)
            end)

            if found then
                return found
            end
        end
    else
        local raid = provider:RaidFrames()
        found = fsEnumerable:From(raid):First(function(frame)
            return isPlayer(frame)
        end)

        if found then
            return found
        end
    end

    return nil
end

local function Run()
    if not CanUpdate() then
        return
    end

    local enabled, mode, _, _ = fsCompare:FriendlySortMode()
    if not enabled then
        return
    end

    local found = false
    for _, provider in pairs(fsFrame.Providers:Enabled()) do
        local player = FindPlayer(provider)

        if player and not player:IsForbidden() then
            player:SetShown(mode ~= addon.PlayerSortMode.Hidden)
            found = true
        end
    end

    if not found and IsInGroup() then
        fsLog:Warning("Couldn't find player raid frame.")
    end
end

---Shows or hides the player (depending on settings).
function M:ShowHidePlayer()
    Run()
end

---Initialises the player show/hide module.
function addon:InitPlayerHiding()
    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", Run)
    eventFrame:RegisterEvent(addon.Events.PLAYER_ENTERING_WORLD)
    eventFrame:RegisterEvent(addon.Events.GROUP_ROSTER_UPDATE)
    eventFrame:RegisterEvent(addon.Events.PLAYER_REGEN_ENABLED)
    fsSort:RegisterPostSortCallback(Run)
end
