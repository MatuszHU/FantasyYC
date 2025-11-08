return {
    ability1 = {
        name = "Crushing Blow",
        cooldown = 2,
        currentCooldown = 0,
        passive = false,
        effect = function(user)
            return math.floor(user.stats.attack * 1.35 - user.stats.attack)
        end
    },
    ability2 = {
        name = "Berserker's Vow",
        cooldown = 5,
        currentCooldown = 0,
        passive = false,
        effect = function(user)
            user.effects.berserkTurns = 2
        end
    },
    ability3 = {
        name = "Battle Cry",
        cooldown = 3,
        currentCooldown = 0,
        passive = false,
        effect = function(user)
            user.effects.battleCryTurns = 3
        end
    },
    ability4 = {
        name = "Steel Discipline",
        cooldown = 0,
        currentCooldown = 0, -- nem tudom megdöglik e nélküle.
        passive = true,
        effect = function(user)
            user.stats.attack = user.stats.attack + 10
        end
    },
    ability5 = {
        name = "Crushing Blow",
        cooldown = 6,
        currentCooldown = 0,
        passive = false,
        effect = function(user)
            if math.random() < 0.25 then
                return (user.stats.attack * 1.5) * 2
            end
            return user.stats.attack * 1.5
        end
    },
}