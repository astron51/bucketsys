ShowHelpNotification = function(msg, thisFrame, beep, duration)
    AddTextEntry('bucketNotify', msg)

    if thisFrame then
        DisplayHelpTextThisFrame('bucketNotify', false)
    else
        BeginTextCommandDisplayHelp('bucketNotify')
        EndTextCommandDisplayHelp(0, false, beep, duration or -1)
    end
end

AddEventHandler('bucketsys:invite', function(target)
	TriggerServerEvent('bucketsys:invite', target)
end)

AddEventHandler('bucketsys:leave', function()
	TriggerServerEvent('bucketsys:leave')
end)

RegisterNetEvent('bucketsys:onInvite')
AddEventHandler('bucketsys:onInvite', function(host, bucketid)
	local instanceInvite = {
		host = host,
		bid = bucketid
	}
	Citizen.CreateThread(function()
		while instanceInvite do
            -- Add Player online check
			Citizen.Wait(0)
			ShowHelpNotification('Press E to Enter') -- Press E to accept to invite.
			if IsControlJustReleased(0, 38) then
				TriggerServerEvent('bucketsys:join', instanceInvite.bid)
				ShowHelpNotification('You joined the session.') -- Entered Instance.
				instanceInvite = nil
			end
		end
	end)
	
	Citizen.CreateThread(function()
		-- Controls for invite
		Citizen.Wait(10000)
		if instanceInvite then
			ShowHelpNotification('Invite Expired') -- Invite has expired.
			instanceInvite = nil
		end
	end)
end)

RegisterCommand("startBucket", function(source, args, rawCommand)
    TriggerServerEvent('bucketsys:create')
end, false)

RegisterCommand("inviteBucket", function(source, args, rawCommand)
    TriggerEvent('bucketsys:invite', args[1])
end,false)

RegisterCommand("leavebucket", function(source, args, rawCommand)
    TriggerServerEvent('bucketsys:leave')
end,false)
