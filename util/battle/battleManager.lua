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

    self.turn = TurnManager:new(self)
    self.ability = AbilityManager:new(self)
    self.combat = CombatManager:new(self)
    self.selection = SelectionManager:new(self)


    return self
end

function BattleManager:assignTeams(playerTeam, aiTeam)
    self.players[1].team = playerTeam or {}
    self.players[2].team = aiTeam or {}
end

function BattleManager:startBattle()
    self.phase = Phase.SELECT
    self.currentPlayerIndex = 1
    self.actedCharacters = {}
    self.selectedCharacter = nil
    self.isBattleOver = false
    self.winner = nil
    self.abilityCooldowns = {}

    for _, player in ipairs(self.players) do
        for _, char in ipairs(player.team) do
            char.effects = {}
            char:setStats()
            char.passivesApplied = nil
            self:applyPassiveAbilities(char)
        end
    end
    print("Battle started! " .. self:getCurrentPlayer().name .. " goes first.")
end


function BattleManager:levelUpCharacters()
    for _, char in ipairs(self.playerRoster:getTeam()) do
        char:levelUp()
    end
end

function BattleManager:endBattle()
    print("Ending battle...")
    local playerTeam = self.playerRoster:getTeam()

    if self.winner == "Player" then
        self.playerWinCount = self.playerWinCount + 1
    end

    if #playerTeam < 6 then
        local raceList = {"dwarf", "elf", "human"}
        local race = raceList[math.random(1, #raceList)]
        local classList = {"knight", "cavalry", "wizard", "priest", "thief"}
        local class = classList[math.random(1, #classList)]
        local newAllyName = self.playerRoster.nameManager:getRandomName(race, "male")
        local spawnCol = 3 + #playerTeam  -- example offset spawn
        local spawnRow = 8 + (#playerTeam % 2)

        local newAlly = self.characterManager:addCharacter(
            newAllyName,
            race,
            class,
            math.random(1, 6),
            spawnCol,
            spawnRow
        )

        table.insert(playerTeam, newAlly)
        print("Added new ally:", newAlly.name)
    end


    -- === Restore and reuse player roster ===
    for _, char in ipairs(self.playerRoster:getTeam()) do
        char.effects = {}
    end

    self.playerRoster:resetAfterBattle()

    local newList = {}
    for _, c in ipairs(self.characterManager.characters) do
        local isRosterChar = false
        for _, pc in ipairs(self.playerRoster:getTeam()) do
            if c == pc then
                isRosterChar = true
                table.insert(newList, c)
                break
            end
        end
        
        if not isRosterChar then
            self.playerRoster.nameManager:removeName(c.name)
        end
    end
    self.characterManager.characters = newList

    local aiTeam = {}
    local aiTeamSize = math.random(#playerTeam, (#playerTeam + 2))  -- variable difficulty, can adjust later
    for i = 1, aiTeamSize do
        local name = self.playerRoster.nameManager:getRandomName("orc", "male")
        local raceList = {"orc", "goblin"}
        local race = raceList[math.random(1, #raceList)]
        local classList = {"knight", "cavalry", "wizard", "priest", "thief"}
        local class = classList[math.random(1, #classList)]
        local x = 25 + love.math.random(0, 3)
        local y = 5 + love.math.random(0, 10)
        local aiChar = self.characterManager:addCharacter(name, race, class, math.random(1, 6), x, y)
        table.insert(aiTeam, aiChar)
    end

    self.characterManager:clearHighlight()
    self:assignTeams(self.playerRoster:getTeam(), aiTeam)

    self:startBattle()
    print("A new battle begins! Your roster returns to fight again!")
end

function BattleManager:getCurrentPlayer()
    return self.turn:getCurrentPlayer()
end

function BattleManager:isCharacterOnCurrentTeam(char)
    for _, c in ipairs(self:getCurrentPlayer().team) do
        if c == char then return true end
    end
    return false
end

function BattleManager:selectCharacter(cell)
    return self.selection:selectCharacter(cell)
end

function BattleManager:selectTarget(cell)
    return self.selection:selectTarget(cell)
end

function BattleManager:deselect(cell)
    return self.selection:deselect(cell)
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
    return self.combat:attack(target)
end

function BattleManager:enterAttackPhase()
    return self.selection:enterAttackPhase()
end

function BattleManager:enterUseAbilityPhase()
    return self.selection:enterAbilityPhase()
end

function BattleManager:passTurn()
    return self.turn:passTurn()
end

function BattleManager:passCharacterTurn()
    return self.turn:passCharacterTurn()
end

function BattleManager:applyPassiveAbilities(char)
    return self.ability:applyPassiveAbilities(char)
end

function BattleManager:useAbility(key, char)
    return self.ability:useAbility(key, char)
end

function BattleManager:calculateDamage(attacker, target)
    return self.combat:calculateDamage(attacker, target)
end

function BattleManager:checkEndOfTurn()
    return self.turn:checkEndOfTurn()
end

function BattleManager:endTurn()
    return self.turn:endTurn()
end


function BattleManager:update(dt)
    -- Future: AI logic
end

function BattleManager:draw()
end

return BattleManager
