---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local sceneName = 'game'

local composer = require( "composer" )
local globals = require('globals')
-- Load scene with same root filename as this file
local scene = composer.newScene( sceneName )

local musicPlaying = globals.musicPlaying

local pop = audio.loadSound("fuaim/softPop.ogg")
local points = audio.loadSound("fuaim/pop.ogg")
local lostLife = audio.loadSound("fuaim/lostLife.ogg")

local loopedMusic = globals.loopedMusic 
local backgroundMusicChannel = audio.reserveChannels( 1 )
local setMusic = {}

---------------------------------------------------------------------------------


local rand  = math.random

local midx = display.contentWidth*0.5
local midy = display.contentHeight*0.5
local W = display.contentWidth
local H = display.contentHeight  


local bg
local bubbleGroup = display.newGroup() 
local babyGroup = display.newGroup() 
local numberBubbles
local bubbles = {}
local babyies = {}
local babyTrans
local circleTrans
local circle
local playing = true
local isDrifting = 0

local scoreTxt
local spkr
local lifeBubbles = {}
local speedBump 


local blueCount
local yellowCount

local score = 0
local penalty
local life


local function makeDriftingText(txt, opts)

	local opts = opts
	local function killDTxt(obj)
		display.remove(obj)
		obj = nil
		isDrifting = isDrifting - 1
		for i = table.maxn( bubbles ),1 ,-1 do
		if(bubbles[i].name == 'blue')then
		bubbles[i]:setFillColor(83/255,178/255,245/255)
		elseif(bubbles[i].name == 'green')then
		bubbles[i]:setFillColor(237/255,237/255,50/255)
		end
		end
		
	end
	local dTime = opts.t or 500
	local del = opts.del or 0
	local yVal = opts.yVal or 40
	local dTxt = display.newText(txt, 0, 0, "Helvetica", 18)
	dTxt.x = opts.x
	dTxt.y = opts.y
	if opts.grp then
		opts.grp:insert(dTxt)
	end
	transition.to(dTxt, { delay=del, time=dTime, y=opts.y-yVal, alpha=0, onComplete=killDTxt} )
	isDrifting = isDrifting + 1
	
end


local function hasCollidedCircle( obj1, obj2 )
    if ( obj1 == nil ) then  -- Make sure the first object exists
        return false
    end
    if ( obj2 == nil ) then  -- Make sure the other object exists
        return false
    end

    local dx = obj1.x - obj2.x
    local dy = obj1.y - obj2.y
	local adjustSensitivity = 60

    local distance = math.sqrt( dx*dx + dy*dy )
    local objectSize = (obj2.contentWidth/2) + (obj1.contentWidth/2)
    if ( distance+adjustSensitivity < objectSize ) then
	
        return true
    end
    return false
end

local function spawnBaby(this)

local function removeBaby(obj)
	babyTrans=nil
	local idx = table.indexOf( babyies, obj )
	table.remove(babyies,idx)
	obj:removeSelf()
	obj=nil
	
end
	local babyScale = this.contentWidth/(rand(3,8))
	local baby = display.newImageRect('images/small.png',babyScale,babyScale)
	baby.x = this.x+rand(-10,10)
	baby.y = this.y+rand(-10,10)
	baby.rotation = rand(360)
	babyies[#babyies+1] = baby
	
	babyGroup:insert(baby)
	local dist = (H-this.y)*2
	babyTrans = transition.to(baby, {time = rand(4000,8000)+dist, y = H+10, x = baby.x+rand(-100,100),onComplete =removeBaby })
return baby
end


local function spawnBubbles(amt,offScreen)
local numberBubbles = amt or numberBubbles
   for i=1,numberBubbles do
	local bubbleScale = (rand(20,40))
	local bubble = display.newImageRect('images/full.png',bubbleScale,bubbleScale)
	bubble.x = offScreen or rand(0,W) 
	bubble.y = rand(0,H)
	bubble.rotation = rand(360)
	bubbles[#bubbles+1] = bubble
	bubbleGroup:insert(bubble)
	if rand(2) == 1 then
		bubble.dirX = 1
	else
		bubble.dirX = -1
	end
	if rand(2) == 1 then

		bubble.dirY = 1
	else
		bubble.dirY = -1
	end	
	bubble.speed = (rand(-50,50)/50)
--	print(bubble.speed)
	if rand(2) == 1 then
		bubble.name = 'blue'
		bubble:setFillColor(83/255,178/255,245/255)
		--bubble:setFillColor(0,0,1)
	else
		bubble.name = 'green'
		bubble:setFillColor(237/255,237/255,50/255)
	end

   end

end

local function makeCircle()

	local object = display.newImageRect('images/small.png',200,200)
	object:scale(.1,.1)
	object:setFillColor(1)
	object.rotation = rand(360)
	circleTrans = transition.to(object,{time=2000,xScale=1,yScale = 1, transition=easing.inOutQuad,onComplete=function()circleTrans=nil; end })
	circleTrans.obj = object
	return object
end

local function removeBubbles(bonus)

playing = false
	for i = table.maxn( bubbles ),1 ,-1 do

		if(bubbles[i] and bubbles[i].target)then

			local rem = bubbles[i]
			for i=1,rand(1,3) do
			spawnBaby(rem)
			end
			makeDriftingText('+' .. tostring(bonus), { x=rem.x, y=rem.y, t=1000 })
			score = score +bonus
			local idx = table.indexOf( bubbles, bubbles[i] )
			table.remove(bubbles,idx)
			rem:removeSelf()
			rem = nil
		end
	end

playing = true
audio.play(points)
local xPos = {10,W}

spawnBubbles(rand(1,4),xPos[rand(1,2)]-10)


end

function gameOver()

		local options =
{
    effect = "slideLeft",
    time = 1300,
    params = {
        score = score
    }
}

  
		composer.gotoScene( "over", options )

end

local function checkTargets(event)

for i = 1,table.maxn( bubbles ) do

		if ( hasCollidedCircle( circle, bubbles[i]) ) then

			if(bubbles[i].name == 'blue')then
			blueCount = blueCount+1
			
			elseif(bubbles[i].name == 'green')then
			yellowCount = yellowCount+1
			end
			bubbles[i].target = true
			bubbles[i]:setFillColor(237/255,95/255,89/255)
		end
end
		if (blueCount==1 and yellowCount==0 or blueCount==0 and yellowCount==1)then
		-- do nothing
	--	print('One hit wonder')
		for i = table.maxn( bubbles ),1 ,-1 do
		if(bubbles[i].target == true)then
		penalty = math.round((bubbles[i].contentWidth)/3) 
	--	print(penalty)
		makeDriftingText('-' .. tostring(penalty), { x=bubbles[i].x, y=bubbles[i].y, t=2000 })
		end
		end
		if(score>penalty)then
		score = score - penalty
		else
		score = 0
		end
		scoreTxt.text = 'Score: ' .. tostring(score)
		elseif (blueCount>0 and yellowCount>0)then
		if(life<=1)then
		life=1
		timer.performWithDelay(2000, gameOver)
		playing=false
		end
		lifeBubbles[life]:setFillColor(0)
		life = life -1
	--	print('life lost')
		makeDriftingText('Lives left: ' .. life, { x=event.x, y=event.y, t=2000 })
		audio.play(lostLife)	
		elseif (blueCount>1 and yellowCount==0 or blueCount==0 and yellowCount>1)then
	--	print('remove guys and add points blueCount: ' .. blueCount, 'yellowCount: ' .. yellowCount)
		removeBubbles(blueCount+yellowCount)
		scoreTxt.text = 'Score: ' .. tostring(score)
		end

end

local function resetTargets()

	blueCount = 0
	yellowCount = 0
	for i = 1,table.maxn( bubbles ) do
	bubbles[i].target = false
	end
end


local function onTouch(event)
local finger = 80

	if(event.phase == "began")then
	display.getCurrentStage():setFocus( event.target )
			resetTargets()
			circle = makeCircle()
			circle.x = event.x
			circle.y = event.y-finger

	elseif(event.phase == "moved" )then
	if(circle)then
		circle.x = event.x
		circle.y = event.y-finger
	end	
	elseif( event.phase == "ended" or event.phase == "cancelled" )then
	if(circle)then
		if(circleTrans)then
		transition.cancel(circleTrans)
		end
		checkTargets(event)
		audio.play(pop)
		circle:removeSelf()
		circle = nil
	end	
	display.getCurrentStage():setFocus( nil )
	event.target.isFocus = false
	end	
	return true
end


local function gameLoop( event )

	if(playing)then
		for i = 1,table.maxn( bubbles ) do
		
		if(bubbles[i].x<-10)then
		bubbles[i].x = W 
		elseif(bubbles[i].x>W)then
		bubbles[i].x = 0
		elseif(bubbles[i].y< 0)then
		bubbles[i].y = H
		elseif(bubbles[i].y> H)then
		bubbles[i].y = 0	
		end
		if(rand(1,30)==5)then
		bubbles[rand(#bubbles)].speed = (rand(-50,50)/50)
		end
			bubbles[i].x  = bubbles[i].x + bubbles[i].dirX+bubbles[i].speed
			bubbles[i].y  = bubbles[i].y + bubbles[i].dirY+bubbles[i].speed
			--bubbles[i].rotation = bubbles[i].rotation + bubbles[i].speed
		end
		if(table.maxn( bubbles )<6)then
	--	print('fresh spawn',(#bubbles ))
		spawnBubbles(9,10)
		end
		return true
	end	
	
end

local function setMusic(music)
print('stMusic functon')
	local isMusicChannelPaused = audio.isChannelPaused( 1 )
	if(music)then 
		if isMusicChannelPaused then
			audio.setVolume( 0.20, { channel=1 } )
			audio.resume( 1 )
			else
			audio.setVolume( 0.20, { channel=1 } ) 	
		backgroundMusicChannel = audio.play( loopedMusic, { channel=1, loops=-1, fadein=5000 } )	
		end
	spkr.alpha=1	
	musicPlaying = true
	elseif(not music)then 
	spkr.alpha=0.3
	if isMusicChannelPaused then
	else
	audio.pause( backgroundMusicChannel )
	end
	musicPlaying = false
	
	end
end


local function sndMusic(event)
if(event.phase=='ended')then

	if(musicPlaying)then 
	setMusic(false)
	elseif(not musicPlaying)then 
    setMusic(true)
	end
end	
return true
end

function scene:create( event )
    local sceneGroup = self.view

	display.setStatusBar(display.HiddenStatusBar)
	




end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
		
	spkr = display.newImageRect("images/music.png",32,32)
	spkr.x = 40
	spkr.y = 30	
	sceneGroup:insert(spkr)	
	
	
	musicPlaying = globals.musicPlaying

	
	print('musicPlaying',musicPlaying)		
	
	numberBubbles = 10
	speedBump = 0
	

	blueCount = 0
	yellowCount = 0

	score = 0
	life = 3		
	playing = true	
	
	
	bg = display.newImage("images/blue.png")
	bg.x = midx
	bg.y = midy	
	sceneGroup:insert(bg)
	
	scoreTxt = display.newText('Score: 0', 0, 0, "Comic Sans MS", 18)
	scoreTxt.x = midx-50
	scoreTxt.y = 30
	sceneGroup:insert(scoreTxt)
	
	
	for i = 1,life do
	lifeBubbles[i] = display.newImageRect("images/small.png",30,30)
	lifeBubbles[i].x = (40*i)+midx
	lifeBubbles[i].y = 30
	lifeBubbles[i]:setFillColor(1,1,1)
	sceneGroup:insert(lifeBubbles[i])
	end
	sceneGroup:insert(babyGroup)
	sceneGroup:insert(bubbleGroup)--spawned bubbles
	
	spkr:toFront()
	
	
    -- Called when the scene's view does not exist
    -- 
    -- INSERT code here to initialize the scene
    -- e.g. add display objects to 'sceneGroup', add touch listeners, etc
	
	bg:addEventListener('touch', onTouch)
	
    elseif phase == "did" then
        -- Called when the scene is now on screen
        -- 
        -- INSERT code here to make the scene come alive
        -- e.g. start timers, begin animation, play audio, etc
		spawnBubbles()
		setMusic(musicPlaying)
	spkr:addEventListener('touch', sndMusic)
	Runtime:addEventListener( "enterFrame", gameLoop )
    end 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
	bg:removeEventListener('touch', onTouch)
	audio.fade( { channel=1, time=3000, volume=0 } )
	globals.score = score
	globals.musicPlaying = musicPlaying
		if(circleTrans)then
		transition.cancel(circleTrans)
	--	print('transition.cancel(circle.trans)')
		if(circleTrans.obj)then
	--	print('circleTrans.obj:removeSelf()')
--		print('circleTrans.obj',circleTrans.obj)	
		local rmvCircle = circleTrans.obj
		display.remove(rmvCircle)
		rmvCircle=nil
		end
		end
	
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
		Runtime:removeEventListener( "enterFrame", gameLoop )
    elseif phase == "did" then
        -- Called when the scene is now off screen

	
	for i = table.maxn( bubbles ),1,-1 do
	bubbles[i]:removeSelf()
	bubbles[i] = nil
--	print('rmv all')
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
