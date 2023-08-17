---@type string, Addon
local _, addon = ...
---@type WoW
local wow = addon.WoW
local fsSpacing = addon.Spacing
local verticalSpacing = addon.OptionsBuilder.VerticalSpacing
local minSpacing = 0
local maxSpacing = 100

local function ConfigureSlider(slider, value)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minSpacing, maxSpacing)
    slider:SetValue(value)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider:SetHeight(20)
    slider:SetWidth(400)

    _G[slider:GetName() .. "Low"]:SetText(minSpacing)
    _G[slider:GetName() .. "High"]:SetText(maxSpacing)
end

local function ConfigureEditBox(box, value)
    box:SetFontObject("GameFontWhite")
    box:SetSize(50, 20)
    box:SetAutoFocus(false)
    box:SetMaxLetters(math.log10(maxSpacing) + 1)
    box:SetText(tostring(value))
    box:SetCursorPosition(0)
    box:SetJustifyH("CENTER")
    box:SetNumeric(true)
end

local function BuildSpacingOptions(panel, parentAnchor, name, spacing, addX, addY, additionalTopSpacing)
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", parentAnchor, "BOTTOMLEFT", 0, -(verticalSpacing + additionalTopSpacing))
    title:SetText(name)

    local anchor = title
    local setValue = function(auto, slider, box)
        local value = tonumber(auto)

        if not value or value < minSpacing or value > maxSpacing then
            box:SetFontObject("GameFontRed")
            return nil
        end

        local text = tostring(value)
        box:SetFontObject("GameFontWhite")

        box:SetText(text)
        slider:SetValue(value)
        return value
    end

    if addX then
        local label = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        label:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
        label:SetText("Horizontal")

        local slider = wow.CreateFrame("Slider", "sld" .. name .. "XSpacing", panel, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -verticalSpacing)
        ConfigureSlider(slider, spacing.Horizontal)

        local box = wow.CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
        box:SetPoint("CENTER", slider, "CENTER", 0, 30)
        ConfigureEditBox(box, spacing.Horizontal)

        slider:SetScript("OnValueChanged", function(_, sliderValue, userInput)
            if not userInput then
                return
            end

            local value = setValue(sliderValue, slider, box)
            if value then
                spacing.Horizontal = value
                fsSpacing:ApplySpacing()
            end
        end)

        box:SetScript("OnTextChanged", function(_, userInput)
            if not userInput then
                return
            end

            local value = setValue(box:GetText(), slider, box)
            if value then
                spacing.Horizontal = value
                fsSpacing:ApplySpacing()
            end
        end)

        anchor = slider
    end

    if addY then
        local label = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        label:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
        label:SetText("Vertical")

        local slider = wow.CreateFrame("Slider", "sld" .. name .. "YSpacing", panel, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -verticalSpacing)
        ConfigureSlider(slider, spacing.Vertical)

        local box = wow.CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
        box:SetPoint("CENTER", slider, "CENTER", 0, 30)
        ConfigureEditBox(box, spacing.Vertical)

        slider:SetScript("OnValueChanged", function(_, sliderValue, userInput)
            if not userInput then
                return
            end

            local value = setValue(sliderValue, slider, box)
            if value then
                spacing.Vertical = value
                fsSpacing:ApplySpacing()
            end
        end)

        box:SetScript("OnTextChanged", function(_, userInput)
            if not userInput then
                return
            end

            local value = setValue(box:GetText(), slider, box)

            if value then
                spacing.Vertical = value
                fsSpacing:ApplySpacing()
            end
        end)

        anchor = slider
    end

    return anchor
end

function addon.OptionsBuilder.Spacing:Build(parent)
    local panel = wow.CreateFrame("Frame", "FrameSortSpacing", parent)
    panel.name = "Spacing"
    panel.parent = parent.name

    local spacingTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    spacingTitle:SetPoint("TOPLEFT", panel, verticalSpacing, -verticalSpacing)
    spacingTitle:SetText("Spacing")

    local descriptionLine1 = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    descriptionLine1:SetPoint("TOPLEFT", spacingTitle, "BOTTOMLEFT", 0, -verticalSpacing)
    descriptionLine1:SetText("Add some spacing between party/raid frames.")

    local descriptionLine2 = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
    descriptionLine2:SetPoint("TOPLEFT", descriptionLine1, "BOTTOMLEFT", 0, -verticalSpacing)
    descriptionLine2:SetText("This only applies to Blizzard frames.")

    local anchor = descriptionLine2
    if wow.WOW_PROJECT_ID == wow.WOW_PROJECT_MAINLINE then
        -- for retail
        anchor = BuildSpacingOptions(panel, anchor, "Party", addon.Options.Appearance.Party.Spacing, true, true, 0)
    end

    local title = wow.WOW_PROJECT_ID == wow.WOW_PROJECT_MAINLINE and "Raid" or "Group"
    anchor = BuildSpacingOptions(panel, anchor, title, addon.Options.Appearance.Raid.Spacing, true, true, verticalSpacing)

    if wow.WOW_PROJECT_ID == wow.WOW_PROJECT_MAINLINE and wow.CompactArenaFrame then
        anchor = BuildSpacingOptions(panel, anchor, "Enemy Arena", addon.Options.Appearance.EnemyArena.Spacing, false, true, verticalSpacing)
    end

    wow.InterfaceOptions_AddCategory(panel)

    return panel
end
