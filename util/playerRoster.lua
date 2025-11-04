local NameManager = require "util.nameManager"

local PlayerRoster = {}
PlayerRoster.__index = PlayerRoster

function PlayerRoster:new(characterManager)
    local self = setmetatable({}, PlayerRoster)
    self.characterManager = characterManager
    self.nameManager = NameManager()

    -- Permanent player-owned characters
    self.characters = {
        characterManager:addCharacter(self.nameManager:getRandomName("elf", "male"), "elf", "knight", 1, 3, 4),
        characterManager:addCharacter(self.nameManager:getRandomName("human", "male"), "human", "knight", 1, 5, 4)
    }

    return self
end

function PlayerRoster:addCharacter(name, race, class, level, gridX, gridY)
    local char = self.characterManager:addCharacter(name, race, class, level, gridX, gridY)
    table.insert(self.characters, char)
    print("Recruited new character: " .. name)
end

function PlayerRoster:resetAfterBattle()
    local startPositions = {
        { x = 3, y = 4 },
        { x = 5, y = 4 },
        { x = 4, y = 5 }
    }

    for i, char in ipairs(self.characters) do
        char.isDefeated = false
        if char.stats then
            char.stats.hp = char.stats.max_hp or 1
        end
        if startPositions[i] then
            char.gridX = startPositions[i].x
            char.gridY = startPositions[i].y
        end
        if char.loadSprite then
            char:loadSprite(char.offsetX)
        end
        if char.spriteManager then
            local cw, ch = self.characterManager.gridManager.cellW, self.characterManager.gridManager.cellH
            local sw, sh = char.spriteManager.sheetWidth, char.spriteManager.sheetHeight
            char.scale = { x = cw / (sw / 3), y = ch / (sh / 2) }
        end
    end
end

function PlayerRoster:getTeam()
    return self.characters
end

return PlayerRoster
