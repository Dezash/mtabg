--[[

				MTA:BG
			MTA Battlegrounds
	Developed By: Null System Works (L, CiBeR, neves768, 1BOY & expert975)
	
]]--

vehicleSpawnPositionTable = {
{-1399.9912109375, -238.28125, 6.0068759918213},
{-2878.1240234375, -848.697265625, 7.195188999176},
{-2240.0341796875, -2658.552734375, 58.462493896484},
{-812.1396484375, -796.693359375, 152.40826416016},
{-1570.76171875, 371.099609375, 7.1875},
{-2488.0390625, 88.6708984375, 25.530117034912},
{-1571.16796875, -2735.0595703125, 48.540679931641},
{127.3486328125, -261.5166015625, 1.578125},
{2357.771484375, 123.212890625, 27.097827911377},
{2452.8525390625, -2029.310546875, 13.546875},
{2054.533203125, -1040.9189453125, 34.506607055664},
{2854.1318359375, 2407.6044921875, 10.8203125},
{1400.8798828125, 1693.12109375, 10.8203125},
{-544.3828125, 2012.5791015625, 60.1875},
}

vehicleDataTable = {}

function spawnVehiclesOnMatchStart()
	for i, veh in ipairs(getElementsByType("vehicle")) do
		if veh then
			destroyElement(veh)
		end
	end
	for i, pos in ipairs(vehicleSpawnPositionTable) do
		veh = createVehicle(551,pos[1],pos[2],pos[3],0,0,0)
		vehicleDataTable[veh] = {}
		vehicleDataTable[veh]["fuel"] = math.random(10,100)
	end
	setTimer(checkFuelOfVehicle,1000,0,veh)
end

function checkFuelOfVehicle(veh)
	if veh then
		if vehicleDataTable[veh]["fuel"] <= 0 then setVehicleEngineState(veh,false) end
	end
end

--Useful Function
function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and 'ignore' argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function setVehicleFuelConsumption(veh,player,seat)
	if veh then
		if seat == 0 then
			local speed = getElementSpeed(veh,1)
			if not speed or speed <= 0 then return end
			if not getVehicleEngineState(veh) then return end
			vehicleDataTable[veh]["fuel"] = math.max(vehicleDataTable[veh]["fuel"]-1,0)
			if vehicleDataTable[veh]["fuel"] <= 0 then setVehicleEngineState(veh,false) end
			triggerClientEvent(player,"mtabg_onPlayerIsInsideVehicle",player,vehicleDataTable[veh]["fuel"])
		end
	end
end

local fuelTimer = false
function onPlayerEnterVehicleCheckFuel(player,seat)
	if vehicleDataTable[source]["fuel"] <= 0 then
		setVehicleEngineState(source,false)
		if isTimer(fuelTimer) then killTimer(fuelTimer) end
	else
		triggerClientEvent(player,"mtabg_onPlayerIsInsideVehicle",player,vehicleDataTable[source]["fuel"])
		fuelTimer = setTimer(setVehicleFuelConsumption,10000,0,source,player,seat)
	end
end
addEventHandler("onVehicleEnter",root,onPlayerEnterVehicleCheckFuel)

function onPlayerExitVehicleStopCheckFuel(player,seat)
	setVehicleEngineState(source,false)
	if isTimer(fuelTimer) then killTimer(fuelTimer) end
	triggerClientEvent(player,"mtabg_onPlayerIsInsideVehicle",player,false)
end
addEventHandler("onVehicleExit",root,onPlayerExitVehicleStopCheckFuel)

function removeVehicleOnExplosion()
	for i, players in ipairs(getElementsByType("player")) do
		if getPedOccupiedVehicle(players) == source then
			killBattleGroundsPlayer(players)
			triggerClientEvent(players,"mtabg_onPlayerIsInsideVehicle",players,false)
		end
	end
	setTimer(destroyElement,5000,1,source)
end
addEventHandler("onVehicleExplode",root,removeVehicleOnExplosion)
		