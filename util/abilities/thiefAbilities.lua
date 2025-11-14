return {
    ability1 = {
        name = "Coin Flip",
        cooldown = 2,
        passive = false,
        effect = function(user)
            if math.random() < 0.5 then
                user.effects.nextAttackCrit = true
                print(user.name .. "'s next attack will be a guaranteed CRIT!")
            else
                print(user.name .. " flips a coin... and gets NOTHING!")
            end
        end
    },

    ability2 = {
        name = "Deadly Precision",
        cooldown = 3,
        passive = false,
        effect = function(user)
            user.effects.deadlyPrecisionTurns = 3
            print(user.name .. " gains heightened precision! +10 LUCK for 3 turns.")
        end
    },

    ability3 = {
        name = "Russian Roulette",
        cooldown = 1,
        passive = false,
        effect = function(user)
            local roll = math.random(1, 6)
            if roll == 6 then
                print(user.name .. " pulls the trigger... and DIES!")
                user.stats.hp = 0
            else
                user.effects.russianRouletteStacks = (user.effects.russianRouletteStacks or 0) + 1
                print(user.name .. " survives and gains +10% crit chance stack!")
            end
        end
    },

    ability4 = {
        name = "Shadow Instinct",
        cooldown = 0,
        passive = true,
        apply = function(user)
            user.stats.attack = user.stats.attack + 10
            print(user.name .. " gains +10 permanent ATK from Shadow Instinct.")
        end
    },

    ability5 = {
        name = "Death Mark",
        cooldown = 6,
        passive = false,
        effect = function(user, target)
            if target.stats.hp / target.stats.maxHp <= 0.5 then
                if math.random() < 0.5 then
                    target.stats.hp = 0
                    print("Death Mark executes the target instantly!")
                else
                    print("Death Mark failed!")
                end
            else
                print("Target HP too high for Death Mark!")
            end
        end
    }
}
