//Honestly, this started as a Rogue mode edit for another purpose, but now it's mostly fixes lmao
-- This script contains function that's able to generate rogue enemies

local t, x, y, z, w

local function R_Random()
	t = x ^^ (x << 11)
	x, y, z, w = y, z, w, w ^^ (w >> 19) ^^ t ^^ (t >> 8)
	return w
end

local function R_RandomRange(a, b)
	return a + abs(R_Random() % (b - a + 1))
end

-- takes an enemyList element, and creates a new enemy from it!
-- to be used when generating enemy waves when we set a floor!

-- In normal rogue mode, enemies get a fixed 10% HP buff.
-- In Marathon, the HP buff is variable depending on how far you've come so that enemies aren't complete pushovers due to your snowball effect.

local marathon_hp_multipliers = {
	100,	-- B1: No buff
	110,	-- B2: 110%
	115,	-- B3: 115%
	120,	-- B4: 120%
	125,	-- B5: 125%
	130,	-- B6: 130%
	130,	-- B7: 130%
}

//I think I've fixed two major desynchs now??
local enemiesrogued = {}
local needresynching

addHook("NetVars", function(net)
	enemiesrogued = net($)
	needresynching = true
end)

rawset(_G, "ROGUE_initEnemyStats", function(ename)
	dprint("Attempting roguegen on "..ename)
	local e = enemyList[ename]

	if enemyList[ename] and enemyList[ename].original
		return ename
	end

	-- enemy was already generated for this session.
	if enemyList[ename.."__roguemode"]
		return ename.."__roguemode"
	end

	if not e return end	-- bruh.

	-- copy the table into a new one
	local cpy = {}
	for k,v in pairs(e)
		cpy[k] = e[k]
	end
	cpy.original = ename

	-- the important part now is shuffling affinities from the random seed
	-- First, build our unique enemy seed from the enemy's name:
	local enemyseed = server.rogueseed
	local shufflename = cpy.shufflename or cpy.name //The one change here that isn't a fix
	for i = 1, #shufflename
		local c = shufflename:sub(i, i)
		enemyseed = $ + c:byte()	-- get the ascii code of the given character
	end
	enemyseed = $ % FRACUNIT		-- make sure it stays between 0 and 65535

	-- ready RNG numbers:
	t, x, y, z, w = 0, enemyseed, enemyseed/2, enemyseed/3, enemyseed/4

	if not cpy.noroguerandom

		local affs = {}
		local aff_max = 10

		for i = 0, aff_max	-- the 11 affinities
			affs[i+1] = 2^i
		end
		-- shuffle that table of affinities

		local shuffled = {}
		while #affs
			local pos = R_RandomRange(1, #affs)
			shuffled[#shuffled+1] = affs[pos]
			table.remove(affs, pos)
		end
		affs = nil

		-- now we have shuffled which is a shuffled version of affs, we can then create a lookup table:
		local aff_lookup = {}
		for i = 0, 10
			aff_lookup[2^i] = shuffled[i+1]
		end


		-- now shuffle enemy affinities:
		local affs = {"weak", "resist", "block", "repel", "drain"}

		for i = 1, #affs do
			local aff = affs[i]
			local newaff = 0
			-- oh boy
			if e[aff]
				dprint("Setting new value for "..aff)
				for j = 0, 10 do

					if e[aff] & (2^j)	-- add the affinity from the
						newaff = $| (aff_lookup[e[aff] & (2^j)])
					end
				end

				cpy[aff] = newaff
			end
		end

		-- Using that same lookup table, change the skills to find the new required elemental skills!
		local newskills = {}
		for i = 1, #e.skills

			local a = attackDefs[e.skills[i]]
			if not a continue end	-- wtf
			dprint("Attempting to change skill "..a.name)

			local atktype = a.type & ~ATK_PASSIVE
			local psv = a.type & ATK_PASSIVE
			local passivetype = a.passive

			if atktype < ATK_FIRE	-- physical attack
			or atktype > ATK_CURSE	-- almighty, support etc
				newskills[#newskills+1] = e.skills[i]
				dprint("Skill type out of range")
				continue	-- ok goodbye asshole
			end

			-- attempt to find a skill with the same power to replace it with.
			-- this is basically intended for use with the basic elemental attacks!

			local targettype = aff_lookup[atktype]
			local found
			for k, p in pairs(attackDefs)	-- yepppppppppppppp

				if p.type and (p.type & ~ATK_PASSIVE) == targettype
				and p.power == a.power
				and p.passive == passivetype
				and a.target == p.target
				and a.instakill == p.instakill
				and (a.hits or 0) == (p.hits or 0)
				and not p.physical	-- LOL //LOL
					newskills[#newskills+1] = k
					dprint("Found skill "..k)
					found = true
					break
				end
			end

			if not found
				newskills[#newskills+1] = e.skills[i]	-- keep the original skill
				continue
			end
		end
		
		cpy.skills = newskills
	end	

	-- make em stronger!!
	cpy.level = $+5	-- (this is only visual)
	if not cpy.noroguebuff
		
		local mult = 110
		if server.marathon
			mult = marathon_hp_multipliers[server.difficulty]	-- fallback just in case
		end
		
		local prevhp = cpy.hp
		cpy.hp = $*mult/100
		cpy.sp = $*400/100
		cpy.strength = $*115/100
		cpy.magic = $*115/100
		cpy.agility = $*115/100
		cpy.endurance = $*115/100
		cpy.luck = $*115/100
	end
	

	-- and finally, add us to the enemy list... dear god that sucked.
	enemyList[ename.."__roguemode"] = cpy
	table.insert(enemiesrogued, ename)

	-- wow, we're done!
	return ename.."__roguemode"	-- yes this is stupid.
end)

-- removes every enemy that has "__roguemode" in its name specifically.
-- don't name your enemies like that, dumbass.
rawset(_G, "ROGUE_reset", function()
	for k, p in pairs(enemyList)

		if k:find("__roguemode")
			enemyList[k] = nil
			continue
		end
	end
	enemiesrogued = {} //resets the rogued enemies table
end)

--addHook("ThinkFrame", do
rawset(_G, "NET_Synch", function()

	-- local checks:
	local dskin = CV_FindVar("defaultskin")
	if charStats[skins[dskin.value].name]
	and not P_unlockedCharacter(skins[dskin.value].name)
		COM_ImmedExecute("defaultskin 0")
		COM_ImmedExecute("skin 0")	-- fuck you
	end

	-- local checks (2)
	dskin = CV_FindVar("skin")
	if charStats[skins[dskin.value].name]
	and not P_unlockedCharacter(skins[dskin.value].name)
		COM_ImmedExecute("skin 0")	-- fuck you
	end

	-- local checks (3)
	if CHEAT
		COM_ImmedExecute("__&cheat "..CHEAT)
		CHEAT = 0
	end

	-- don't use characters we shouldn't be able to use!!

	if not server return end	-- titlemap
	if not netgame return end	-- No need for all that synching BS in singleplayer
	local proceed

	if consoleplayer and consoleplayer.valid
		if not consoleplayer.setunlocks
			for i = 1, 99
				if srb2p.local_conds[i]
					COM_ImmedExecute("__&sendunlocks "..i)	-- funny!
					dprint("Sending UCOND '"..i.."' to server...")
				end
			end
			consoleplayer.setunlocks = true	-- warning, clientside spaghetti.
		end
	end


	for p in players.iterate do
		p.synchtimer = $ and $+ 1 or 1
		if p.synchtimer <= 10
			if SYS_systemmenu and SYS_systemmenu.menu == 1	-- wtf!
				SYS_closeMenu()	-- just to be sure as that seems to be a reoccuring issue
			end
			proceed = p
			break
		end
	end

	if not proceed return end

	if not server.P_BattleStatus return end	-- lol

	//print("Player "..proceed.name.." will be synched with the server.")

	if server.curpreset
		DNG_setextradata(tartarus_floors[server.curpreset])	-- reset extra data for skybox
	end
	
	-- No longer required
	/*for f = 1, 4

		local btl = server.P_BattleStatus[f]
		if not btl return end	-- < true if server itself is joining lol

		for i = 1, #btl.fighters
			local mo = btl.fighters[i]
			if not mo or not mo.valid continue end
			NET_synchAttack(mo)
		end
	end*/
	
	//I wonder if this will cause any issues?
	if type(consoleplayer) == "userdata" and consoleplayer and consoleplayer.valid
		local btl
		btl = server.P_BattleStatus and server.P_BattleStatus[consoleplayer.P_party]
		if not S_MusicPlaying()
			if gamemap == 2
				local block = server and server.P_DungeonStatus and server.P_DungeonStatus.floor and DNG_returnBlock(server.P_DungeonStatus.floor)
				COM_BufInsertText(consoleplayer, "tunes "..DNG_getTartarusMusic(block))
				if server.blocktrans
					S_ChangeMusic("BLCKT", false, consoleplayer, nil, nil, MUSICRATE/2)
				end
				if btl and btl.hudtimer and btl.hudtimer.endb
					S_ChangeMusic(MUS_PlayRandomBattleMusic("mus_battle_results"), nil, consoleplayer)
				end
			elseif gamemap == 3
				local music = server.P_BattleStatus[1].music or "BATL1"
				COM_BufInsertText(consoleplayer, "tunes "..music)
			elseif gamemap == 4
				local cdungeonmusic = server.cdungeon and server.cdungeon.dungeonmusic
				COM_BufInsertText(consoleplayer, "tunes "..cdungeonmusic)
				if btl and btl.hudtimer and btl.hudtimer.endb
					S_ChangeMusic(MUS_PlayRandomBattleMusic("mus_battle_results"), nil, consoleplayer)
				end
			end
		end
		if server.gamemode ~= GM_VOIDRUN and (gamemap == 5 or not S_MusicPlaying())
			if btl and btl.running
				local music = btl.music or "BATL1"
				S_ChangeMusic(music, true, consoleplayer)
			end
		end
		if server.gamemode == GM_VOIDRUN
		and server.P_DungeonStatus.VR_timer
			local challengemus = (((server.P_DungeonStatus.VR_challenge-1)/3) +1 )%5
			if not (challengemus%5)
				challengemus = 5
			end
			challengemus = $ or 1
			local cmusic = "VRCH"..challengemus
			COM_BufInsertText(consoleplayer, "tunes "..cmusic)
		end
	end
	
	for i = 1, 4
		local btl = server.P_BattleStatus[i]
		for j = 1, #btl.subpersonas
			local per = btl.subpersonas[j]
			per.ref = subpersonaList[per.int]
		end
	end
	for i=1, #enemiesrogued
		ROGUE_initEnemyStats(enemiesrogued[i])
	end

	-- fix waves in rogue mode if necessary
	if server.roguemode	-- hahahahaha....
	and server.waves
	and #server.waves
	and server.rogueseed
		for i = 1, #server.waves
			for j = 1, #server.waves[i]
				server.waves[i][j] = ROGUE_initEnemyStats($) or $	-- keep the original enemy if we failed to generate the new enemy
			end
		end
	end	
	
end)

-- removes team pn
local function PLYR_removeTeam(pn)

	//#server.playerlist[pn] can sometimes be 0 when the party isn't empty lol
	//if #server.playerlist[pn]
	local plentities = server.plentities[pn]
	local partysize = #plentities
	local count = 0
	for j=1, partysize
		if server.playerlist[pn][j] and server.playerlist[pn][j].valid
			count = $+1
		end
	end
	if count
		dprint("There are still players in team "..pn..", can't remove it!!")
		return
	end	-- uh are you dumb or something?		

	if server.gamemode == GM_PVP //Only one party left, back to the lobby
		SRB2P_killHUD()
		SYS_closeMenu()
		COM_ImmedExecute("map "..G_BuildMapName(srb2p.tartarus_map))
	end
	local i = #server.plentities[pn]
	while i
		local mo = server.plentities[pn][i]
		if mo and mo.valid
			if mo.control and mo.control.valid
				mo.control.control = nil
				mo.control.P_party = 0
			end
			P_RemoveMobj(server.plentities[pn][i])
		end
		i = $-1
	end
	
	local num = 0
	for i=1, 4
		local plist = server.playerlist[i]
		for j=1, partysize
			if plist[j] and plist[j].valid
				num = $+1
				break //There's a player in this party, on to the next one
			end
		end
	end

	if num
		if partysize
			COM_BufInsertText(server, "maxplayers "..(num*partysize))
		else
			COM_BufInsertText(server, "maxplayers "..(num*4))
		end
	end
	server.plentities[pn] = {}
	server.playerlist[pn] = {}
	dprint("Removed team "..pn)
end

rawset(_G, "PLYR_updatecontrol", function(mo)
	mo.savecontrol = mo.control.name
	mo.inputs = mo.control.mo.P_inputs

	--if (netgame)
		if mo.control.maincontrol == mo	-- not the best of checks
			mo.name = mo.savecontrol
			if mo.control.mo.skin ~= mo.skin
				R_SetPlayerSkin(mo.control, mo.skin)	-- make sure our real player looks like the character they chose.
				COM_BufInsertText(mo.control, "skin "..mo.skin) //So the game doesn't try changing them back whenever they change name
			end	-- don't do it every frame
			mo.color = mo.control.mo.color
			mo.displaycontrolname = nil
		else
			mo.displaycontrolname = true
		end
	--end
end)

local function PLYR_checkforPlayer(mo)	-- check if whoever is controlling 'mo' is still in the game, update our controller / data accordingly.
	if not (mo and mo.valid			-- you never know.
	and mo.plyr						-- we're not a player, so it doesn't matter lol
	and mo.control					-- no one was controlling us to begin with.
	and netgame						-- nobody cares, no one will be leaving there
	and server.plentities 
	and server.plentities[mo.party]) then return end	
	
	local partysize = #server.plentities[mo.party]

	local plist = server.playerlist[mo.party]
	local twopset

	local header = "PN "..mo.party..": "

	if mo.control and mo.control.valid and not mo.control.quittime //rejointimeout ghost
		PLYR_updatecontrol(mo)				-- update our info
	else	-- !!
		for i = 1, partysize
			if plist[i] 
			and not plist[i].valid
				plist[i] = nil
				dprint(header.."Removed index "..i.." from partytable")
			end
		end
	end

	-- scan for players that should be controlling us instead of whoever's in charge now
	local seek	-- seek our index in the party
	--for i = 1, #server.plentities[mo.party] do
	for i = 1, partysize do
		if server.plentities[mo.party][i] == mo
			if plist[i]
			and not plist[i].valid
				plist[i] = nil
				dprint(header.."Removed index "..i.." from partytable")
			end
			seek = i
			break
		end
	end

	if not seek return end

	-- okay, very, VERY special case...
	-- if we only have 2 players, then bot #4 should be controlled by p2 and not p1, make control split even~
	//Players 1 and/or 2 could easily not exist, you could have players 1 and 3, 1 and 4, 2 and 3, 2 and 4, or 3 and 4

	local count = 0
	local botcount = 0
	local firstp
	local firstpindex
	local lastp
	local lastpindex
	local oddbot
	local evenbot
	--for k,p in ipairs(plist) do
	for i = 1, partysize do	-- always count with teamlen!!! //Hmm, or maybe plentities?
		local p = server.playerlist[mo.party][i]
		if p and p.valid and not p.quittime and p.P_party == mo.party
			count = $+1
			firstp = $ or p
			firstpindex = $ or i
			lastp = p
			lastpindex = i
		end
	end

	if count == 2
		twopset = true
	end

	if twopset	-- exactly 2 players;
		//Are we an odd or even bot?
		for i = 1, partysize do
			local pmo = server.plentities[mo.party][i]
			if pmo and i ~= firstpindex and i ~= lastpindex
				botcount = $+1
				if mo == pmo
					if (botcount%2)
						oddbot = true
					else
						evenbot = true
					end
					break
				end
			end
		end
		//Wait for the players to first have their maincontrol, so they have the right character outside of battles
		if oddbot and mo.control ~= firstp and firstp.maincontrol
			PLYR_setcontrol(mo, firstp)
		elseif evenbot and mo.control ~= lastp and lastp.maincontrol
			PLYR_setcontrol(mo, lastp)
		end
	end

	if plist[seek] and plist[seek].valid and not plist[seek].quittime and (not mo.control or not mo.control.valid or mo.control.quittime or mo.control.maincontrol ~= mo)
	//and not twopset
		dprint(header.."Updated bot "..(seek).."'s controls to "..plist[seek].name)
		--mo.control = players[seek]
		PLYR_setcontrol(mo, plist[seek])
	end

	if not mo.control.valid or mo.control.quittime					-- mysterious!
		mo.control = nil			-- go back to being a good bot

		if not (plist[1] and plist[1].valid)	-- ....player 1 from our team left as well!?
			-- remove everyone from this team; //There might still be players in the party
			local count = 0
			for j=2, partysize
				if plist[j] and plist[j].valid
					count = $+1
				end
			end
			if not count //Okay, the party is actually empty
				//print(count)
				dprint(header.."No one left in party "..mo.party..", removing this party.")
				PLYR_removeTeam(mo.party)
				return
			end
		end
		for j=1, partysize
			if plist[j] and plist[j].valid and not plist[j].quittime
				PLYR_setcontrol(mo, plist[j]) //First actual player
				return
			end
		end
		
		if plist[seek] and plist[seek].valid //Just give any rejoin ghosts control, it doesn't matter
			PLYR_setcontrol(mo, plist[seek])
		else
			for i=1, partysize
				if plist[i] and plist[i].valid
					PLYR_setcontrol(mo, plist[i])
					break
				end
			end
		end
		local btl = server.P_BattleStatus[mo.party]		//If you're in a battle, then you all die lol
		if btl and btl.running
			for j=1, #server.plentities[mo.party]
				if server.plentities[mo.party][j].hp
					local pmo = server.plentities[mo.party][j]
					for k=1, #pmo.enemies
						local e = pmo.enemies[k]
						e.skills = {"trigonometry", "megagarula", "agneyastra", "road roller", "kannon", "fitness", "teddeh", "gigantic fish", "buchikamashi", "panty raid", "agi2"}
						e.strength = 999999
						e.magic = 999999
						e.agility = 999999
						e.luck = 999999
						e.endurance = 999999
						//damageObject(server.plentities[mo.party][j], max(99999, server.plentities[mo.party][j].hp))
					end
					break
				end
			end
			mo.t_acttimer = $ and min($, 1)
		end
		dprint(header.."Reverted bot "..(seek).."'s controls to whoever can be found")
	end
end

//Join a damn party please!
local function PLYR_checkjoincontrol(p)
	if not (server.plentities
	and server.plentities[1]		-- no bots in the game. skip.
	and #server.plentities[1])
	or p.P_party return end			-- player shouldn't have had respawned in the first goddamn place.

	-- check which party has the least players:
	local spacesfree = 0
	local partytojoin = 0
	local nameindex	-- if we find a bot with our exact name (rejoining?)

	for i = 1, 4
		local pa = server.playerlist[i]
		local plentities = server.plentities[i] //Using server.P_netstat.teamlen messes with boss mode
		local partysize = #plentities

		/*if not #pa	-- this party has NO players. //Maybe not?
		or #pa >= server.P_netstat.teamlen	-- full
			continue	-- don't try
		end*/
		
		local count = 0
		for j = 1, partysize
			if pa[j] and pa[j].valid
				count = $+1
			end
		end
		if not count //empty, really
		or count >= partysize //full
			continue
		end

		for j = 1, partysize do

			-- scan for the actual bot team, if they have a bot with YOUR player name, it means you're rejoining
			if server.plentities[i][j]
			and server.plentities[i][j].name == p.name
				-- it's impossible for 2 players to have the same name, so we don't need to check for that.
				partytojoin = i
				nameindex = j
				break //No point checking the other players
			end

		end
		if nameindex then break end //No point checking the other parties

		if (partysize - count) > spacesfree
			partytojoin = i
			spacesfree = partysize - count
		end
	end

	if partytojoin
		dprint("Affected "..p.name.." to party "..partytojoin)

		-- if anyone from that party is inside a battle's plist, add us to it as well...!
		local pa = server.playerlist[partytojoin]
		local plentities = server.plentities[partytojoin]
		local partysize = #plentities
		for i=1, partysize
			if pa[i] and pa[i].valid and pa[i].control and pa[i].control.valid and pa[i].control.battlen
			and server.P_BattleStatus[pa[i].control.battlen].running
				table.insert(server.P_BattleStatus[pa[i].control.battlen].plist, p)
				dprint("Affected "..p.name.." to running battle "..pa[i].control.battlen)
				break
			end
		end

		-- on the player list we just joined, check if the boss was cleared to give ourselevs that flag as well:
		-- (otherwise we'd be able to trigger the boss as well... oops?)
		for i=1, partysize
			if pa[i] and pa[i].valid and pa[i].mo and pa[i].mo.valid and pa[i].mo.eventclear
				p.mo.eventclear = true
				break
			end
		end

		p.P_party = partytojoin

		if nameindex	-- I got somewhere to be!
			-- iterate table backwards and move everyone from that spot and after to the back
			//First see if we can just join in the slot without doing that
			local j = partysize
			local pa = server.playerlist[partytojoin]
			if not (pa[nameindex] and pa[nameindex].valid)
				pa[nameindex] = p
			else

				while j > nameindex
					if j < partysize or not pa[j]
						pa[j] = pa[j-1]
					end
					j = $-1
				end
				pa[nameindex] = p
			end

		else	-- take the first free spot
		
			for i = 1, partysize
				if not (server.playerlist[partytojoin][i] and server.playerlist[partytojoin][i].valid)
					server.playerlist[partytojoin][i] = p

					return true
				end
			end
		end
	end
end

local function CustomThinkFrame()
	if not (server and netgame) then return end
	if consoleplayer and consoleplayer.valid and needresynching
		consoleplayer.synchtimer = 0
		needresynching = nil
	end
	if gamemap == 1 then return end
	for p in players.iterate do
		if not (p.mo and p.mo.valid) then continue end

		PLYR_checkjoincontrol(p)
		local mo = p.mo
		if p.P_party
			local btl = server.P_BattleStatus[p.P_party]
			local evt = server.P_DialogueStatus and server.P_DialogueStatus[p.P_party]
			if mo.spr_nfloor
			and not ((mo.flags2 & MF2_DONTDRAW) and (p.pflags & PF_GODMODE))
			and not (btl and btl.running)
			and not (evt and (evt.event or evt.running))
			and not (renderMenus(v,mo) or R_drawShop(v, mo) or R_drawEquipLab(v, mo))
				PLAY_move(p)
				mo.spr_nfloor = nil
			end
		end
	end
	if server.plentities
		for i=1, 4
			local plentities = server.plentities[i]
			local partysize = #plentities
			for j=1, partysize
				PLYR_checkforPlayer(plentities[j])
			end
		end
	end
end

addHook("PreThinkFrame", CustomThinkFrame)

rawset(_G, "NET_isset", function()
	return server and server.plentities and #server.plentities and server.skinlist and server.P_netstat and server.P_netstat.ready and not server.P_netstat.running //or not netgame
end)

//Edited from Event_Handler.lua (fixing the Lua warnings in the console seemed to fix the PVP bug?)
-- always make this run in places where events should be able to happen.
-- returns true if an event is undergoing.
rawset(_G, "D_eventHandler", function(pn)
	if not server.P_BattleStatus return end
	if not server.P_BattleStatus[pn] return end
	local battle = server.P_BattleStatus[pn]
	if not server.plentities or not #server.plentities or not server.skinlist return end
	if not server.plentities[pn] or not #server.plentities[pn] return end
	
	local firstp
	for i = 1, server.P_netstat.teamlen or 4
		if server.plentities[pn][i]
		and server.plentities[pn][i].valid
		and server.plentities[pn][i].control
			firstp = server.plentities[pn][i]
			break
		end
	end
	
	if not (firstp and firstp.valid) return end	--??
	if not (firstp.control and firstp.control.valid and firstp.control.mo and firstp.control.mo.valid) return end
	local inputs = firstp.control.mo.P_inputs
	if not inputs return end	-- errors

	local evt = server.P_DialogueStatus and server.P_DialogueStatus[pn]

	if evt and evt.event

		evt.running = true
		evt.time = $+1

		for p in players.iterate do
			if p.P_party == pn
				p.awayviewmobj = battle.cam
				if evt.usecam
					p.awayviewtics = 2
					p.awayviewaiming = battle.cam.aiming or 0
				end
				--p.mo.flags2 = $|MF2_DONTDRAW
				PLAY_nomove(p)
			end	
		end

		-- handle timers and special cases
		for k, v in pairs(evt.timers)
			if evt.timers[k]
				evt.timers[k] = $-1
				if k == "to" and evt.timers[k] == 0 and evt.save_event
					--dprint("Switching to next index after animation.")
					evt.eventindex = evt.save_event
					evt.save_event = nil
					evt.texttime = 0
				elseif k == "quit" and evt.timers[k] == 0	-- quit timer elapsed, cleanse event
					D_endEvent(pn)
					return
				end
			end
		end

		-- these timers are special and cut our handlers from doing anything:
		if evt.timers.start or evt.timers.to or evt.timers.quit
			return true	-- still technically running, but on time out
		end

		local cur = eventList[evt.event][evt.eventindex]

		if not cur	-- index doesn't exist. We'll assume it ended!
		and not evt.timers.quit
			evt.timers.quit = TICRATE/3
			--dprint("Requesting for end of event")
			return true
		end

		local evflags = cur[6] or 0
		if cur[1] == "text"	-- regular shit handling

			if evt.curtype ~= "text"	-- we started with a text box, ready the animation, quick, quick!
				evt.timers.textboxanim_in = TICRATE/3
				evt.curtype = cur[1]
			end

			local txt = cur[3]

			if evt.timers.textboxanim_in or evt.timers.textboxanim_out then return true end	-- cannot proceed yet
			if evt.timers.choices then return true end	-- yoinks...


			-- quick hack to skip control characters:
			local curchar = txt:sub(evt.texttime, evt.texttime)
			local nextchar = txt:sub(evt.texttime+1, evt.texttime+1)

			-- set delay if the current character is one of these and if the last character is a space
			/*if (curchar == "," or curchar == "." or curchar == "?" or curchar == "!")
			and (nextchar == " " or nextchar == "\n")
			and not evt.textdelay
				evt.textdelay = 8
			end*/

			if evt.textdelay
				evt.textdelay = $-1
			end
			if not evt.textdelay
				evt.texttime = $+1
			end

			-- skip control characters.
			while txt:sub(evt.texttime, evt.texttime) and V_isControlChar(txt:sub(evt.texttime, evt.texttime))
				evt.texttime = $+1
			end

			if evt.texttime == txt:len()
			and cur[4]	-- there are choices
				evt.timers.choices = 8
				return true
			end

			if cur[4]	-- handle choice selection:
				if inputs["down"] == 1
					evt.choice = $+1
					S_StartSound(nil, sfx_hover)
					if evt.choice > #cur[4]
						evt.choice = 1
					end
				elseif inputs["up"] == 1
					evt.choice = $-1
					S_StartSound(nil, sfx_hover)
					if evt.choice < 1
						evt.choice = #cur[4]
					end
				end
			end

			if evflags & EV_AUTO	-- wait for text box
				if evt.texttime < txt:len() + 20
					inputs[BT_JUMP] = 0
				else
					inputs[BT_JUMP] = 1
				end
			end

			if inputs[BT_JUMP] == 1
				if evt.texttime < txt:len()
					evt.texttime = txt:len()
					if cur[4]
						evt.timers.choices = 8	-- bring up the choices.
					end
				else

					if cur[4]	-- in case of dialogue choices:
						S_StartSound(nil, sfx_confir)
						local newe = cur[4][evt.choice][2] or 0
						if cur[5]
							D_requestIndex(pn, newe)
						else
							evt.eventindex = newe
							evt.texttime = 0
						end
					else
						S_StartSound(nil, sfx_hover)
						-- in the case of text, 4 is for potential choices;
						-- 5 is whether or not we want a transition for the next box
						if cur[5]
							D_requestIndex(pn, evt.eventindex+1)
						else
							evt.eventindex = $+1	-- next
							evt.texttime = 0
						end
					end
				end
			end
		elseif cur[1] == "function"	-- execute a function.
			evt.ftimer = $ and $+1 or 1	-- function timer
			if cur[2](evt, battle)	-- makes acting on the tables easier.
				evt.eventindex = $+1
				evt.ftimer = 0
			end
		end

		-- event has been running
		return true
	end
end)


//Edited from Net_Team.lua (just to fix a Lua warning, honestly)
local function NET_exitready(n)
	G_SetCustomExitVars(n, 1)
end

-- reset net stat, used at the end of multiplayer sessions or when returning to the tartarus lobby:
rawset(_G, "NET_reset", function()
	server.P_netstat = {}
	server.plentities = {}
	server.playerlit = {}
	server.skinlist = {}
	for p in players.iterate
		if p.mo
			p.mo.P_net_ready = false
		end
	end
end)

rawset(_G, "NET_startgame", function()

	-- special case; LOADING.
	-- if we're loading a game, we can potentially have empty parties.
	-- ...remove them, and apply the changes to the loaded save file. (doesn't modify the actual file on-disk, only in memory)
	if server.P_netstat.buffer.load
		print("File loading corrections in progress....")
		local emptyparties = {}
		for i = 1, #server.P_netstat.playerlist
			local found
			for j = 1, server.P_netstat.teamlen do
				if server.P_netstat.playerlist[i][j]
				and server.P_netstat.playerlist[i][j].valid
					found = true
					break
				end
			end

			if not found
				emptyparties[#emptyparties+1] = i
			end
		end

		if #emptyparties
			-- act upon empty parties
			-- what we'll do is simply remove these parties from the list and the save file. that's about it.
			local i = #emptyparties
			local file = server.netgamefile

			while i
				local r = emptyparties[i]
				-- remove from netstat
				table.remove(server.P_netstat.playerlist, r)
				table.remove(server.P_netstat.skinlist, r)
				-- remove from file
				table.remove(file.playerlist, r)
				table.remove(file.battle, r)
				i = $-1
			end

			for i = 1, 4
				-- this table can't be empty.
				-- add empty tables on the last indexes after we performed the removal
				server.P_netstat.playerlist[i] = $ or {}
			end

		end
	end

	server.playerlist = server.P_netstat.playerlist
	-- ^ this is maintained each frame from now on

	-- ultimatum: Check skinlist:
	local num = 0
	for i = 1, 4

		/*if not #server.playerlist[i] //LOL
			continue
		end	-- skip empty teams*/
		local count = 0
		for j = 1, server.P_netstat.teamlen
			if server.playerlist[i][j] and server.playerlist[i][j].valid
				count = 1
				break //We only need to know if there's at least one valid player in the party
			end
		end
		if not count then continue end
		
		num = $+1


		local findp
		for j = 1, server.P_netstat.teamlen
			if server.playerlist[i][j] and server.playerlist[i][j].valid
				findp = server.playerlist[i][j]
				break //We found p
			end
		end

		if not (findp and findp.valid)
			print("\x82".."NET_startgame / FATAL: ".."\x80".."No player in team "..i..", P_netstat will be reset.")
			NET_end(true)
			return
		end
	end

	PLYR_spawn(server.P_netstat.skinlist)
	server.P_netstat.ready = true	-- ready to play

	local buf = server.P_netstat.buffer

	if not buf return end

	-- depending on buffer info, do some stuff
	server.gamemode = buf.gamemode	-- cool
	if num
		if server.bossmode //Always two teams, and one is the boss
			if server.P_netstat.teamlen
				COM_BufInsertText(server, "maxplayers "..(server.P_netstat.teamlen+1))
			else
				COM_BufInsertText(server, "maxplayers "..(5))
			end		
		else
			if server.P_netstat.teamlen
				COM_BufInsertText(server, "maxplayers "..(num*server.P_netstat.teamlen))
			else
				COM_BufInsertText(server, "maxplayers "..(num*4))
			end
		end
	end

	server.difficulty = 1	-- default

	if server.gamemode == GM_COOP	-- extradata = difficulty
		server.difficulty = buf.extradata
	elseif server.gamemode == GM_PVP
		server.pvpmode = buf.extradata
	end

	if server.roguemode
		ROGUE_reset()
		if not server.rogueseed
			server.rogueseed = max(1, P_RandomFixed())
		end	
		-- Initialize rogue mode seed, unless it's already set (file loading)
	end

	if buf.map
		NET_exitready(buf.map)
		G_ExitLevel()
	end

	NET_end()
end)

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
			server.bosslevel = enemyList[bosses[p.bossselect]].level
			p.confirmboss = 2
		elseif inpt[BT_BTNB] == 1
			S_StartSound(nil, sfx_cancel, p)
			p.confirmboss = nil
		end	
	end
	
end

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

	if not net.buffer then return end
	local nostack = net.buffer.nostack	-- No stacking skins! //net.buffer can be nil?? (This entire fix conflicts with Teamsize, so add that after)
	--print(nostack)


	local mo = p.mo
	if not mo return end

	local inpt = mo.P_inputs
	if not net.playerlist then return end
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

local state_2_func = {
	[NET_TEAMSELECT] = NET_teamselect,
	[NET_SKINSELECT] = NET_teamselect,
	[NET_PVP_SKINSELECT] = NET_skinselect,
	[NET_PVP_TEAMSELECT] = NET_pvpteam,
	[NET_LOAD] = NET_load
}

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

local function statusConditionEffects(mo)	-- the little animations over the enemy's head when that happens
	if not mo or not mo.valid or not mo.hp return end
	if mo.hp <= 0 return end

	-- down:
	-- note: down isn't actually a status condition but still has its visual handled here because it's close enough
	if mo.down
		local an = leveltime * ANG1 * 8
		for i = 1, 2 do
			local dx = mo.x + 64*cos(an)
			local dy = mo.y + 64*sin(an)
			local dz = mo.z + mo.height + 12*sin(an + leveltime*ANG1*4)
			local s = P_SpawnMobj(dx, dy, dz, MT_DUMMY)
			s.state = S_SPRK1
			s.scale = FRACUNIT*2
			s.destscale = 0
			s.frame = A|FF_FULLBRIGHT
			s.tics = 1
			if (leveltime%2)
				s.fuse = 2
			end
			an = $+ ANG1*180
		end
	end

	-- fields that spawn particles i guess??
	if mo.fieldstate

		if mo.fieldstate.type == FLD_ZIOVERSE

			if leveltime%2 == 0

				local x = mo.x + P_RandomRange(-64, 64)*mo.scale
				local y = mo.y + P_RandomRange(-64, 64)*mo.scale
				local z = mo.z + P_RandomRange(-64, 64)*mo.scale

				P_SpawnMobj(x, y, z, MT_SUPERSPARK)

			end

		elseif mo.fieldstate.type == FLD_AGIVERSE

			local rfac = (mo.maxhp + mo.maxsp) - mo.level

			local ang = (rfac + leveltime)*ANG1*12
			local zpos = mo.z + 32*mo.scale + 32*sin((rfac + leveltime)*ANG1*8)

			local x = mo.x + 64*cos(ang)
			local y = mo.y + 64*sin(ang)
			local f = P_SpawnMobj(x, y, zpos, MT_DUMMY)
			f.tics = 2
			f.sprite = SPR_FPRT
			f.frame = $ & ~FF_TRANSMASK
			f.frame = $|FF_FULLBRIGHT|TR_TRANS20
			f.scale = mo.scale*5/2

			local g = P_SpawnGhostMobj(f)
			g.destscale = 1
			g.scalespeed = FRACUNIT/4
		end
	end

	-- uh, i mean i guess we can count tetrakarn / makrakarn / mind charge / power charge as special effects too~

	if server.P_BattleStatus[mo.battlen]
	and server.P_BattleStatus[mo.battlen].battlestate == BS_DOTURN

		if (mo.tetrakarn or mo.makarakarn or mo.tetraja)
		and leveltime%2

			local x, y = mo.x + 32*cos(mo.angle), mo.y + 32*sin(mo.angle)
			local s = P_SpawnMobj(x, y, mo.z+mo.height/2, MT_DUMMY)
			s.scale = mo.scale
			s.fuse = 2
			if mo.tetraja
				s.sprite = SPR_ELEM
			else
				s.sprite = mo.tetrakarn and SPR_FORC or SPR_ARMA
			end
			s.frame = $|FF_PAPERSPRITE|FF_FULLBRIGHT |FF_TRANS50
			s.angle = mo.angle + ANG1*90
		end
	end

	-- mind charge
	if mo.mindcharge
		if not (leveltime%4)
			local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height/2, MT_DUMMY)
			elec.sprite = SPR_DELK
			elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
			elec.destscale = FRACUNIT*4
			elec.scalespeed = FRACUNIT/4
			elec.tics = TICRATE/8
			elec.color = SKINCOLOR_CYAN
		end

		if leveltime %4 == 0
			local a = R_PointToAngle(mo.x, mo.y)
			local x = mo.x - cos(a)
			local y = mo.y - sin(a)

			local dummy = P_SpawnMobj(x, y, mo.z, MT_DUMMY)
			if mo.skin
				dummy.skin = mo.skin
			end
			dummy.state = mo.state
			dummy.sprite = mo.sprite
			dummy.sprite2 = mo.sprite2
			dummy.frame = mo.frame
			dummy.angle = mo.angle
			dummy.scale = mo.scale
			dummy.colorized = true
			dummy.color = SKINCOLOR_CYAN
			dummy.fuse = 2
		end
	end

	-- power charge
	if mo.powercharge
		if not (leveltime%4)
			local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height, MT_DUMMY)
			elec.sprite = SPR_DELK
			elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
			elec.destscale = FRACUNIT*4
			elec.scalespeed = FRACUNIT/4
			elec.tics = TICRATE/8
			elec.color = SKINCOLOR_CRIMSON
		end

		if leveltime %4 == 0
			local a = R_PointToAngle(mo.x, mo.y)
			local x = mo.x - cos(a)
			local y = mo.y - sin(a)

			local dummy = P_SpawnMobj(x, y, mo.z, MT_DUMMY)
			if mo.skin
				dummy.skin = mo.skin
			end
			dummy.state = mo.state
			dummy.sprite = mo.sprite
			dummy.sprite2 = mo.sprite2
			dummy.frame = mo.frame
			dummy.angle = mo.angle
			dummy.scale = mo.scale
			dummy.colorized = true
			dummy.color = SKINCOLOR_CRIMSON
			dummy.fuse = 2
		end
	end

	-- guaranteed evasion
	if mo.guaranteedevasion
		if leveltime%10 == 0

			local g = P_SpawnGhostMobj(mo)
			g.colorized = true
			g.destscale = mo.scale*4
			g.scalespeed = mo.scale/12

			g = P_SpawnGhostMobj(mo)
			g.colorized = true
			g.destscale = mo.scale*4
			g.scalespeed = mo.scale/6
		end
	end

	-- oh boy I wish Lua had switch cases LOL
	-- burn

	if mo.status_condition == COND_BURN
		local steam = P_SpawnMobj(mo.x+P_RandomRange(-45, 45)*mo.scale, mo.y+P_RandomRange(-45, 45)*mo.scale, mo.z+P_RandomRange(5, 30)*mo.scale, MT_SMOKE)
		P_SetObjectMomZ(steam, P_RandomRange(1, 3)*mo.scale)

		if not (leveltime%2)
			local fire = P_SpawnMobj(mo.x+P_RandomRange(-45, 45)*mo.scale, mo.y+P_RandomRange(-45, 45)*FRACUNIT, mo.z+P_RandomRange(5, 30)*mo.scale, MT_DUMMY)
			fire.sprite = SPR_FPRT
			fire.frame = $ & ~FF_TRANSMASK
			fire.frame = $|FF_FULLBRIGHT|TR_TRANS20
			fire.scale = mo.scale*5/2
			fire.momz = P_RandomRange(1, 3)*mo.scale
			fire.scalespeed = mo.scale/12
			fire.destscale = 1
			fire.tics = TICRATE
		end

	-- poison
	elseif mo.status_condition == COND_POISON
		for i = 1,2
			local psn = P_SpawnMobj(mo.x+P_RandomRange(-15,15)*FRACUNIT, mo.y+P_RandomRange(-15,15)*FRACUNIT, mo.z+P_RandomRange(0,15)*FRACUNIT, MT_DUMMY)
			psn.sprite = SPR_THOK
			psn.frame = A
			psn.color = SKINCOLOR_PURPLE
			psn.scale = FRACUNIT/2
			psn.destscale = FRACUNIT/99
			psn.momz = P_RandomRange(5, 12)*FRACUNIT
			psn.tics = TICRATE
		end

	-- brainwash: <3 <3 <3
	elseif mo.status_condition == COND_BRAINWASH

		for i = 1, 2
			local s = P_SpawnMobj(mo.x + P_RandomRange(-32, 32)*FRACUNIT, mo.y + P_RandomRange(-32, 32)*FRACUNIT, mo.z + 32*FRACUNIT, MT_DUMMY)
			s.sprite = SPR_LOVE
			s.frame = P_RandomRange(0, 2)|FF_FULLBRIGHT|FF_TRANS30
			s.momz = P_RandomRange(2, 5)*FRACUNIT
			s.scale = P_RandomRange(FRACUNIT*3/4, FRACUNIT*3/2)
			s.destscale = 1
			s.tics = TICRATE*3/2
		end

	-- dizzy: stars above the head or whatvs
	elseif mo.status_condition == COND_DIZZY

		for i = 1, 3
			local s = P_SpawnMobj(mo.x + P_RandomRange(-32, 32)*FRACUNIT, mo.y + P_RandomRange(-32, 32)*FRACUNIT, mo.z + 32*FRACUNIT, MT_DUMMY)
			s.sprite = SPR_STUN
			s.frame = P_RandomRange(0, 2)|FF_FULLBRIGHT|FF_TRANS30
			s.color = P_RandomRange(0,1) and SKINCOLOR_LAVENDER or SKINCOLOR_ORANGE
			s.momz = P_RandomRange(2, 5)*FRACUNIT
			s.scale = P_RandomRange(FRACUNIT/2, FRACUNIT)
			s.destscale = 1
			s.tics = TICRATE*3/2
		end

	elseif mo.status_condition == COND_HEX

		for i = 1, 3
			local s = P_SpawnMobj(mo.x + P_RandomRange(-32, 32)*FRACUNIT, mo.y + P_RandomRange(-32, 32)*FRACUNIT, mo.z + 32*FRACUNIT, MT_DUMMY)
			s.sprite = SPR_FEAR
			s.frame = P_RandomRange(0, 1)|FF_FULLBRIGHT
			s.momz = P_RandomRange(2, 5)*FRACUNIT
			s.scale = P_RandomRange(FRACUNIT/2, FRACUNIT)
			s.destscale = 1
			s.tics = TICRATE*3/2
		end

	elseif mo.status_condtion == COND_HUNGER	-- ez just vore smth lol

		local thok = P_SpawnMobj(mo.x+P_RandomRange(-40, 40)*FRACUNIT, mo.y+P_RandomRange(-40, 40)*FRACUNIT, mo.z+P_RandomRange(20, 60)*FRACUNIT, MT_DUMMY)
		thok.sprite = SPR_SUMN
		thok.frame = F|FF_FULLBRIGHT|TR_TRANS30
		thok.momz = -P_RandomRange(6, 16)*FRACUNIT
		thok.color = SKINCOLOR_GREEN
		thok.tics = P_RandomRange(10, 35)

	-- GO TO SLEEP -Cae-sama
	elseif mo.status_condition == COND_SLEEP

		if leveltime%16 == 0
			local s = P_SpawnMobj(mo.x, mo.y, mo.z + 32*FRACUNIT, MT_DUMMY)
			s.sprite = SPR_SLEP
			s.frame = FF_FULLBRIGHT
			s.momz = P_RandomRange(2, 5)*FRACUNIT
			s.scale = P_RandomRange(FRACUNIT, FRACUNIT*3/2)
			P_InstaThrust(s, P_RandomRange(0, 359)*ANG1, 4<<FRACBITS)
			s.destscale = 1
			s.tics = TICRATE*3/2
		end

	-- shock: shake and spawn yellow sparks
	elseif mo.status_condition == COND_SHOCK
		mo.flags2 = $|MF2_DONTDRAW
		local dummy = P_SpawnMobj(mo.x + P_RandomRange(-4, 4)*FRACUNIT, mo.y + P_RandomRange(-4, 4)*FRACUNIT, mo.z, MT_DUMMY)
		if mo.skin
			dummy.skin = mo.skin
		end
		dummy.state = mo.state
		dummy.sprite = mo.sprite
		dummy.sprite2 = mo.sprite2
		dummy.frame = mo.frame
		dummy.angle = mo.angle
		dummy.scale = mo.scale
		dummy.color = mo.color
		dummy.fuse = 2

		if not (leveltime%4)
			local elec = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
			elec.sprite = SPR_DELK
			elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
			elec.destscale = FRACUNIT*4
			elec.scalespeed = FRACUNIT/4
			elec.tics = TICRATE/8
			elec.color = SKINCOLOR_YELLOW
		end

	-- silence! make as much noise as kanade (so none, dipshit)
	elseif mo.status_condition == COND_SILENCE

		local cam = server.P_BattleStatus[mo.battlen].cam

		local startx = mo.x + 20*cos(cam.angle-ANG1*90)
		local starty = mo.y + 20*sin(cam.angle-ANG1*90)

		local glan = R_PointToAngle(startx, starty)
		local glx = startx - 4*cos(glan)
		local gly = starty - 4*sin(glan)

		local stfu = P_SpawnMobj(glx, gly, mo.z + 48*FRACUNIT, MT_DUMMY)
		stfu.sprite = SPR_STFU
		stfu.frame = ((leveltime%21)/7)|FF_FULLBRIGHT
		stfu.tics = 2

	-- despair, teloli moment
	elseif mo.status_condition == COND_DESPAIR

		local cam = server.P_BattleStatus[mo.battlen].cam

		local startx = mo.x + 20*cos(cam.angle-ANG1*90)
		local starty = mo.y + 20*sin(cam.angle-ANG1*90)

		local glan = R_PointToAngle(startx, starty)
		local glx = startx - 4*cos(glan)
		local gly = starty - 4*sin(glan)

		local sad = P_SpawnMobj(glx, gly, mo.z + 48*FRACUNIT + P_RandomRange(-1, 1)*FRACUNIT, MT_DUMMY)
		sad.sprite = SPR_DESP
		sad.frame = FF_FULLBRIGHT
		sad.tics = 2

	-- rage (zxys tsun tsun mode~)
	elseif mo.status_condition == COND_RAGE

		local cam = server.P_BattleStatus[mo.battlen].cam

		local startx = mo.x + 20*cos(cam.angle-ANG1*90) + P_RandomRange(-1, 1)*FRACUNIT
		local starty = mo.y + 20*sin(cam.angle-ANG1*90) + P_RandomRange(-1, 1)*FRACUNIT

		local glan = R_PointToAngle(startx, starty)
		local glx = startx - 10*cos(glan)
		local gly = starty - 10*sin(glan)

		local tsun = P_SpawnMobj(glx, gly, mo.z + 48*FRACUNIT + P_RandomRange(-1, 1)*FRACUNIT, MT_DUMMY)
		tsun.sprite = SPR_TSUN
		tsun.frame = FF_FULLBRIGHT
		tsun.scale = (leveltime%20 < 10) and FRACUNIT or FRACUNIT*3/4
		tsun.tics = 2

	-- freeze
	elseif mo.status_condition == COND_FREEZE

		local dust = P_SpawnMobj(mo.x+P_RandomRange(-64, 64)*FRACUNIT, mo.y+P_RandomRange(-64, 64)*FRACUNIT, mo.z+P_RandomRange(0, 64)*FRACUNIT, MT_DUMMY)
		dust.flags = $|MF_NOGRAVITY|MF_NOCLIPHEIGHT
		dust.state, dust.scale, dust.angle = S_BUFUDYNE_DUST1, FRACUNIT, 0
		dust.destscale = FRACUNIT*9/4
		dust.scalespeed = FRACUNIT/18
		dust.momz = 5*FRACUNIT/2

	-- hyper mode!
	elseif mo.status_condition == COND_HYPER

		-- spawn periodically flashing dummy
		local glan = R_PointToAngle(mo.x, mo.y)
		local glx = mo.x - 2*cos(glan)
		local gly = mo.y - 2*sin(glan)

		local inv = P_SpawnMobj(glx, gly, mo.z, MT_DUMMY)
		inv.fuse = 2
		inv.sprite = SPR_HYPR
		inv.frame = (leveltime%8) /2
		inv.scale = mo.scale

		if leveltime%8 == 0

			glx = mo.x - cos(glan)
			gly = mo.y - sin(glan)

			local dum = P_SpawnMobj(glx, gly, mo.z, MT_DUMMY)

			dum.state = mo.state
			dum.sprite = mo.sprite
			if mo.skin
				dum.skin = mo.skin
				dum.sprite2 = mo.sprite2
			end
			dum.frame = mo.frame|FF_FULLBRIGHT
			dum.color = SKINCOLOR_WHITE
			dum.colorized = true
			dum.angle = mo.angle
			dum.color = mo.color
			dum.scale = mo.scale
			dum.flags = MF_NOGRAVITY|MF_BOSS|MF_NOCLIPTHING
			dum.fuse = 2
		end

	elseif mo.status_condition == COND_SUPER
		-- super colour:
		local supercolor = charStats[mo.stats].supercolor_start
		if supercolor
			mo.color = supercolor + abs(((leveltime >> 1) % 9) - 4)
		else
			-- super orb
			local scale = charStats[mo.stats].superorbscale or FRACUNIT*12/10
			local caman = R_PointToAngle(mo.x, mo.y)

			local orb = P_SpawnMobj(mo.x - cos(caman), mo.y - sin(caman), mo.z, MT_DUMMY)
			orb.sprite = SPR_SORB
			orb.frame = FF_FULLBRIGHT|FF_TRANS30| (leveltime%16 / 2)
			orb.fuse = 2
		end
	end
end

rawset(_G, "DNG_Thinker", function()

	if not server return end

	if server.entrycard
		server.entrytime = $-1
		if server.P_DungeonStatus.gameoverfade
			server.P_DungeonStatus.gameoverfade = $-1
		end
		if server.P_DungeonStatus.lifeexplode
			if server.P_DungeonStatus.lifeexplode == 20
			and server.P_BattleStatus and server.P_BattleStatus.lives and server.P_BattleStatus.lives >= 0
				S_StartSound(nil, sfx_mchurt)
			end
			server.P_DungeonStatus.lifeexplode = $-1
		end

		if not server.entrytime
			server.entrycard = nil
			server.entrytime = nil
		end
	end

	if NET_running() return end	-- don't run anything during character selection

	if not server.P_BattleStatus return end

	if gamemap == srb2p.tartarus_play
	or server.gamemode == GM_VOIDRUN
		for i = 1, 4
			if server.P_BattleStatus[i].battlestate ~= BS_MPFINISH
				server.P_BattleStatus[i].netstats.time = $+1
			end
		end
	end

	//There's stuff I want run around this point
	if netgame and server.plentities and server.P_netstat and server.P_netstat.teamlen
		for i=1, 4
			local plentities = server.plentities[i]
			local partysize = #plentities
			for j=1, partysize
				PLYR_checkforPlayer(plentities[j])	//And now rejoin ghosts lose control until they rejoin
				statusConditionEffects(plentities[j]) //And doing that broke these, so I'm putting this here lol
			end
		end
	end
	-- menus & shops:
	for p in players.iterate do
		if p.maincontrol and p.maincontrol.valid
			if server.P_BattleStatus[p.maincontrol.battlen] and server.P_BattleStatus[p.maincontrol.battlen].running continue end	-- nope
		end
		local mo = p.mo
		if not mo continue end
		if DNG_handleShop(mo) continue end		-- in shop, don't open the menus in that case
		if DNG_handleEquipLab(mo) continue end	-- in equip lab, don't open menu either
		D_HandleMenu(mo)	-- let menus open even without net
	end

	for p in players.iterate do
		local btl = server.P_BattleStatus
		if btl and p.P_party
			btl = btl[p.P_party]
			if btl.running continue end
		end

		DNG_HandleAbilities(p, true)
	end

	if not NET_isset() return end	-- wait until we're finished setting up our team in MP

	SRB2P_runHook("DungeonThinker", battle)

	if server.entrytime

		-- voidrun hack
		if server.gamemode == GM_VOIDRUN
		and server.P_DungeonStatus.VR_type == VC_REPEL
		and server.entrytime == TICRATE/2
		and server.P_DungeonStatus.VR_timer ~= nil

			local bwaves = {}
			server.P_DungeonStatus.VR_target = 0

			for i = 1, 3 do
				bwaves[i] = server.waves[P_RandomRange(1, #server.waves)]
				server.P_DungeonStatus.VR_target = $ + #bwaves[i]
			end

			BTL_start(1, bwaves[1])
			server.P_BattleStatus[1].storedwaves = bwaves
		end
		D_voidRun()

		return
	else

		D_tartarusCrawler()
		if server.gamemode == GM_VOIDRUN
			D_voidRun()
			return
		end

		if not mapheaderinfo[gamemap].tartarus
		and not server.cdungeon
			for p in players.iterate do

				if not p.mo or not p.mo.valid continue end

				if D_ReadyBattle(p) continue end

			end
		end
	end
end)
