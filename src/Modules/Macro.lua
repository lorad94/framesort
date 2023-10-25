---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsScheduler = addon.Scheduling.Scheduler
local fsMacro = addon.WoW.Macro
local fsLog = addon.Logging.Log
local fsTarget = addon.Modules.Targeting
local maxMacros = 138
local isSelfEditingMacro = false
---@type table<number, boolean>
local isFsMacroCache = {}
---@class MacroModule: IInitialise
local M = {}
addon.Modules.Macro = M

---@return boolean updated, boolean isFrameSortMacro, number newId
local function Rewrite(id, friendlyUnits, enemyUnits)
    local _, _, body = wow.GetMacroInfo(id)

    if not body or not fsMacro:IsFrameSortMacro(body) then
        return false, false, id
    end

    local newBody = fsMacro:GetNewBody(body, friendlyUnits, enemyUnits)

    if not newBody then
        return false, true, id
    end

    if body == newBody then
        return false, true, id
    end

    isSelfEditingMacro = true
    local newId = wow.EditMacro(id, nil, nil, newBody)
    isSelfEditingMacro = false

    return true, true, newId
end

local function UpdateMacro(id, friendlyUnits, enemyUnits, bypassCache)
    -- if we've already inspected this macro and it's not a framesort macro
    -- then skip attempting to re-process it
    local shouldInspect = bypassCache or isFsMacroCache[id] == nil or isFsMacroCache[id]

    if not shouldInspect then
        return false
    end

    friendlyUnits = friendlyUnits or fsTarget:FriendlyTargets()
    enemyUnits = enemyUnits or fsTarget:EnemyTargets()

    local updated, isFsMacro, newId = Rewrite(id, friendlyUnits, enemyUnits)
    isFsMacroCache[newId] = isFsMacro

    if updated then
        fsLog:Debug("Updated macro: " .. newId)
    end

    return updated
end

local function ScanMacros()
    local start = wow.GetTimePreciseSec()
    local friendlyUnits = fsTarget:FriendlyTargets()
    local enemyUnits = fsTarget:EnemyTargets()
    local updatedCount = 0

    for id = 1, maxMacros do
        local updated = UpdateMacro(id, friendlyUnits, enemyUnits, false)

        if updated then
            updatedCount = updatedCount + 1
        end
    end

    if updatedCount > 0 then
        fsLog:Debug(string.format("Updated %d macros", updatedCount))
    end

    local stop = wow.GetTimePreciseSec()
    fsLog:Debug(string.format("Update macros took %fms.", (stop - start) * 1000))
end

local function OnEditMacro(id, _, _, _)
    -- prevent recursion from EditMacro hook
    if isSelfEditingMacro then
        return
    end

    fsScheduler:RunWhenCombatEnds(function()
        UpdateMacro(id, nil, nil, true)
    end, "EditMacro" .. id)
end

function M:Run()
    assert(not wow.InCombatLockdown())

    ScanMacros()
end

function M:Init()
    if #isFsMacroCache > 0 then
        isFsMacroCache = {}
    end

    wow.hooksecurefunc("EditMacro", OnEditMacro)
end
