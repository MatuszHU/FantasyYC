local love = require "love"

local function GameInstructionsView()
    local w, h = love.graphics.getDimensions()

    local self = {}

    function self:draw()
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", 0, 0, w, h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("How to play", 0, 10, w, "center")
        love.graphics.printf("Step 1: Select a character from your team", 0, 40, w, "center")
        love.graphics.printf("Step 2: If any available, use an ability", 0, 70, w, "center")
        love.graphics.printf("Step 3: Move your character one of the highlighted fields", 0, 100, w, "center")
        love.graphics.printf("Step 4: If it is possible, perform an attack by clicking to an enemy character", 0, 130, w, "center")
        love.graphics.printf("Step 5: If you move with all your characters, then it switches to the enemy turn", 0, 160, w, "center")
        love.graphics.printf("Shortcuts: Action = Key \nSkip character turn = p\nSkip your turn = shift+p\nEnter attack phase = a\nExtra: Divine Intervention = u", 0, 220, w, "center")
    end

    return self
end

return GameInstructionsView
