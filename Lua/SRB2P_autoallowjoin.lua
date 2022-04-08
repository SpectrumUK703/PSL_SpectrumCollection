if not (srb2p and reapertimers)
	print("This addon is intended for SRB2P V1.3.3 or later.")
	return
end

//The one thing I'll make optional but have default to non-vanilla behaviour, because dungeons desynch so much
//Actually, since I've fixed two of the main causes of desynchs, this will default to vanilla behaviour too.
if CV_FindVar("autoallowjoin") then return end
local autoallowjoin = CV_RegisterVar({
	name = "autoallowjoin",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	possiblevalue = CV_OnOff
})

addHook("MapLoad", function(mapnum)
	if not (server and netgame) then return end
	if autoallowjoin.value == 1
		if mapnum == 1 //and server.allowjoin ~= 1
			//print("Turning joins on.")
			COM_BufInsertText(server, "allowjoin on")
			//server.allowjoin = 1
		elseif mapnum ~= 3 //and server.allowjoin ~= 0
			//print("Turning joins off.")
			COM_BufInsertText(server, "allowjoin off")
			//server.allowjoin = 0
		end
	//else
		//server.allowjoin = nil
	end
end)

//Nah, this was a bad idea
/*addHook("ThinkFrame", function()
	if not (server and netgame) then return end
	if autoallowjoin.value == 0
		server.allowjoin = nil
		return
	end
	if (server.gamemode ~= GM_COOP and server.gamemode ~= GM_VOIDRUN) then return end //leave joins on during PVP and Vision Quest
	if server.entrycard and server.entrytime //Floor transition, turn joins off
		if server.allowjoin ~= 0
			//print("Turning joins off.")
			COM_BufInsertText(server, "allowjoin off")
			server.allowjoin = 0
		end
		return
	end
	for p in players.iterate
		local btl = server.P_BattleStatus[p.P_party]
		if btl and btl.running //Someone's in a battle, turn joins off
			if server.allowjoin ~= 0
				//print("Turning joins off.")
				COM_BufInsertText(server, "allowjoin off")
				server.allowjoin = 0
			end
			return
		end
	end
	if server.allowjoin ~= 1
		//print("Turning joins on.")
		COM_BufInsertText(server, "allowjoin on")
		server.allowjoin = 1
	end
end)*/