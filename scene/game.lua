local scene = GB.composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local background
local btnEasy, btnHard, btnChallenge
local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local frontGroup = display.newGroup()

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- create()
function scene:create(event)
    local sceneGroup = self.view
    -- Code here runs when the scene is first created but has not yet appeared on screen
    background = display.newRect(backGroup, GB.cx, GB.cy, GB.w, GB.h)
    local title = display.newText(frontGroup, "CHẾ ĐỘ CHƠI", GB.cx, 0, nil, 30)
    title:setFillColor(0)
    
    
    btnEasy = display.newImageRect(mainGroup, "assets/coban.png", 150, 150)
    btnEasy.x, btnEasy.y = GB.cx - 100, 180
    btnEasy.text = display.newText(frontGroup, "Cơ bản", btnEasy.x, btnEasy.y + 75, nil, 15)
    btnEasy.text:setFillColor(0)
    btnEasy.name = "coban"
    btnHard = display.newImageRect(mainGroup, "assets/nangcao.png", 200, 150)
    btnHard.x, btnHard.y = GB.cx + 75, 180
    btnHard.text = display.newText(frontGroup, "Nâng cao", btnHard.x, btnHard.y + 75, nil, 15)
    btnHard.text:setFillColor(0)
    btnHard.name = "nangcao"
    btnChallenge = display.newImageRect(mainGroup, "assets/thachdau.png", 150, 150)
    btnChallenge.x, btnChallenge.y = GB.cx, 370
    btnChallenge.text = display.newText(frontGroup, "Thách đấu", btnChallenge.x, btnChallenge.y + 75, nil, 15)
    btnChallenge.text:setFillColor(0)
    btnChallenge.name = "thachdau"
    sceneGroup:insert(backGroup)
    sceneGroup:insert(mainGroup)
    sceneGroup:insert(frontGroup)
end

local function onTouch(event)
    local name = event.target.name
    if event.phase == "ended" or event.phase == "cancelled" then
        GB.choose = name
        if GB.choose == "thachdau" then
            GB.composer.gotoScene("scene.game.thachdau")
        elseif GB.choose == "coban" then
            --GB.choose = "coban"
            GB.composer.gotoScene("scene.menu")
        elseif GB.choose == "nangcao" then
            GB.composer.gotoScene("scene.game.nangcao")
        end
   
    end
    return true
end
-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if (phase == "will") then
        -- Code here runs when the scene is still off screen (but is about to come on screen)
        elseif (phase == "did") then
        -- Code here runs when the scene is entirely on screen
        btnEasy:addEventListener("touch", onTouch)
        btnHard:addEventListener("touch", onTouch)
        btnChallenge:addEventListener("touch", onTouch)
        end
end

-- hide()
function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase
    
    if (phase == "will") then
        -- Code here runs when the scene is on screen (but is about to go off screen)
        elseif (phase == "did") then
        -- Code here runs immediately after the scene goes entirely off screen
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
