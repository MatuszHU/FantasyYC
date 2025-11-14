return {
    ability1 = {
        name = "Holy Mend",
        cooldown = 2,
        passive = false,
        effect = function(user, ally)
            local heal = ally.maxHp * 0.4
            ally.hp = math.min(ally.hp + heal, ally.maxHp)
        end
    },
    ability2 = {
        name = "Smite of Faith",
        cooldown = 2,
        passive = false,
        effect = function(user)
            return user.stats.magic * 1.05
        end
    },
    ability3 = {
        name = "Curse of Weakness",
        cooldown = 3,
        passive = false,
        effect = function(user, target)
            effectImplementations.curseTurns.apply(user, 3)
            target.effects.curseTurns = 3
        end
    },
    ability4 = {
        name = "Divine Fortitude",
        cooldown = 0,
        passive = true,
        apply = function(user)
            user.stats.resistance = user.stats.resistance + 10
        end
    },
    ability5 = {
        name = "Resurrection",
        cooldown = 6,
        passive = false,
        effect = function(user, ally)
            local healAmount = ally.maxHp - ally.hp
            ally.hp = ally.maxHp
        end
    }
}
