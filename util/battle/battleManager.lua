-- util/battleManager.lua
local BattleManager = {}
BattleManager.__index = BattleManager

local Phase = require "enums.battlePhases"
local PlayerRoster = require "util.playerRoster"
local effectImplementations = require "util.effectImplementations"
local TurnManager = require "util.battle.turnManager"
local AbilityManager = require "util.battle.abilityManager"
local CombatManager = require "util.battle.combatManager"
local SelectionManager = require "util.battle.selectionManager"
local EffectManager = require "util.battle.effectManager"
local BattleFlow = require "util.battle.battleFlow"



function BattleManager:new(characterManager)
    local self = setmetatable({}, BattleManager)
    self.characterManager = characterManager
    self.phase = Phase.IDLE

    self.playerRoster = PlayerRoster:new(self.characterManager)


    self.players = {
        { id = 1, name = "Player", team  = self.playerRoster:getTeam() },
        { id = 2, name = "AI", team = {} }
    }

    self.currentPlayerIndex = 1
    self.actedCharacters = {}
    self.selectedCharacter = nil
    self.isBattleOver = false
    self.winner = nil
    self.playerWinCount = 0
    self.extradmg = 0
    self.abilityCooldowns = {}

    self.turnManager= TurnManager:new(self)
    self.abilityManager = AbilityManager:new(self)
    self.combatManager = CombatManager:new(self)
    self.selectionManager = SelectionManager:new(self)
    self.battleFlow = BattleFlow:new(self)
    self.effectManager = EffectManager:new(self, effectImplementations)


    return self
end

function BattleManager:assignTeams(playerTeam, aiTeam)
    self.players[1].team = playerTeam or {}
    self.players[2].team = aiTeam or {}
end

function BattleManager:startBattle()
    self.battleFlow:startBattle()
end


function BattleManager:levelUpCharacters()
    for _, char in ipairs(self.playerRoster:getTeam()) do
        char:levelUp()
    end
end

function BattleManager:endBattle()
    self.battleFlow:endBattle()
end

function BattleManager:getCurrentPlayer()
    return self.turnManager:getCurrentPlayer()
end

function BattleManager:isCharacterOnCurrentTeam(char)
    for _, c in ipairs(self:getCurrentPlayer().team) do
        if c == char then return true end
    end
    return false
end

function BattleManager:selectCharacter(cell)
    return self.selectionManager:selectCharacter(cell)
end

function BattleManager:selectTarget(cell)
    return self.selectionManager:selectTarget(cell)
end

function BattleManager:deselect(cell)
    return self.selectionManager:deselect(cell)
end

function BattleManager:moveCharacter(gridX, gridY)
    if self.phase ~= Phase.MOVE or not self.selectedCharacter then return end

    local char = self.selectedCharacter
    local reachable = self.characterManager:getReachableCells(char)

    for _, cell in ipairs(reachable) do
        if cell.x == gridX and cell.y == gridY then
            char:moveTo(gridX, gridY)
            if self.characterManager then
                self.characterManager:clearHighlight()
            end
            self.phase = Phase.ATTACK
            print(char.name .. " moved to (" .. gridX .. "," .. gridY .. ")")
            return
        end
    end

    print("Cannot move there!")
end

function BattleManager:attack(target)
    return self.combatManager:attack(target)
end

function BattleManager:enterAttackPhase()
    return self.selectionManager:enterAttackPhase()
end

function BattleManager:enterUseAbilityPhase()
    return self.selectionManager:enterAbilityPhase()
end

function BattleManager:passTurn()
    return self.turnManager:passTurn()
end

function BattleManager:passCharacterTurn()
    return self.turnManager:passCharacterTurn()
end

function BattleManager:applyPassiveAbilities(char)
    return self.abilityManager:applyPassiveAbilities(char)
end

function BattleManager:useAbility(key, char)
    return self.abilityManager:useAbility(key, char)
end

function BattleManager:calculateDamage(attacker, target)
    return self.combatManager:calculateDamage(attacker, target)
end

function BattleManager:checkEndOfTurn()
    return self.turnManager:checkEndOfTurn()
end

function BattleManager:endTurn()
    return self.turnManager:endTurn()
end


function BattleManager:update(dt)
    -- Future: AI logic
end

function BattleManager:draw()
end

return BattleManager
