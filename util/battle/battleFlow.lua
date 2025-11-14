local BattleFlow = {}
BattleFlow.__index = BattleFlow

local Phase = require "../enums.battlePhases"

function BattleFlow:new(battle)
    local self = setmetatable({}, BattleFlow)
    self.battle = battle
    return self
end

function BattleFlow:resetDivineIntervention()
    local battle = self.battle
    battle.players[1].isDivineInterventionUsed = false
    battle.players[2].isDivineInterventionUsed = false
end

-- 🔹 Assign teams (usually once per battle)
function BattleFlow:assignTeams(playerTeam, aiTeam)
    local battle = self.battle
    battle.players[1].team = playerTeam or {}
    battle.players[2].team = aiTeam or {}
end

-- 🔹 Initialize a new battle
function BattleFlow:startBattle()
    local battle = self.battle

    battle.phase = Phase.SELECT
    battle.currentPlayerIndex = 1
    battle.actedCharacters = {}
    battle.selectedCharacter = nil
    battle.isBattleOver = false
    battle.winner = nil
    battle.abilityCooldowns = {}
    self:resetDivineIntervention()

    for _, player in ipairs(battle.players) do
        for _, char in ipairs(player.team) do
            char.effects = {}
            char:setStats()
            char.passivesApplied = nil
            battle.abilityManager:applyPassiveAbilities(char)
        end
    end

    print("Battle started! " .. battle:getCurrentPlayer().name .. " goes first.")
end

-- 🔹 End the current battle and prepare for the next
function BattleFlow:endBattle()
    local battle = self.battle
    print("Ending battle...")

    local playerTeam = battle.playerRoster:getTeam()

    if battle.winner == "Player" then
        battle.playerWinCount = battle.playerWinCount + 1
    end

    -- === Add new ally if under 6 members ===
    if #playerTeam < 6 then
        local raceList = {"dwarf", "elf", "human"}
        local classList = {"knight", "cavalry", "wizard", "priest", "thief"}

        local race = raceList[math.random(#raceList)]
        local class = classList[math.random(#classList)]
        local newName = battle.playerRoster.nameManager:getRandomName(race, "male")

        local spawnCol = 3 + #playerTeam
        local spawnRow = 8 + (#playerTeam % 2)

        local newAlly = battle.characterManager:addCharacter(
            newName, race, class, math.random(1, 6), spawnCol, spawnRow
        )

        table.insert(playerTeam, newAlly)
        print("Added new ally:", newAlly.name)
    end

    -- === Reset effects and cleanup ===
    for _, char in ipairs(playerTeam) do
        char.effects = {}
    end
    battle.playerRoster:resetAfterBattle()

    local newList = {}
    for _, c in ipairs(battle.characterManager.characters) do
        local keep = false
        for _, pc in ipairs(playerTeam) do
            if c == pc then
                keep = true
                table.insert(newList, c)
                break
            end
        end
        if not keep then
            battle.playerRoster.nameManager:removeName(c.name)
        end
    end
    battle.characterManager.characters = newList

    -- === Create a new AI team ===
    local aiTeam = {}
    local aiTeamSize = math.random(#playerTeam, #playerTeam + 2)
    local raceList = {"orc", "goblin"}
    local classList = {"knight", "cavalry", "wizard", "priest", "thief"}

    for i = 1, aiTeamSize do
        local name = battle.playerRoster.nameManager:getRandomName("orc", "male")
        local race = raceList[math.random(#raceList)]
        local class = classList[math.random(#classList)]
        local x = 25 + love.math.random(0, 3)
        local y = 5 + love.math.random(0, 10)
        local aiChar = battle.characterManager:addCharacter(name, race, class, math.random(1, 6), x, y)
        table.insert(aiTeam, aiChar)
    end

    battle.characterManager:clearHighlight()
    self:assignTeams(playerTeam, aiTeam)
    self:startBattle()

    print("A new battle begins! Your roster returns to fight again!")
end

-- 🔹 End turn and check for victory
function BattleFlow:checkVictory()
    local battle = self.battle
    local playerAlive, aiAlive = false, false

    for _, c in ipairs(battle.players[1].team) do
        if not c.isDefeated then playerAlive = true break end
    end
    for _, c in ipairs(battle.players[2].team) do
        if not c.isDefeated then aiAlive = true break end
    end

    if not playerAlive or not aiAlive then
        local winner = playerAlive and battle.players[1].name or battle.players[2].name
        battle.winner = winner
        battle.isBattleOver = true
        battle.phase = Phase.IDLE
        print("Battle over! " .. winner .. " wins!")
        return true
    end
    return false
end

function BattleFlow:changePhase(newPhase)
    local battle = self.battle
    battle.phase = newPhase
end

return BattleFlow
