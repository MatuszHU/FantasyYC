local effectImplementations = require "util.effectImplementations"

return {
    ability1 = {
        name = "Crushing Blow",
        cooldown = 2,
        passive = false,
        effect = function(user)
            return math.floor(user.stats.attack * 0.35)  -- Fixed calculation
        end
    },
    ability2 = {
        name = "Berserker's Vow",
        cooldown = 5,
        passive = false,
        effect = function(user)
            effectImplementations.berserkTurns.apply(user, 2)  -- Call apply!
        end
    },
    ability3 = {
        name = "Battle Cry",
        cooldown = 3,
        passive = false,
        effect = function(user)
            effectImplementations.battleCryTurns.apply(user, 3)  -- Call apply!
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
        name = "Crushing Blow+",
        cooldown = 6,
        passive = false,
        effect = function(user)
            local baseDmg = user.stats.attack * 0.5
            if math.random() < 0.25 then
                return baseDmg * 2  -- Critical hit
            end
            return baseDmg
        end
    },
}