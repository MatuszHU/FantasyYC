local CombatManager = {}
CombatManager.__index = CombatManager

local Phase = require "enums.battlePhases"

function CombatManager:new(battle)
    local self = setmetatable({}, CombatManager)
    self.battle = battle
    return self
end

--------------------------------------------------------
-- Executes an attack
--------------------------------------------------------
function CombatManager:attack(attacker, target)
    local battle = self.battle
    if not attacker or not target then
        print("CombatManager: Missing attacker or target.")
        return
    end
    -- TODO fix the attack range stat
    local dx = math.abs(attacker.gridX - target.gridX)
    local dy = math.abs(attacker.gridY - target.gridY)
    local distance = dx + dy  -- Manhattan distance, change to math.sqrt(dx*dx + dy*dy) for Euclidean
    if distance > (attacker.stats.attackRange or 1) then
        print(attacker.name .. " cannot reach " .. target.name .. " (out of range).")
        return
    end

    print(attacker.name .. " attacks " .. target.name .. "!")

    local dmg = self:calculateDamage(attacker, target)
    if self:isCrit(attacker) then
        target.stats.hp = math.max(target.stats.hp - (dmg * 2), 0)
    else
        target.stats.hp = math.max(target.stats.hp - dmg, 0)
    end

    print(string.format("  %s deals %d damage. (%d HP left)", attacker.name, dmg, target.stats.hp))

    if target.stats.hp <= 0 then
        self:checkCharacterDeath(target)
    end

    -- Reset extra damage after each attack
    battle.extradmg = 0
    self.battle.actedCharacters[attacker] = true
    print(battle:checkEndOfTurn())
    if battle:checkEndOfTurn() then
        battle:endTurn()
    else
        battle.phase = Phase.SELECT
    end
end

function CombatManager:heal(healer, target, amount)
    local battle = self.battle
    if not healer or not target then
        print("CombatManager: Missing healer or target.")
        return
    end

    if battle.effectManager:isCharacterDisabled(healer) then
        print(healer.name .. " is unable to act!")
        return
    end

    local healAmount = math.floor(amount)
    local oldHp = target.stats.hp
    target.stats.hp = math.min(target.stats.hp + healAmount, target.stats.maxHp)

    print(string.format(
        "%s heals %s for %d HP. (%d → %d)",
        healer.name, target.name, healAmount, oldHp, target.stats.hp
    ))

    battle.actedCharacters[healer] = true

    if battle:checkEndOfTurn() then
        battle:endTurn()
    else
        battle.phase = Phase.SELECT
    end
end


function CombatManager:isCrit(attacker)
    local critrate = (attacker.stats.luck or 0) / 100
    local crit = (math.random() < critrate)

    if attacker.effects.nextAttackCrit then
        crit = effectImplementations.nextAttackCrit.modifyCritChance(attacker, crit)
    end

    if attacker.effects.russianRouletteStacks then
        crit = effectImplementations.russianRouletteStacks.modifyCritChance(attacker, crit)
    end

    return crit
end

--------------------------------------------------------
-- Calculates damage output
--------------------------------------------------------
function CombatManager:calculateDamage(attacker, target)
    local effectManager = self.battle.effectManager
    local base, defense
    if attacker.class == "wizard" or attacker.class == "priest" then
        base = attacker.stats.magic or 0
        defense = target.stats.resistance or 0
    else
        base = attacker.stats.attack or 0
        defense = target.stats.defense or 0
    end
    local bonus = self.battle.extradmg or 0

    local dmg = math.max((base - defense) + bonus, 0)
    dmg = effectManager:modifyOutgoingDamage(dmg, attacker)

    -- Apply incoming modifiers (like Shield)
    dmg = effectManager:modifyIncomingDamage(dmg, target)

    -- Final interception (like Last Stand)
    dmg = effectManager:onDamageTaken(target, dmg)

    return math.floor(math.max(dmg, 0))
end

--------------------------------------------------------
-- Handles death and victory checks
--------------------------------------------------------
function CombatManager:checkCharacterDeath(target)
    print(target.name .. " has been defeated!")

    local battle = self.battle
    target.isDefeated = true

    self.battle.battleFlow:checkVictory()
end

return CombatManager
