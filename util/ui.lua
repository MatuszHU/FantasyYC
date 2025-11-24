local love = require "love"
local Button = require "Button"
local button = require "enums.button"
local ilm = require "enums.inLineMode"

function ui()
    return {
        drawButtonsInLine = function(self, mode, start_x, start_y, displayWidth, b_height, ...)
           
            local buttons = {...}
            local mode = mode or ilm.EQ_SP --equalSpace, stretch
            local maxWidth = displayWidth or love.graphics.getWidth()
            local height = b_height or button.DEFAULT_HEIGHT
            local width = b_width or button.DEFAULT_WIDTH
            local gaps = #buttons - 1
            local gapWidth = 10
            local vGap = 25
            local start_x = start_x or 0
            local start_y = start_y or 0
            
            if mode == ilm.EQ_SP then
                gapWidth = (displayWidth - (#buttons * button.DEFAULT_WIDTH)) / gaps
            else
                gapWidth = 10
            end
            if (button.DEFAULT_WIDTH * #buttons)+gapWidth > maxWidth then
                for i = 1, #buttons-1 do
                    buttons[i].button_x = start_x
                    buttons[i].button_y = start_y
                    start_y = start_y + height + vGap
                end
                buttons[#buttons].button_x = start_x
                buttons[#buttons].button_y = start_y
            else
                for i = 1, #buttons-1 do
                    buttons[i].button_x = start_x
                    buttons[i].button_y = start_y
                    start_x = start_x + width + gapWidth
                end
                buttons[#buttons].button_x = start_x
                buttons[#buttons].button_y = start_y

            end
            for i = 1, #buttons do
                buttons[i]:texturedDraw(buttons[i].button_x, buttons[i].button_y)
            end
            return start_y+height
        end,
    }
end

return ui