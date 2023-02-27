local _, addon = ...
local memberUnitPatterns = {
    "^player$",
    "^party%d$",
    "^raid%d$",
    "^raid%d%d$",
}
local petUnitPatterns = {
    "^pet$",
    "^playerpet$",
    "^party%dpet$",
    "^partypet%d$",
    "^raidpet%d$",
    "^raidpet%d%d$",
    "^raid%dpet$",
    "^raid%d%dpet$"
}

---Gets a table of group member unit tokens that exist (UnitExists()).
---@return table<string>
function addon:GetUnits()
    local isRaid = IsInRaid()
    local prefix = isRaid and "raid" or "party"
    local toGenerate = isRaid and MAX_RAID_MEMBERS or (MEMBERS_PER_RAID_GROUP - 1)
    local members = {}

    -- raids don't have the "player" token frame
    if not isRaid then
        table.insert(members, "player")
    end

    for i = 1, toGenerate do
        local unit = prefix .. i
        if UnitExists(unit) then
            table.insert(members, unit)
        end
    end

    return members
end

---Returns a list of unit aliases.
---Only used for pets at this point, as raid1pet and raidpet1 are both the same unit.
---@param unit string the unit token
---@return table<string> aliases
function addon:GetUnitAliases(unit)
    if not string.match(unit, "pet") then
        return { unit }
    end

    if unit == "pet" or unit == "playerpet" then
        return { "pet", "playerpet" }
    end

    local isRaid = nil

    if string.match(unit, "raid") then
        isRaid = true
    elseif string.match(unit, "party") then
        isRaid = false
    else
        return { unit }
    end

    local prefix = isRaid and "raid" or "party"
    local index = string.match(unit, "%d%d") or string.match(unit, "%d")

    return {
        prefix .. index .. "pet",
        prefix .. "pet" .. index
    }
end

---Gets the pet units for the specified player units.
---@param units table<string>
---@return table<string> pet unit tokens
function addon:GetPets(units)
    local pets = {}
    for _, unit in ipairs(units) do
        local petUnit = unit .. "pet"
        if UnitExists(petUnit) then
            pets[#pets + 1] = petUnit
        end
    end

    return pets
end

---Determines if the unit token is a pet.
---@param unit string
---@return boolean true if the unit is a pet, otherwise false.
function addon:IsPet(unit)
    for _, pattern in pairs(petUnitPatterns) do
        if string.match(unit, pattern) ~= nil then
            return true
        end
    end

    return false
end

---Determines if the unit token is a person/member/human.
---@param unit string
---@return boolean true if the unit is a member, otherwise false.
function addon:IsMember(unit)
    for _, pattern in pairs(memberUnitPatterns) do
        if string.match(unit, pattern) ~= nil then
            return true
        end
    end

    return false
end
