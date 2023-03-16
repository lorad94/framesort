local _, addon = ...
local upgrader = {}

addon.OptionsUpgrader = upgrader

function upgrader:UpgradeToVersion2(options)
    assert(options.Version == nil or options.Version == 1)

    options.ArenaEnabled = options.PartySortEnabled
    options.ArenaPlayerSortMode = options.PlayerSortMode
    options.ArenaSortMode = options.PartySortMode

    options.DungeonEnabled = options.PartySortEnabled
    options.DungeonPlayerSortMode = options.PlayerSortMode
    options.DungeonSortMode = options.PartySortMode

    options.WorldEnabled = options.PartySortEnabled
    options.WorldPlayerSortMode = options.PlayerSortMode
    options.WorldSortMode = options.PartySortMode

    options.RaidEnabled = options.RaidSortEnabled
    options.RaidPlayerSortMode = options.PlayerSortMode

    options.DebugEnabled = false

    options.PartySortEnabled = nil
    options.PartySortMode = nil
    options.PlayerSortMode = nil
    options.RaidSortEnabled = nil

    options.Version = 2
end

function upgrader:UpgradeToVersion3(options)
    assert(options.Version == 2)

    options.ExperimentalEnabled = false
    options.Version = 3
end

function upgrader:UpgradeToVersion4(options)
    assert(options.Version == 3)

    options.SortingMethod = {
        TaintlessEnabled = true,
        TraditionalEnabled = false
    }

    options.Version = 4
end

function upgrader:UpgradeToVersion5(options)
    assert(options.Version == 4)

    options.Debug = {
        Enabled = options.DebugEnabled
    }

    options.Arena = {
        Enabled = options.ArenaEnabled,
        PlayerSortMode = options.ArenaPlayerSortMode,
        GroupSortMode = options.ArenaSortMode
    }

    options.Dungeon = {
        Enabled = options.DungeonEnabled,
        PlayerSortMode = options.DungeonPlayerSortMode,
        GroupSortMode = options.DungeonSortMode
    }

    options.Raid = {
        Enabled = options.RaidEnabled,
        PlayerSortMode = options.RaidPlayerSortMode,
        GroupSortMode = options.RaidSortMode
    }

    options.World = {
        Enabled = options.WorldEnabled,
        PlayerSortMode = options.WorldPlayerSortMode,
        GroupSortMode = options.WorldSortMode
    }

    options.DebugEnabled = nil

    options.ArenaEnabled = nil
    options.ArenaPlayerSortMode = nil
    options.ArenaSortMode = nil

    options.DungeonEnabled = nil
    options.DungeonPlayerSortMode = nil
    options.DungeonSortMode = nil

    options.RaidEnabled = nil
    options.RaidPlayerSortMode = nil
    options.RaidSortMode = nil

    options.WorldEnabled = nil
    options.WorldPlayerSortMode = nil
    options.WorldSortMode = nil

    -- forgot to remove this in version 4
    options.ExperimentalEnabled = nil

    options.Version = 5
end

function upgrader:UpgradeToVersion6(options)
    assert(options.Version == 5)

    options.Appearance = {
        Party = {
            Spacing = {
                Horizontal = 0,
                Vertical = 0
            },
        },
        Raid = {
            Spacing = {
                Horizontal = 0,
                Vertical = 0
            }
        }
    }

    options.Version = 6
end

function upgrader:UpgradeToVersion7(options)
    assert(options.Version == 6)

    options.Debug.Enabled = false
    options.Version = 7
end

function upgrader:UpgradeToVersion8(options)
    assert(options.Version == 7)

    options.Arena.Reverse = false
    options.Dungeon.Reverse = false
    options.Raid.Reverse = false
    options.World.Reverse = false
    options.Version = 8
end

local upgradeFunctions = {
    Version2 = upgrader.UpgradeToVersion2,
    Version3 = upgrader.UpgradeToVersion3,
    Version4 = upgrader.UpgradeToVersion4,
    Version5 = upgrader.UpgradeToVersion5,
    Version6 = upgrader.UpgradeToVersion6,
    Version7 = upgrader.UpgradeToVersion7,
    Version8 = upgrader.UpgradeToVersion8,
}

---Upgrades saved options to the current version.
function addon:UpgradeOptions()
    while (addon.Options.Version or 1) < addon.Defaults.Version do
        local nextVersion = (addon.Options.Version or 1) + 1
        local next = upgradeFunctions["Version" .. nextVersion]
        assert(next ~= nil)

        addon:Debug("Upgrading options to version " .. nextVersion .. ".")
        next(upgrader, addon.Options)
    end
end
