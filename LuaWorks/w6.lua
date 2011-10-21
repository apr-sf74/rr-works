-- w6.lua 
-- write down answers on the game of tower of hanoi
-- 

module(..., package.seeall)

local towers = {}

towers["t1"] = {}
towers["t2"] = {}
towers["t3"] = {}

local answers = {
	{ disk=1, from="t1", to="t3"},
	{ disk=2, from="t1", to="t2"},
	{ disk=1, from="t3", to="t2"},
	{ disk=3, from="t1", to="t3"},
	{ disk=1, from="t2", to="t1"},
	{ disk=2, from="t2", to="t3"},
	{ disk=1, from="t1", to="t3"},-- homework here. add all steps
	-- there are total 7 steps
}

local function towerStart()
	towers["t1"] = {3, 2, 1}
	towers["t2"] = {}
	towers["t3"] = {}
end

local function moveDiskFromTo(diskNo,fromTower, toTower)
	-- homework in w5, copy result here
	if (fromTower[#fromTower] ~= diskNo) then 
		return false
	end
	if ((toTower[#fromTower] or 99) < diskNo) then
		return false
	end
	toTower[#toTower+1] = diskNo
	fromTower [#fromTower] = nil
	return true
end


run = function()

	for i=1,9 do
		WorkTable[i]:setText(" ")
	end
	
	WorkPad1:setText("all steps on worktable 1-7")
	
	towerStart()
	for i=1,#answers do
		WorkTable[i]:setText(
			"move disk "   .. answers[i].disk .. 
			" from " .. answers[i].from  ..
			" to "   .. answers[i].to  )
	end
	
end