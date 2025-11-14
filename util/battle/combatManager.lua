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
    if distance > (attacker.stats.attackrange or 1) then
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

function CombatManager:isCrit(attacker)
    local critrate = attacker.stats.luck / 100
    if math.random() < critrate then
        return true
    else
        return false
    end
end

--------------------------------------------------------
-- Calculates damage output
--------------------------------------------------------
function CombatManager:calculateDamage(attacker, target)
    local effectManager = self.battle.effectManager
    local base = attacker.stats.attack or 0
    local defense = target.stats.defense or 0
    local bonus = self.battle.extradmg or 0

    local dmg = math.max((base - defense) + bonus, 0)
    dmg = effectManager:modifyOutgoingDamage(dmg, attacker)

    -- Apply incoming modifiers (like Shield)
    dmg = effectManager:modifyIncomingDamage(dmg, target)

    -- Final interception (like Last Stand)
    dmg = effectManager:onDamageTaken(target, dmg)

    return math.max(dmg, 0)
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
