-- hanoiDrag.lua 
--

module(..., package.seeall)

local physics = require("physics")

gNumOfMovements = 0
gStartingStickIdx = 0
gEndingStickIdx = 0
gNumOfSteps = 0
gLastPlate = 0

-- write all the rule for valid movement as functions
-- then drag handler should call these rules

local function isTopPlate(plate)
	local plateId = plate.myName
	local stickIdx = 0
	

	-- find the stick I am in
	for i=1,3 do
		if (math.abs(gSticks[i].x - plate.x) < 1) then
			stickIdx = i
			break
		end
	end	
	
	-- am I on top of the stick I am in?
	local theStick = gSticks[stickIdx]
	local theTopPlateId = theStick.plates[#theStick.plates]
	if theTopPlateId == plateId then
		return true
	else
		return false
	end
end

local function isSmallerThanTop(plateId, stickIdx)
	local theStick = gSticks[stickIdx]
	local plateCount = #theStick.plates
	
	if (plateCount == 0) then
		return true
	end
	
	local theTopPlateId = theStick.plates[plateCount]
	if theTopPlateId > plateId then
		return true
	else
		return false
	end
end

local function movePlateFromStickToStick(plateId, fromStickIdx, toStickIdx)
	
	print( "move: " .. plateId .. " from ".. fromStickIdx .. " to " .. toStickIdx )
	
	if (fromStickIdx == toStickIdx) then
		return
	end
	
	local fromStick = gSticks[fromStickIdx]
	local toStick = gSticks[toStickIdx]
	
	fromStick.plates[#fromStick.plates] = nil
	toStick.plates[#toStick.plates+1] = plateId
	
	gNumOfSteps = gNumOfSteps+1
	
	for i=1,3 do
		print("tower ".. i .. " contain " .. 
			(gSticks[i].plates[1] or " ") ..",".. 
			(gSticks[i].plates[2] or " ") ..",".. 
			(gSticks[i].plates[3] or " ")  .. 
			" num " .. #gSticks[i].plates)
	end
end

local function activateAllPlates()
	-- bonus homework
end

local function freezeOtherPlate(plateId)
	-- bonus homework
	
end

local function isGameFinished()
	-- homework
	-- conditions:
	-- stick 1 is empty
	-- either either 2 or either 3 is empty, i.e. all plates moved
	if (#gSticks[1].plates == 0 and #gSticks[2].plates == 0) or (#gSticks[1].plates == 0 and #gSticks[3].plates == 0) then
		return true
	end
end


local function bestNumberOfStepsForPlates(numOfPlates)
	-- calculate the best number
	-- homework
	-- formula, bestMove (n) =  bestMove(n-1) + 1 + bestMove(n-1) 
	-- i.e. bestMove is by 
		-- moving plate1..plate(N-1) to stick 2, need bestMove(N-1) steps
		-- move Plate(N) to stick 3, need 1 step
		-- then move plate1..plate(N-1) on top of plate(N) on stick3, need bestMove(N-1) steps
	-- and bestMove(1) = 1
	
	return math.pow(2,numOfPlates) - 1
end

local function isBestMovement()
	if gNumOfSteps == bestNumberOfStepsForPlates(gNumOfPlates) then
		return true
	else
		return false
	end
end

local function playCongradulation(isBest, main)
	local backgroundMusicChannel = audio.play( backgroundMusic, { loops=-1 }  ) 
     audio.pause( backgroundMusicChannel )
	local beepSound = audio.loadSound( "cheer.wav" )
	local bepSound = audio.loadSound( "Boo.wav" )
	local doneAward
	if (isBest) then
		doneAward = display.newImage( "star.png" )
		audio.play( beepSound )
	else
		doneAward = display.newImage( "thumbs.png" )
		audio.play( bepSound )

		
	end
	
	function doneAward:tap( event )
		self:removeSelf()
		local backgroundMusicChannel = audio.play( backgroundMusic, { loops=-1 }  ) 
         audio.resume( backgroundMusicChannel )
	end
	
	doneAward:addEventListener( "tap", doneAward )
	
	doneAward.x = display.contentWidth / 2
	doneAward.y = display.contentHeight/ 2
end


local function recoverDynamic(obj)
	print ("recover plate ".. obj.myName)
	obj.bodyType = "dynamic"
end


local function checkCollision(event)
    thePlate = gLastPlate
    if (gEndingStickIdx==0) then
        local startingStick = gSticks[gStartingStickIdx]
		thePlate.bodyType = "static"
		transition.to( thePlate, { time=200, x= startingStick.x, y = 280-30*#startingStick.plates, 
									transition=easing.inQuad, onComplete=recoverDynamic} )
		gStartingStickIdx = 0
    end
    
end


-- A basic function for dragging physics objects
function startDrag( event )
	local t = event.target
	local phase = event.phase
    if ( ("began"==phase) and isTopPlate(t) ) then
	   s = display.newImage("bullet_red.png", event.x-16, event.y-16)
	   s.x0 = event.x - s.x
	   s.y0 = event.y - s.y
	   t.s = s
	elseif "ended" == phase then
	  s:removeSelf( )
	 
	 end
---	if ( ("began"==phase)  )then
	if ( ("began"==phase) and isTopPlate(t) )then
		
		display.getCurrentStage():setFocus( t )
		t.isFocus = true

		-- Store initial position
		t.x0 = event.x - t.x
		t.y0 = event.y - t.y
		
	
		-- Make body type temporarily "kinematic" (to avoid gravitional forces)
		event.target.bodyType = "kinematic"
		
		-- Stop current motion, if any
		event.target:setLinearVelocity( 0, 0 )
		event.target.angularVelocity = 0

	elseif t.isFocus then
		if "moved" == phase then
			s = t.s
			t.x = event.x - t.x0
			t.y = event.y - t.y0

			s.x = event.x - s.x0
			s.y = event.y - s.y0

		elseif "ended" == phase or "cancelled" == phase then
			display.getCurrentStage():setFocus( nil )
			t.isFocus = false
			
			-- Switch body type back to "dynamic", unless we've marked this sprite as a platform
			if ( not event.target.isPlatform ) then
				event.target.bodyType = "dynamic"
				
				gLastPlate = event.target
				timer.performWithDelay( 200, checkCollision )
			end
            
		end
	end

	-- Stop further propagation of touch event!
	return true
end


local function delayedCheckResult()
	local done=isGameFinished()
	if  done == true then
		local isBest = isBestMovement() 
		playCongradulation ( isBest )
	end
end

function stickCollision( self, event )
	local thePlate = event.other
	local thePlateId = thePlate.myName

	if ( event.phase == "began" ) and (gStartingStickIdx ~= 0) then
		
		gEndingStickIdx = self.myName

		print( "began plate: " .. thePlateId .. " from ".. gStartingStickIdx .. " to " .. gEndingStickIdx )
		
		if (isSmallerThanTop(thePlateId, gEndingStickIdx)) then
			movePlateFromStickToStick(thePlateId, gStartingStickIdx, gEndingStickIdx)
			transition.to( thePlate, { time=200, x= self.x, transition=easing.inQuad} )
			
			timer.performWithDelay(600, delayedCheckResult )
		else
			local startingStick = gSticks[gStartingStickIdx]
			thePlate.bodyType = "static"
			transition.to( thePlate, { time=200, x= startingStick.x, y = 280-30*#startingStick.plates, 
										transition=easing.inQuad, onComplete=recoverDynamic} )
			gStartingStickIdx = 0
		end

	elseif ( event.phase == "ended" ) then
		print( "ended stick: " .. self.myName .. " with plate " .. thePlateId )
		if (thePlate.bodyType ~= "static") then
			gStartingStickIdx = self.myName
			gEndingStickIdx=0
		end
	end

	return true
end

