return {
    ability1 = {
        name = "Crushing Blow",
        cooldown = 2,
        passive = false,
        effect = function(user)
            return user.stats.attack * 1.35
        end
    },
    ability2 = {
        name = "Berserker's Vow",
        cooldown = 5,
        passive = false,
        effect = function(user)
            user.effects.berserkTurns = 2
        end
    },
    ability3 = {
        name = "Battle Cry",
        cooldown = 3,
        passive = false,
        effect = function(user)
            user.effects.battleCryTurns = 3
        end
    },
    ability4 = {
        name = "Steel Discipline",
        cooldown = 0,
        passive = true,
        effect = function(user)
            user.stats.attack = user.stats.attack + 10
        end
    },
    ability5 = {
        name = "Crushing Blow",
        cooldown = 6,
        passive = false,
        effect = function(user)
            if math.random() < 0.25 then
                return (user.stats.attack * 1.5) * 2
            end
            return user.stats.attack * 1.5
        end
    },
}