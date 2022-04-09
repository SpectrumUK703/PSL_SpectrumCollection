if CV_FindVar("showreapertimer") then return end
local showreapertimer = CV_RegisterVar({
	name = "showreapertimer",
	defaultvalue = "On",
	flags = 0,
	possiblevalue = CV_OnOff
})


hud.add(function(v, p) //Most of this is copied from SRB2P's code

	if server.gamemode ~= GM_COOP return end	//No reaper timer outside of Co-op
	if server.entrycard and server.entrytime then return end //Don't show the timer during the entrycard screen
	local mo = p.mo
	local menutimers = mo.m_hudtimers
	local menutimer = (menutimers and (menutimers.smenuopen and (TICRATE/3 - menutimers.smenuopen) or menutimers.sclosemenu or 10)) or 10

	local dng = server.P_DungeonStatus
	local btl = server.P_BattleStatus and server.P_BattleStatus[p.P_party]
	local evt = server.P_DialogueStatus and server.P_DialogueStatus[p.P_party]

	local bx, by = 30, 16
	if mo and ((btl and btl.running) 
	or (evt and (evt.event or evt.running))
	or not (renderMenus(v,mo) or R_drawShop(v, mo) or R_drawEquipLab(v, mo)))
		by = min(-64 + menutimer*8, 16) //Slide it in when the menu is closed, or when we're in a battle or event
	else
		by = max(16 - menutimer*8, -64) //Slide it out when the menu is opened
	end
	local time = dng.reapertimer
	if time ~= nil
		local timer
		timer = ((time >= 1) and time) or ($ and $-1 or 34) //Always non-negative, the clock gets weird with negative times
		if showreapertimer.value == 1
			if not (dng.noreaper) and (reapertimers or (cv_reaper and cv_reaper.value))
				drawTimeClock(v, bx, by, timer, 60*TICRATE) //SRB2P's clock drawing function
			else
				drawTimeClock(v, bx, by, nil, 60*TICRATE) //Show a nil timer on boss floors or if the reaper is disabled
			end
		end
	elseif showreapertimer.value == 1
		drawTimeClock(v, bx, by, nil, 60*TICRATE) //Show a nil timer
	end
end)
