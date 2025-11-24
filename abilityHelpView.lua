local love = require "love"
local AbilityDescriptions = require "util.abilityDescriptions"

local function AbilityHelpView()
    local w, h = love.graphics.getDimensions()
    local self = { character = nil }

    function self:setCharacter(char)
        self.character = char
    end

    function self:draw()
        if not self.character then return end

        local className = self.character.class.name:lower()
        local abilities = AbilityDescriptions[className]
        if not abilities then return end

        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, 0, w, h)

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Abilities - " .. self.character.class.name, 0, 370, w, "center")

        local y = 450
        for i, text in ipairs(abilities) do
            love.graphics.printf(i .. ". " .. text, 40, y, w - 80, "center")
            y = y + 40
        end
    end

    return self
end

return AbilityHelpView
