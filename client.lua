local Keys = {
  ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
  ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
  ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
  ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
  ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
  ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
  ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
  ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
  ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil
local RadarBlip = {}
local LoadedPropList = {}
local HasAlreadyEnteredMarker = false
local resource = esx_jb_radars

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	LoadRadarProps()
end)

-- create radar props
function LoadRadarProps()
	local propName = 'prop_cctv_pole_01a'
	RequestModel(propName)
	while not HasModelLoaded(propName) do
		Citizen.Wait(100)
	end

	for k, v in pairs(Config.Radars) do
		local radar = CreateObject(GetHashKey(propName), v.x, v.y, v.z - 7, true, true, true)

		SetObjectTargettable(radar, true)
		SetEntityHeading(radar, v.heading - 115)
		SetEntityAsMissionEntity(radar, true, true)
		FreezeEntityPosition(radar, true)

		table.insert(LoadedPropList, radar)
	end
end

function UnloadRadarProps()
	for k, v in pairs(LoadedPropList) do
		DeleteEntity(v)
	end
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		UnloadRadarProps()
	end
end)

RegisterNetEvent('esx_jb_radars:ShowRadarBlip')
AddEventHandler('esx_jb_radars:ShowRadarBlip', function()
	for k, v in pairs(Config.Radars) do
		RadarBlip[k] = AddBlipForCoord(v.x,v.y,v.z)
		SetBlipColour(RadarBlip[k], 69)
		SetBlipScale(RadarBlip[k], 0.8)
		SetBlipAsShortRange(RadarBlip[k], true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(('Cam: %s (%s)'):format(k, v.maxSpeed))
		EndTextCommandSetBlipName(RadarBlip[k])
		-- SetBlipFlashTimer(RadarBlip[k], 10000)
	end
end)

RegisterNetEvent('esx_jb_radars:ShowRadarProp')
AddEventHandler('esx_jb_radars:ShowRadarProp', function()
	LoadRadarProps()
end)

RegisterNetEvent('esx_jb_radars:RemoveRadarBlip')
AddEventHandler('esx_jb_radars:RemoveRadarBlip', function()
	for k, v in pairs(Config.Radars) do
		RemoveBlip(RadarBlip[k])
	end
end)

local lastRadar = nil
-- Determines if player is close enough to trigger cam
function HandlespeedCam(speedCam, hasBeenBusted)
	local myPed = GetPlayerPed(-1)
	local playerPos = GetEntityCoords(myPed)
	local isInMarker  = false

	-- DrawMarker(1, speedCam.x, speedCam.y, speedCam.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 30.0, 30.0,1.0, 255.0, 0.0, 0.0, 100, false, true, 2, false, false, false, false)
	if GetDistanceBetweenCoords(playerPos, speedCam.x, speedCam.y, speedCam.z, true) < Config.SpeedCamRange then
		isInMarker  = true
	end

	if isInMarker and not HasAlreadyEnteredMarker and lastRadar==nil then
		HasAlreadyEnteredMarker = true
		lastRadar = hasBeenBusted

		local vehicle = GetPlayersLastVehicle() -- gets the current vehicle the player is in.
		if IsPedInAnyVehicle(myPed, false) then
			if GetPedInVehicleSeat(vehicle, -1) == myPed then
				if GetVehicleClass(vehicle) ~= 18 then
					local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
					local numberPlate = vehicleProps.plate
					local driver = GetPedInVehicleSeat(vehicle, -1)
					-- local name = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
					-- ESX.TriggerServerCallback('esx_jb_radars:checkvehicle',function(valid)
						-- if(valid) then
							local kmhSpeed = math.ceil(GetEntitySpeed(vehicle)* 3.6)
							if (tonumber(kmhSpeed) > tonumber(speedCam.maxSpeed)) then
								local fine = 0
								local TooMuchSpeed = tonumber(kmhSpeed) - tonumber(speedCam.maxSpeed)
								if TooMuchSpeed >= 25 and TooMuchSpeed <= 50 then
									fine =200 + (TooMuchSpeed*Config.KmhFine)
								elseif TooMuchSpeed > 50 and TooMuchSpeed <= 100 then
									fine =250 + (TooMuchSpeed*Config.KmhFine)
								elseif TooMuchSpeed > 100 and TooMuchSpeed <= 125 then
									fine =300 + (TooMuchSpeed*Config.KmhFine)
								elseif TooMuchSpeed > 125 and TooMuchSpeed <= 150 then
									fine =400 + (TooMuchSpeed*Config.KmhFine)
								elseif TooMuchSpeed > 150 and TooMuchSpeed <= 175 then
									fine =450 + (TooMuchSpeed*Config.KmhFine)
								elseif TooMuchSpeed > 175 then
									fine =500 + (TooMuchSpeed*Config.KmhFine)
								end
								if fine ~= 0 then
									SetTimeout(60000, function()
										-- TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(PlayerId()), 'society_police', "Radar fixe: amende vitesse "..kmhSpeed.."km/h a la place de "..speedCam.maxSpeed, fine) 
										TriggerServerEvent('esx_jb_radars:PayFine',GetPlayerServerId(PlayerId()), numberPlate, kmhSpeed, speedCam.maxSpeed, fine)
									end)
								end
							end
						-- end
					-- end,vehicleProps)
				end
			end
		end
	end
		
	if not isInMarker and HasAlreadyEnteredMarker and lastRadar==hasBeenBusted then
		HasAlreadyEnteredMarker = false
		lastRadar = nil
	end
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		for key, value in pairs(Config.Radars) do
			HandlespeedCam(value, key)
		end
	end
end)
