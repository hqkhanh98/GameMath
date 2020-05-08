local composer = require("composer")
local utils = require("lib.utils")
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local bg, btnBack, btnStart
local label_1, label_time, question
local rectTrue, rectFalse
local expA, expB, op, rs
local btns = {}
local ops = {"+", "-", "x", "/"}

local isPlay = false

local time = 16
local score = 0
local correct = 0
local gameLoop

local playGroup

local backGroup

local frontGroup

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
local function gameOver()
    print("gameover")
    timer.pause( gameLoop )
    local panel = display.newRoundedRect(frontGroup, GB.cx, GB.cy, 300, 250, 30)
    local text = display.newText(frontGroup, "Bạn đạt được " .. score .. " điểm !", panel.x, panel.y, nil, 10)
    text:setFillColor(0)
    local rect = display.newRect(frontGroup, panel.x, panel.y + 100, 30, 30)
    rect:setFillColor(0)
    rect.onTap = function()

        composer.gotoScene("scene.game")
        --
        -- panel:removeSelf()
        -- text:removeSelf()

        -- rect:removeEventListener("tap", rect.onTap)
        -- rect:removeSelf()
        return true
    end
    
    rect:addEventListener("tap", rect.onTap)
    --playGroup.alpha = 0
end
local function createQuestion()
    local op_rnd = ops[math.random(1, 4)]
    local level = 1
    local min
    local max
    if score < 500 then
        level = 1
    end
    if level == 1 then
        min = 1
        max = 10
    elseif level == 2 then
        min = 1
        max = 100
    elseif level == 3 then
        min = 1
        max = 1000
    end
    expA = math.random(min, max)
    expB = math.random(min, max)
    if op_rnd == "x" then
        correct = expA * expB
    elseif op_rnd == "/" then
        correct = expA / expB
    elseif op_rnd == "+" then
        correct = expA + expB
    elseif op_rnd == "-" then
        correct = expA - expB
    end
    if math.random(0, 100) > 50 then
        rs = correct
    else
        rs = correct + math.random(1, 100)
    end
    local check = ""..rs
    if op_rnd == "/" and #check > 10 then
        rs = math.floor(rs)
    end
    question.text = expA .. " " .. op_rnd .. " " .. expB .. " = " .. rs
end

-- create()
function scene:create(event)
    local sceneGroup = self.view
    playGroup = display.newGroup()
    backGroup = display.newGroup()
    frontGroup = display.newGroup()
    -- Code here runs when the scene is first created but has not yet appeared on screen
    bg = display.newRect(backGroup, GB.cx, GB.cy, GB.w, GB.h)
    bg:setFillColor(14 / 255, 124 / 255, 0)
    btnBack = display.newImageRect(frontGroup, "assets/btn_back.png", 60, 90)
    btnBack.x = 30
    btnBack.y = 0
    btnBack.onTouch = function(event)
        print(event.phase)
        if event.phase == "ended" or event.phase == "cancelled" then
            GB.composer.gotoScene("scene.game")
        end
        return true
    end
    label_1 = display.newText(playGroup, score, GB.cx, 0, nil, 30)
    label_1.alpha = 0
    label_time = display.newText(playGroup, "15 giây", GB.cx, 100, nil, 30)
    label_time.alpha = 0

    question = display.newText(playGroup, "", GB.cx, 250, nil, 30)
    --label_2 = display.newText( frontGroup, "/"..maxLevel, GB.cx+30, 0, nil, 30 )
    rectTrue = display.newImageRect(playGroup, "assets/dung.png", 120, 120)
    rectTrue.x, rectTrue.y = 100, 400
    rectTrue.alpha = 0
    rectTrue.onTouch = function(event)
        if event.phase == "ended" then
            if rs == correct then
                score = score + (10 * label_time.text)
                label_1.text = score
                event.target:setFillColor(1, 1, 1)
                createQuestion()
                time = 15
                label_time.text = time
            else
                gameOver()
                event.target:setFillColor(1, 0, 0)
                isPlay = false
            end
        end
    end
    rectFalse = display.newImageRect(playGroup, "assets/sai.png", 120, 120)
    rectFalse.x, rectFalse.y = 240, 400
    rectFalse.alpha = 0
    rectFalse.onTouch = function(event)
        if event.phase == "ended" then
            if rs ~= correct then
                score = score + (10 * label_time.text)
                label_1.text = score
                event.target:setFillColor(1, 1, 1)
                createQuestion()
                time = 15
                label_time.text = time
            else
                gameOver()
                event.target:setFillColor(1, 0, 0)
                isPlay = false
            end
        end
    end
    btnStart = display.newRoundedRect(frontGroup, GB.cx, 100, 100, 50, 10)
    btnStart.label = display.newText(frontGroup, "Bắt đầu", btnStart.x, btnStart.y, nil, 22)
    btnStart.label:setFillColor(1, 74 / 255, 89 / 255)
    btnStart.onTouch = function(event)
        if event.phase == "ended" then
            btnStart.label.alpha = 0
            btnStart.alpha = 0
            rectTrue.alpha = 1
            rectFalse.alpha = 1
            label_1.alpha = 1
            label_time.alpha = 1
            isPlay = true
            createQuestion()
        end
    end
   
    sceneGroup:insert(backGroup)
    frontGroup:insert(playGroup)
    sceneGroup:insert(frontGroup)
end

local a = 0
local prev = 0
local function times()

    if isPlay then
        time = time - 1

        --print(time)
        label_time.text = time
        if time == 0 then
            isPlay = false
            time = 16
            gameOver()
            --print("gameover")
        end
    end
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        gameLoop = timer.performWithDelay(1000, times, 0)
        -- Code here runs when the scene is still off screen (but is about to come on screen)
    elseif (phase == "did") then
        -- Code here runs when the scene is entirely on screen
        btnBack:addEventListener("touch", btnBack.onTouch)
        btnStart:addEventListener("touch", btnStart.onTouch)
        rectTrue:addEventListener("touch", rectTrue.onTouch)
        rectFalse:addEventListener("touch", rectFalse.onTouch)
        --Runtime:addEventListener("enterFrame", printTimeSinceStart)
    end
end

-- hide()
function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        timer.cancel(gameLoop)
        
    elseif (phase == "did") then
        -- Code here runs immediately after the scene goes entirely off screen
        composer.removeScene("scene.game.thachdau")
        btnBack:removeEventListener("touch", btnBack.onTouch)
        btnStart:removeEventListener("touch", btnStart.onTouch)
        rectTrue:removeEventListener("touch", rectTrue.onTouch)
        rectFalse:removeEventListener("touch", rectFalse.onTouch)
        --print("Check remove")
        --print(Runtime:removeEventListener("enterFrame", printTimeSinceStart))
    end
end

-- destroy()
function scene:destroy(event)
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene
