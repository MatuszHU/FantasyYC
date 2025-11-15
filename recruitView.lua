local love = require("love")
local class_defs = require("class")
local race_defs = require("race")
local Character = require("character")
local Button = require("Button")
local font = require("util.fonts")
local nameManager = require("util.nameManager")()

local RecruitView = {}
RecruitView.__index = RecruitView

function RecruitView:new(characterManager, onRecruit)
    local self = setmetatable({}, RecruitView)
    self.characterManager = characterManager
    self.onRecruit = onRecruit

    self.candidates = self:generateCandidates(10)
    self.selected = 1

    self.scrollY = 0
    self.maxVisible = 7
    self.itemHeight = 54
    self.listClickableRects = {}

    self.recruitButton = Button(
        "Felvesz",
        function() self:recruitSelected() end,
        nil,
        200, 54
    )
    return self
end

function RecruitView:generateCandidates(num)
    local candidates = {}
    local classKeys, raceKeys = {}, {}
    for k, _ in pairs(class_defs) do table.insert(classKeys, k) end
    for k, _ in pairs(race_defs) do table.insert(raceKeys, k) end
    for i=1, num do
        local raceKey = raceKeys[math.random(#raceKeys)]
        local classKey = classKeys[math.random(#classKeys)]
        local gender = math.random(1,2) == 1 and "male" or "female"
        local name = nameManager:getRandomName(raceKey, gender) or "Jelölt_"..i
        local spriteIndex = 1
        local candidate = Character(name, raceKey, classKey, spriteIndex)
        candidate:setStats()
        table.insert(candidates, candidate)
    end
    return candidates
end

function RecruitView:draw()
    local screenWidth  = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local x = screenWidth * 0.09
    local y = screenHeight * 0.09
    local width  = screenWidth * 0.82
    local height = screenHeight * 0.82

    love.graphics.setColor(0,0,0,0.16)
    love.graphics.rectangle("fill", x+8, y+12, width, height, 26, 26)
    love.graphics.setColor(0.17, 0.13, 0.09, 0.96)
    love.graphics.rectangle("fill", x, y, width, height, 22, 22)
    love.graphics.setColor(0.55, 0.40, 0.13, 0.68)
    love.graphics.setLineWidth(8)
    love.graphics.rectangle("line", x, y, width, height, 22, 22)

    local listX, listY = x+30, y+30
    local listW, listH = width*0.36, height-60
    love.graphics.setColor(0.26, 0.22, 0.15, 1)
    love.graphics.rectangle("fill", listX, listY, listW, listH, 18, 18)
    love.graphics.setColor(0.44, 0.37, 0.22, 0.4)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", listX, listY, listW, listH, 18, 18)

    love.graphics.setFont(font.big.font)
    love.graphics.setColor(1, 0.85, 0.5, 0.95)
    love.graphics.print("Candidates", listX + 32, listY + 12)

    self.listClickableRects = {}
    local startIdx = math.max(1, self.selected - math.floor(self.maxVisible/2))
    local endIdx = math.min(#self.candidates, startIdx + self.maxVisible-1)
    for idx = startIdx, endIdx do
        local i = idx
        local lY = listY + 54 + (i-startIdx)*self.itemHeight
        local isSelected = (i == self.selected)
        if isSelected then
            love.graphics.setColor(0.77, 0.66, 0.34, 0.95)
            love.graphics.rectangle("fill", listX + 12, lY - 6, listW - 24, self.itemHeight-7, 12, 12)
            love.graphics.setColor(0.33, 0.11, 0, 0.5)
            love.graphics.setLineWidth(3)
            love.graphics.rectangle("line", listX + 12, lY - 6, listW - 24, self.itemHeight-7, 12, 12)
        end
        love.graphics.setColor(1,0.95,0.80,0.98)
        love.graphics.setFont(font.button.font)
        love.graphics.print(self.candidates[i].name, listX + 40, lY)

        table.insert(self.listClickableRects, {
            idx = i,
            x = listX + 12,
            y = lY - 6,
            w = listW - 24,
            h = self.itemHeight-7
        })
    end


    local infoX, infoY = x + width*0.40, y + 30
    local infoW, infoH = width*0.55, height - 60
    love.graphics.setColor(0.93,0.89,0.78,1)
    love.graphics.rectangle("fill", infoX, infoY, infoW, infoH, 16, 16)
    love.graphics.setColor(0.55, 0.40, 0.13, 0.25)
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", infoX, infoY, infoW, infoH, 16, 16)

    local sel = self.candidates[self.selected]
    love.graphics.setColor(0.19,0.17,0.13,1)
    love.graphics.setFont(font.title.font)
    love.graphics.print("Character Stats", infoX + 35, infoY + 17)

    love.graphics.setFont(font.big.font)
    love.graphics.setColor(0.36,0.21,0.09,1)
    love.graphics.print("Name: ", infoX + 35, infoY + 80)
    love.graphics.setColor(0.17,0.06,0,1)
    love.graphics.print(sel.name or "", infoX + 140, infoY + 80)

    love.graphics.setColor(0.36,0.21,0.09,1)
    love.graphics.print("Race: ", infoX + 35, infoY + 120)
    love.graphics.setColor(0.32,0.11,0,1)
    love.graphics.print(sel.race and sel.race.name or "", infoX + 140, infoY + 120)

    love.graphics.setColor(0.36,0.21,0.09,1)
    love.graphics.print("Class: ", infoX + 35, infoY + 160)
    love.graphics.setColor(0.23,0.09,0,1)
    love.graphics.print(sel.class and sel.class.name or "", infoX + 140, infoY + 160)

    love.graphics.setFont(font.medium.font)
    local sY = infoY + 220
    for stat, value in pairs(sel.stats or {}) do
        love.graphics.setColor(0.23,0.18,0.13,1)
        love.graphics.print(string.format("%-12s:", stat), infoX + 65, sY)
        love.graphics.setColor(0.13,0.25,0.17,1)
        love.graphics.print(tostring(value), infoX + 210, sY)
        sY = sY + 34
        if sY > infoY + infoH - 100 then break end
    end

    self.recruitButton.button_x = infoX + infoW - 225
    self.recruitButton.button_y = infoY + infoH - 75
    love.graphics.setColor(0.40, 0.30, 0.09, 0.4)
    love.graphics.rectangle("fill", self.recruitButton.button_x + 4, self.recruitButton.button_y + 6, self.recruitButton.width, self.recruitButton.height, 10,10)
    love.graphics.setColor(0.86,0.65,0.21,0.96)
    love.graphics.rectangle("fill", self.recruitButton.button_x, self.recruitButton.button_y, self.recruitButton.width, self.recruitButton.height, 10,10)
    love.graphics.setColor(0.37,0.21,0.08,1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", self.recruitButton.button_x, self.recruitButton.button_y, self.recruitButton.width, self.recruitButton.height, 10,10)
    love.graphics.setFont(font.button.font)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(self.recruitButton.text, self.recruitButton.button_x + 36, self.recruitButton.button_y + 12)
end

function RecruitView:keypressed(key)
    if key == "down" then
        self.selected = math.min(self.selected + 1, #self.candidates)
    elseif key == "up" then
        self.selected = math.max(self.selected - 1, 1)
    end
end

function RecruitView:mousepressed(x, y, button)
    for _, rect in ipairs(self.listClickableRects or {}) do
        if x >= rect.x and x <= rect.x + rect.w and y >= rect.y and y <= rect.y + rect.h then
            self.selected = rect.idx
            return
        end
    end
    if self.recruitButton and self.recruitButton.pressed then
        self.recruitButton:pressed(x, y, 20)
    end
end

function RecruitView:recruitSelected()
    if self.onRecruit then
        self.onRecruit(self.candidates[self.selected])
    end
end

return RecruitView
