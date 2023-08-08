---@class FrameProvider
---@field Name fun(self: table): string Returns the display name for this provider.
---@field Enabled fun(self: table): boolean Whether the provider is enabled.
---@field Priority fun(self: table): number A lower number = higher priority.
---@field PartyFramesEnabled fun(self: table): boolean Whether party frames are enabled.
---@field RaidFramesEnabled fun(self: table): boolean Whether raid frames are enabled.
---@field EnemyArenaFramesEnabled fun(self: table): boolean Whether enemy arena frames are enabled.
---@field GetUnit fun(self: table, frame: table): string? A function that accepts a frame from this provider and returns the unit token.
---@field PartyFrames fun(self: table): table[] Returns a collection of party frames.
---@field RaidFrames fun(self: table): table[] Returns a collection of raid frames.
---@field RaidGroups fun(self: table): table[] Returns a collection of raid groups.
---@field RaidGroupMembers fun(self: table, group: table): table[] Returns a collection of raid frames from the specified group.
---@field EnemyArenaFrames fun(self: table): table[] Returns a collection of enemy arena frames.
---@field ShowPartyPets fun(self: table): boolean Whether party pets are enabled.
---@field ShowRaidPets fun(self: table): boolean Whether raid pets are enabled.
---@field PartyGrouped fun(self: table): boolean Whether the party is grouped.
---@field RaidGrouped fun(self: table): boolean Whether the raid is grouped.
---@field PartyHorizontalLayout fun(self: table): boolean Whether the party layout is horizontal.
---@field RaidHorizontalLayout fun(self: table): boolean Whether the raid layout is horizontal.
