ESX               = nil
local ItemsLabels = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('onMySQLReady', function()

	MySQL.Async.fetchAll(
		'SELECT * FROM items',
		{},
		function(result)

			for i=1, #result, 1 do
				ItemsLabels[result[i].name] = result[i].label
			end--

		end
	)

end)

ESX.RegisterServerCallback('esx_shop:requestDBItems', function(source, cb)

	MySQL.Async.fetchAll(
		'SELECT * FROM shops',
		{},
		function(result)

			local shopItems  = {}

			for i=1, #result, 1 do

				if shopItems[result[i].name] == nil then
					shopItems[result[i].name] = {}
				end

				table.insert(shopItems[result[i].name], {
					name  = result[i].item,
					price = result[i].price,
					label = ItemsLabels[result[i].item]
				})

			end

			cb(shopItems)

		end
	)

end)

RegisterServerEvent('esx_shop:buyItem')
AddEventHandler('esx_shop:buyItem', function(itemName, price)

	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)
	local targetItem = xPlayer.getInventoryItem(itemName)

	if targetItem.limit ~= -1 and (targetItem.count + 1) > targetItem.limit then
	    TriggerClientEvent('esx:showNotification', source, "You have reached the maximum limit of the item.")
	else
		if xPlayer.get('money') >= price then
			xPlayer.removeMoney(price)
			xPlayer.addInventoryItem(itemName, 1)

			TriggerClientEvent('esx:showNotification', _source, _U('bought') .. ItemsLabels[itemName])

		else
			TriggerClientEvent('esx:showNotification', _source, _U('not_enough'))
		end
	end
end)

RegisterServerEvent('esx_shop:buyIllegalItem')
AddEventHandler('esx_shop:buyIllegalItem', function(itemName, price)

	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)
	local account = xPlayer.getAccount('black_money')
	local targetItem = xPlayer.getInventoryItem(itemName)

	if targetItem.limit ~= -1 and (targetItem.count + 1) > targetItem.limit then
	    TriggerClientEvent('esx:showNotification', source, "You have reached the maximum limit of the item.")
	else
		if account.money >= price then
			xPlayer.removeAccountMoney('black_money', price)
			xPlayer.addInventoryItem(itemName, 1)

			TriggerClientEvent('esx:showNotification', _source, _U('bought') .. ItemsLabels[itemName])

		else
			TriggerClientEvent('esx:showNotification', _source, _U('not_enough'))
		end
	end

end)