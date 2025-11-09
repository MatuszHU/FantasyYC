return {
    ability1 = {
        name = "Flame Orb",
        cooldown = 2,
        passive = false,
        effect = function(user)

            local damage = math.floor((user.stats.magic or 0) * 1.10)

            if math.random() < 0.15 then
                target.effects.burn = 1
            end
            return damage
        end
    },
    ability2 = {
        name = "Frost Shard",
        cooldown = 3,
        passive = false,
        effect = function(user)

            local damage = math.floor((user.stats.magic or 0) * 1.10)

            if math.random() < 0.20 then
                target.effects.freeze = 1
            end
            return damage
        end
    },
    ability3 = {
        name = "Mind Focus",
        cooldown = 3,
        passive = false,
        effect = function(user)
            user.effects.mindFocusTurns = 3
        end
    },
    ability4 = {
        name = "Arcane Insight",
        cooldown = 0,
        passive = true,
        apply = function(user)
            user.stats.accuracy = user.stats.accuracy + 10
        end
    },
    ability5 = {
        name = "Meteor Burst",
        cooldown = 6,
        passive = false,
        effect = function(user)
            local damage = user.stats.magic * 1.60
        end
    }
}
