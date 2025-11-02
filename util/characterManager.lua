local Character = require "../character"

local CharacterManager = {}
CharacterManager.__index = CharacterManager

function CharacterManager:new(gridManager)
    local self = setmetatable({}, CharacterManager)
    self.characters = {}           -- stores all Character instances
    self.selectedCharacter = nil   -- currently selected unit
    self.gridManager = gridManager
    return self
end

function CharacterManager:addCharacter(name, race, class, spriteIndex, gridX, gridY)
    local char = Character(name, race, class, spriteIndex, gridX, gridY)
    char:loadSprite()
    char:setStats()
    -- dynamically calculate scale based on sprite size
    local cw, ch = self.gridManager.cellW, self.gridManager.cellH
    local sw = char.spriteManager.sheetWidth
    local sh = char.spriteManager.sheetHeight
    char.scale = {
        x = cw / (sw/3),
        y = ch / (sh/2)
    }
    table.insert(self.characters, char)
    return char
end

function CharacterManager:selectAt(gridX, gridY)
    for _, char in ipairs(self.characters) do
        if char.gridX == gridX and char.gridY == gridY then
            self.selectedCharacter = char
            print("Selected: " .. char.name)
            return char
        end
    end
    self.selectedCharacter = nil
    return nil
end

function CharacterManager:moveSelectedTo(gridX, gridY)
    if not self.selectedCharacter then return end

    local reachable = self:getReachableCells(self.selectedCharacter)

    for _, cell in ipairs(reachable) do
        if cell.x == gridX and cell.y == gridY then
            self.selectedCharacter:moveTo(gridX, gridY)
            return
        end
    end
    print("Cannot move there, out of range!")
end

function CharacterManager:getReachableCells(character)
    local reachable = {}
    local maxMove = character.stats.movement or 0
    local startX, startY = character.gridX, character.gridY

    local cols = self.gridManager.cols
    local rows = self.gridManager.rows

    for dx = -maxMove, maxMove do
        for dy = -maxMove, maxMove do
            local x = startX + dx
            local y = startY + dy
            local distance = math.abs(dx) + math.abs(dy)

            if distance <= maxMove and x >= 0 and x < cols and y >= 0 and y < rows then
                table.insert(reachable, {x = x, y = y})
            end
        end
    end

    return reachable
end

function CharacterManager:highlightReachable()
    if not self.selectedCharacter then return end
    local cells = self:getReachableCells(self.selectedCharacter)
    self.gridManager:highlightCells(cells, 0, 1, 0, 0.3) -- green highlight
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

function CharacterManager:update(dt)
    for _, char in ipairs(self.characters) do
        if char.update then
            char:update(dt)
        end
    end
end

function CharacterManager:draw()
    local mapScale = self.gridManager.scale

    for _, char in ipairs(self.characters) do
        local baseX, baseY = self.gridManager:gridToScreen(char.gridX, char.gridY)
        local drawX = baseX + (char.offsetX or 0) * mapScale
        local drawY = baseY + (char.offsetY or 0) * mapScale
        char:draw(drawX, drawY, mapScale * char.scale.x, mapScale * char.scale.y)
    end
end

return CharacterManager
