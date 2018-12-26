ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local jobplates = {}

AddEventHandler('onMySQLReady', function ()
  MySQL.Async.fetchAll(
	"SELECT name FROM jobs", {},	function(result)
		
	  for k,v in pairs(result) do
	  local job = string.upper(string.sub(v.name, 0, 4))
		jobplates[job] = true
	  end
	end
  )
end)

RegisterServerEvent('esx_jb_radars:PayFine')
AddEventHandler('esx_jb_radars:PayFine', function(source, plate, kmhSpeed, maxSpeed, amount, vehicleModel, radarStreet)
	local platePrefix = string.upper(string.sub(plate, 0, 4))
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local color = Config.orange
	local title = ""
	local speed = kmhSpeed - maxSpeed
	print('test')
	print("'"..plate.."'")
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE @plate = plate', {
		['@plate'] = plate
	}, 	function (result)
	print(dump(result))
		if result[1] ~= nil then
			title = 'Vehicule personel'
			local identifier = result[1].owner
			MySQL.Async.execute('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)',
			{
				['@identifier']  = identifier,
				['@sender']      = "Radar fixe",
				['@target_type'] = 'society',
				['@target']      = 'society_police',
				['@label']       = ("ðŸ“¸:plaque %s, %s km/h a la place de %s"):format(plate, kmhSpeed, maxSpeed),
				['@amount']      = amount
			}, function(rowsChanged)
				TriggerClientEvent('esx:showNotification', _source, "Votre voiture a Ã©tÃ© flashÃ©e.")
			end)

		elseif jobplates[platePrefix] then
			title = 'Vehicule société'
			MySQL.Async.execute('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)',
			{
				['@identifier']  = xPlayer.identifier,
				['@sender']      = "Radar fixe",
				['@target_type'] = 'society',
				['@target']      = 'society_police',
				['@label']       = "ðŸ“¸:plaque sociÃ©tÃ© "..plate..", "..kmhSpeed.."km/h a la place de "..maxSpeed,
				['@amount']      = amount
			}, function(rowsChanged)
				TriggerClientEvent('esx:showNotification', _source, "Votre voiture de sociÃ©tÃ© a Ã©tÃ© flashÃ©e.")
			end)
		else
			title = 'Vehicule inconnu'
		end
		if speed <= 50 then
			color = Config.green
		elseif speed <= 100 then
			color = Config.orange
		elseif speed > 100 then
			color = Config.red
		end
		sendToDiscord('Excès de vitesse',title,'Modele : '..vehicleModel..'\nPlaque : '..plate..'\nVitesse : '..kmhSpeed.. '\nVitesse max : '..maxSpeed..'\nRadar : '..radarStreet  ,color)
	end)
end)

local IsEnabled = false
ESX.RegisterUsableItem('coyotte', function(source)
	if not IsEnabled then
		IsEnabled  = true
		TriggerClientEvent('esx_jb_radars:ShowRadarBlip', source)
		TriggerClientEvent('esx:ShowNotification',source, "Tu as activÃ© ton coyotte.")
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
		-- TriggerClientEvent('esx:showNotification', source, "Ton coyotte est dÃ©sactivÃ©.")
	end
end)

function sendToDiscord(name,message,text,color)
print(name)
print(message)
print(text)
print(color)

	local DiscordWebHook = Config.webhook
	-- Modify here your discordWebHook username = name, content = message,embeds = embeds

	local embeds = {
		{
			["title"]=message,
			["description"]=text,
			["type"]="rich",
			["color"] =color,
			["footer"]=  {
			["text"]= os.date("%d/%m/%Y %H:%M:%S"),
		   },
		}
	}
	if message == nil or message == '' then return FALSE end
	PerformHttpRequest(DiscordWebHook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

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
