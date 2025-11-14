local effectImplementations = {}

local function ensureEffectsTable(char)
    if not char.effects then
        char.effects = {}
    end
end

-- Burn: lasts 1 turn
effectImplementations.burn = {
    apply = function(character)
        ensureEffectsTable(character)
        character.effects.burn = 1
        print(character.name .. " is burning!")
    end,

    onTurnEnd = function(character)
        if character.effects.burn and character.effects.burn > 0 then
            character.stats.hp = math.max(0, character.stats.hp - 5)
            print(character.name .. " suffers 5 burn damage! HP: " .. character.stats.hp)
            character.effects.burn = character.effects.burn - 1
            if character.effects.burn <= 0 then
                character.effects.burn = nil
                print(character.name .. " is no longer burning.")
            end
        end
    end
}

-- Freeze: lasts 1 turn
effectImplementations.freeze = {
    apply = function(character)
        ensureEffectsTable(character)
        character.effects.freeze = 1
        print(character.name .. " is frozen solid and cannot move this turn!")
    end,

    onTurnEnd = function(character)
        if character.effects.freeze and character.effects.freeze > 0 then
            character.effects.freeze = character.effects.freeze - 1
            if character.effects.freeze <= 0 then
                character.effects.freeze = nil
                print(character.name .. " thaws out!")
            end
        end
    end
}

-- Berserk: numeric-turn effect (MISSING APPLY!)
effectImplementations.berserkTurns = {
    apply = function(character, duration)
        ensureEffectsTable(character)
        duration = duration or 2
        character.effects.berserkTurns = duration
        print(character.name .. " enters a berserk rage for " .. duration .. " turns!")
    end,

    modifyOutgoingDamage = function(damage, char)
        if char.effects.berserkTurns and char.effects.berserkTurns > 0 then
            return damage * 2
        end
        return damage
    end,

    modifyIncomingDamage = function(damage, char)
        if char.effects.berserkTurns and char.effects.berserkTurns > 0 then
            return damage * 2
        end
        return damage
    end,

    onTurnEnd = function(char)
        if char.effects.berserkTurns and char.effects.berserkTurns > 0 then
            char.effects.berserkTurns = char.effects.berserkTurns - 1
            if char.effects.berserkTurns <= 0 then
                char.effects.berserkTurns = nil
                print(char.name .. " calms down. Berserk has ended.")
            end
        end
    end
}

-- Battle Cry: increases stats temporarily (MISSING APPLY!)
effectImplementations.battleCryTurns = {
    apply = function(character, duration)
        ensureEffectsTable(character)
        duration = duration or 3
        character.effects.battleCryTurns = duration
        character.stats.attack = character.stats.attack + 10
        if character.stats.magic then
            character.stats.magic = character.stats.magic + 10
        end
        print(character.name .. " unleashes a Battle Cry! (+10 ATK/MAG for " .. duration .. " turns)")
    end,

    onTurnEnd = function(character)
        if character.effects.battleCryTurns and character.effects.battleCryTurns > 0 then
            character.effects.battleCryTurns = character.effects.battleCryTurns - 1
            if character.effects.battleCryTurns <= 0 then
                character.stats.attack = character.stats.attack - 10
                if character.stats.magic then
                    character.stats.magic = character.stats.magic - 10
                end
                character.effects.battleCryTurns = nil
                print(character.name .. "'s Battle Cry fades.")
            end
        end
    end
}

-- Iron Wall: increases defense/resistance temporarily (MISSING APPLY!)
effectImplementations.ironWallTurns = {
    apply = function(character, duration)
        ensureEffectsTable(character)
        duration = duration or 3
        character.effects.ironWallTurns = duration
        character.stats.defense = (character.stats.defense or 0) + 10
        character.stats.resistance = (character.stats.resistance or 0) + 10
        print(character.name .. " forms an Iron Wall! (+10 DEF/RES for " .. duration .. " turns)")
    end,

    onTurnEnd = function(character)
        if character.effects.ironWallTurns and character.effects.ironWallTurns > 0 then
            character.effects.ironWallTurns = character.effects.ironWallTurns - 1
            if character.effects.ironWallTurns <= 0 then
                character.stats.defense = (character.stats.defense or 0) - 10
                character.stats.resistance = (character.stats.resistance or 0) - 10
                character.effects.ironWallTurns = nil
                print(character.name .. "'s Iron Wall Formation ends.")
            end
        end
    end
}

-- Last Stand: boolean effect (MISSING APPLY!)
effectImplementations.hasLastStand = {
    apply = function(character)
        ensureEffectsTable(character)
        character.effects.hasLastStand = true
        print(character.name .. " prepares Last Stand! Will survive one fatal blow.")
    end,

    onDamageTaken = function(character, damage)
        if character.effects.hasLastStand then
            if (character.stats.hp - damage) <= 0 then
                character.stats.hp = 1
                character.effects.hasLastStand = nil
                print(character.name .. " refuses to fall! Last Stand activated.")
                return 0
            end
        end
        return damage
    end
}

-- Shield: numeric-turn effect (MISSING APPLY!)
effectImplementations.shieldTurns = {
    apply = function(character, duration)
        ensureEffectsTable(character)
        duration = duration or 2
        character.effects.shieldTurns = duration
        print(character.name .. " raises a shield! (90% damage reduction for " .. duration .. " turns)")
    end,

    modifyIncomingDamage = function(damage, character)
        if character.effects.shieldTurns and character.effects.shieldTurns > 0 then
            return damage * 0.1 -- 90% reduction
        end
        return damage
    end,

    onTurnEnd = function(character)
        if character.effects.shieldTurns and character.effects.shieldTurns > 0 then
            character.effects.shieldTurns = character.effects.shieldTurns - 1
            if character.effects.shieldTurns <= 0 then
                character.effects.shieldTurns = nil
                print(character.name .. "'s Aegis Charge fades.")
            end
        end
    end
}

effectImplementations.mindFocusTurns = {
    apply = function(character, duration)
        ensureEffectsTable(character)

        if character.effects.mindFocusTurns then
            return
        end

        duration = duration or 3

        character.effects.mindFocusTurns = {
            remaining = duration,
            active = true
        }

        character.stats.accuracy = (character.stats.accuracy or 0) + 10
        character.stats.evasion = (character.stats.evasion or 0) + 10

        print(character.name .. " focuses their mind! (+10 ACC / +10 EVA for " .. duration .. " turns)")
    end,

    onTurnEnd = function(character)
        local eff = character.effects.mindFocusTurns
        if eff and eff.active then
            eff.remaining = eff.remaining - 1

            if eff.remaining <= 0 then
                character.stats.accuracy = (character.stats.accuracy or 0) - 10
                character.stats.evasion = (character.stats.evasion or 0) - 10

                character.effects.mindFocusTurns = nil
                print(character.name .. "'s concentration fades.")
            end
        end
    end
}

effectImplementations.curseTurns = {
    apply = function(character, duration)
        ensureEffectsTable(character)

        if character.effects.curseTurns then
            return
        end

        duration = duration or 3

        character.effects.curseTurns = {
            remaining = duration,
            active = true
        }

        character.stats.attack = math.max(0, (character.stats.attack or 0) - 5)
        character.stats.magic = math.max(0, (character.stats.magic or 0) - 5)
        character.stats.defense = math.max(0, (character.stats.defense or 0) - 5)
        character.stats.resistance = math.max(0, (character.stats.resistance or 0) - 5)
        character.stats.accuracy = math.max(0, (character.stats.accuracy or 0) - 5)
        character.stats.evasion = math.max(0, (character.stats.evasion or 0) - 5)

        print(character.name .. " is weakened by a curse! (-5 to all stats for " .. duration .. " turns)")
    end,

    onTurnEnd = function(character)
        local eff = character.effects.curseTurns
        if eff and eff.active then
            eff.remaining = eff.remaining - 1

            if eff.remaining <= 0 then
                eff.active = false

                character.stats.attack = (character.stats.attack or 0) + 5
                character.stats.magic = (character.stats.magic or 0) + 5
                character.stats.defense = (character.stats.defense or 0) + 5
                character.stats.resistance = (character.stats.resistance or 0) + 5
                character.stats.accuracy = (character.stats.accuracy or 0) + 5
                character.stats.evasion = (character.stats.evasion or 0) + 5

                character.effects.curseTurns = nil
                print(character.name .. "'s Curse of Weakness fades.")
            end
        end
    end
}

effectImplementations.nextAttackCrit = {
    modifyCritChance = function(character, crit)
        if character.effects.nextAttackCrit then
            character.effects.nextAttackCrit = nil
            print(character.name .. " lands a GUARANTEED critical strike!")
            return true
        end
        return crit
    end
}

effectImplementations.deadlyPrecisionTurns = {
    apply = function(character, duration)
        duration = duration or 3
        character.effects.deadlyPrecisionTurns = duration

        character.stats.luck = (character.stats.luck or 0) + 10
        print(character.name .. " gains +10 LUCK for " .. duration .. " turns!")
    end,

    onTurnEnd = function(character)
        local eff = character.effects.deadlyPrecisionTurns
        if eff then
            character.effects.deadlyPrecisionTurns = eff - 1
            if character.effects.deadlyPrecisionTurns <= 0 then
                character.stats.luck = character.stats.luck - 10
                character.effects.deadlyPrecisionTurns = nil
                print(character.name .. "'s Deadly Precision fades.")
            end
        end
    end
}

effectImplementations.russianRouletteStacks = {
    modifyCritChance = function(character, crit)
        local stacks = character.effects.russianRouletteStacks or 0
        if stacks > 0 then
            local bonus = stacks * 0.10
            local totalCrit = crit or false

            if math.random() < bonus then
                print(character.name .. " hits a Russian Roulette CRIT from stacks!")
                return true
            end
        end
        return crit
    end
}

return effectImplementations
