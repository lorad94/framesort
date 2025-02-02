---@type string, Addon
local _, addon = ...
local fsConfig = addon.Configuration
local wow = addon.WoW.Api
local L = addon.Locale
local callbacks = {}

fsConfig.VerticalSpacing = 13
fsConfig.HorizontalSpacing = 50

local function AddCategory(panel)
    if wow.IsRetail() then
        local category = wow.Settings.RegisterCanvasLayoutCategory(panel, panel.name, panel.name)
        category.ID = panel.name
        wow.Settings.RegisterAddOnCategory(category)
    else
        wow.InterfaceOptions_AddCategory(panel)
    end
end

local function AddSubCategory(panel)
    if wow.IsRetail() then
        local category = wow.Settings.GetCategory(panel.parent)
        local subcategory = wow.Settings.RegisterCanvasLayoutSubcategory(category, panel, panel.name, panel.name)
        subcategory.ID = panel.name
    else
        wow.InterfaceOptions_AddCategory(panel)
    end
end

function fsConfig:RegisterConfigurationChangedCallback(callback)
    callbacks[#callbacks + 1] = callback
end

function fsConfig:NotifyChanged()
    for _, callback in ipairs(callbacks) do
        pcall(callback)
    end
end

function fsConfig:TextBlock(lines, parent, anchor)
    local textAnchor = anchor

    for i, line in ipairs(lines) do
        local description = parent:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", textAnchor, "BOTTOMLEFT", 0, i == 1 and -fsConfig.VerticalSpacing or -fsConfig.VerticalSpacing / 2)
        description:SetText(line)
        textAnchor = description
    end

    return textAnchor
end

function fsConfig:MultilineTextBlock(text, parent, anchor)
    local lines = {}

    for str in string.gmatch(text, "([^\n]+)") do
        -- convert any \n literals into new lines
        str = string.gsub(str, "\\n", "\n")
        lines[#lines + 1] = str
    end

    return fsConfig:TextBlock(lines, parent, anchor)
end

function fsConfig:Init()
    local panel = wow.CreateFrame("ScrollFrame", nil, nil, "UIPanelScrollFrameTemplate")
    panel.name = L["FrameSort"]

    local main = wow.CreateFrame("Frame")

    if wow.IsRetail() then
        main:SetWidth(wow.SettingsPanel.Container:GetWidth())
        main:SetHeight(wow.SettingsPanel.Container:GetHeight())
    else
        main:SetWidth(wow.InterfaceOptionsFramePanelContainer:GetWidth())
        main:SetHeight(wow.InterfaceOptionsFramePanelContainer:GetHeight())
    end

    panel:SetScrollChild(main)

    AddCategory(panel)

    local panels = fsConfig.Panels
    panels.Sorting:Build(main)

    local sortingMethod = panels.SortingMethod:Build(panel)
    local roleOrdering = panels.RoleOrdering:Build(panel)
    local autoLeader = wow.IsRetail() and panels.AutoLeader:Build(panel)
    local keybinding = panels.Keybinding:Build(panel)
    local macro = panels.Macro:Build(panel)
    local spacing = panels.Spacing:Build(panel)
    local addons = panels.Addons:Build(panel)
    local api = panels.Api:Build(panel)
    local health = panels.Health:Build(panel)
    local help = panels.Help:Build(panel)

    AddSubCategory(sortingMethod)
    AddSubCategory(roleOrdering)

    if wow.IsRetail() then
        AddSubCategory(autoLeader)
    end

    AddSubCategory(keybinding)
    AddSubCategory(macro)
    AddSubCategory(spacing)
    AddSubCategory(addons)
    AddSubCategory(api)
    AddSubCategory(health)
    AddSubCategory(help)

    SLASH_FRAMESORT1 = "/fs"
    SLASH_FRAMESORT2 = "/framesort"

    wow.SlashCmdList.FRAMESORT = function()
        if wow.IsRetail() then
            wow.Settings.OpenToCategory(panel.name)
        else
            -- workaround the classic bug where the first call opens the Game interface
            -- and a second call is required
            wow.InterfaceOptionsFrame_OpenToCategory(panel)
            wow.InterfaceOptionsFrame_OpenToCategory(panel)
        end
    end
end
