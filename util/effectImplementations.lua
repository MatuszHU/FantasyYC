effectImplementations = {}

local function ensureEffectsTable(char)
    if not char.effects then
        char.effects = {}
    end
end

effectImplementations.burn = {
    onTurnEnd = function(character)
        if character.effects.burn and character.effects.burn.active then
            character.stats.hp = math.max(0, character.stats.hp - 5)
            print(character.name .. " suffers 5 burn damage! HP: " .. character.stats.hp)
            character.effects.burn.remaining = character.effects.burn.remaining - 1
            if character.effects.burn.remaining <= 0 then
                character.effects.burn = nil
                print(character.name .. " is no longer burning.")
            end
        end
    end,
}

effectImplementations.freeze = {
    apply = function(character)
        character.effects.freeze = { remaining = 1, active = true }
        print(character.name .. " is frozen solid and cannot move this turn!")
    end,

    onTurnEnd = function(character)
        if character.effects.freeze then
            character.effects.freeze.remaining = character.effects.freeze.remaining - 1
            if character.effects.freeze.remaining <= 0 then
                character.effects.freeze = nil
                print(character.name .. " thaws out!")
            end
        end
    end
}

effectImplementations.berserkTurns = {
    apply = function(char)
        ensureEffectsTable(char)
        if not char.effects.berserkTurns then
            char.effects.berserkTurns = { remaining = 2, active = true }
            print(char.name .. " enters Berserk mode! Deals and takes double damage for 2 turns.")
        end
    end,

    modifyOutgoingDamage = function(damage, char)
        if char.effects.berserkTurns and char.effects.berserkTurns.active then
            return damage * 2
        end
        return damage
    end,

    modifyIncomingDamage = function(damage, char)
        if char.effects.berserkTurns and char.effects.berserkTurns.active then
            return damage * 2
        end
        return damage
    end,

    onTurnEnd = function(char)
        local eff = char.effects.berserkTurns
        if eff and eff.active then
            eff.remaining = eff.remaining - 1
            if eff.remaining <= 0 then
                print(char.name .. " calms down. Berserk has ended.")
                char.effects.berserkTurns = nil
            end
        end
    end
}

effectImplementations.battleCryTurns = {
    apply = function(character)
        if not character.effects.battleCryTurns then
            character.effects.battleCryTurns = { remaining = 3, active = true }
            character.stats.attack = character.stats.attack + 10
            if character.stats.magic then
                character.stats.magic = character.stats.magic + 10
            end
            print(character.name .. " lets out a mighty Battle Cry! ATK and MAG increased.")
        end
    end,

    onTurnEnd = function(character)
        local eff = character.effects.battleCryTurns
        if eff and eff.active then
            eff.remaining = eff.remaining - 1
            if eff.remaining <= 0 then
                eff.active = false
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

effectImplementations.ironWallTurns = {
    apply = function(character)
        if not character.effects.ironWallTurns then
            character.effects.ironWallTurns = { remaining = 3, active = true }
            character.stats.defense = (character.stats.defense or 0) + 10
            character.stats.resistance = (character.stats.resistance or 0) + 10
            print(character.name .. " takes formation! DEF and RES increased.")
        end
    end,

    onTurnEnd = function(character)
        local eff = character.effects.ironWallTurns
        if eff and eff.active then
            eff.remaining = eff.remaining - 1
            if eff.remaining <= 0 then
                character.stats.defense = character.stats.defense - 10
                character.stats.resistance = character.stats.resistance - 10
                character.effects.ironWallTurns = nil
                print(character.name .. "'s Iron Wall Formation ends.")
            end
        end
    end
}

effectImplementations.hasLastStand = {
    onDamageTaken = function(character, damage)
        if character.effects.hasLastStand and character.effects.hasLastStand == true then
            if (character.stats.hp - damage) <= 0 then
                character.stats.hp = 1
                character.effects.hasLastStand = false
                print(character.name .. " refuses to fall! Last Stand activated.")
                return 0 -- negate lethal damage
            end
        end
        return damage
    end
}

effectImplementations.shieldTurns = {
    apply = function(character)
        character.effects.shieldTurns = { remaining = 1, active = true }
        print(character.name .. " braces for impact! Incoming damage reduced.")
    end,

    modifyIncomingDamage = function(damage, character)
        if character.effects.shieldTurns and character.effects.shieldTurns.active then
            return damage * 0.1 -- 90% reduction
        end
        return damage
    end,

    onTurnEnd = function(character)
        local eff = character.effects.shieldTurns
        if eff and eff.active then
            eff.remaining = eff.remaining - 1
            if eff.remaining <= 0 then
                character.effects.shieldTurns = nil
                print(character.name .. "'s Aegis Charge fades.")
            end
        end
    end
}

function effectImplementations:updateEffects(char)
    if not char.effects then return end

    for effectName, effData in pairs(char.effects) do
        local impl = self[effectName]
        if impl and impl.onTurnEnd then
            impl.onTurnEnd(char)
        end
    end
end

return effectImplementations