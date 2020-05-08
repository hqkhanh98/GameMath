local widget = require "widget"
local scene = GB.composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
local background
local btnCong, btnTru, btnNhan, btnChia, btnBack

local backGroup, mainGroup, frontGroup

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------
-- local function handleButtonEvent(event)
--     if event.phase == "ended" then
--         GB.level = event.target:getLabel()
--         GB.composer.gotoScene("scene.game")
--     end
-- end
-- create()
function scene:create(event)
    local sceneGroup = self.view
    
    backGroup = display.newGroup()
    mainGroup = display.newGroup()
    frontGroup = display.newGroup()
    local title = display.newText(frontGroup, "CHỌN PHÉP TOÁN", GB.cx, 100, nil, 30)
    title:setFillColor(0)

    btnTru = display.newRoundedRect(frontGroup, 95, GB.cy +20, 75, 120, 15)
    btnTru:setFillColor(0 / 255, 201 / 255, 255 / 255)
    btnTru.strokeWidth = 5
    btnTru:setStrokeColor(62 / 255, 70 / 255, 124 / 255)
    btnTru.text = display.newText(frontGroup, "-", btnTru.x, btnTru.y, nil, 50)
    btnTru.name = "-"

    btnCong = display.newRoundedRect(frontGroup, 230, GB.cy +20, 75, 120, 15)
    btnCong:setFillColor(133 / 255, 232 / 255, 1 / 255)
    btnCong.strokeWidth = 5
    btnCong:setStrokeColor(69 / 255, 94 / 255, 21 / 255)
    btnCong.text = display.newText(frontGroup, "+", btnCong.x, btnCong.y, nil, 50)
    btnCong.name = "+"

    btnChia = display.newRoundedRect(frontGroup, 95, GB.cy + 180, 75, 120, 15)
    btnChia:setFillColor(255 / 255, 74 / 255, 203 / 255)
    btnChia.strokeWidth = 5
    btnChia:setStrokeColor(134 / 255, 66 / 255, 115 / 255)
    btnChia.text = display.newText(frontGroup, "/", btnChia.x, btnChia.y, nil, 50)
    btnChia.name = "/"

    btnNhan = display.newRoundedRect(frontGroup, 230, GB.cy + 180, 75, 120, 15)
    btnNhan:setFillColor(255 / 255, 133 / 255, 0 / 255)
    btnNhan.strokeWidth = 5
    btnNhan:setStrokeColor(145 / 255, 68 / 255, 48 / 255)
    btnNhan.text = display.newText(frontGroup, "X", btnNhan.x, btnNhan.y, nil, 50)
    btnNhan.name = "x"

    btnBack = display.newImageRect(mainGroup, "assets/btn_back.png", 60, 90)
    btnBack.x, btnBack.y = 30, 0
    btnBack.onTouch = function(event)
        if event.phase == "ended" or event.phase =="cancelled" then
            
            GB.composer.gotoScene("scene.game")
        end
        return true
    end

    -- Code here runs when the scene is first created but has not yet appeared on screen
    background = display.newRect(backGroup, GB.cx, GB.cy, GB.w, GB.h)
    sceneGroup:insert(backGroup)
    sceneGroup:insert(mainGroup)
    sceneGroup:insert(frontGroup)
end

local function onTouch(event)
    if event.phase == "began" then
            
    elseif event.phase == "ended" then
        GB.type = event.target.name
        -- if GB.type == "thachdau"
        print(GB.type)
        if GB.choose ~= "" then 
            GB.composer.gotoScene("scene.game."..GB.choose)
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
        btnTru:addEventListener("touch", onTouch)
        btnNhan:addEventListener("touch", onTouch)
        btnChia:addEventListener("touch", onTouch)
        btnCong:addEventListener("touch", onTouch)
        btnBack:addEventListener("touch", btnBack.onTouch)
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
