local TurnManager = {}
TurnManager.__index = TurnManager

local Phase = require "enums.battlePhases"

function TurnManager:new(battle)
    local self = setmetatable({}, TurnManager)
    self.battle = battle
    return self
end

--- Returns the currently active player
function TurnManager:getCurrentPlayer()
    return self.battle.players[self.battle.currentPlayerIndex]
end

--- Checks if all non-defeated characters of the current player have acted
function TurnManager:checkEndOfTurn()
    local allActed = true
    local currentPlayer = self:getCurrentPlayer()
    for _, char in ipairs(currentPlayer.team) do
        if (not self.battle.actedCharacters[char]) and (not char.isDefeated) then
            allActed = false
            break
        end
    end
    return allActed
end

--- Ends the current player's turn and passes it to the next one
function TurnManager:endTurn()
    local battle = self.battle
    local currentPlayer = self:getCurrentPlayer()

    print(currentPlayer.name .. "'s turn ended.")
    battle.phase = Phase.END_TURN

    -- === Cooldown management ===
    for _, char in ipairs(currentPlayer.team) do
        local cooldowns = battle.abilityCooldowns[char]
        if cooldowns then
            for abilityKey, cooldown in pairs(cooldowns) do
                if cooldown > 0 then
                    cooldowns[abilityKey] = cooldown - 1
                    if cooldowns[abilityKey] == 0 then
                        local ability = char.abilities and char.abilities[abilityKey]
                        if ability then
                            print("  " .. char.name .. "'s " .. ability.name .. " is ready!")
                        end
                    end
                end
            end
        end
    end

    -- === End-of-turn effects ===
    for _, char in ipairs(currentPlayer.team) do
        for effectName, effData in pairs(char.effects or {}) do
            local impl = battle.effectImplementations and battle.effectImplementations[effectName]
            if impl and impl.onTurnEnd then
                impl.onTurnEnd(char)
            end
        end
    end

    -- Reset turn data
    battle.actedCharacters = {}
    battle.currentPlayerIndex = (battle.currentPlayerIndex % #battle.players) + 1
    battle.phase = Phase.SELECT

    if battle.characterManager then
        battle.characterManager:clearHighlight()
    end

    print("Now it's " .. self:getCurrentPlayer().name .. "'s turn!")
end

--- Forces the current player to pass their turn
function TurnManager:passTurn()
    local battle = self.battle
    if battle.isBattleOver then return end

    print("Turn passed by " .. self:getCurrentPlayer().name)

    -- clear any selection and highlights
    if battle.characterManager then
        battle.selectedCharacter = nil
        if battle.characterManager.gridManager and battle.characterManager.gridManager.clearHighlight then
            battle.characterManager.gridManager:clearHighlight()
        end
    end

    self:endTurn()
end

--- Marks a character’s turn as passed and checks end-of-turn
function TurnManager:passCharacterTurn()
    local battle = self.battle
    if battle.isBattleOver then return end

    local selected = battle.selectedCharacter
    if not selected then
        print("[DEBUG] No character selected to pass turn for.")
        return
    end

    -- mark character as acted
    battle.actedCharacters[selected] = true
    print(string.format("[DEBUG] %s passed their turn.", selected.name or "Unnamed"))

    -- deselect and reset phase
    battle.selectedCharacter = nil
    battle.phase = Phase.SELECT

    -- check if all characters on this team have acted
    if self:checkEndOfTurn() then
        print("[DEBUG] All characters have acted. Passing turn to next player.")
        self:passTurn()
    end

    if battle.characterManager then
        battle.characterManager:clearHighlight()
    end
end

return TurnManager
