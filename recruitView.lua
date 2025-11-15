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

    self.candidates = self:generateCandidates(8)
    self.selected = 1
    self.listClickableRects = {}

    self.recruitButton = Button(
        "Recruit!",
        function() self:recruitSelected() end,
        nil,
        240, 58
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
        local name = nameManager:getRandomName(raceKey, gender) or "a_"..i
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

   
    love.graphics.setColor(0,0,0,0.22)
    love.graphics.rectangle("fill", x+18, y+18, width, height, 36, 36)
    love.graphics.setColor(0.09, 0.07, 0.02, 0.97)
    love.graphics.rectangle("fill", x, y, width, height, 30, 30)
    love.graphics.setColor(0.4, 0.32, 0.12, 1)
    love.graphics.setLineWidth(10)
    love.graphics.rectangle("line", x, y, width, height, 28, 28)


    local listX, listY = x+35, y+35
    local listW, listH = width*0.345, height-70
    love.graphics.setColor(0.18, 0.15, 0.10,1)
    love.graphics.rectangle("fill", listX, listY, listW, listH, 22, 22)
    love.graphics.setColor(0.94, 0.84, 0.33, 0.17)
    love.graphics.setLineWidth(6)
    love.graphics.rectangle("line", listX, listY, listW, listH, 22, 22)
    love.graphics.setColor(1,0.91,0.55,1)
    love.graphics.setFont(font.title.font)
    love.graphics.print("Candidates", listX + 60, listY + 18)
    love.graphics.setLineWidth(2)
    love.graphics.setColor(0.87, 0.79, 0.35, 0.25)
    love.graphics.line(listX+32, listY+65, listX+listW-32, listY+65)

 
    self.listClickableRects = {}
    local candidateCount = #self.candidates
    local headerPad = 80
    local itemHeight = (listH - headerPad - 20) / math.max(candidateCount, 1)
    for i=1, candidateCount do
        local lY = listY + headerPad + (i-1)*itemHeight
        local isSelected = (i == self.selected)
        if isSelected then
            love.graphics.setColor(0.88, 0.7, 0.19, 0.92)
            love.graphics.rectangle("fill", listX + 17, lY - 4, listW - 34, itemHeight-4, 14, 14)
            love.graphics.setColor(0.42, 0.21, 0, 0.62)
            love.graphics.setLineWidth(4)
            love.graphics.rectangle("line", listX+17, lY-4, listW-34, itemHeight-4, 14, 14)
        end
        if i % 2 == 0 then
            love.graphics.setColor(0.97,0.96,0.85,0.03)
            love.graphics.rectangle("fill", listX + 17, lY - 4, listW - 34, itemHeight-4, 14, 14)
        end
        love.graphics.setFont(isSelected and font.big.font or font.button.font)
        love.graphics.setColor(isSelected and {0.22,0.13,0.03,1} or {1,0.95,0.80,1})
        love.graphics.print(self.candidates[i].name, listX + 42, lY)
        table.insert(self.listClickableRects, {
            idx = i,
            x = listX + 17,
            y = lY - 4,
            w = listW - 34,
            h = itemHeight-4
        })
    end

    
    local infoX, infoY = x + width*0.385, y + 35
    local infoW, infoH = width*0.57, height - 70
    love.graphics.setColor(0.96,0.93,0.81,1)
    love.graphics.rectangle("fill", infoX, infoY, infoW, infoH, 22, 22)
    love.graphics.setColor(0.8,0.68,0.33, 0.19)
    love.graphics.setLineWidth(7)
    love.graphics.rectangle("line", infoX, infoY, infoW, infoH, 22, 22)

    
    local sel = self.candidates[self.selected]
    love.graphics.setColor(0.09,0.05,0.01, 1)
    love.graphics.setFont(font.title.font)
    love.graphics.print("Character Stats", infoX + 56, infoY + 24)


    love.graphics.setFont(font.big.font)
    love.graphics.setColor(0.13,0.07,0.02, 1)
    love.graphics.print("Name:", infoX + 48, infoY + 94)
    love.graphics.setColor(0.48,0.05,0,1)
    love.graphics.print(sel.name or "", infoX + 210, infoY + 94)

    love.graphics.setColor(0.13,0.07,0.02, 1)
    love.graphics.print("Race:", infoX + 48, infoY + 142)
    love.graphics.setColor(0.43,0.11,0, 1)
    love.graphics.print(sel.race and sel.race.name or "", infoX + 210, infoY + 142)

    love.graphics.setColor(0.13,0.07,0.02, 1)
    love.graphics.print("Class:", infoX + 48, infoY + 186)
    love.graphics.setColor(0.11,0.13,0.21, 1)
    love.graphics.print(sel.class and sel.class.name or "", infoX + 210, infoY + 186)


    love.graphics.setFont(font.medium.font)
    local keys, vals = {}, {}
    for stat, value in pairs(sel.stats or {}) do
        table.insert(keys, stat)
        table.insert(vals, value)
    end
    local col1 = math.ceil(#keys / 2)
    local leftx, rightx = infoX+90, infoX+260
    local sy = infoY + 260
    local rowH = 36
    for i=1,col1 do

        love.graphics.setColor(0.22,0.17,0.09,1)
        love.graphics.print(string.format("%-10s:", keys[i] or ""), leftx, sy)
        love.graphics.setColor(0,0.32,0.18,1)
        love.graphics.print(tostring(vals[i] or ""), leftx+110, sy)
    
        if keys[col1+i] then
            love.graphics.setColor(0.22,0.17,0.09,1)
            love.graphics.print(string.format("%-10s:", keys[col1+i]), rightx, sy)
            love.graphics.setColor(0,0.32,0.18,1)
            love.graphics.print(tostring(vals[col1+i]), rightx+110, sy)
        end
        sy = sy + rowH
    end

    self.recruitButton.button_x = infoX + infoW - 265
    self.recruitButton.button_y = infoY + infoH - 92
    love.graphics.setColor(0.14,0.09,0.07,0.38)
    love.graphics.rectangle("fill", self.recruitButton.button_x+10, self.recruitButton.button_y+12, self.recruitButton.width, self.recruitButton.height, 18,18)
    love.graphics.setColor(0.96,0.78,0.23,0.98)
    love.graphics.rectangle("fill", self.recruitButton.button_x, self.recruitButton.button_y, self.recruitButton.width, self.recruitButton.height, 18,18)
    love.graphics.setColor(0.41,0.19,0,1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", self.recruitButton.button_x, self.recruitButton.button_y, self.recruitButton.width, self.recruitButton.height, 18,18)
    love.graphics.setFont(font.button.font)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(self.recruitButton.text, self.recruitButton.button_x + 46, self.recruitButton.button_y + 18)
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