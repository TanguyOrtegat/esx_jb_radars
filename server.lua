ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- TriggerEvent('es:addGroupCommand', 'blip', 'admin', function(source, args, user)
    -- TriggerClientEvent('esx_jb_radars:ShowRadarBlip', source)
-- end)

-- TriggerEvent('es:addGroupCommand', 'rmblip', 'admin', function(source, args, user)
    -- TriggerClientEvent('esx_jb_radars:RemoveRadarBlip', source)
-- end)

-- TriggerEvent('es:addGroupCommand', 'radar', 'admin', function(source, args, user)
    -- TriggerClientEvent('esx_jb_radars:ShowRadarProp', -1)
-- end)

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

RegisterServerEvent('esx_jb_radars:PayFine')
AddEventHandler('esx_jb_radars:PayFine', function (source, plate, kmhspeed, maxspeed, amount)
	local shortplate = string.sub(plate, 0,4)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
  MySQL.Async.fetchAll(
    'SELECT * FROM owned_vehicles',
    {},
    function (result)
      for i=1, #result, 1 do
        local vehicleProps = json.decode(result[i].vehicle)
        if vehicleProps.plate == plate then
			identifier = result[i].owner
			MySQL.Async.execute(
				'INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)',
				{
					['@identifier']  = identifier,
					['@sender']      = "Radar fixe",
					['@target_type'] = 'society',
					['@target']      = 'society_police',
					['@label']       = "📸:plaque "..plate..", "..kmhspeed.."km/h a la place de "..maxspeed,
					['@amount']      = amount
				},
				function(rowsChanged)
					-- TriggerClientEvent('esx:showNotification', _source, "Votre voiture a été flashée.")
				end
			)
			break
		elseif shortplate == "TAXI" 
				or shortplate == "AMBU" 
				or shortplate == "FISH" 
				or shortplate == "POLI" 
				or shortplate == "MECA" 
				or shortplate == "FUEL" 
				or shortplate == "BUCH"
				or shortplate == "MINE"
				or shortplate == "JOUR" 
				or shortplate == "ABAT"
				or shortplate == "COUT"
				or shortplate == "BIKE"
				or shortplate == "BREW"
				or shortplate == "BRIN"
				or shortplate == "BAHA"
				or shortplate == "FOOD"
				or shortplate == "FTNE"
				or shortplate == "GANG"
				or shortplate == "JOAL"
				or shortplate == "STAT"
				or shortplate == "UNIC"
				or shortplate == "BANK"
				or shortplate == "TRUC"
				or shortplate == "PIZZ"
				or shortplate == "PROP"
				or shortplate == "WORK"
				or shortplate == "COFF" then
			-- xPlayer.removeMoney(amount)
			-- TriggerClientEvent('esx:showNotification', _source, "Votre voiturede société a été flashé.")
			MySQL.Async.execute(
				'INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)',
				{
					['@identifier']  = xPlayer.identifier,
					['@sender']      = "Radar fixe",
					['@target_type'] = 'society',
					['@target']      = 'society_police',
					['@label']       = "📸:plaque société "..plate..", "..kmhspeed.."km/h a la place de "..maxspeed,
					['@amount']      = amount
				},
				function(rowsChanged)
					TriggerClientEvent('esx:showNotification', _source, "Votre voiture de société a été flashée.")
				end
			)
			break
        end
      end
    end
  )
end)


local IsEnnabled = false
ESX.RegisterUsableItem('coyotte', function(source)
	-- local xPlayer = ESX.GetPlayerFromId(source)
	if not IsEnnabled then
		IsEnnabled  = true
		TriggerClientEvent('esx_jb_radars:ShowRadarBlip', source)
		TriggerClientEvent('esx:ShowNotification',source, "Tu as activé ton coyotte.")
	else
		TriggerClientEvent('esx_jb_radars:RemoveRadarBlip', source)
		IsEnnabled = false
	end
end)

RegisterServerEvent('esx:onRemoveInventoryItem')
AddEventHandler('esx:onRemoveInventoryItem', function(source, item, count)
  if item.name ~= nil and item.name == 'coyotte' and item.count == 0 then
	IsEnnabled = false
	TriggerClientEvent('esx_jb_radars:RemoveRadarBlip', source)
	-- TriggerClientEvent('esx:showNotification', source, "Ton coyotte est désactifé.")
  end
end)

function dump(o, nb)
  if nb == nil then
    nb = 0
  end
   if type(o) == 'table' then
      local s = ''
      for i = 1, nb + 1, 1 do
        s = s .. "    "
      end
      s = '{\n'
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
          for i = 1, nb, 1 do
            s = s .. "    "
          end
         s = s .. '['..k..'] = ' .. dump(v, nb + 1) .. ',\n'
      end
      for i = 1, nb, 1 do
        s = s .. "    "
      end
      return s .. '}'
   else
      return tostring(o)
   end
end