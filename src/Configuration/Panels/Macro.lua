---@type string, Addon
local _, addon = ...
local wow = addon.WoW.Api
local fsMacro = addon.WoW.Macro
local fsConfig = addon.Configuration
local maxMacros = 138
local M = {}
fsConfig.Panels.Macro = M

local function CountMacros()
    local count = 0

    for i = 1, maxMacros do
        local _, _, body = wow.GetMacroInfo(i)

        if body and fsMacro:IsFrameSortMacro(body) then
            count = count + 1
        end
    end

    return count
end

function M:Build(parent)
    local verticalSpacing = fsConfig.VerticalSpacing
    local panel = wow.CreateFrame("Frame", "FrameSortMacros", parent)
    panel.name = "Macros"
    panel.parent = parent.name

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", verticalSpacing, -verticalSpacing)
    title:SetText("Macros")

    local countLine = panel:CreateFontString(nil, "ARTWORK", "GameFontGreen")
    countLine:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -verticalSpacing)
    countLine:SetText("FrameSort has found 0 macros to manage.")

    panel:HookScript("OnShow", function()
        local count = CountMacros()
        countLine:SetText("FrameSort has found " .. count .. " |4macro:macros; to manage.")
    end)

    local intro = {
        'FrameSort will dynamically update variables within macros that contain the "#FrameSort" header.',
        "Below are some examples on how to use this.",
    }

    local anchor = countLine
    for i, line in ipairs(intro) do
        local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, i == 1 and -verticalSpacing or -verticalSpacing / 2)
        description:SetText(line)
        anchor = description
    end

    local examples = {
        [[#showtooltip
#FrameSort Mouseover, Target, Healer
/cast [@mouseover,help][@target,help][@healer,exists] Blessing of Sanctuary]],

        [[#showtooltip
#FrameSort Frame1, Frame2, Player
/cast [mod:ctrl,@frame1][mod:shift,@frame2][mod:alt,@player][] Dispel]],

        [[#FrameSort EnemyHealer, EnemyHealer
/cast [@doesntmatter] Shadowstep;
/cast [@placeholder] Kick;
]],
    }

    local padding = 10
    for i, example in ipairs(examples) do
        local header = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        header:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -verticalSpacing)
        header:SetText(string.format("Example %d", i))

        local box = wow.CreateFrame("EditBox", nil, panel)
        box:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -verticalSpacing)
        box:SetSize(500, 1)
        box:SetFontObject("GameFontWhite")
        box:SetAutoFocus(false)
        box:SetMultiLine(true)
        box:SetText(example)
        box:SetCursorPosition(0)

        -- undo any user changes
        box:SetScript("OnTextChanged", function(_, userInput)
            if not userInput then
                return
            end

            box:SetText(example)
        end)

        box:SetScript("OnEscapePressed", function()
            box:ClearFocus()
        end)
        box:SetTextInsets(padding, padding, padding, padding)

        local bg = wow.CreateFrame("Frame", nil, panel, "BackdropTemplate")
        bg:SetBackdrop({
            edgeFile = "Interface\\Glues\\Common\\TextPanel-Border",
            edgeSize = 16,
        })
        bg:SetAllPoints(box)

        anchor = box
    end

    local notes = {
        "Supported variables:",
        " - Frame1, Frame2, Frame3, etc.",
        " - EnemyFrame1, EnemyFrame2, EnemyFrame3, etc. - Retail only (doesn't work in Wotlk and Classic).",
        " - BottomFrame",
        " - Tank, Healer, DPS.",
        " - OtherDps - The first DPS that's not you.",
        " - EnemyTank, EnemyHealer, EnemyDPS - Retail only (doesn't work in Wotlk and Classic).",
        " - Add a number to choose the Nth target, e.g., DPS2 selects the 2nd DPS.",
        " - Variables are case-insensitive so 'fRaMe1', 'Dps', 'enemyhealer', etc., will all work.",
    }

    for i, line in ipairs(notes) do
        local description = panel:CreateFontString(nil, "ARTWORK", "GameFontWhite")
        description:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, i == 1 and -verticalSpacing or -verticalSpacing / 2)
        description:SetText(line)
        anchor = description
    end

    return panel
end
