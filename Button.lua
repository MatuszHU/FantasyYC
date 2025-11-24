local love = require "love"
local button = require "enums.button"

function Button(text, func, func_param, width, height)

    return {
        width = width or button.DEFAULT_WIDTH,
        height = height or button.DEFAULT_HEIGHT,
        func = func or function()
            print("-Nincs hozzárendelt funkció-")
        end,
        func_param = func_param,
        text = text or "No text",
        button_x = 0,
        button_y = 0,
        text_x = 0,
        text_y = 0,

        pressed = function(self, mouse_x, mouse_y, cursor_radius)
            if (mouse_x + cursor_radius >= self.button_x) and (mouse_x - cursor_radius <= self.button_x + self.width) then
                if (mouse_y + cursor_radius >= self.button_y) and (mouse_y - cursor_radius <= self.button_y + self.height) then
                    if self.func_param then
                        self.func(self.func_param)
                    else
                        self.func()
                    end
                end
            end
        end,
        mouseHover = function(self, mouse_x, mouse_y, cursor_radius)
            if (mouse_x + cursor_radius >= self.button_x) and (mouse_x - cursor_radius <= self.button_x + self.width) then
                if (mouse_y + cursor_radius >= self.button_y) and (mouse_y - cursor_radius <= self.button_y + self.height) then
                    return true
                end
            end
            return false
        end,

        draw = function(self, button_x, button_y, text_x, text_y)
            self.button_x = button_x or self.button_x
            self.button_y = button_y or self.button_y

            if text_x then
                self.text_x = text_x + self.button_x
            else
                self.text_x = self.button_x
            end

            if text_y then
                self.text_y = text_y + self.button_y
            else
                self.text_y = self.button_y
            end

            love.graphics.setColor(120,120,120,0.6)

            love.graphics.rectangle("fill", self.button_x, self.button_y, self.width, self.height)

            love.graphics.setColor(0,0,0,1)

            love.graphics.print(self.text, self.text_x, self.text_y)
            
            love.graphics.setColor(1,1,1,1)
        end,

        texturedDraw = function(self, button_x, button_y)

            self.button_x = button_x or self.button_x
            self.button_y = button_y or self.button_y
            mouse_x, mouse_y = love.mouse.getPosition()
            if self:mouseHover(mouse_x, mouse_y, 10) then
                love.graphics.setColor(0.97, 0.89, 0.64, 0.8)
            else
                love.graphics.setColor(0.97, 0.89, 0.64, 1)
            end
            love.graphics.rectangle("fill", self.button_x, self.button_y, self.width, self.height, 18, 18)
            love.graphics.setColor(0.77, 0.61, 0.19, 1) 
            love.graphics.setLineWidth(4)
            love.graphics.rectangle("line", self.button_x, self.button_y, self.width, self.height, 18, 18)
    
            love.graphics.setColor(0.3, 0.2, 0.1, 0.25)
            love.graphics.rectangle("fill", self.button_x+6, self.button_y+6, self.width, self.height, 18, 18)
    
            love.graphics.setColor(0.3,0.2,0.15,1)
            local tw = love.graphics.getFont():getWidth(self.text)
            local th = love.graphics.getFont():getHeight()
            love.graphics.print(self.text, self.button_x + (self.width-tw)/2, self.button_y + (self.height-th)/2)
            love.graphics.setColor(1,1,1,1)
        end

    }
end

return Button