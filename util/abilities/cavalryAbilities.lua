return {
    ability1 = {
        name = "Lance Thrust",
        cooldown = 2,
        passive = false,
        effect = function(user)
            return user.stats.attack * 1.15
        end
    },
    ability2 = {
        name = "Iron Wall Formation",
        cooldown = 3,
        passive = false,
        effect = function(user)
            effectImplementations.ironWallTurns.apply(user, 3)
        end
    },
    ability3 = {
        name = "Battle-Hardened",
        cooldown = 0,
        passive = true,
        effect = function(user)
            user.stats.defense = user.stats.defense + 10
        end
    },
    ability4 = {
        name = "Last Stand",
        cooldown = 0,
        passive = true,
        effect = function(user)
            user.effects.hasLastStand = true
        end
    },
    ability5 = {
        name = "Aegis Charge",
        cooldown = 6,
        passive = false,
        effect = function(user)
            user.effects.shieldTurns = 1
        end
    }
}
