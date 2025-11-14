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
function SelectionManager:selectCharacter(char)
    local battle = self.battle

    if not char then
        print("No character at this cell.")
        return
    end

    if not battle:isCharacterOnCurrentTeam(char) then print('Can not move with an opponent') return end

    for _, acted in ipairs(battle.actedCharacters) do
        if acted == char then
            print(char.name .. " has already acted this turn.")
            return
        end
    end

    if char.stats.hp == 0 then print('That character is knocked out.') return end


    self.selectedCharacter = char
    battle.selectedCharacter = char
    self.selectedTarget = nil

    print("Selected character: " .. char.name)
    battle.phase = Phase.MOVE -- or Phase.IDLE, depending on your flow

    self.battle.characterManager:highlightReachable(char)
end

--------------------------------------------------------
-- Deselect everything
--------------------------------------------------------
function SelectionManager:deselect()
    if self.selectedCharacter then
        print("Deselected " .. self.selectedCharacter.name)
    end
    self.selectedCharacter = nil
    self.battle.selectedCharacter = nil
    self.selectedTarget = nil
    self.battle.characterManager:clearHighlight()
    self.battle.phase = Phase.SELECT
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
    self.battle.characterManager:clearHighlight()
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
    self.battle.characterManager:clearHighlight()
end

return SelectionManager
