-- RecruitFlow.lua
local RecruitView = require("../recruitView")

local RecruitFlow = {}
RecruitFlow.__index = RecruitFlow

function RecruitFlow:new(battle, battleFlow)
    local self = setmetatable({}, RecruitFlow)
    self.battle = battle
    self.battleFlow = battleFlow
    return self
end

-- Start the recruitment phase
function RecruitFlow:start()
    local battle = self.battle
    self.playersToRecruit = {}

    -- Determine which players need recruits (team < 6)
    for _, player in ipairs(battle.players) do
        if #player.team < 6 then
            table.insert(self.playersToRecruit, player)
        end
    end

    self.currentIndex = 1

    if #self.playersToRecruit > 0 then
        self:startRecruitFor(self.playersToRecruit[self.currentIndex])
    else
        -- No recruitment needed, start battle immediately
        self.battleFlow:startBattle()
    end
end

-- Start recruitment for a specific player
function RecruitFlow:startRecruitFor(player)
    local battle = self.battle
    battle.showRecruit = true

    -- Create a new RecruitView for this player
    battle.recruitView = RecruitView:new(
        battle.characterManager,
        function(selectedChar)
            self:onRecruitForPlayer(player, selectedChar)
        end
    )
end

-- Callback when a player selects a recruit
function RecruitFlow:onRecruitForPlayer(player, selectedChar)
    local battle = self.battle

    -- Add new character to player's team
    local newChar = battle.characterManager:addCharacter(
        selectedChar.name,
        selectedChar.race and selectedChar.race.name or "human",
        selectedChar.class and selectedChar.class.name or "knight",
        math.random(1, 6),
        selectedChar.gridX or 1,
        selectedChar.gridY or 1
    )

    table.insert(player.team, newChar)
    print("Recruited for " .. player.name .. ": " .. newChar.name)

    -- Move to next player
    self.currentIndex = self.currentIndex + 1
    if self.currentIndex <= #self.playersToRecruit then
        self:startRecruitFor(self.playersToRecruit[self.currentIndex])
    else
        -- Recruitment done for all players, start battle
        battle.showRecruit = false
        self.battleFlow:startBattle()
    end
end

return RecruitFlow
