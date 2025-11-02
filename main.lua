-- Gyakorlatilag import
local love = require "love"
local Button = require "Button"
local settingsView = require "SettingsView"
local font = require "util/fonts"
local character = require "character"
local CharacterManager = require "util/characterManager"
local GridManager = require "util/gridManager"
local NameManager = require "util/nameManager"
--Minden globálisan érvényes érték itt legyen kezelve
local game = {
    --Játék állapotok
    state = {
        menu = true,
        paused = false,
        running = false,
    }
}
local settings = settingsView()
local names = NameManager()


local buttons = {
    menu = {}
}
local function changeGameState(state)
    game.state["menu"] = state == "menu"
    game.state["paused"] = state == "paused"
    game.state["running"] = state == "running"
    print(string.format("[DEBUG] game.state changed to '%s' (menu=%s, paused=%s, running=%s)",
    state,
    tostring(game.state["menu"]),
    tostring(game.state["paused"]),
    tostring(game.state["running"])
    ))
end
local mouse = {
    radius = 20,
    x = 30,
    y = 30
}

grid = nil
characters = nil

function loadMap(mapName)
    print("[DEBUG] Loading map:", mapName)
    local screenW, screenH = love.graphics.getDimensions()
    grid = GridManager:new("assets.maps." .. mapName .. "Meta", "assets/maps/" .. mapName .. ".png", screenW, screenH)
    print("[DEBUG] Map loaded successfully.")
    characters = CharacterManager:new(grid)
    print("[DEBUG] Characters initialized successfully.")
    characters:addCharacter(names.getRandomName(),"elf","cavalry", 3, 5,5)
    changeGameState("running")
    characters:addCharacter("En","goblin","cavalry", 3, 10,10)
    print("[DEBUG] Changed game state to running.")
    local test = love.graphics.newImage("assets/maps/ForestCamp.png")
    print(test:getWidth(), test:getHeight())
end

function love.mousepressed(x,y,button,touch,presses)
    if settings.displayed then
        for k, btn in pairs(settings.buttons.windowMode) do
            btn:pressed(x, y, mouse.radius)
        end
    end
    if not game.state['running'] then
        if button == 1 then
            if game.state["menu"] then
                for index in pairs(buttons.menu) do
                    buttons.menu[index]:pressed(x,y, mouse.radius)
                end
            elseif game.state["ended"] then
                for index in pairs(buttons.ended) do
                    buttons.ended[index]:pressed(x,y, mouse.radius)
                end
            end
        end
    end
    if game.state["running"] and grid then
        if button == 1 then
            local gx, gy = grid:screenToGrid(x, y)
            if gx and gy then
                grid.selectedCell = { x = gx, y = gy }
                grid:onCellClicked(gx, gy)
            end
            if not characters.selectedCharacter then
                characters:selectAt(gx, gy)
            else
                characters:moveSelectedTo(gx, gy)
            end
        elseif button == 2 then
            characters.selectedCharacter = nil
            grid.highlightedCells = nil
        end
    end
end


function love.load()
    love.window.setFullscreen(true)
    background = love.graphics.newImage("assets/backgrounds/medievalBG.jpg")
    --settings = settingsView()

    love.window.setTitle("CS2 Nagy Projekt")
    buttons.menu.play = Button("Start", loadMap, "ForestCamp", 150, 40)
    buttons.menu.continue = Button("Continue", nil, nil, 150, 40)
    buttons.menu.setting = Button("Settings", function() settings:changeDisplay() end, nil, 150, 40)
    buttons.menu.exit = Button("Exit",love.event.quit, nil, 100, 40)
    settings:loadButtons()
end

function love.update(dt)
    mouse.x, mouse.y = love.mouse.getPosition()
    if characters then
        characters:update(dt)
    end
end

function love.draw()

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    if game.state["menu"] then
         if background then
            love.graphics.draw(background, 0, 0, 0, love.graphics.getWidth()/background:getWidth(), love.graphics.getHeight()/background:getHeight())
        else
            love.graphics.clear(0.8, 0.7, 0.6)
        end
        love.graphics.printf("Játék címe",font.title.font,0,100,love.graphics.getWidth(), "center")
        love.graphics.setFont(font.button.font)
        buttons.menu.play:texturedDraw(screenWidth/2 - buttons.menu.play.width/2, 200)
        buttons.menu.continue:texturedDraw(screenWidth/2 - buttons.menu.continue.width/2, 270)
        buttons.menu.setting:texturedDraw(screenWidth/2 - buttons.menu.setting.width/2, 340)
        buttons.menu.exit:texturedDraw(screenWidth - buttons.menu.exit.width - 20, screenHeight - buttons.menu.exit.height - 20)

        love.graphics.setFont(font.button.font)
        if settings.displayed then
            settings:draw(30,30)
        end

        if settings.cornerInfoDisplayed then
            love.graphics.printf("FPS:"..love.timer.getFPS().." Platform: "..love.system.getOS().." Settings Display: "..tostring(settings.displayed).." Fullscreen Mode:"..tostring(love.window.getFullscreen()).." cornerInfoDisplayed: "..tostring(settings.cornerInfoDisplayed), font.debug.font,10,love.graphics.getHeight()-30,love.graphics.getWidth())
        end
        

    elseif game.state["running"] then
        grid:draw()
        characters:highlightReachable()
        characters:draw()
        love.graphics.setBackgroundColor(74,103,65,1)
        
    end

--debug

end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    -- TODO: possible remove
    if key == "l" then
        characters:levelUpCharacters()
    end
end