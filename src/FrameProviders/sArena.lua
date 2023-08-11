local _, addon = ...
local fsFrame = addon.Frame
local M = {}

fsFrame.Providers.sArena = M
table.insert(fsFrame.Providers.All, M)

local function GetUnit(frame)
    return frame.unit
end

function M:Name()
    return "sArena"
end

function M:Enabled()
    if GetAddOnEnableState(nil, "sArena Updated") == 0 then
        return false
    end

    return sArena ~= nil
end

function M:GetUnit(frame)
    return GetUnit(frame)
end

function M:PartyFrames()
    return {}
end

function M:RaidFrames()
    return {}
end

function M:RaidGroupMembers(_)
    return {}
end

function M:RaidGroups()
    return {}
end

function M:EnemyArenaFrames()
    return fsFrame:ChildUnitFrames(sArena, GetUnit)
end

function M:ShowPartyPets()
    return false
end

function M:ShowRaidPets()
    return false
end

function M:IsRaidGrouped()
    return false
end
