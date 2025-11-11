local CombatManager = {}
CombatManager.__index = CombatManager

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

    print(attacker.name .. " attacks " .. target.name .. "!")

    local dmg = self:calculateDamage(attacker, target)
    if self:isCrit(attacker) then
        target.hp = math.max(target.hp - (dmg * 2), 0)
    else
        target.hp = math.max(target.hp - dmg, 0)
    end

    print(string.format("  %s deals %d damage. (%d HP left)", attacker.name, dmg, target.hp))

    if target.hp <= 0 then
        self:checkCharacterDeath(target)
    end

    -- Reset extra damage after each attack
    battle.extradmg = 0
end

function CombatManager:isCrit(attacker)
    local critrate = attacker.luck / 100
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
    local base = attacker.atk or 0
    local defense = target.def or 0
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
    battle.characterManager:removeCharacter(target)

    self:checkVictory()
end

--------------------------------------------------------
-- Checks if one team has won
--------------------------------------------------------
function CombatManager:checkVictory()
    local cm = self.battle.characterManager
    local team1, team2 = cm:getTeams()

    local alive1 = #team1 > 0
    local alive2 = #team2 > 0

    if not alive1 or not alive2 then
        local winner = alive1 and "Player 1" or "Player 2"
        print("🏆 " .. winner .. " wins the battle!")
        self.battle.phase = require("enums.battlePhases").IDLE
    end
end

return CombatManager
