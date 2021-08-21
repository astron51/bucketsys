local instances = {}

function CreateBucket(source)
    -- Looking for empty bucket world
    local instanceSource = math.random(1, 62)
    while instances[instanceSource] and #instances[instanceSource] >= 1 do
        instanceSource = math.random(1, 62)
        Citizen.Wait(1)
    end
    -- Found empty bucket world, adding to Server List for later use
    if instanceSource ~= 0 then
        if not instances[instanceSource] then
            instances[instanceSource] = {
                host = source,
                players = {} -- Player inside bucket, needed for management
            }
        end
    end
    SetPlayerRoutingBucket(source, instanceSource) -- Transfer Player Into Bucket upon creation
end

function CloseBucket(bucketID)
    if instances[bucketID] then
        SetPlayerRoutingBucket(instances[bucketID].host, 0) -- Remove host from the bucket while closing
        for i=1, #instances[bucketID].players do
            SetPlayerRoutingBucket(instances[bucketID].players[i], 0) -- Remove player inside the bucket being close, teleport handle by the script using this
		end
        instances[bucketID] = nil
    else
        print('Error on closing Virtual World : ' .. bucketID)
    end
end

RegisterServerEvent('bucketsys:create')
AddEventHandler('bucketsys:create', function()
	CreateBucket(source)
end)

RegisterServerEvent('bucketsys:close')
AddEventHandler('bucketsys:close', function(bucketID)
	CloseBucket(bucketID)
end)

RegisterServerEvent('bucketsys:join')
AddEventHandler('bucketsys:join', function(bucketID)
    table.insert(instances[bucketID].players, source)
    SetPlayerRoutingBucket(source, bucketID) -- Transfer Player Into Bucket 
    TriggerClientEvent('bucketsys:onEnter', source, instances[bucketID])
end)

RegisterServerEvent('bucketsys:leave')
AddEventHandler('bucketsys:leave', function()
    local hostRBID = GetPlayerRoutingBucket(source)
    -- Do a host Check
    if instances[hostRBID].host == source then
        CloseBucket(hostRBID)
        return
    end
    for i=1, #instances[hostRBID].players do
        if instances[hostRBID].players[i] == source then
            table.remove(instances[hostRBID].players, i)
        end
    end
    SetPlayerRoutingBucket(source, 0) -- Transfer Player out from bucket
end)

RegisterServerEvent('bucketsys:invite')
AddEventHandler('bucketsys:invite', function(target)
	local hostRBID = GetPlayerRoutingBucket(source)
    if instances[hostRBID] then
        TriggerClientEvent('bucketsys:onInvite', target, source, hostRBID)
    else
        print('~r~Error : World does not exist.')
    end
end)

RegisterServerEvent('bucketsys:estop')
AddEventHandler('bucketsys:estop', function()
    SetPlayerRoutingBucket(source, 0) -- Transfer Player out from bucket
end)