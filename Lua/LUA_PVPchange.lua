enemyList["maya_boss_monad"].pvplevel = 98 //Level 2 my ass

//Important
local function NET_exitready(n)
	G_SetCustomExitVars(n, 1)
end

//Important
-- do net loading
local function NET_load()
	local net = server.P_netstat
	local plist = net.playerlist
	local h = server.netgamefile
	local skinlist = h.playerlist
	local nteams = 0

	for i = 1, #skinlist
		if skinlist[i] and #skinlist[i]
			nteams = $+1
			for j = 1, #skinlist[i]
				net.skinlist[i][j] = skinlist[i][j].skin
			end
		end
	end

	-- count how many players are ready
	local count = 0
	local ready = 0
	for p in players.iterate do
		if not p.mo continue end
		count = $+1
		if p.mo.P_net_ready
			ready = $+1
		end
	end

	local allready = ready >= count

	for p in players.iterate do

		PLAY_nomove(p)

		local mo = p.mo
		if not mo return end
		local inpt = mo.P_inputs

		mo.P_net_skinselect = $ or 0

		-- get our position on the fake """grid"""
		local hpos = (mo.P_net_skinselect / h.teamlen)+1
		local vpos = (mo.P_net_skinselect % h.teamlen)+1

		if inpt["down"] == 1
		and not mo.P_net_ready
			S_StartSound(nil, sfx_hover, p)
			if vpos < h.teamlen
				mo.P_net_skinselect = $+1
			else
				mo.P_net_skinselect = $ - (h.teamlen-1)
			end

		elseif inpt["up"] == 1
		and not mo.P_net_ready
			S_StartSound(nil, sfx_hover, p)
			if vpos > 1
				mo.P_net_skinselect = $-1
			else
				mo.P_net_skinselect = $ + (h.teamlen-1)
			end

		elseif inpt["left"] == 1
		and nteams > 1
		and not mo.P_net_ready
			S_StartSound(nil, sfx_hover, p)
			if hpos > 1
				mo.P_net_skinselect = $-(h.teamlen)
			else
				mo.P_net_skinselect = $ + (h.teamlen)*(nteams-1)
			end

		elseif inpt["right"] == 1
		and nteams > 1
		and not mo.P_net_ready
			S_StartSound(nil, sfx_hover, p)
			if hpos < nteams
				mo.P_net_skinselect = $+(h.teamlen)
			else
				mo.P_net_skinselect = $ - (h.teamlen)*(nteams-1)
			end
		elseif inpt[BT_BTNA] == 1
			if not mo.P_net_ready

				-- check if there's already someone in that spot
				if plist[hpos][vpos] and plist[hpos][vpos].valid	-- and they're valid...
					S_StartSound(nil, sfx_not, p)	-- nop
					continue
				end

				-- otherwise, apply!
				plist[hpos][vpos] = p
				mo.P_net_ready = true
				S_StartSound(nil, sfx_select, p)

			elseif p == server
			and allready
				NET_startgame()
			end

		elseif inpt[BT_BTNB] == 1

			if mo.P_net_ready	-- undo your selection
				plist[hpos][vpos] = nil
				mo.P_net_ready = nil
				S_StartSound(nil, sfx_cancel, p)
			elseif p == server	-- not cancelling ready status and server? you end the selection.
				NET_end(true)	-- cancel net selection
			end
		end
	end
end

//Important
local function NET_team_bossselect(p)
	local bosses = server.bosslist
	local mo = p.mo
	local inpt = mo.P_inputs
	
	p.bossselect = $ or #bosses
	
	-- the launch prompt:
	if mo.P_net_launchprompt
		if inpt[BT_JUMP] == 1	-- yeah let's go
			-- this is where we begin the game
			NET_startgame()
		end
		return
	end	
	
	if not p.confirmboss
	
		if inpt["left"] == 1
			S_StartSound(nil, sfx_turn, p)
			p.bossselect = $-1 
			if p.bossselect < 1
				p.bossselect = #bosses
			end
			
		elseif inpt["right"] == 1
			S_StartSound(nil, sfx_turn, p)
			p.bossselect = $+1
			if p.bossselect > #bosses
				p.bossselect = 1
			end
			
		elseif inpt[BT_BTNA] == 1
			S_StartSound(nil, sfx_confir, p)
			p.confirmboss = 1
		end
	elseif p.confirmboss == 1	-- prompt confirmation
		
		if inpt[BT_BTNA] == 1
			mo.P_net_ready = true	-- we good
			S_StartSound(nil, sfx_confir, p)
			server.bosslevel = enemyList[bosses[p.bossselect]].pvplevel or enemyList[bosses[p.bossselect]].level
			p.confirmboss = 2
		elseif inpt[BT_BTNB] == 1
			S_StartSound(nil, sfx_cancel, p)
			p.confirmboss = nil
		end	
	end
	
end

//Important
local function NET_team_skinselect(p)
	local net = server.P_netstat
	local minskin = 0
	local maxskin = 0
	for i = 0, 31
		if skins[i] and skins[i].valid
			maxskin = i
		else
			break	-- skins are a normal list, so as soon as one is invalid, all the others are too
		end
	end

	local nostack = net.buffer.nostack	-- No stacking skins!
	--print(nostack)


	local mo = p.mo
	if not mo return end

	local inpt = mo.P_inputs
	local party = net.playerlist[p.P_party]

	-- figure out where in the party i am
	local myindex
	for i = 1, #party
		if party[i] == p
			myindex = i
			break
		end
	end

	mo.P_net_selectindex = $ or myindex

	if mo.P_net_skinselect == nil
		for i = 0, 31 do
			if skins[i].name == mo.skin
				mo.P_net_skinselect = i
				break
			end
		end
	end
	mo.P_net_skinselect = $ or 0

	-- check if we're trying to select a skin a player is going to take:
	local ind = mo.P_net_selectindex
	if party[ind] and party[ind].valid and party[ind] ~= p	-- no we don't count lol
		-- try to find a skin to set, otherwise ready up
		for i = mo.P_net_selectindex+1, net.teamlen
			if i > net.teamlen
				break
			end

			if not party[i]
				mo.P_net_selectindex = i
				dprint("Now setting skin "..i)
				break
			end
		end

		if mo.P_net_selectindex == ind	-- yikes!
			mo.P_net_ready = true
		end
	end

	-- the launch prompt:
	if mo.P_net_launchprompt
		if inpt[BT_JUMP] == 1	-- yeah let's go
			-- this is where we begin the game
			NET_startgame()
			return
		end
		-- pressing BT_USE will undo our last skin selection as expected, handled in the code below :P
	end

	-- handle skin selection

	if inpt["left"] == 1
		mo.P_net_skinselect = $-1
		S_StartSound(nil, sfx_hover, p)

		if mo.P_net_skinselect < 0
			mo.P_net_skinselect = maxskin
		end

		while (not P_netUnlockedCharacter(mo.player, skins[mo.P_net_skinselect].name))
			mo.P_net_skinselect = $-1

			if mo.P_net_skinselect < 0
				mo.P_net_skinselect = maxskin
			end
		end

	elseif inpt["right"] == 1
		mo.P_net_skinselect = $+1
		S_StartSound(nil, sfx_hover, p)

		if mo.P_net_skinselect > maxskin
			mo.P_net_skinselect = 0
		end

		while (not P_netUnlockedCharacter(mo.player, skins[mo.P_net_skinselect].name))
			mo.P_net_skinselect = $+1

			if mo.P_net_skinselect > maxskin
				mo.P_net_skinselect = 0
			end
		end

	elseif inpt[BT_JUMP] == 1
	and not mo.P_net_ready

		-- check if this skin CAN be selected:
		local s = skins[mo.P_net_skinselect].name

		if nostack
			for i = 1, 4
				if net.skinlist[p.P_party][i] == s
					S_StartSound(nil, sfx_not, p)
					return
					-- No skin stacking if this is on!
				end
			end
		end

		-- lock on to this skin:

		if not p.P_teamleader or mo.P_net_selectindex >= net.teamlen
			mo.P_net_ready = true
		end

		net.skinlist[p.P_party][mo.P_net_selectindex] = s
		S_StartSound(nil, sfx_confir, p)

		if p.P_teamleader
			-- do we need to check another skin......??
			for i = mo.P_net_selectindex+1, net.teamlen+1
				if i > net.teamlen
					mo.P_net_ready = true	-- then there's nothing to set, huh!
					dprint("Partyleader ready")
					break
				end


				if not party[i]
					mo.P_net_selectindex = i
					dprint("Now setting skin "..i)
					break
				end
			end
		end

	elseif inpt[BT_USE] == 1
	and (p.P_teamleader or mo.P_net_ready)

		if mo.P_net_ready
			mo.P_net_ready = nil
			mo.P_net_launchprompt = nil
			S_StartSound(nil, sfx_cancel, p)
			net.skinlist[p.P_party][mo.P_net_selectindex] = nil
			return
		end

		-- can we go back?
		local goback = mo.P_net_selectindex
		if goback <= 1
			if p.P_teamleader and p.P_party == 1
				NET_end(true)
			end
			return
		end

		if p.P_teamleader
			goback = $-1
		end

		while goback

			if not party[goback]
			or party[goback] == p	-- yeah it's fine if it's moi~
				net.skinlist[p.P_party][mo.P_net_selectindex] = nil
				net.skinlist[p.P_party][goback] = nil
 				mo.P_net_selectindex = goback
				S_StartSound(nil, sfx_cancel, p)
				return
			end
			goback = $-1
		end
		S_StartSound(nil, sfx_not, p)
	end
end

//Important
local function NET_teamselect()
	local nump = 0
	local ready = 0
	local validpnums = {}
	local netstat = server.P_netstat
	local firstp

	local count = 0

	for p in players.iterate do
		if p.mo and p.mo.valid

			count = $+1

			firstp = $ or p

			PLAY_nomove(p)	-- disable cmd
			nump = $+1

			if not p.P_party
				validpnums[#validpnums+1] = #p
			end

			if p.mo.P_net_ready
				ready = $+1
			end
		end
	end

	-- Cancel the gamemode / party selection if we have too many players!!
	if netstat.buffer and netstat.buffer.maxparties
		--dprint(count.."/"..(netstat.buffer.maxparties*4))
		if count > netstat.buffer.maxparties*4
			chatprint("\x82".."*Max # of players for the gamemode reached! ("..(netstat.buffer.maxparties*4)..")")
			NET_end(true)
			return
		end
	end

	if ready >= nump	-- everyone is ready
		firstp.mo.P_net_launchprompt = true
	else	-- dynamically check for new joiners
		firstp.mo.P_net_launchprompt = nil
	end

	-- determine how many leaders we NEED (we COULD have more than that.)
	local numteams
	local gamemode = netstat.buffer.gamemode

	if gamemode == GM_PVP
		-- how many players per team do we allow...?
		server.P_netstat.teamlen = 4 -- nump/2 + (nump%2 and 1 or 0)	-- split players in half (add 1 for .5 player ofc)
		numteams = 2	-- always.

		if nump > 8	-- there is an issue (for now.)
			return
		end
	else
		numteams = nump/4 +((nump%4) and 1 or 0)
	end
	
	if server.bossmode
		numteams = 0	-- leaders are automatically assigned
	end	

	while numteams
		if netstat.leaders[numteams]
		and netstat.leaders[numteams].valid
			-- avoid validity errors...
		else

			dprint("Assigning leader for team "..numteams)

			if numteams == 1	-- p1 takes the spot, always
				netstat.leaders[numteams] = players[validpnums[1]]
				-- we needn't worry about removing that one
			else
				local k = P_RandomRange(1, #validpnums)
				netstat.leaders[numteams] = players[validpnums[k]]
				table.remove(validpnums, k)	-- don't make this player the leader of 2 teams obv
			end
			server.P_netstat.leaders[numteams].P_teamleader = true	-- set as team leader (mostly used as reference for the game)
			server.P_netstat.leaders[numteams].P_party = numteams	-- assign to party
			server.P_netstat.playerlist[numteams][1] = server.P_netstat.leaders[numteams]
			server.P_netstat.leaders[numteams].mo.P_net_selectindex = 1
			chatprint("\x82*"..netstat.leaders[numteams].name.." was assigned leader of team "..numteams)
		end

		numteams = $-1
	end
	-- technically speaking, if there's only one team we don't need this screen at all!

	-- party cleansing etc:
	for i = 1, #server.P_netstat.playerlist
		local j = #server.P_netstat.playerlist[i]

		while j
			if not (server.P_netstat.playerlist[i][j] and server.P_netstat.playerlist[i][j].valid)
				table.remove(server.P_netstat.playerlist[i], j)
				-- if the leader is invalid for this team, cleanse the skin data from it as well.
				server.skinlist[i] = {}
				-- all players from this team should be made un-ready as well.
				for k = 1, #server.P_netstat.playerlist[i]
					server.P_netstat.playerlist[i][k].mo.P_net_ready = nil
					-- we must also reattribute a selectindex to EACH OF THEM
					server.P_netstat.playerlist[i][k].mo.P_net_selectindex = k -- luckily, it's 'k'
					dprint("Player left, reseting team status to ensure net-safety.")

					-- another issue...;
					if k > server.P_netstat.teamlen
						table.remove(server.P_netstat.playerlist[i], k)
						dprint("Removed player "..k.." from team "..i.." to ensure team balance.")
					end
				end
			end

			if j == 1
			and server.P_netstat.playerlist[i][j]
			and server.P_netstat.playerlist[i][j].valid

				if not server.P_netstat.playerlist[i][j].P_teamleader
					server.P_netstat.playerlist[i][j].P_teamleader = true
					server.P_netstat.leaders[i] = server.P_netstat.playerlist[i][j]
				end
			end
			j = $-1
		end
	end

	-- leader cleansing:
	local i = 4
	while i
		-- if the leader doen't exist, make it nil
		if not (server.P_netstat.leaders[i] and server.P_netstat.leaders[i].valid)
			server.P_netstat.leaders[i] = nil
			--dprint("Removed leader data from team "..i)
		end
		i = $-1
	end

	-- now it's a per player case...
	for p in players.iterate do

		local mo = p.mo
		if not mo continue end
		if mo.P_net_teamstate == 2
			if p.tempboss
				NET_team_bossselect(p)
			else	
				NET_team_skinselect(p)
			end	
			continue
		end
		local inpt = mo.P_inputs

		if p.P_teamleader
			mo.P_net_teamstate = 2	-- consider things as if we had selected.
			continue
		end

		mo.P_net_teamstate = $ or 0
		mo.P_net_teamchoice = $ or 1

		-- else, we aren't a team leader

		-- teamstate 0, select our team
		if not mo.P_net_teamstate
			local maxc = min(4, #netstat.leaders)

			if server.P_netstat.buffer
			and server.P_netstat.buffer.gamemode == GM_COOP
				maxc = $+1
			end		-- +1 choice in coop for Party Creation.

			-- in case players leave and teams need to be undone...
			mo.P_net_teamchoice = min($, maxc)

			if inpt["down"] == 1
				S_StartSound(nil, sfx_hover, p)
				-- make sure this team exists...
				mo.P_net_teamchoice = $+1
				if mo.P_net_teamchoice > maxc
					mo.P_net_teamchoice = 1
				end
				while not netstat.playerlist[mo.P_net_teamchoice]
					mo.P_net_teamchoice = $+1
					if mo.P_net_teamchoice > maxc
						mo.P_net_teamchoice = 1
						break
					end
				end
			elseif inpt["up"] == 1
				S_StartSound(nil, sfx_hover, p)
				mo.P_net_teamchoice = $-1
				if mo.P_net_teamchoice < 1
					mo.P_net_teamchoice = maxc
				end
				while not netstat.playerlist[mo.P_net_teamchoice]
					mo.P_net_teamchoice = $-1
					if mo.P_net_teamchoice < 0
						mo.P_net_teamchoice = maxc
						break
					end
				end

			elseif inpt[BT_JUMP] == 1

				local team = netstat.playerlist[mo.P_net_teamchoice]

				if team and #team >= netstat.teamlen	-- team not valid means the new party choice
					S_StartSound(nil, sfx_not, p)
					continue
				end

				if not #team
					mo.P_net_createparty = true
				end

				S_StartSound(nil, sfx_confir, p)
				mo.P_net_teamstate = 1	-- confirm?
			end


		-- ask for confirmation
		elseif mo.P_net_teamstate == 1

			-- check if team exists each frame, if it doesn't anymore, yeet tf outta here

			if not mo.P_net_createparty
				if not netstat.leaders[mo.P_net_teamchoice]
					mo.P_net_teamchoice = 1
					mo.P_net_teamstate = 0
					mo.P_net_createparty = nil
					continue
				end

				local team = netstat.playerlist[mo.P_net_teamchoice]
				if #team >= 4
					S_StartSound(nil, sfx_not, p)
					mo.P_net_teamstate = 0
					continue
				end
			else
				-- check if we CAN create a party in that case...
				if #netstat.leaders >= 4
					S_StartSound(nil, sfx_not, p)
					mo.P_net_teamstate = 0
					continue
				end
			end

			if inpt[BT_JUMP] == 1
				-- yes mom i wanna be there
				S_StartSound(nil, sfx_confir, p)

				if mo.P_net_createparty
					-- tell you what i wanna make my OWN TEAM!!!
					local firstinvalid
					for i = 1, 4
						if not netstat.leaders[i]
							firstinvalid = i
							break
						end
					end

					if not firstinvalid	-- soz
						S_StartSound(nil, sfx_not, p)
						chatprintf(p, "\x82*No more parties can be made, maximum reached (4)")
						mo.P_net_teamstate = 0
						continue
					end

					-- otherwise, make my OWN team!
					netstat.leaders[firstinvalid] = p
					p.P_teamleader = true	-- set as team leader (mostly used as reference for the game)
					p.P_party = firstinvalid	-- assign to party
					netstat.playerlist[firstinvalid][1] = p
					chatprint("\x82*"..p.name.." created a party.")
					mo.P_net_createparty = nil
					continue
				end

				chatprint("\x82*"..p.name.." joined team "..mo.P_net_teamchoice)
				p.P_party = mo.P_net_teamchoice
				table.insert(netstat.playerlist[mo.P_net_teamchoice], p)
				mo.P_net_teamstate = 2
				local myindex = 0
				for i = 1, netstat.teamlen
					if netstat.playerlist[mo.P_net_teamchoice][i] == p
						myindex = i
						break
					end
				end
				mo.P_net_selectindex = myindex

			elseif inpt[BT_USE] == 1
				S_StartSound(nil, sfx_confir, p)
				mo.P_net_teamstate = 0
			end
		end
	end

	local pready = 0
	for p in players.iterate
		if p.P_net_team
			pready = $+1
		end
	end

	--if pready >= nump
	--	dprint("thighs")
	--	NET_setstate(NET_SKINSELECT)
	--end
end

//Important
local state_2_func = {
	[NET_TEAMSELECT] = NET_teamselect,
	[NET_SKINSELECT] = NET_teamselect,
	[NET_PVP_SKINSELECT] = NET_skinselect,
	[NET_PVP_TEAMSELECT] = NET_pvpteam,
	[NET_LOAD] = NET_load
}

//Important
-- handle character selection
--addHook("ThinkFrame", do
rawset(_G, "NET_Lobby", function()
	if not netgame
	and server
	and not server.skinlist
		-- quick intialization
		--server.skinlist = {{"sonic"}}
	end

	if not NET_isset()
	and gamemap ~= srb2p.tartarus_map
	and leveltime == 3	-- oddly specific, I know, but this guarantees the mapchange only happens once.
	and netgame			-- Only pull this weird stunt in netgames!
		NET_exitready(srb2p.tartarus_map, true)
		G_ExitLevel()
		return
	end

	if not NET_running() return end

	if state_2_func[server.P_netstat.netstate]
		state_2_func[server.P_netstat.netstate]()
	end
end)