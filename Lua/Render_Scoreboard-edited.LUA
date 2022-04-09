hud.disable("rankings")

local function drawPlayerInfo(v, p, showhp, ypos)
	if not (p.valid and p.mo) then return end
	local ico = charStats[p.mo.skin] and charStats[p.mo.skin].icon or charStats["sonic"].icon //If the character doesn't have SRB2P support, use Sonic's icon
			
	-- get ping
	local ping = SRB2P_getPing(#p)
	if not #p
		V_drawString(v, 4, ypos, "\x82".."HOST", "NFNT", 0, V_SNAPTOLEFT, 0, 31)
	else
		if ping > 127
			if ping < 255
				ping = "\x82"..$
			else
				ping = "\x85"..$
			end
		end	
		V_drawString(v, 4, ypos, ping.."ms", "NFNT", 0, V_SNAPTOLEFT, 0, 31)
	end
			
	
	PDraw(v, 38, ypos, v.cachePatch(ico), V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, p.mo.color))
	V_drawString(v, 50, ypos, p.name, "NFNT", 0, V_SNAPTOLEFT, 0, 31)
	
	if showhp
		
		if server.gamemode == GM_PVP and p.P_party ~= consoleplayer.P_party return end	-- don't cheat :)
		
		local control = p.maincontrol
		if not control or not control.valid return end
		
		local str = "HP: "..control.hp.."/"..control.maxhp
		V_drawString(v, 128, ypos, str, "NFNT", 0, V_SNAPTOLEFT, 135, 31)
		local str2 = "SP: "..control.sp.."/"..control.maxsp
		V_drawString(v, 192, ypos, str2, "NFNT", 0, V_SNAPTOLEFT, 181, 31)
		
	end
end

hud.add(function(v, lp, c)
	
	if not netgame return end	-- Not in singleplayer.
	
	v.fadeScreen(31, 7)
	
	local ypos = 24
	
	if not NET_isset()
		for p in players.iterate do
			
			drawPlayerInfo(v, p, false, ypos)
			
			ypos = $+10
		end
	else
		for i = 1, 4 do
			local drawn
			if server.playerlist[i]
				for j = 1, server.P_netstat.teamlen do
					
					if server.playerlist[i][j]
						drawPlayerInfo(v, server.playerlist[i][j], true, ypos)
						ypos = $+10
						drawn = true
					end
				end
			end
			
			if drawn
				v.drawFill(0, ypos, 999, 1, 135)
			end
			ypos = $+10
		end
	end
end, "scores")