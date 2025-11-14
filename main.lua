-- Gyakorlatilag import
local love = require "love"
local nameManager = require("util.nameManager")()
local Button = require "Button"
local settingsView = require "SettingsView"
local font = require "util/fonts"
local character = require "character"
local CharacterManager = require "util.characterManager"
local raceTable = require("race")
local classTable = require("class")
local GameManager = require "game" -- refaktorálni kell majd a maint, hogy amit lehet a game.lua-ból használjon.
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
--gridManager
local gameInstance = nil

local characterManager;

function generateRecruitCharacters(manager, n)
    local races = {"orc", "elf", "goblin", "human", "dwarf"}
    local genders = {"male", "female"}
    local classes = {"knight", "cavalry", "wizard", "priest", "thief"} 
    --ősember megoldás tudom

    for i = 1, n do
        local race = races[math.random(#races)]
        local gender = genders[math.random(#genders)]
        local class = classes[math.random(#classes)]
        local spriteIndex = math.random(1, 6)
        local gridX, gridY = 0, 0

        local name = nameManager:getRandomName(race, gender)
        manager:addCharacter(name, race, class, spriteIndex, gridX, gridY)
    end
end


local recruitScroll = 0
local selectedRecruit = nil
local recruitList = {}


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

function loadMap(mapName)
    gameInstance = GameManager:new()
    changeGameState("running")
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
    if game.state["running"] and gameInstance then
        gameInstance:mousepressed(x, y, button)
    end

    local width = love.graphics.getWidth()
    local listWidth = width / 3
    local itemHeight = 35
    if button == 1 and x < listWidth then
        local clicked = math.floor((y + recruitScroll - 20) / itemHeight) + 1
        if recruitList[clicked] then
            selectedRecruit = recruitList[clicked]
        end
    end

    local buttonX, buttonY = width - 220, love.graphics.getHeight() - 70
    if button == 1 and selectedRecruit then
        if x > buttonX and x < buttonX + 180 and y > buttonY and y < buttonY + 50 then
-- todo
        end
    end
end

function setupRecruit()
    characterManager.characters = {}
    generateRecruitCharacters(characterManager, 25)
    recruitList = characterManager.characters
    selectedRecruit = recruitList[1]
end

function drawRecruitScreen()
    local width, height = love.graphics.getWidth(), love.graphics.getHeight()
    local listWidth = width / 3
    local detailWidth = width * 2 / 3

    love.graphics.rectangle("line", 0, 0, listWidth, height)
    local startY = 20
    local itemHeight = 35
    for i, char in ipairs(recruitList) do
        local y = startY + (i - 1) * itemHeight - recruitScroll
        if y > 0 and y < height - itemHeight then
            if selectedRecruit == char then
                love.graphics.setColor(0.6, 0.8, 1)
            else
                love.graphics.setColor(1,1,1)
            end
            love.graphics.print(char.name, 20, y)
            love.graphics.setColor(1,1,1)
        end
    end

 
    love.graphics.rectangle("line", listWidth, 0, detailWidth, height)
    if selectedRecruit then
        love.graphics.setFont(font.normal.font)
        love.graphics.print("Név: "..selectedRecruit.name, listWidth + 30, 70)
        love.graphics.print("Faj: "..selectedRecruit.race.name, listWidth + 30, 110)
        love.graphics.print("Kaszt: "..selectedRecruit.class.name, listWidth + 30, 150)

    end


    if selectedRecruit then
        local buttonX, buttonY = width - 220, height - 70
        love.graphics.setColor(0.3, 0.7, 0.3)
        love.graphics.rectangle("fill", buttonX, buttonY, 180, 50)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Select", buttonX, buttonY + 13, 180, "center")
        love.graphics.setColor(1,1,1)
    end
end


function love.wheelmoved(x, y)
    recruitScroll = math.max(0, recruitScroll - y*30)
end


function love.mousepressed(x, y, button)
    
end

function love.load()
    love.window.setFullscreen(true)
    background = love.graphics.newImage("assets/backgrounds/medievalBG.jpg")
    love.window.setTitle("CS2 Nagy Projekt")
    buttons.menu.play = Button("Start", loadMap, "ForestCamp", 150, 40)
    buttons.menu.continue = Button("Continue", nil, nil, 150, 40)
    buttons.menu.setting = Button("Settings", function() settings:changeDisplay() end, nil, 150, 40)
    buttons.menu.exit = Button("Exit",love.event.quit, nil, 100, 40)
    settings:loadButtons()
    setupRecruit()
end

function love.update(dt)
    mouse.x, mouse.y = love.mouse.getPosition()
    if game.state["running"] and gameInstance then
        gameInstance:update(dt)
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

    elseif game.state["running"] and gameInstance then
        gameInstance:draw()
    end

--debug

end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if gameInstance then
        gameInstance:keypressed(key)
    end
    if key == "c" then
        drawRecruitScreen()
    end
end