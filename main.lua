-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local utils = require "lib.utils"
GB = {}
GB.cx = display.contentCenterX
GB.cy = display.contentCenterY
-- GB.mx = display.contentWidth
-- GB.my = display.contentHeight

GB.w = display.actualContentWidth
GB.h = display.actualContentHeight
GB.type = ""
GB.level = "ez"
GB.choose = ""
GB.best_score = 0
GB.data = utils.loadTable("data/data.json", system.ResourceDirectory )

GB.composer = require "composer"

GB.composer.gotoScene("scene.game")