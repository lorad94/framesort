---@meta
---@class Configuration
---@field Init fun(self: table)
---@field Panels Panels
---@field HorizontalSpacing number
---@field VerticalSpacing number
---@field Defaults Options
---@field PlayerSortMode PlayerSortModeEnum
---@field GroupSortMode GroupSortModeEnum
---@field RoleOrdering RoleOrderingEnum
---@field SortingMethod SortingMethodEnum
---@field Upgrader OptionsUpgrader
---@field RegisterConfigurationChangedCallback fun(self: table, callback: fun())
---@field NotifyChanged fun(self: table)

---@class Panels
---@field Announcement OptionsPanel
---@field Sorting OptionsPanel
---@field Spacing OptionsPanel
---@field Health OptionsPanel
---@field Keybinding OptionsPanel
---@field Macro OptionsPanel
---@field Integration OptionsPanel
---@field RoleOrdering OptionsPanel
---@field SortingMethod OptionsPanel
