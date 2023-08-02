local _, addon = ...
local fsUnit = addon.Unit
local fsSort = addon.Sorting
local fsEnumerable = addon.Enumerable
local fsMacro = addon.Macro
local fsFrame = addon.Frame
local fsCompare = addon.Compare
local fsLog = addon.Log
local maxMacros = 138
local isSelfEditingMacro = false
local updatePending = false
---@type table<number, boolean>
local isFsMacroCache = {}

local function CanUpdate()
    if InCombatLockdown() then
        fsLog:Warning("Can't update macros during combat.")
        return false
    end

    return true
end

local function GetTargets()
    local players, _, getUnit = fsFrame:GetFrames()
    if #players > 0 then
        return fsEnumerable
            :From(players)
            :OrderBy(function(x, y)
                return fsCompare:CompareTopLeftFuzzy(x, y)
            end)
            :Map(getUnit)
            :ToTable()
    end

    -- fallback to retrieve the group units
    return fsUnit:GetUnits()
end

local function InspectMacro(slot)
    local _, _, body = GetMacroInfo(slot)

    if not body or not fsMacro:IsFrameSortMacro(body) then
        return false
    end

    local units = GetTargets()
    local newBody = fsMacro:GetNewBody(body, units)

    if not newBody then
        return false
    end

    isSelfEditingMacro = true
    EditMacro(slot, nil, nil, newBody)
    isSelfEditingMacro = false

    return true
end

local function ScanMacros()
    for slot = 1, maxMacros do
        -- if we've already inspected this macro and it's not a framesort macro
        -- then skip attempting to re-process it
        local probablyFsMacro = isFsMacroCache[slot] == nil or isFsMacroCache[slot]

        if probablyFsMacro then
            isFsMacroCache[slot] = InspectMacro(slot)
        end
    end
end

local function OnEditMacro(slot, _, _, _)
    -- prevent recursion from EditMacro hook
    if isSelfEditingMacro then
        return
    end

    if not CanUpdate() then
        updatePending = true
        return
    end

    isFsMacroCache[slot] = InspectMacro(slot)
end

local function Run()
    if not CanUpdate() then
        updatePending = true
        return
    end

    ScanMacros()
    updatePending = false
end

local function CombatEnded()
    if updatePending then
        Run()
    end
end

---Initialises the macros module.
function addon:InitMacros()
    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", Run)
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        eventFrame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
    end

    local endCombatFrame = CreateFrame("Frame")
    endCombatFrame:HookScript("OnEvent", CombatEnded)
    endCombatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

    fsSort:RegisterPostSortCallback(Run)

    hooksecurefunc("EditMacro", OnEditMacro)
end
