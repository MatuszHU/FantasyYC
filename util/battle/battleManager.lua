-- util/battleManager.lua
local BattleManager = {}
BattleManager.__index = BattleManager

local Phase = require "enums.battlePhases"
local PlayerRoster = require "util.playerRoster"
local effectImplementations = require "util.effectImplementations"
local TurnManager = require "util.battle.turnManager"
local AbilityManager = require "util.battle.abilityManager"


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

function BattleManager:selectCharacter(char)
    if char.isDefeated then
        print("Cannot select defeated character!")
        return false
    end
    if not self:isCharacterOnCurrentTeam(char) then
        print("Cannot control enemy units!")
        return false
    end
    if self.actedCharacters[char] then
        print(char.name .. " has already acted this turn.")
        return false
    end
    self.selectedCharacter = char
    self.phase = Phase.MOVE
    print("Selected " .. char.name .. " to act.")
    if self.characterManager then
        self.characterManager:highlightReachable(char)
    end
    return true
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
    if self.phase ~= Phase.ATTACK or not self.selectedCharacter then return end
    if not target then
        print("No target selected.")
        return
    end
    if self:isCharacterOnCurrentTeam(target) then
        print("Cannot attack allies!")
        return
    end

    local attacker = self.selectedCharacter

    local dist = math.abs(attacker.gridX - target.gridX) + math.abs(attacker.gridY - target.gridY)
    local range = attacker.stats.attackRange or 1
    if dist > range then
        print(string.format("%s cannot reach %s (distance %d, range %d)", attacker.name, target.name, dist, range))
        return
    end

    -- Attack execution
    local damage = self:calculateDamage(attacker, target)
    target.stats.hp = math.max(0, target.stats.hp - damage)
    print(attacker.name .. " attacks " .. target.name .. " for " .. damage .. " damage! HP left: " .. target.stats.hp)

    self.extradmg = 0
    self.actedCharacters[attacker] = true
    self.selectedCharacter = nil
    self.phase = Phase.SELECT

    if target.stats.hp <= 0 then
        print(target.name .. " has been defeated.")
        target.isDefeated = true
    end

    -- Check victory
    local playerAlive = false
    for _, c in ipairs(self.players[1].team) do
        if not c.isDefeated then
            playerAlive = true
            break
        end
    end

    local aiAlive = false
    for _, c in ipairs(self.players[2].team) do
        if not c.isDefeated then
            aiAlive = true
            break
        end
    end

    if not playerAlive or not aiAlive then
        local winner = playerAlive and self.players[1].name or self.players[2].name
        print("Battle over! " .. winner .. " wins!")

        self.winner = winner
        self.isBattleOver = true
        self.phase = Phase.IDLE
        return
    end

    if self.characterManager then
        self.characterManager:clearHighlight()
    end

    if self:checkEndOfTurn() then
        self:endTurn()
    end
end

function BattleManager:enterAttackPhase()
    if not self.selectedCharacter then
        print("No character selected to attack.")
        return
    end

    if self.phase ~= Phase.MOVE and self.phase ~= Phase.SELECT and self.phase ~= Phase.USE_ABILITY then
        print("Cannot enter attack phase right now.")
        return
    end

    self.phase = Phase.ATTACK
    print(self.selectedCharacter.name .. " is preparing to attack!")

    -- optional: highlight enemies in range
    local char = self.selectedCharacter
    local attackRange = char.stats.attackRange or 1
    local enemies = {}

    local currentPlayer = self:getCurrentPlayer()
    local enemyPlayer = (self.currentPlayerIndex == 1) and self.players[2] or self.players[1]
    for _, enemy in ipairs(enemyPlayer.team) do
        if not enemy.isDefeated then
            local dx = math.abs(enemy.gridX - char.gridX)
            local dy = math.abs(enemy.gridY - char.gridY)
            if (dx + dy) <= attackRange then
                table.insert(enemies, { x = enemy.gridX, y = enemy.gridY })
            end
        end
    end

    if #enemies > 0 then
        self.characterManager.reachableCells = nil
        self.characterManager.gridManager:highlightCells(enemies, 1, 0, 0, 0.4)
    else
        print("No enemies in attack range.")
        self.phase = Phase.MOVE
    end
end

function BattleManager:enterUseAbilityPhase()
    if not self.selectedCharacter then
        print("No character selected to use ability.")
        return
    end

    if self.phase ~= Phase.MOVE and self.phase ~= Phase.SELECT then
        print("Cannot enter use ability phase right now.")
        return
    end

    self.phase = Phase.USE_ABILITY
    print(self.selectedCharacter.name .. " is preparing to use ability!")

    -- optional: highlight enemies in range
    local char = self.selectedCharacter
    local attackRange = char.stats.attackRange or 1
    local enemies = {}

    local currentPlayer = self:getCurrentPlayer()
    local enemyPlayer = (self.currentPlayerIndex == 1) and self.players[2] or self.players[1]
    for _, enemy in ipairs(enemyPlayer.team) do
        if not enemy.isDefeated then
            local dx = math.abs(enemy.gridX - char.gridX)
            local dy = math.abs(enemy.gridY - char.gridY)
            if (dx + dy) <= attackRange then
                table.insert(enemies, { x = enemy.gridX, y = enemy.gridY })
            end
        end
    end

    if #enemies > 0 then
        self.characterManager.reachableCells = nil
        self.characterManager.gridManager:highlightCells(enemies, 1, 0, 0, 0.4)
    else
        print("No enemies in attack range.")
        self.phase = Phase.MOVE
    end
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
    local atk = 0
    local def = 0
    if attacker.class == "wizard" or attacker.class == "priest" then
        atk = (attacker.stats and attacker.stats.magic) or 0
        def = (target.stats and target.stats.resistance) or 0
    else
        atk = (attacker.stats and attacker.stats.attack) or 0
        def = (target.stats and target.stats.defense) or 0
    end
    local baseDamage = math.max(0, atk - def)

    if effectImplementations.berserkTurns and effectImplementations.berserkTurns.modifyOutgoingDamage then
        baseDamage = effectImplementations.berserkTurns.modifyOutgoingDamage(baseDamage, attacker)
    end

    if effectImplementations.shieldTurns and effectImplementations.shieldTurns.modifyIncomingDamage then
        baseDamage = effectImplementations.shieldTurns.modifyIncomingDamage(baseDamage, target)
    end

    if effectImplementations.hasLastStand and effectImplementations.hasLastStand.onDamageTaken then
        baseDamage = effectImplementations.hasLastStand.onDamageTaken(target, baseDamage)
    end

    return baseDamage + self.extradmg
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
