-- util/battle/SelectionManager.lua
local SelectionManager = {}
SelectionManager.__index = SelectionManager

local Phase = require "enums.battlePhases"

function SelectionManager:new(battle)
    local self = setmetatable({}, SelectionManager)
    self.battle = battle
    self.selectedCharacter = nil
    self.selectedTarget = nil
    return self
end

--------------------------------------------------------
-- Select a character on a given grid cell
--------------------------------------------------------
function SelectionManager:selectCharacter(cell)
    local battle = self.battle
    local char = battle.characterManager:getCharacterAt(cell)

    if not char then
        print("No character at this cell.")
        return
    end

    self.selectedCharacter = char
    self.selectedTarget = nil

    print("Selected character: " .. char.name)
    battle.phase = Phase.MOVE -- or Phase.IDLE, depending on your flow

    -- Optionally, highlight movement or ability range here
end

--------------------------------------------------------
-- Deselect everything
--------------------------------------------------------
function SelectionManager:deselect()
    if self.selectedCharacter then
        print("Deselected " .. self.selectedCharacter.name)
    end
    self.selectedCharacter = nil
    self.selectedTarget = nil
end

--------------------------------------------------------
-- Select a target for attack or ability
--------------------------------------------------------
function SelectionManager:selectTarget(cell)
    local battle = self.battle
    local target = battle.characterManager:getCharacterAt(cell)

    if not target then
        print("No target on this cell.")
        return
    end

    self.selectedTarget = target
    print("Selected target: " .. target.name)

    if battle.phase == Phase.ATTACK then
        battle.combat:attack(self.selectedCharacter, target)
        battle.phase = Phase.END_TURN
    elseif battle.phase == Phase.USE_ABILITY then
        battle.ability:useAbility(1, self.selectedCharacter) -- or selected ability
        battle.phase = Phase.ATTACK
    end
end

--------------------------------------------------------
-- Enter attack targeting mode
--------------------------------------------------------
function SelectionManager:enterAttackPhase()
    local battle = self.battle
    if not self.selectedCharacter then
        print("No character selected to attack.")
        return
    end

    print(self.selectedCharacter.name .. " is preparing to attack.")
    battle.phase = Phase.ATTACK
end

--------------------------------------------------------
-- Enter ability targeting mode
--------------------------------------------------------
function SelectionManager:enterAbilityPhase()
    local battle = self.battle
    if not self.selectedCharacter then
        print("No character selected to use an ability.")
        return
    end

    print(self.selectedCharacter.name .. " is ready to use an ability.")
    battle.phase = Phase.USE_ABILITY
end

return SelectionManager
