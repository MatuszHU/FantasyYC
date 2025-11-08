local Character = require "../character"

local CharacterManager = {}
CharacterManager.__index = CharacterManager

function CharacterManager:new(gridManager)
    local self = setmetatable({}, CharacterManager)
    self.characters = {}           -- all Character instances
    self.gridManager = gridManager
    return self
end

-- Add a new character to the manager
function CharacterManager:addCharacter(name, race, class, spriteIndex, gridX, gridY)
    local char = Character(name, race, class, spriteIndex, gridX, gridY)
    char:loadSprite()
    char:setStats()

    -- dynamically calculate scale based on sprite size
    local cw, ch = self.gridManager.cellW, self.gridManager.cellH
    local sw = char.spriteManager.sheetWidth
    local sh = char.spriteManager.sheetHeight

    char.scale = {
        x = cw / (sw / 3),
        y = ch / (sh / 2)
    }

    table.insert(self.characters, char)
    return char
end


-- Utility: find character at grid position
function CharacterManager:getCharacterAt(gridX, gridY)
    for _, char in ipairs(self.characters) do
        if char.gridX == gridX and char.gridY == gridY then
            return char
        end
    end
    return nil
end

-- Utility: get all characters belonging to a team (table of references)
function CharacterManager:getTeamCharacters(team)
    local teamChars = {}
    for _, char in ipairs(self.characters) do
        for _, member in ipairs(team) do
            if char == member then
                table.insert(teamChars, char)
            end
        end
    end
    return teamChars
end

-- Calculate reachable cells for movement (used by BattleManager)
function CharacterManager:getReachableCells(character)
    local reachable = {}
    local maxMove = character.stats.movement or 0
    local startX, startY = character.gridX, character.gridY
    local cols, rows = self.gridManager.cols, self.gridManager.rows

    for dx = -maxMove, maxMove do
        for dy = -maxMove, maxMove do
            local x = startX + dx
            local y = startY + dy
            local distance = math.abs(dx) + math.abs(dy)
            if distance <= maxMove and x >= 0 and x < cols and y >= 0 and y < rows then
                table.insert(reachable, { x = x, y = y })
            end
        end
    end

    return reachable
end

function CharacterManager:highlightReachable(char)
    self.reachableCells = self:getReachableCells(char)
end
-- TODO: possible remove
function CharacterManager:levelUpCharacters()
    for _, char in ipairs(self.characters) do
        char:levelUp()
        for k, v in pairs(char.stats) do
            print(string.format("%s : %d",k,v))
        end
    end
end

function CharacterManager:clearHighlight()
    self.reachableCells = nil
end


-- Draw HP bar above a character
function CharacterManager:drawHP(char, x, y)
    local hp, max = char.stats.hp, char.stats.max_hp
    local ratio = hp / max

    -- background bar
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", x, y - 8, 40, 5)

    -- health bar
    love.graphics.setColor(1 - ratio, ratio, 0) -- red to green
    love.graphics.rectangle("fill", x, y - 8, 40 * ratio, 5)

    -- text
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(hp .. "/" .. max, x, y - 20)
end

-- Main draw call for all characters
function CharacterManager:draw()
    local mapScale = self.gridManager.scale

    if self.reachableCells then
        self.gridManager:highlightCells(self.reachableCells, 0, 1, 0, 0.3)
    end

    for _, char in ipairs(self.characters) do
        local baseX, baseY = self.gridManager:gridToScreen(char.gridX, char.gridY)
        local drawX = baseX + (char.offsetX or 0) * mapScale
        local drawY = baseY + (char.offsetY or 0) * mapScale

        char:draw(drawX, drawY, mapScale * char.scale.x, mapScale * char.scale.y)
        self:drawHP(char, baseX, baseY)
    end
end

return CharacterManager
