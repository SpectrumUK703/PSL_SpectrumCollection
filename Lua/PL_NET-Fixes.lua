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

ROGUE_initEnemyStats = function(ename)
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
	local shufflename = cpy.name
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
end

-- removes every enemy that has "__roguemode" in its name specifically.
-- don't name your enemies like that, dumbass.
ROGUE_reset = function()
	for k, p in pairs(enemyList)

		if k:find("__roguemode")
			enemyList[k] = nil
			continue
		end
	end
	enemiesrogued = {} //resets the rogued enemies table
end

local CHEAT
-- send my unlocks to the server!
COM_AddCommand("__&sendunlocks2", function(p, arg)
	if not arg return end
	p.unlocks = $ or {}
	arg = tonumber(arg)
	CHEAT = (not srb2p.local_conds[arg]) and arg or 0	-- I can see you there...
	if p ~= consoleplayer	-- If it's not me, I don't care!
		CHEAT = 0
	end

	--print(p.name..": UNLOCK "..arg.." "..tostring(CHEAT))
	p.unlocks[arg] = true
	dprint("Recived UCOND "..arg.." from "..p.name)
end)

--addHook("ThinkFrame", do
NET_Synch = function()

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
					COM_ImmedExecute("__&sendunlocks2 "..i)	-- funny!
					dprint("Sending UCOND '"..i.."' to server...")
				end
			end
			consoleplayer.setunlocks = true	-- warning, clientside spaghetti.
		end
		if needresynching
			consoleplayer.synchtimer = 0
			needresynching = nil
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
	if consoleplayer and consoleplayer.valid
		local btl = server.P_BattleStatus and server.P_BattleStatus[consoleplayer.P_party]
		local dng = server.P_DungeonStatus
		if not S_MusicPlaying()
			if gamemap == 2
				local block = server and dng and dng.floor and DNG_returnBlock(dng.floor)
				COM_BufInsertText(consoleplayer, "tunes "..DNG_getTartarusMusic(block))
				if server.blocktrans
					S_ChangeMusic("BLCKT", false, consoleplayer, nil, nil, MUSICRATE/2)
				end
			elseif gamemap == 4
				local cdungeonmusic = server.cdungeon and server.cdungeon.dungeonmusic
				COM_BufInsertText(consoleplayer, "tunes "..cdungeonmusic)
			end
		end
		if server.gamemode ~= GM_VOIDRUN
			if btl and btl.running
				if gamemap == 3 or gamemap == 5
					local music = server.P_BattleStatus[1].music or "BATL1"
					COM_BufInsertText(consoleplayer, "tunes "..music)
				else
					if btl.battlestate == BS_SHUFFLE or btl.battlestate == BS_END or btl.battlestate == BS_LEVELUP or btl.battlestate == BS_FINISH
						S_ChangeMusic(btl.savemusic or MUS_PlayRandomBattleMusic("mus_battle_results"), nil, consoleplayer)
					elseif btl.battlestate ~= BS_GAMEOVER
						local music = btl.music or "BATL1"
						S_ChangeMusic(music, true, consoleplayer)
					end
				end
			elseif server.reaper and server.reaper.valid
				S_ChangeMusic("REAPER", true, p)
			elseif consoleplayer.mo and consoleplayer.mo.valid 
			and ((consoleplayer.mo.equiplab and consoleplayer.mo.equiplab.using)
			or (consoleplayer.mo.shop and consoleplayer.mo.shop.shopping))
				S_ChangeMusic("SHOP", true, consoleplayer, nil, nil, 400)
			end
		else
			if dng.VR_challenge%3 == 0
				COM_BufInsertText(consoleplayer, "tunes SHOP")
			elseif dng.VR_timer
				local challengemus = (((dng.VR_challenge-1)/3) +1 )%5
				if not (challengemus%5)
					challengemus = 5
				end
				challengemus = $ or 1
				local cmusic = "VRCH"..challengemus
				COM_BufInsertText(consoleplayer, "tunes "..cmusic)
			end
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
	
end

-- removes team pn
local function PLYR_removeTeam(pn)

	//if #server.playerlist[pn] can sometimes be 0 when the party isn't empty lol
	local partysize = #server.plentities[pn]
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

	if num == 0 or (num < 2 and server.gamemode == GM_PVP) //Only one party left, back to the lobby
		SRB2P_killHUD()
		SYS_closeMenu()
		COM_ImmedExecute("map "..G_BuildMapName(srb2p.tartarus_map))
	end
end

PLYR_updatecontrol = function(mo)
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
end

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

	if mo.control and mo.control.valid
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
			seek = i
			break
		end
	end

	if not seek return end

	-- okay, very, VERY special case...
	-- if we only have 2 players, then even bots should be controlled by p2 and not p1, make control split even~


	local count = 0
	local botcount = 0
	local firstp
	local lastp
	local evenbot
	local oddbot
	--for k,p in ipairs(plist) do
	for i = 1, partysize do	-- always count with teamlen!!! //Hmm, or maybe plentities?
		local p = server.playerlist[mo.party][i]
		local pmo = server.plentities[mo.party][i]
		if p and p.valid and p.P_party == mo.party
			count = $+1
			firstp = $ or p
			lastp = p
		else
			if pmo
				botcount = $+1
				if mo == pmo
					if (botcount%2) == 0
						evenbot = true
					else
						oddbot = true
					end
				end
			end
		end
	end

	if count == 2
	and (evenbot or oddbot)
		twopset = true
	end

	if twopset	-- exactly 2 players;
		if evenbot	-- We're an even bot
		and mo.control ~= lastp and lastp.maincontrol -- Make sure player 2 has maincontrol first
			PLYR_setcontrol(mo, lastp)
		elseif oddbot	-- We're an odd bot
		and mo.control ~= firstp and firstp.maincontrol -- Make sure "player 1" has maincontrol first
			PLYR_setcontrol(mo, firstp)
		end
	end

	if plist[seek] and plist[seek].valid and (not mo.control or not mo.control.valid or mo.control.maincontrol ~= mo)
	and not twopset
		dprint(header.."Updated bot "..(seek).."'s controls to "..plist[seek].name)
		--mo.control = players[seek]
		PLYR_setcontrol(mo, plist[seek])
	end

	if not mo.control.valid					-- mysterious!
		mo.control = nil			-- go back to being a good bot

		if not (firstp and firstp.valid)	-- ....player 1 from our team left as well!?
			-- remove everyone from this team;
			dprint(header.."No one left in party "..mo.party..", removing this party.")
			PLYR_removeTeam(mo.party)
			return
		end

		PLYR_setcontrol(mo, firstp)
		dprint(header.."Reverted bot "..(seek).."'s controls to party leader")
	end
end

//Join a damn party please!
local function PLYR_checkjoincontrol(p)
	if not (server.plentities
	and (server.plentities[1]
	or server.plentities[2]
	or server.plentities[3]
	or server.plentities[4])		-- no bots in the game. skip.
	and (#server.plentities[1]
	or #server.plentities[2]
	or #server.plentities[3]
	or #server.plentities[4]))
	or p.P_party return end			-- player shouldn't have had respawned in the first goddamn place.

	-- check which party has the least players:
	local spacesfree = 0
	local partytojoin = 0
	local nameindex	-- if we find a bot with our exact name (rejoining?)

	for i = 1, 4
		local pa = server.playerlist[i]
		local plentities = server.plentities[i] //Using server.P_netstat.teamlen messes with boss mode
		local partysize = #plentities

		local count = 0
		for j = 1, partysize
			if pa[j] and pa[j].valid
				count = $+1
			else
				-- scan for the actual bot team, if they have a bot with YOUR player name, it means you're rejoining
				if server.plentities[i][j]
				and server.plentities[i][j].name == p.name
					-- it's impossible for 2 players to have the same name, so we don't need to check for that.
					partytojoin = i
					nameindex = j
					break //No point checking the other players
				end
			end
		end
		if nameindex then break end //No point checking the other parties
		if not count //empty, really
		or count >= partysize //full
			continue
		end

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
			local j = partysize
			local pa = server.playerlist[partytojoin]
			pa[nameindex] = p

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
	if gamemap == 1 then return end
	for p in players.iterate do
		if not (p.mo and p.mo.valid) then continue end

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
		else
			PLYR_checkjoincontrol(p)
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

NET_isset = function()
	return server and server.plentities and #server.plentities and server.skinlist and server.P_netstat and server.P_netstat.ready and not server.P_netstat.running //or not netgame
end
