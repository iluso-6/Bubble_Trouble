---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local sceneName = 'over'

local composer = require( "composer" )

local globals = require('globals')

-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

---------------------------------------------------------------------------------

local Btn
local trans1
local trans2
local musicPlaying

local scoreTxt
local score


function scene:create( event )
    local sceneGroup = self.view
		
    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
	musicPlaying = globals.musicPlaying
	score = globals.score
	
        -- Called when the scene is still off screen and is about to move on screen
        local overImage = display.newImageRect('images/gameOver.png',320,480)
        overImage.x = display.contentWidth / 2
        overImage.y = display.contentHeight / 2
		sceneGroup:insert(overImage)
		
        Btn = display.newImageRect('images/replay.png',60,60)
        Btn.x = display.contentWidth / 2
        Btn.y = display.contentHeight -100
		sceneGroup:insert(Btn)		
		
    elseif phase == "did" then
        -- Called when the scene is now on screen
        -- 
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc
   --     nextSceneButton = self:getObjectByTag( "GoToScene1Btn" )
   	scoreTxt = display.newText('Score: 0', 0, 0, "Comic Sans MS", 28)
	scoreTxt.x = display.contentWidth / 2
	scoreTxt.y = 100
	scoreTxt.text = 'Score: ' .. tostring(score)
   
	sceneGroup:insert(scoreTxt)
	
local function startAnim()   
   trans1 = nil
   local function reset()
   trans2 = nil
   trans1 = transition.to(Btn,{time=300,rotation=-90,xScale = 1,yScale = 1, transition=easing.inExpo,onComplete=startAnim})
   end
   trans2 = transition.to(Btn,{time=2500,rotation=90,xScale = 1.3,yScale = 1.3, transition=easing.outExpo,onComplete=reset})
   
end   
startAnim() 
        if Btn then
        	function Btn:touch ( event )
        		local phase = event.phase
				if "began" == phase then
				display.getCurrentStage():setFocus( event.target )
					elseif "ended" == phase then
					display.getCurrentStage():setFocus( nil )
					event.target.isFocus = false
					local options =
					{
					effect = "slideRight",
					time = 800,
					params = {
					sampleVar2 = "another sample variable"
							}
					}
        			composer.gotoScene( "game", options )
        		end
        	end
        	-- add the touch event listener to the button
        	Btn:addEventListener( "touch", Btn )
        end
    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
		if (trans1)then
		transition.cancel(trans1)
		end
		if (trans2)then
		transition.cancel(trans2)
		end		
    elseif phase == "did" then
        -- Called when the scene is now off screen
		if Btn then
			Btn:removeEventListener( "touch", Btn )
		end
    end 
end


function scene:destroy( event )
    local sceneGroup = self.view

    -- Called prior to the removal of scene's "view" (sceneGroup)
    -- 
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
