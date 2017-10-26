local bubble_sheet = graphics.newImageSheet("bubble.png", {width = 40, height = 40, numFrames = 5, })

				local _sprite = display.newSprite(bubble_sheet, {
					{name = "float", start = 1, count = 5, time = 500, loopCount = 0, loopDirection = "bounce", }
				})
				_sprite.x = math.random(-63, 543)
				_sprite.y = 384
				_sprite:play()

				-- Float the bubble up and destroy it
			--	transition.to(_sprite, {time = math.random(tMax / 2, tMax), y = -40, onComplete = function(obj)
			--		obj:removeSelf()
			--	end, })
				
				