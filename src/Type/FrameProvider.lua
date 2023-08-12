---@class FrameProvider
---@field Name fun(self: table): string Returns the display name for this provider.
---@field Init fun(self: table) Performs any initialisation logic the provider might have.
---@field Enabled fun(self: table): boolean Whether the provider is enabled.
---@field GetUnit fun(self: table, frame: table): string? A function that accepts a frame from this provider and returns the unit token.
---@field PartyFrames fun(self: table): table[] Returns a collection of party frames.
---@field RaidFrames fun(self: table): table[] Returns a collection of raid frames.
---@field RaidGroups fun(self: table): table[] Returns a collection of raid groups.
---@field RaidGroupMembers fun(self: table, group: table): table[] Returns a collection of raid frames from the specified group.
---@field EnemyArenaFrames fun(self: table): table[] Returns a collection of enemy arena frames.
---@field ShowPartyPets fun(self: table): boolean Whether party pets are enabled.
---@field ShowRaidPets fun(self: table): boolean Whether raid pets are enabled.
---@field IsRaidGrouped fun(self: table): boolean Whether the raid is grouped.
---@field RegisterCallback fun(self: table, callback: fun(provider: FrameProvider): boolean) Registers a callback to be invoked when sorting is required.
