ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--[[
TriggerEvent('es:addGroupCommand', 'blip', 'admin', function(source, args, user)
	TriggerClientEvent('esx_jb_radars:ShowRadarBlip', source)
end)

TriggerEvent('es:addGroupCommand', 'rmblip', 'admin', function(source, args, user)
	TriggerClientEvent('esx_jb_radars:RemoveRadarBlip', source)
end)

TriggerEvent('es:addGroupCommand', 'radar', 'admin', function(source, args, user)
	TriggerClientEvent('esx_jb_radars:ShowRadarProp', -1)
end)
--]]

--[[
ESX.RegisterServerCallback('jb_radars:checkvehicle',function(source,cb, vehicleProps)
	local isFound = false
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local vehicules = getPlayerVehicles(xPlayer.getIdentifier())
	local plate = vehicleProps.plate

	for _,v in pairs(vehicules) do
		if(plate == v.plate)then
			isFound = true
			break
		end
	end
	cb(isFound)
end)
--]]

RegisterServerEvent('esx_jb_radars:PayFine')
AddEventHandler('esx_jb_radars:PayFine', function(source, plate, kmhSpeed, maxSpeed, amount)
	local platePrefix = string.sub(plate, 0, 4)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE @plate = plate', {
		['@plate'] = plate
	}, function (result)
		if result[1] ~= nil then

			local identifier = result[1].owner
			MySQL.Async.execute('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)',
			{
				['@identifier']  = identifier,
				['@sender']      = "Radar fixe",
				['@target_type'] = 'society',
				['@target']      = 'society_police',
				['@label']       = ("📸:plaque %s, %s km/h a la place de %s"):format(plate, kmhSpeed, maxSpeed),
				['@amount']      = amount
			}, function(rowsChanged)
				-- TriggerClientEvent('esx:showNotification', _source, "Votre voiture a été flashée.")
			end)

		elseif platePrefix == "TAXI" 
			or platePrefix == "AMBU" 
			or platePrefix == "FISH" 
			or platePrefix == "POLI" 
			or platePrefix == "MECA" 
			or platePrefix == "FUEL" 
			or platePrefix == "BUCH"
			or platePrefix == "MINE"
			or platePrefix == "JOUR" 
			or platePrefix == "ABAT"
			or platePrefix == "COUT"
			or platePrefix == "BIKE"
			or platePrefix == "BREW"
			or platePrefix == "BRIN"
			or platePrefix == "BAHA"
			or platePrefix == "FOOD"
			or platePrefix == "FTNE"
			or platePrefix == "GANG"
			or platePrefix == "JOAL"
			or platePrefix == "STAT"
			or platePrefix == "UNIC"
			or platePrefix == "BANK"
			or platePrefix == "TRUC"
			or platePrefix == "PIZZ"
			or platePrefix == "PROP"
			or platePrefix == "WORK"
			or platePrefix == "COFF"
		then
			-- xPlayer.removeMoney(amount)
			-- TriggerClientEvent('esx:showNotification', _source, "Votre voiturede société a été flashé.")
			MySQL.Async.execute('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)',
			{
				['@identifier']  = xPlayer.identifier,
				['@sender']      = "Radar fixe",
				['@target_type'] = 'society',
				['@target']      = 'society_police',
				['@label']       = "📸:plaque société "..plate..", "..kmhSpeed.."km/h a la place de "..maxSpeed,
				['@amount']      = amount
			}, function(rowsChanged)
				TriggerClientEvent('esx:showNotification', _source, "Votre voiture de société a été flashée.")
			end)
		end
	end)
end)

local IsEnabled = false
ESX.RegisterUsableItem('coyotte', function(source)
	-- local xPlayer = ESX.GetPlayerFromId(source)
	if not IsEnabled then
		IsEnabled  = true
		TriggerClientEvent('esx_jb_radars:ShowRadarBlip', source)
		TriggerClientEvent('esx:ShowNotification',source, "Tu as activé ton coyotte.")
	else
		TriggerClientEvent('esx_jb_radars:RemoveRadarBlip', source)
		IsEnabled = false
	end
end)

RegisterServerEvent('esx:onRemoveInventoryItem')
AddEventHandler('esx:onRemoveInventoryItem', function(source, item, count)
	if item.name ~= nil and item.name == 'coyotte' and item.count == 0 then
		IsEnabled = false
		TriggerClientEvent('esx_jb_radars:RemoveRadarBlip', source)
		-- TriggerClientEvent('esx:showNotification', source, "Ton coyotte est désactifé.")
	end
end)
