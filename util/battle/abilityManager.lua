local AbilityManager = {}
AbilityManager.__index = AbilityManager

local Phase = require "enums.battlePhases"

function AbilityManager:new(battle)
    local self = setmetatable({}, AbilityManager)
    self.battle = battle
    return self
end

--------------------------------------------------------
-- Apply passive abilities at the start of battle
--------------------------------------------------------
function AbilityManager:applyPassiveAbilities(char)
    if not char.abilities then return end
    if char.passivesApplied then return end

    for abilityKey, ability in pairs(char.abilities) do
        if ability.passive then
            ability.effect(char)
            print(char.name .. " passive ability activated: " .. ability.name)
        end
    end

    char.passivesApplied = true
end

--------------------------------------------------------
-- Use an active ability (by key 1–5)
--------------------------------------------------------
function AbilityManager:useAbility(key, char)
    local battle = self.battle

    if not char then
        print("No character selected to use ability.")
        return
    end

    local abilityIndex = tonumber(key)
    if not abilityIndex or abilityIndex < 1 or abilityIndex > 5 then
        print("Invalid ability key.")
        return
    end

    local abilityKey = "ability" .. abilityIndex
    local ability = char.abilities and char.abilities[abilityKey]

    if not ability then
        print(char.name .. " does not have ability " .. abilityIndex)
        return
    end

    if ability.passive then
        print(ability.name .. " is a passive ability and cannot be activated.")
        return
    end

    -- Ensure cooldown storage exists for this character
    battle.abilityCooldowns[char] = battle.abilityCooldowns[char] or {}
    local cooldowns = battle.abilityCooldowns[char]

    local currentCooldown = cooldowns[abilityKey] or 0
    if currentCooldown > 0 then
        print(ability.name .. " is on cooldown for " .. currentCooldown .. " more turns.")
        return
    end

    --------------------------------------------------------
    -- Execute ability
    --------------------------------------------------------
    local result = ability.effect(char)

    cooldowns[abilityKey] = ability.cooldown or 0
    print(char.name .. " uses " .. ability.name .. "!")
    if ability.cooldown and ability.cooldown > 0 then
        print("  [Cooldown: " .. ability.cooldown .. " turns]")
    end

    -- If ability.effect returns a number, treat it as extra damage
    if type(result) == "number" then
        battle.extradmg = result
        print("  (+" .. result .. " extra damage)")
    else
        battle.extradmg = 0
    end

    -- Enter attack phase afterwards (so ability + attack can chain)
    if battle.selection and battle.selection.enterAttackPhase then
        battle.selection:enterAttackPhase()
    elseif battle.enterAttackPhase then
        battle:enterAttackPhase() -- fallback for legacy behavior
    end
end

return AbilityManager
