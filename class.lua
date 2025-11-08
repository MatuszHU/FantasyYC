local kabilities = require "util.abilities.knightAbilities"
local cabilities = require "util.abilities.cavalryAbilities"

return {
    knight = {
        name = "knight",
        stats = {
            attack = 7,
            defense = 2,
            resistance = 2,
            accuracy = 2
        },
        abilities = kabilities
    },
    cavalry = {
        name = "cavalry",
        stats = {
            attack = 3,
            defense = 7,
            resistance = 7,
            evasion = 5,
            fow = 2,
            movement = 4
        },
        abilities = cabilities
    },
    wizard = {
        name = "wizard",
        stats = {
            magic = 6,
            resistance = 3,
            accuracy = 4
        },
        abilities = kabilities
    },
    priest = {
        name = "priest",
        stats = {
            defense = 5,
            magic = 1,
            resistance = 5,
            accuracy = 2,
            evasion = 5,
            luck = 1,
            movement = 1
        },
        abilities = kabilities
    },
    thief = {
        name = "thief",
        stats = {
            luck = 10,
            fow = 2,
            movement = 3
        },
        abilities = kabilities
    }
}