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
    battle.showRecruit = false
    battle.abilityCooldowns = {}
    self:resetDivineIntervention()
    battle:levelUpCharacters()

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

function BattleFlow:endBattle() -- TODO player2 has a roster
    local battle = self.battle
    print("Ending battle...")

    local playerTeam = battle.playerRoster:getTeam()

    battle.showRecruit = false

    local canRecruit = false
    for _, player in ipairs(battle.players) do
        if #player.team < 6 then
            canRecruit = true
            break
        end
    end

    if canRecruit then
        print("Opening Recruit Flow...")
        battle.recruitFlow:start()  -- <-- this replaces the old recruitView block
        return -- stop endBattle here until recruitment is done
    end

    -- Reset character effects for both players
    for _, player in ipairs(battle.players) do
        for _, char in ipairs(player.team) do
            char.effects = {}
        end
        if player.id == 1 then
            battle.playerRoster:resetAfterBattle()
        elseif player.id == 2 then
            battle.player2Roster:resetAfterBattle()
        end
    end

    -- At this point, both players have their teams intact and ready for the next battle
    print("Battle ended. Both teams are ready for the next battle.")
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
