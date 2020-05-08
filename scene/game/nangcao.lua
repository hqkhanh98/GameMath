local composer = require("composer")
local widget = require "widget"
local json = require( "json" )
local utils = require "lib.utils"
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local bg, exp_1, op, exp_2, rs, cal, boxPanel, rndType, lblScore, heart, lblHeart
local scoreBar, firework_left, firework_right, gameLoop
local backGroup, frontGroup, gameGroup, boxGroup, questGroup, overGroup
local btnAnswer, lblBestScore, btnBack, lblTime
local gameState = "ready"
local pieces = {}
local quests = {}
local score = 0
local time = 16
local best_score = GB.data[2].best_score
GB.best_score = best_score
local slot = {
    {
        id = 1,
        x = 64,
        y = 332,
        rotate = math.random(360)
    },
    {
        id = 2,
        x = 160,
        y = 332,
        rotate = math.random(360)
    },
    {
        id = 3,
        x = 256,
        y = 332,
        rotate = math.random(360)
    },
    {
        id = 4,
        x = 64,
        y = 428,
        rotate = math.random(360)
    },
    {
        id = 5,
        x = 160,
        y = 428,
        rotate = math.random(360)
    },
    {
        id = 6,
        x = 256,
        y = 428,
        rotate = math.random(360)
    }
}
local function readFileDataEffect(path)
    local filePath = system.pathForFile( path )
    local f = io.open( filePath, "r" )
    local emitterData = f:read( "*a" )
    f:close()
    return emitterData
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
local function pieceInQuestBox(x, y, object)
    local bounds = object.contentBounds
    if not bounds then return false end
    if x > bounds.xMin and x < bounds.xMax and y > bounds.yMin and y < bounds.yMax then
      return true 
    else 
      return false
    end
end

local function showQuestDisplay(obj)
    obj.isEmpty = false
    obj.cover.alpha = 1
    if obj.label then
        obj.label.text = obj.value
        obj.label:toFront()
    else
        obj.label = display.newText(gameGroup, obj.value, obj.cover.x, obj.cover.y, nil, 20)
        obj.label:setFillColor(0)
    end
end

local function showPieceDisplay(obj, value)
    obj.label.text = value
    obj.label.alpha = 1
    obj.value = value
    if obj.label then
        obj.label.text = obj.value
        obj.label:toFront()
    else
        obj.label = display.newText(boxGroup, obj.value, obj.cover.x, obj.cover.y, nil, 20)
        obj.label:setFillColor(0)
    end
end
-- Tự sinh câu hỏi
local function GenerateQuestion()
    local ops = {"+", "-", "*", "/"}
    local rndOp = math.random(4) -- Ngẫu nhiên phép toán
    quests[1].value = math.random(10) -- Ngẫu nhiên giá trị thứ 1
    quests[2].value = ops[rndOp] -- Gán phép toán
    quests[3].value = math.random(10)  -- Ngẫu nhiên giá trị thứ 2

    if rndOp == 1 then
        quests[4].value = quests[1].value + quests[3].value
    elseif rndOp == 2 then
        quests[4].value = quests[1].value - quests[3].value
    elseif rndOp == 3 then
        quests[4].value = quests[1].value * quests[3].value
    elseif rndOp == 4 then
        while true do -- Kiểm tra chia hết liên tục đến khi nào chia hết thì dừng
            if quests[1].value % quests[3].value == 0 then
                break
            else
                quests[1].value = math.random(10)
                quests[3].value = math.random(10)
            end
        end
        -- Gán kết quả chia
        quests[4].value = quests[1].value / quests[3].value
    end

    rndType = 1--math.random(2) -- Ngẫu nhiên 2 chế độ 1-2
    if rndType == 1 then
        for i = 1, 3 do
            showQuestDisplay(quests[i]) -- Hiển thị phép tính
        end
        local idx = math.random(#pieces)
        
        for i = 1, #pieces do
            if i == idx then
                showPieceDisplay(pieces[idx], quests[4].value)
            else
                local value = 0
                while true do
                    value = math.random(quests[4].value-10, quests[4].value+10)
                    if value ~= quests[4].value then
                        break
                    end
                end
                showPieceDisplay(pieces[i], value)
            end
        end
    else
        showQuestDisplay(quests[4]) -- Hiển thị kết quả
        local boxs = {}
        for i = 1, 3 do
            boxs[i] = math.random(#pieces)
        end
        while true do
            local check = true
            for i = 1, #boxs - 1 do
                for j = i + 1, #boxs do
                    if boxs[i] == boxs[j] then
                        boxs[i] = math.random(#pieces)
                        check = false
                    end
                end
            end
            if check then
                break
            end
        end
        for i = 1, #pieces do
            local check = true 
            for j = 1, #boxs do
                if i == boxs[j] then
                    check = false
                end
            end
            if check then
                boxs[4] = i
            end
        end
        local count = 1
        for i = 1, #pieces do
            local check = true 
           
            for j = 1, #boxs do
                if i == boxs[j] then
                    if count <= 3 then
                        showPieceDisplay(pieces[i], quests[count].value)
                        count = count + 1
                    else
                        --print(ops[2])
                        --showPieceDisplay(pieces[i], "-")
                    end

                end
            end
            if check then
                boxs[4] = i
            end
            
        end
    end
end
function checkMatch()
    --print(box.value, obj.label.text)
    if rndType == 1 then
        if quests[4].matchValue then
            if quests[4].value == quests[4].matchValue then
                boxGroup:removeSelf()
                questGroup:removeSelf()
                createQuest()
                createPieces()
                score = score + 5
                lblScore.text = "Điểm "..score
                GenerateQuestion()
            else
                for i = 1, #pieces do
                    pieces[i].x = pieces[i].saveX
                    pieces[i].y = pieces[i].saveY
                    pieces[i].label.x = pieces[i].x
                    pieces[i].label.y = pieces[i].y
                end
                quests[4].isEmpty = true
                heart.value = heart.value - 1
                
                lblHeart.text = "x "..heart.value
                if heart.value == 0 then
                    gameState = "gameover"
                    if score > GB.best_score then 
                        firework_left:start()
                        firework_right:start()
                        GB.best_score = score
                        lblBestScore.text = "Best score: "..GB.best_score
                    else

                    end
                end
            end
        end
    end
end
local function showGameOver()
    overGroup = display.newGroup()
    --local popupBG = display.newRoundedRect()
end
-- create()
function scene:create(event)
    
    local sceneGroup = self.view
    backGroup = display.newGroup()
    frontGroup = display.newGroup()
    gameGroup = display.newGroup()

    function createQuest()
        questGroup = display.newGroup()
        quests[1] = display.newImageRect(questGroup, "assets/rs.png", 48, 48)
        quests[1].x, quests[1].y = 48, 100
        quests[1].isEmpty = true
        quests[1].cover = display.newImageRect(questGroup, "assets/Box-contain.png", 48, 48)
        quests[1].cover.x, quests[1].cover.y = quests[1].x, quests[1].y
        quests[1].cover.alpha = 0
        
        quests[2] = display.newImageRect(questGroup, "assets/rs.png", 48, 48)
        quests[2].x, quests[2].y = quests[1].x + 72, 100
        quests[2].isEmpty = true
        quests[2].cover = display.newImageRect(questGroup, "assets/Box-contain.png", 48, 48)
        quests[2].cover.x, quests[2].cover.y = quests[2].x, quests[2].y
        quests[2].cover.alpha = 0
        
        quests[3] = display.newImageRect(questGroup, "assets/rs.png", 48, 48)
        quests[3].x, quests[3].y = quests[2].x + 72, 100
        quests[3].isEmpty = true
        quests[3].cover = display.newImageRect(questGroup, "assets/Box-contain.png", 48, 48)
        quests[3].cover.x, quests[3].cover.y = quests[3].x, quests[3].y
        quests[3].cover.alpha = 0

        cal = display.newText(questGroup, "=", quests[3].x + 48, quests[3].y, nil, 25)
        
        quests[4] = display.newImageRect(questGroup, "assets/rs.png", 48, 48)
        quests[4].x, quests[4].y = cal.x + 48, cal.y
        quests[4].isEmpty = true
        quests[4].cover = display.newImageRect(questGroup, "assets/Box-contain.png", 48, 48)
        quests[4].cover.x, quests[4].cover.y = quests[4].x, quests[4].y
        quests[4].cover.alpha = 0
            for i = 1, 4 do
                quests[i].label = display.newText(questGroup, "", quests[i].cover.x, quests[i].cover.y, nil, 20)
                quests[i].label:setFillColor(0)
            end
            gameGroup:insert(questGroup)
    end
    
    createQuest()
    boxPanel = display.newImageRect(gameGroup, "assets/box-panel.jpg", 300, 200)
    boxPanel.x = display.contentCenterX
    boxPanel.y = display.contentHeight - 100
    lblScore = display.newText( frontGroup, "Điểm "..score, 160, 50, nil, 20 )
    heart = display.newImageRect( frontGroup, "assets/heart.png", 20, 20 )
    heart.x, heart.y = 15, 15
    heart.value = 3
    lblBestScore = display.newText(frontGroup, "Best score: "..GB.best_score, heart.x + 220, heart.y , nil, 20)
    lblHeart = display.newText(frontGroup, "x "..heart.value, heart.x + 30, heart.y, nil, 25)
    btnBack = display.newImageRect(frontGroup, "assets/butt_5.png", 30, 30)
    btnBack.x, btnBack.y = 20, -20
    btnBack.onTap = 
    function()
        composer.gotoScene( "scene.game" )
        return true
    end
    lblTime = display.newText( frontGroup, time, GB.cx, GB.cy - 50, nil, 20 )
    --print(display.contentHeight - 200, display.contentHeight)
    local function pieceOnTouch(event)
        local target = event.target
        local phase = event.phase
        --local rotate
        if gameState == "play" then
            if phase == "began" then
                
                display.currentStage:setFocus(target)
                target.offsetX = event.x - target.x
                target.offsetY = event.y - target.y
                target:toFront()
                target.alpha = .7
                target.saveX = target.x
                target.saveY = target.y
                --rotate = target.rotation
                target.rotation = 0
            elseif phase == "moved" then
                target.x = event.x - target.offsetX
                target.y = event.y - target.offsetY
                if target.label then
                    target.label.x, target.label.y = target.x, target.y
                end
            elseif phase == "ended" or phase == "cancelled" then
                local _x, _y = target.x, target.y
                target.x = slot[target.id].x
                target.y = slot[target.id].y
                target.rotation = slot[target.id].rotation  
                local idx = 1
                if target.quest then
                    quests[target.quest].isEmpty = true
                end
                while idx <= #quests do

                    if pieceInQuestBox(_x, _y, quests[idx]) and quests[idx].isEmpty then
                        target.x = quests[idx].x
                        target.y = quests[idx].y
                        target.rotation = 0
                        target.quest = idx
                        quests[idx].isEmpty = false
                        quests[idx].matchValue = target.value
                        --checkMatch(quests[idx], target)
                        break
                    end
                    
                    idx = idx + 1
                end
                if target.label then
                    target.label.x, target.label.y = target.x, target.y
                end
                target:toBack()
                display.currentStage:setFocus(nil)
                target.alpha = 1
            end
        end
        return true
    end

    function createPieces()
        boxGroup = display.newGroup()
        for i = 1, 6 do
        
            pieces[i] = display.newImageRect(boxGroup, "assets/Box-contain.png", 48, 48)
            pieces[i].x = slot[i].x
            pieces[i].y = slot[i].y
            pieces[i].id = slot[i].id
            pieces[i].saveX = pieces[i].x
            pieces[i].saveY = pieces[i].y
            pieces[i].label = display.newText(boxGroup, "", pieces[i].x, pieces[i].y, nil, 25)
            pieces[i].label:setFillColor(0)
            pieces[i].label.alpha = 0
            pieces[i].rotation = slot[i].rotate
            pieces[i]:addEventListener("touch", pieceOnTouch)
        end
        gameGroup:insert(boxGroup)
    end

    createPieces()

    local emitterParams = json.decode(readFileDataEffect("particle_texture.json"))

    firework_left = display.newEmitter( emitterParams )
    firework_right = display.newEmitter(emitterParams)
    -- Center the emitter within the content area
    firework_left.x = -10
    firework_left.y = 150
    firework_right.x = 360
    firework_right.y = 150
    firework_right:scale(-1, 1)
    gameGroup:insert(firework_left)
    gameGroup:insert(firework_right)
    --boxGroup:toFront()
    bg = display.newImageRect(backGroup, "assets/gamebackground.png",GB.w, GB.h)
    bg.x, bg.y =  GB.cx, GB.cy
    --bg:setFillColor(14 / 255, 124 / 255, 0)
    
    -- Function to handle button events
local function onClick( event )
    if "began" == event.phase then

    end
    if ( "ended" == event.phase ) and gameState == "play" then
        checkMatch()
    end
end
 
    -- Create the widget
    btnAnswer = widget.newButton(
        {
            label = "answer",
            onEvent = onClick,
            emboss = false,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            width = 200,
            height = 40,
            cornerRadius = 5,
            fillColor = { default={1,1,0,1}, over={1,0.1,0.7,0.4} },
            strokeColor = { default={1,0.4,0,0}, over={0.8,0.8,1,0} },
        }
    )
    
    -- Center the button
    btnAnswer.x = display.contentCenterX
    btnAnswer.y = display.contentCenterY
    
    -- Change the button's label text
    btnAnswer:setLabel( "Tra Loi" )
    gameState = "play"
    frontGroup:insert(btnAnswer)
    sceneGroup:insert(backGroup)
    sceneGroup:insert(gameGroup)
    sceneGroup:insert(frontGroup)
end

local function times()

    if gameState == "play" then
        time = time - 1

        --print(time)
        lblTime.text = time
        if time == 0 then
            gameState = "gameover"
            time = 16
            --gameOver()
            --print("gameover")
        end
    end
end

-- show()
function scene:show(event)
    
    local sceneGroup = self.view
    local phase = event.phase
    
    if (phase == "will") then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        GenerateQuestion()
    elseif (phase == "did") then
        -- Code here runs when the scene is entirely on screen
        gameLoop = timer.performWithDelay(1000, times, 0)
        btnBack:addEventListener( "tap", btnBack.onTap )
    end
end


-- hide()
function scene:hide(event)
    
    local sceneGroup = self.view
    local phase = event.phase
    
    if (phase == "will") then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        elseif (phase == "did") then
            GB.data[2].best_score = GB.best_score
            utils.saveTable(GB.data, "data/data.json", system.ResourceDirectory)
        -- Code here runs immediately after the scene goes entirely off screen
        --btnBack:addEventListener("touch", btnBack.onTouch)
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
