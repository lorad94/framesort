local addonName, addon = ...
local fsFrame = addon.Frame
local fsEnumerable = addon.Enumerable
local M = {}
addon.Health = M

local function AddonFriendlyName(name)
    if not name then
        return "(unknown)"
    elseif name == "" then
        return "(user macro)"
    elseif name == "*** ForceTaint_Strong ***" then
        return "(user macro)"
    else
        return name
    end
end

local function SortingFunctionsTampered()
    local functions = {
        "CRFSort_Group",
        "CRFSort_Role",
        "CRFSort_Alphabetical",
    }

    for _, f in ipairs(functions) do
        local issecure, taintedAddon = issecurevariable(f)
        if not issecure then
            return AddonFriendlyName(taintedAddon)
        end
    end

    return nil
end

local function ConflictingAddons()
    local raidContainer, raidContainerName = fsFrame:GetRaidFramesContainer()
    if raidContainer then
        local issecure, taintedAddon = issecurevariable(raidContainerName)
        if not issecure and taintedAddon ~= addonName then
            return AddonFriendlyName(taintedAddon)
        end

        -- issecurevariable returns true if the variable is nil or doesn't exist on the table
        -- so it'll still work if the container isn't Blizzard's
        issecure, taintedAddon = issecurevariable(raidContainer, "flowSortFunc")
        if not issecure and taintedAddon ~= addonName then
            return AddonFriendlyName(taintedAddon)
        end
    end

    local partyContainer, partyContainerName = fsFrame:GetPartyFramesContainer()
    if partyContainer then
        local issecure, taintedAddon = issecurevariable(partyContainerName)
        if not issecure and taintedAddon ~= addonName then
            return AddonFriendlyName(taintedAddon)
        end

        issecure, taintedAddon = issecurevariable(partyContainer, "flowSortFunc")
        if not issecure and taintedAddon ~= addonName then
            return AddonFriendlyName(taintedAddon)
        end
    end

    -- running both at the same time would cause issues
    if GetAddOnEnableState(nil, "SortGroup") ~= 0 then
        return "SortGroup"
    end

    return nil
end

local function SupportsGroups()
    return addon.Options.SortingMethod.TaintlessEnabled or (not fsFrame:IsRaidGrouped() and not fsFrame:IsPartyGrouped())
end

local function CanSeeFrames()
    if not IsInGroup() then
        return true
    end

    local frames = fsFrame:GetFrames()
    return #frames > 0
end

---Returns true if the environment/settings is in a good state, otherwise false.
---@return boolean healthy,HealthCheckResult[] results
function M:IsHealthy()
    local results = {}

    results[#results + 1] = {
        Passed = CanSeeFrames(),
        Description = "Default Blizzard frames are being used",
        Help = "FrameSort currently only supports the default Blizzard frames",
    }

    results[#results + 1] = {
        Passed = fsFrame:IsUsingRaidStyleFrames(),
        Description = "Using Raid-Style Party Frames",
        Help = "Please enable 'Use Raid-Style Party Frames' in the Blizzard settings",
    }

    results[#results + 1] = {
        Passed = SupportsGroups(),
        Description = "'Keep Groups Together' setting disabled, or using Taintless sorting",
        Help = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and "Change the raid display mode to one of the 'Combined Groups' options via Edit Mode"
            or "Disable the 'Keep Groups Together' raid profile setting",
    }

    local conflictingSorter = SortingFunctionsTampered()
    results[#results + 1] = {
        Passed = conflictingSorter == nil,
        Description = "Blizzard sorting functions not tampered with",
        Help = string.format("%s may cause conflicts, consider disabling it", conflictingSorter or ""),
    }

    local conflictingAddon = ConflictingAddons()
    results[#results + 1] = {
        Passed = conflictingAddon == nil,
        Description = "No conflicting addons",
        Help = string.format("%s may cause conflicts, consider disabling it", conflictingAddon or ""),
    }

    return fsEnumerable:From(results):All(function(x)
        return x.Passed
    end), results
end
