local _, addon = ...
local M = {}
local fsEnumerable = addon.Enumerable
addon.Scheduler = M

local combatEndCallbacks = {}

local function OnCombatEnded()
    local copy = fsEnumerable:From(combatEndCallbacks):ToTable()
    wipe(combatEndCallbacks)

    for _, callback in ipairs(copy) do
        callback()
    end
end

---Invokes the callback on the next frame.
---@param callback fun()
function M:RunNextFrame(callback)
    C_Timer.After(0, callback)
end

---Invokes the callback once combat ends.
---@param callback fun()
function M:RunWhenCombatEnds(callback)
    if not InCombatLockdown() then
        callback()
        return
    end

    combatEndCallbacks[#combatEndCallbacks + 1] = callback
end

function addon:InitScheduler()
    local eventFrame = CreateFrame("Frame")
    eventFrame:HookScript("OnEvent", OnCombatEnded)
    eventFrame:RegisterEvent(addon.Events.PLAYER_REGEN_ENABLED)
end
