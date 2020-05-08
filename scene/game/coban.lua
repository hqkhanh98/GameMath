local composer = require( "composer" )
local utils = require "lib.utils"
 
local scene = composer.newScene()
 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- local question
local data = {}
local reps = {}
local score = 0
local lblScore,question, backGroup, frontGroup, gameGroup
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
local function updateQuestion()
    local rnd = math.random(#data)
    question.text = data[rnd].quest
    question.label = data[rnd].quest
    local rndAnswers = { math.random(1, 3), math.random(1, 3), math.random(1, 3) }
    
    while true do
        local check = false
        for i = 1, #rndAnswers-1 do
            for j = i + 1, #rndAnswers do
                if rndAnswers[i] == rndAnswers[j] then
                    rndAnswers[i] = math.random(1, 3)
                    check = true
                end
            end
        end
        if not check then
            break
        end

        --print(check)
    end
    --print(rndAnswers[1], rndAnswers[2], rndAnswers[3])
    for i = 1, 3 do
        reps[i].text = data[rnd].answer[rndAnswers[i]]
        reps[i].label = data[rnd].answer[rndAnswers[i]]
        reps[i]:addEventListener("touch", onTouchRep)
    end
end
local function createPopup()
    local popupGroup = display.newGroup()
    
    local popupBG = display.newRoundedRect( popupGroup, GB.cx, GB.cy, 300, 200, 25 )
    popupBG:setFillColor(200/255,125/255, 100/255)
    local btnReplay = display.newImageRect(popupGroup, "assets/btn-replay.png", 64, 64)
    btnReplay.x = popupBG.x - popupBG.contentWidth/2 + 64
    btnReplay.y = popupBG.y + popupBG.contentHeight/2  - 32
    btnReplay.name = "replay"
    local btnMenu = display.newImageRect( popupGroup, "assets/btn-menu.png", 64,64)
    btnMenu.x = popupBG.x + popupBG.contentWidth/2 - 64
    btnMenu.y = popupBG.y + popupBG.contentHeight/2 - 32
    btnMenu.name = "menu"
    local function onTouchPopupButton(event)
       -- local target = event.target
        local name = event.target.name
        local phase = event.phase

        if phase == "ended" then
            if name == "replay" then
                btnReplay:removeEventListener("touch", onTouchPopupButton)
                btnMenu:removeEventListener("touch", onTouchPopupButton)        
                updateQuestion()
                lblScore.text = score
                popupGroup:removeSelf()
                popupGroup = nil
                gameGroup.alpha = 1
                
            elseif name == "menu" then
                
                composer.gotoScene( "scene.menu" )
            end
        end
        return true
    end 
    popupGroup.complete = function (obj)
        gameGroup.alpha = .3
        btnReplay:addEventListener("touch", onTouchPopupButton)
        btnMenu:addEventListener("touch", onTouchPopupButton)
    end
    transition.from(popupGroup, { time = 500, alpha = 0, onComplete = popupGroup.complete})
    frontGroup:insert(popupGroup)
end


local function checkCorrect(quest, answer)
    for i = 1, #data do
        if quest == data[i].quest then
            if answer == data[i].correct then
                score = score + 100
                lblScore.text = score
                return true
            else
                score = 0
                createPopup()
                return false
            end
        end
    end
   
end
function onTouchRep(event)
    --print(event.target.text)
    if event.phase == "began" then
        
    end
    if event.phase == "ended" then
        --local answer = event.target.text
        if checkCorrect(question.label, event.target.label) then
            updateQuestion() 
        else 
            
        end
        for i = 1, 3 do
            reps[i]:removeEventListener("touch", onTouchRep)
        end
        -- updateQuestion()
    end 
    return true
end
local function createQuestion()
    local rnd = math.random(#data)
    question = display.newText( gameGroup, data[rnd].quest, GB.cx, GB.cy - 150, nil, 25 )
    question:setFillColor(0)
    question.label = data[rnd].quest
    for i = 1, 3 do
        reps[i] = display.newText(gameGroup, data[rnd].answer[i], (i * 81), 250 , nil, 25)
        reps[i]:setFillColor(0)
        reps[i].label = data[rnd].answer[i]
        reps[i]:addEventListener("touch", onTouchRep)
    end
end
local function loadDataWithLevelAndType(level, ops)
    datas = utils.loadTable( "data/coban.json" ,system.ResourceDirectory )
    local dataWLevel = {}
    if datas == nil then
        --print("dasa")
        return false
    end 
    
    for i = 1, #datas do
        --print(datas[i].op)
        if datas[i].level == level and datas[i].op == ops then
            dataWLevel[#dataWLevel+1] = datas[i]
        end
    end
    return dataWLevel
end
-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    backGroup = display.newGroup()
    frontGroup = display.newGroup()
    gameGroup = display.newGroup()
    bg = display.newRect( backGroup, GB.cx, GB.cy, GB.w, GB.h )
    lblScore =  display.newText( gameGroup, "SCORE : "..score, GB.cx, 50, nil, 20 )
    lblScore:setFillColor(1,0,1)
    bg:setFillColor(233/255, 233/255, 233/255)
    if loadDataWithLevelAndType(GB.level, GB.type) then 
        data = loadDataWithLevelAndType(GB.level, GB.type)
    end
    
    utils.print_r(data)

    createQuestion()

    sceneGroup:insert(backGroup)
    frontGroup:insert(gameGroup)
    
    sceneGroup:insert(frontGroup)
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
 
    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        composer.removeScene("scene.game.coban")
  
        --sceneGroup:removeSelf()
    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
 
end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene