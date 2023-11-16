---@type string, Addon
local _, addon = ...
local fsFrame = addon.WoW.Frame
local fsProviders = addon.Providers
local M = {}
local callbacks = {}

fsProviders.sArena = M
table.insert(fsProviders.All, M)

function M:Name()
    return "sArena"
end

function M:Enabled()
    -- there are a few of variants of sArena
    -- e.g. "sArena Updated" and "sArena_Updated2_by_sammers"
    -- so instead of checking for enabled state just check if the container exists
    return sArena ~= nil and type(sArena) == "table"
end

function M:Init()
    if not M:Enabled() then
        return
    end

    if #callbacks > 0 then
        callbacks = {}
    end
end

function M:RegisterRequestSortCallback(_) end

function M:RegisterContainersChangedCallback(_) end

function M:Containers()
    if not sArena then
        return {}
    end

    ---@type FrameContainer
    local arena = {
        Frame = sArena,
        Type = fsFrame.ContainerType.EnemyArena,
        LayoutType = fsFrame.LayoutType.Soft,
        SupportsSpacing = false,

        -- not applicable
        FramesOffset = function() return nil end,
        IsGrouped = function() return nil end,
        IsHorizontalLayout = function() return nil end,
        GroupFramesOffset = function(_) return nil end,
        FramesPerLine = function(_) return nil end
    }

    return {
        arena
    }
end
