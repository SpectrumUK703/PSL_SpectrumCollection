if CV_FindVar("fewerspikes") then return end
local fewerspikes = CV_RegisterVar({
	name = "fewerspikes",
	defaultvalue = "On",
	flags = CV_NETVAR,
	possiblevalue = CV_OnOff
})

-- Stuff relative to tartarus dungeon generation goes here

-- Actual map array in Map_Generator.LUA

local finalbossfloor	-- Used to know if we must fade music out after floor generation

local function pitorwall(i)
	return not (i == 0 or i == T_PIT or i == T_SPIKES or i == T_GATE)
end

-- generates floor from preset #
local function DNG_generatefloor(t, floornum)

	-- voidrun preemptive hacks (yikes)
	if server.gamemode == GM_VOIDRUN
		if server.P_DungeonStatus.VR_floor ~= nil
		and server.P_DungeonStatus.VR_floor < server.P_DungeonStatus.VR_floors
			dprint(server.P_DungeonStatus.VR_floor.."/"..server.P_DungeonStatus.VR_floors)
			-- depending on the type, change floor type
			if server.P_DungeonStatus.VR_type == VC_BOSS
				t = 5	-- boss floor
			else
				t = 2	-- random floor
			end
		elseif server.P_DungeonStatus.VR_floor
		and server.P_DungeonStatus.VR_floor >= server.P_DungeonStatus.VR_floors
			t = 3	-- Interval area
			if server.P_DungeonStatus.VR_challenge%3 == 0
				t = 4	-- shop area
			end

			dprint("I:"..server.P_DungeonStatus.VR_floor.."/"..server.P_DungeonStatus.VR_floors)
		end
	end

	dprint("Generating floor from preset "..t.."...")

	if server.gamemode == GM_VOIDRUN
		t = VR_floors[$]
	elseif server.cdungeon
		t = server.cdungeon.floordata[$]
	else
		t = tartarus_floors[$]
	end
	--t = server.gamemode == GM_VOIDRUN and VR_floors[t] or tartarus_floors[t]
	server.gentype = GEN_NORMAL

	local map
	if t and t.map
		map = t.map
	else
		-- Special generation stuff?
		if server.gamemode ~= GM_VOIDRUN
		and (server.difficulty > 1 or server.cdungeon and server.cdungeon.allowinterference)	-- Don't generate anything special in block 1, this is the safe block
			server.gentype = DNG_getGenerationType()
		else
			-- get gentype depending on voidrun challenge
			if server.P_DungeonStatus.VR_type == VC_HUNT
				server.gentype = GEN_DARK	-- whoa...
			end
		end
		map = MAP_generate(server.gentype)
	end
	server.map = copyTable(map)
	local gen = server.gentype

	server.fastmap = {}
	-- ready a faster table in memory.
	-- this one will only have non-0 tiles pointing to their position in server.map
	-- this is to avoid making a 48^2 iteration every frame for the display

	for i = 1, #server.map
		if server.map[i]
			server.fastmap[#server.fastmap+1] = i	-- point to position
			if server.gentype == GEN_CLEAR
				-- map out the floor directly on clear type
				for j = 1, 4
					server.rendermap[j][i] = server.map[i]
				end
			end
		end
	end

	server.DNG_entities = {}
	finalbossfloor = nil
	local switches = {}		-- table containing switches to be teleported

	local prefix, texture, ceil, range, brightness, ceilheight
	local usetiles = true

	-- regular internal random dungeons
	if server.cdungeon == nil
		ceil = "~PIT"
		ceilheight = 256
		prefix = (t.default and t.default.floorpic) and t.default.floorpic or "TART_"	-- floortexture prefix
		texture = (t.default and t.default.walltexture) and R_TextureNumForName(t.default.walltexture) or R_TextureNumForName("TART_W1")	-- default walltexture; will try to get later!
		range = (t.default and t.default.texturerange) and t.default.texturerange or 0			-- texture random range
		brightness = (t.default and t.default.brightness) and t.default.brightness or 192
		server.P_DungeonStatus.noreaper = nil or t.default.noreaper

		DNG_setextradata(t)
	else	-- custom dungeons

		prefix = server.cdungeon.floortextures
		ceilheight = server.cdungeon.ceilingheight*FRACUNIT
		ceil = server.cdungeon.ceilingtexture
		texture = R_TextureNumForName(server.cdungeon.startwalltexture)
		range = server.cdungeon.texturerange
		brightness = server.cdungeon.brightness
		usetiles = server.cdungeon.useautotile
		P_SetupLevelSky(server.cdungeon.skynum)
		server.P_DungeonStatus.noreaper = nil or t.noreaper
	end

	server.P_DungeonStatus.beatenboss = 0

	-- VoidRun timer & objectives
	if server.gamemode == GM_VOIDRUN
		if not (t and t.normalizedfloor)
			if server.P_DungeonStatus.VR_floor == 0
				server.P_DungeonStatus.VR_timer = TICRATE*10*60

				-- clauses (ie: skilljammer ...)
				if server.P_DungeonStatus.VR_clausebuf
					server.P_DungeonStatus.VR_clause = server.P_DungeonStatus.VR_clausebuf
					server.P_DungeonStatus.VR_clausebuf = nil

					local notes = {
						[VE_SKILLJAMMER] = "Oh no! Your skills are all jammed and unreadable...",
						[VE_ITEMJAMMER] = "Oh no! Your items are all jammed and unreadable...",
						[VE_NOSKILLS] = "Yikes! Your skills were sealed...",
						[VE_NOITEMS] = "Yikes! Your items were sealed...",
					}

					DNG_logMessage("\x85"..notes[server.P_DungeonStatus.VR_clause])
				end
			end
			server.P_DungeonStatus.VR_floor = $+1
		else
			server.P_DungeonStatus.VR_timer = nil
			server.P_DungeonStatus.VR_clause = nil
			if t.nextchallenge
				D_setVoidChallenge(t.nextchallenge, t.nextthreshold, t.nextnumfloors)
			elseif server.P_DungeonStatus.VR_challenge
				D_makeVoidChallenge()
			end
		end
	end


	if gen == GEN_DARK
		brightness = max(124, $/2)	-- low light
	elseif gen == GEN_DREAD
		brightness = max(142, $*2/3)	-- "reaper" light
	elseif gen == GEN_CLEAR
		brightness = 255	-- clear light
	end


	-- generate floor shit

	local numenemies = 0
	local numitems = 0

	local numspawn = 0			-- # of spawn, used for multi-parties
	local parties_spawn = {}	-- party # left to spawn
	local party_firstn = {}

	for i = 1, 4
		if not parties_spawn[i]
			for j = 1, 4
				if server.playerlist[i][j]
					party_firstn[i] = server.playerlist[i][j]
					break
				end
			end

			if party_firstn[i]
				parties_spawn[#parties_spawn+1] = i
				dprint("Added party "..i.." to spawn table")
			end
		end
	end

	local checkpoint		-- if true, ignore playerspawn tiles

	for i = 1, #map
		local s = sectors[i-1]

		s.lightlevel = brightness

		-- start by reseting floor height:
		s.floorheight = 0
		s.ceilingpic = ceil

		if not map[i]			-- wall
			if server.cdungeon

				if server.cdungeon.wallheight
					s.floorheight = server.cdungeon.wallheight*FRACUNIT
					s.ceilingheight = s.floorheight
				end
				if server.cdungeon.walltoptexture
					s.floorpic = server.cdungeon.walltoptexture
				end
			else
				s.floorheight = s.ceilingheight
			end


		elseif (map[i] == T_ITEM or map[i] == T_GOLDI) and not (server.P_netstat.buffer.load)		-- item/gold item (once / party): Don't spawn them if we're loading a Marathon save

			local gold = map[i] == T_GOLDI

			local allowgold = nil
			-- count parties?
			for p in players.iterate
				if p.P_party and p.P_party > 1
					allowgold = true
					break
				end
			end

			numitems = $+1

			map[i] = T_ITEM	-- cheat a little and always mark it as an item regardless

			if not allowgold
			and gold
				gold = nil
			end

			local r = P_SpawnMobj(0, 0, 0, MT_P3CHEST)
			server.DNG_entities[#server.DNG_entities+1] = r
			DNG_tpmobj(r, i)
			r.scale = FRACUNIT*12/10
			if gold
				r.state = S_P3_GOLDRANDOM1
				r.hitflags = 0
			end

			-- set the chest's contents:
			r.content = {}
			local tbl = server.items	-- possible list of items on this floor

			if tbl

				local newtable = {}
				for k,v in ipairs(tbl)
					for j = 1, v[2]
						newtable[#newtable+1] = v[1]
					end
				end

				-- how many items
				local numitems = P_RandomRange(1, 3)

				for j= 1, numitems do	-- max 2 items / chest
					local rng = P_RandomRange(1, #newtable)	-- rng seed
					table.insert(r.content, newtable[rng])	-- insert item in possible list
				end
			end

		elseif map[i] == T_ENEMY	-- enemy

			if server.P_DungeonStatus.VR_type == VC_HUNT
			and numenemies >= server.P_DungeonStatus.VR_target+1
				continue	-- Only have target+1 shadows on that floor.
			end

			local t = MT_SHEDEW

			if gen == GEN_PERFORATED
			or not P_RandomRange(0, 3)
			and not server.gamemode == GM_VOIDRUN	-- no unecessary floating shadows in void run
				t = MT_FOGSHADOW
			end

			local r = P_SpawnMobj(0, 0, 0, t)
			r.shadowflags = 0
			r.scale = FRACUNIT*8/10
			server.DNG_entities[#server.DNG_entities+1] = r
			DNG_tpmobj(r, i)
			-- so uh is it a strong shadow?

			local diff = 20 - server.difficulty

			if P_RandomRange(1, diff) == 1
			or gen == GEN_STRONG	-- 100% strong shadows in red floors
				r.shadowflags = $|SHF_STRONG
			end

			-- That shadow could be gold!
			if not (r.shadowflags & SHF_STRONG)	-- Let's not have strong gold shadows lmfao
			and not P_RandomRange(0, 32)		-- 1/32
			or gen == GEN_GOLD	-- 100% gold shadows in golden floors!
			or server.P_DungeonStatus.VR_type == VC_HUNT	-- in hunt, the shadow that spawns will always be gold.
				r.shadowflags = $|SHF_GOLD
			end

			numenemies = $+1

			--r.scale = FRACUNIT*2/3
		elseif map[i] == T_START	-- player spawn
		and not checkpoint
		and server.gentype ~= GEN_INTERFERENCE

			--print("Spawn #"..numspawn)

			if not numspawn
				for p in players.iterate do
					DNG_tpmobj(p.mo, i)
					if t.default and t.default.spawndir
						p.mo.angle = ANG1*t.default.spawndir
					elseif t.spawndir
						p.mo.angle = ANG1*t.spawndir	-- custom dungeons...
					end
				end
				-- by default, teleport everyone to the first spawn found. This is to ensure that everyone at least finds a spawn.
			end

			numspawn = $+1

			local spawned
			while not spawned and #parties_spawn

				if not #parties_spawn -- all parties spawned
					break
				end

				local index = P_RandomRange(1, #parties_spawn)
				local party = parties_spawn[index]
				local canspawn = true

				table.remove(parties_spawn, index)

				if canspawn	-- no duplicate, so let's do it
					--print("Can spawn!")
					for p in players.iterate do
						if p and p.mo and p.mo.valid and p.P_party == party
							DNG_tpmobj(p.mo, i)
							p.mo.dng_savesector = i	-- set default spawn location to the player spawn
						end
					end

					-- make the spawn a bit fancier:
					local ang = party_firstn[party].mo.angle

					if #server.playerlist[party] > 1	-- if there's only 1 player, keep them centered.

						local addang = 360 / #server.playerlist[party]
						local refx = party_firstn[party].mo.x
						local refy = party_firstn[party].mo.y

						for i = 1, #server.playerlist[party]
							if server.playerlist[party][i] and server.playerlist[party][i].valid
								local mo = server.playerlist[party][i].mo
								local x = refx + 48*cos(ang)
								local y = refy + 48*sin(ang)
								ang = $+ addang*ANG1
								P_TeleportMove(mo, x, y, mo.z)
							end
						end
					end

					spawned = true
				end
			end


		elseif map[i] == T_EXIT	-- "stairs"
			local r = P_SpawnMobj(0, 0, 0, MT_REDSPRING)
			server.DNG_entities[#server.DNG_entities+1] = r
			DNG_tpmobj(r, i)
			r.scale = FRACUNIT*2
			r.flags = MF_SCENERY
		elseif map[i] == T_CHECKPOINT	-- starpost
			local r = P_SpawnMobj(0, 0, 0, MT_STARPOST)
			server.DNG_entities[#server.DNG_entities+1] = r
			DNG_tpmobj(r, i)
			r.scale = FRACUNIT*3/2
			r.flags = MF_SCENERY|MF_NOCLIP

			if server.P_DungeonStatus.savefloor >= server.P_DungeonStatus.floor	-- already activated
				r.state = S_STARPOST_FLASH	-- make it activated by default
				checkpoint = true

				-- our players should spawn there, then!
				for p in players.iterate do
					DNG_tpmobj(p.mo, i)
					p.mo.angle = 0
					p.mo.eventclear = true	-- consider that we cleared the boss out for this floor.
				end
			end

		elseif map[i] == T_SHOP	-- shop point: enter shop by stepping on this tile

			local r = P_SpawnMobj(0, 0, 0, MT_DUMMY)
			server.DNG_entities[#server.DNG_entities+1] = r
			DNG_tpmobj(r, i)
			r.tics = -1
			r.scale = FRACUNIT*8/10	-- 80%
			r.sprite = SPR_SDOR
			r.frame = FF_PAPERSPRITE
			r.radius = 64<<FRACBITS
			r.height = 256<<FRACBITS
			r.flags = $|MF_SOLID	-- fuck you!

			local ang = 0
			if t.default and t.default.shopdir
				ang = t.default.shopdir*ANG1
			elseif t.shopdir	-- custom dungeons...
				ang = t.shopdir*ANG1
			end

			r.angle = ang
			ang =$+ANG1*90
			local newx = r.x + 90*cos(ang)
			local newy = r.y + 90*sin(ang)
			P_TeleportMove(r, newx, newy, r.z)

		elseif map[i] == T_BOSS	-- event point: forces a battle

			if server.P_DungeonStatus.savefloor < server.P_DungeonStatus.floor	-- otherwise, the boss was already beaten

				-- spawn the wave:
				-- select wave:
				local wave
				local r = P_SpawnMobj(0, 0, 0, MT_SHEDEW)
				server.DNG_entities[#server.DNG_entities+1] = r
				DNG_tpmobj(r, i)	-- teleport the mobj to the floor immediately

				--if mapheaderinfo[gamemap].tartarus	-- tartarus uses special kind of waves, it needs its own table since it's pretty long
				--or server.gamemode == GM_VOIDRUN
				wave = server.waves[P_RandomRange(1, #server.waves)]
				--else	-- for other dungeons
				--	local wave_sets = DNG_dungeonwaves[gamemap][server.P_DungeonStatus.section]
				--	wave = wave_sets[P_RandomRange(1, #wave_sets)]
				--end

				-- spawn the shadows from the wave in a circle
				local curangle = (t.default and t.default.eventdir) and t.default.eventdir*ANG1 or 0
				if t.eventdir
					curangle = t.eventdir*ANG1
				end	-- custom dungeons...
				local dist = 96

				if #wave == 2
					curangle = $+ANG1*90	-- it's cooler that way
				elseif #wave == 1
					dist = 0	-- spawn directly at the center
				end

				local curentity = r

				for i = 1,#wave

					local x = r.x + dist*cos(curangle)
					local y = r.y + dist*sin(curangle)

					local enm = P_SpawnMobj(x, y, 0, MT_PFIGHTER)
					enm.state = S_PLAY_STND
					enm.tics = -1
					enm.enemy = wave[i]
					if t.default and t.default.eventdir
						enm.angle = t.default.eventdir*ANG1
					elseif t.eventdir
						enm.angle = t.eventdir*ANG1		-- custom dungeons...
					end

					-- init enemy's standing animation and start it
					local tbl = enemyList[enm.enemy]
					if tbl
						enm.anim_stand = tbl.anim_stand or {SPR_PLAY, A, 1}
						ANIM_set(enm, enm.anim_stand)
						if tbl.color
							enm.color = tbl.color
						end

						if tbl.boss and tbl.endboss
							finalbossfloor = true
							dprint("Final boss floor")
						end

					else
						dprint("Enemy "..enm.enemy.." has no enemyList entry, cannot begin animation")
					end

					server.DNG_entities[#server.DNG_entities+1] = enm

					curentity.hnext = enm	-- build hnext list
					curentity = enm

					curangle = $+ 360/(#wave) *ANG1

				end

				r.eventshadow = true
				r.eventwave = wave		-- saved to make sure we spawn the same enemies

				r.flags2 = $|MF2_DONTDRAW
				r.flags = MF_NOTHINK|MF_NOCLIPTHING
				if t.default and t.default.eventdir
					r.angle = t.default.eventdir*ANG1
				elseif t.eventdir
					r.angle = t.eventdir*ANG1	-- custom dungeons...
				end
			end

		elseif map[i] == T_PIT	-- pit
			s.floorheight = -256*FRACUNIT
			if server.cdungeon and server.cdungeon.pittexture
				s.floorpic = server.cdungeon.pittexture
			else
				s.floorpic = "PIT"
			end

		elseif map[i] == T_SPIKES	-- spikes
			s.floorheight = -100*FRACUNIT
			s.floorpic = "PIT"

			-- spawn spikes:
			local r = P_SpawnMobj(0, 0, -100*FRACUNIT, MT_DUMMY)
			r.sprite = SPR_USPK
			r.frame = A
			r.scale = $*4
			r.tics = -1
			server.DNG_entities[#server.DNG_entities+1] = r
			DNG_tpmobj(r, i)
			
			//Fewer spikes because they lag for some people
			-- Teleport random spikes near the one we just did:
			local spikepitnumber
			if fewerspikes.value
				spikepitnumber = 12
			else
				spikepitnumber = 24
			end
			for i = 1, spikepitnumber
				local x = r.x + P_RandomRange(-100, 100)*FRACUNIT //xdiff
				local y = r.y + P_RandomRange(-100, 100)*FRACUNIT //ydiff

				local s = P_SpawnMobj(x, y, -100*FRACUNIT, MT_DUMMY)
				s.sprite = SPR_USPK
				s.frame = A
				s.scale = $*4
				s.tics = -1

				server.DNG_entities[#server.DNG_entities+1] = s		-- add them to the table too so that they get removed when we switch floors!
			end

		elseif map[i] == T_FLOORSPIKES
			-- welp:
			local r = P_SpawnMobj(0, 0, 1, MT_DUMMY)
			DNG_tpmobj(r, i)

			//I wonder if these spikes also lag for people?
			local spikegridnumber
			if fewerspikes.value
				spikegridnumber = 4 //16 spikes
			else
				spikegridnumber = 5 //25 spikes
			end
			local x = r.x - gridsize/2 + gridsize/(spikegridnumber*2)
			local y = r.y - gridsize/2 + gridsize/(spikegridnumber*2)

			for i = 1, spikegridnumber*spikegridnumber

				local s = P_SpawnMobj(x, y, 1, MT_SPIKE)
				s.flags = $|MF_NOGRAVITY|MF_SOLID	-- why do they.. clip through the floor???
				s.flags = $ & ~(MF_NOBLOCKMAP)
				s.scale = FRACUNIT + FRACUNIT/4
				s.height = $*3/4
				s.radius = $*2
				server.DNG_entities[#server.DNG_entities+1] = s


				if i%spikegridnumber == 0
					x = r.x - gridsize/2 + gridsize/(spikegridnumber*2)
					y = $+ gridsize/spikegridnumber
				else
					x = $+ gridsize/spikegridnumber
				end
			end

			P_RemoveMobj(r)	-- remove dummy

		elseif map[i] == T_GATE

			dprint("got gate")
			s.floorheight = FRACUNIT*256

			if server.cdungeon and server.cdungeon.wallheight
				s.floorheight = server.cdungeon.wallheight*FRACUNIT
				s.ceilingheight = s.floorheight
			end

			local r = P_SpawnMobj(0, 0, 0, MT_SHSWITCH)
			r.flags = $|MF_NOCLIPTHING
			server.DNG_entities[#server.DNG_entities+1] = r	-- we'll teleport that later

			r.extravalue1 = i-1	-- sectors are indexes from 0 to 2047!!
			local colours = {SKINCOLOR_RED, SKINCOLOR_BLUE, SKINCOLOR_YELLOW}
			local flats = {"GATER", "GATEB", "GATEY"}
			switches[#switches+1] = r
			s.floorpic = flats[#switches] or "GATER"
			r.color = colours[#switches] or SKINCOLOR_YELLOW
			r.angle = #switches


		elseif map[i] == T_RINGS	-- rings
			local r = P_SpawnMobj(0, 0, 128*FRACUNIT, MT_RINGCLUSTER)
			server.DNG_entities[#server.DNG_entities+1] = r
			DNG_tpmobj(r, i)
		end

		--if 1 continue end	-- test

		local sec = s
		if pitorwall(map[i])

			local up,down,left,right,diag1,diag2,diag3,diag4
			local upn,downn,leftn,rightn,diag1n,diag2n,diag3n,diag4n

			if map[i-48]
				up = pitorwall(map[i-48])
			end

			if map[i+48]
				down = pitorwall(map[i+48])
			end

			if map[i-1]
			and i%48 ~= 1
				left = pitorwall(map[i-1])
			end

			if map[i+1]
			and i%48 ~= 0
				right = pitorwall(map[i+1])
			end

			if map[i-49]
			and i%48 ~= 1
				diag1 = pitorwall(map[i-49])
			end

			if map[i-47]
			and i%48 ~= 0
				diag2 = pitorwall(map[i-47])
			end

			if map[i+49]
			and i%48 ~= 0
				diag3 = pitorwall(map[i+49])
			end

			if map[i+47]
			and i%48 ~= 1
				diag4 = pitorwall(map[i+47])
			end

			sec.floorpic = prefix.."F0"

			-- From there we can assume the following;
			-- nil/0 = wall
			-- anything else = walkable surface


			-- This happens to be near a wall.
			-- It will be overwritten if any other condition is met.

			-- Corners

			if not diag1
			//and up and right and down and left
				sec.floorpic = prefix.."F20"
			end

			if not diag2
			//and up and right and down and left
				sec.floorpic = prefix.."F21"
			end

			if not diag3
			//and up and right and down and left
				sec.floorpic = prefix.."F22"
			end

			if not diag4
			//and up and right and down and left
				sec.floorpic = prefix.."F23"
			end

			-- normal walls

			if not left
			and up and right and down
				sec.floorpic = prefix.."F7"
			end

			if not up
			and left and right and down
				sec.floorpic = prefix.."F8"
			end

			if not right
			and left and up and down
				sec.floorpic = prefix.."F9"
			end

			if not down
			and up and right and left
				sec.floorpic = prefix.."F10"
			end

			-- 2corner

			if not diag1 and not diag3
			and up and down
				sec.floorpic = prefix.."F44"
			end

			if not diag2 and not diag4
			and left and right
				sec.floorpic = prefix.."F45"
			end

			-- More specific corners

			if not diag1 and not diag2
			and up and down and left and right
				sec.floorpic = prefix.."F28"
			end

			if not diag2 and not diag3
			and up and down and left and right
				sec.floorpic = prefix.."F29"
			end

			if not diag3 and not diag4
			and up and down and left and right
				sec.floorpic = prefix.."F30"
			end

			if not diag4 and not diag1
			and up and down and left and right
				sec.floorpic = prefix.."F31"
			end

			-- this one is pretty damn frustrating.

			if not diag1 and not right
			and up and down and left
				sec.floorpic = prefix.."F32"
			end

			if not diag2 and not down
			and up and left and right
				sec.floorpic = prefix.."F33"
			end

			if not diag3 and not left
			and up and down and right
				sec.floorpic = prefix.."F34"
			end

			if not diag4 and not up
			and right and down and left
				sec.floorpic = prefix.."F35"
			end

			-- frustration (2)

			if not diag2 and not left
			and up and down and right
				sec.floorpic = prefix.."F36"
			end

			if not diag3 and not up
			and down and left and right
				sec.floorpic = prefix.."F37"
			end

			if not diag4 and not right
			and up and down and left
				sec.floorpic = prefix.."F38"
			end

			if not diag1 and not down
			and right and up and left
				sec.floorpic = prefix.."F39"
			end

			-- W-Wait... there's three of them!?

			if not diag1 and not diag2 and not diag3
			and up and down and left and right
				sec.floorpic = prefix.."F40"
			end

			if not diag2 and not diag3 and not diag4
			and up and down and left and right
				sec.floorpic = prefix.."F41"
			end

			if not diag3 and not diag4 and not diag1
			and up and down and left and right
				sec.floorpic = prefix.."F42"
			end

			if not diag4 and not diag1 and not diag2
			and up and down and left and right
				sec.floorpic = prefix.."F43"
			end



			-- Two walls are near.

			if not left and not up
			and right and down
				sec.floorpic = prefix.."F11"
			end

			if not right and not up
			and left and down
				sec.floorpic = prefix.."F12"
			end

			if not right and not down
			and left and up
				sec.floorpic = prefix.."F13"
			end

			if not left and not down
			and right and up
				sec.floorpic = prefix.."F14"
			end

			-- Vertical lined corridor

			if up and down
			and not left and not right
				sec.floorpic = prefix.."F1"
			end

			-- Horizontal lined corridor

			if left and right
			and not up and not down
				sec.floorpic = prefix.."F2"
			end

			-- Turn (down to right)

			if down and right
			and not up and not left
			and not diag3
				sec.floorpic = prefix.."F3"
			end

			-- Turn (down to left)
			if down and left
			and not up and not right
			and not diag4
				sec.floorpic = prefix.."F4"
			end

			-- Turn (right to up)
			if right and up
			and not down and not left
			and not diag2
				sec.floorpic = prefix.."F6"
			end

			-- Turn (left to up)
			if left and up
			and not down and not right
			and not diag1
				sec.floorpic = prefix.."F5"
			end

			-- Dead end

			if down
			and not up and not left and not right
				sec.floorpic = prefix.."F24"
			end

			if left
			and not up and not right and not down
				sec.floorpic = prefix.."F25"
			end

			if up
			and not down and not left and not right
				sec.floorpic = prefix.."F26"
			end

			if right
			and not left and not down and not up
				sec.floorpic = prefix.."F27"
			end

			-- Intersection between 2 perpendicular paths

			if left and up and down and right
			and not diag1
			and not diag2
			and not diag3
			and not diag4
				sec.floorpic = prefix.."F15"
			end


			if up and left and right
			and not down
			and not diag1
			and not diag2
				sec.floorpic = prefix.."F16"
			end

			if right and up and down
			and not left
			and not diag2
			and not diag3
				sec.floorpic = prefix.."F17"
			end

			if down and left and right
			and not up
			and not diag3
			and not diag4
				sec.floorpic = prefix.."F18"
			end

			if left and up and down
			and not right
			and not diag1
			and not diag4
				sec.floorpic = prefix.."F19"
			end


			if not usetiles
				sec.floorpic = prefix	-- custom dungeons
			end
		end

		local nl = #sec.lines
		for k=0, nl
			local v = sec.lines[k]
			if not v or not v.valid continue end

			/*if map[i] == T_PIT
				--print("Sec "..#sec..": Adding line #"..k.." ("..#v..")")
				climblines[#climblines+1] = #v
			end*/

			local t = texture+P_RandomRange(0,range)
			if map[i] == T_GATE
				t = R_TextureNumForName("GATER") + (#switches-1)	-- GATER, GATEB, GATEY

				-- apply it in specifc ways....
				if v.frontsector and v.frontsector.floorheight < sec.floorheight
				and v.backsector and v.backsector == sec
					v.frontside.bottomtexture = t
					v.frontside.toptexture = t
				end

				if v.backsector and v.backsector.floorheight < sec.floorheight
				and v.frontsector and v.frontsector == sec
					v.backside.bottomtexture = t
					v.backside.toptexture = t
				end

				continue	-- don't apply normal textures
			end

			if v.frontside
			and v.frontside.bottomtexture
				v.frontside.bottomtexture = t
			end

			if v.backside
			and v.backside.bottomtexture
				v.backside.bottomtexture = t
			end
		end

		-- for interference gen type: get every player on random spots because it's funny
		if server.gentype == GEN_INTERFERENCE
			for p in players.iterate do

				local s = P_RandomRange(0, 2047)
				while server.map[s] ~= T_EMPTY
					s = P_RandomRange(0, 2047)
				end

				DNG_tpmobj(p.mo, s)
			end
		end

		-- Teleport switches generated from the gate somewhere random
		for i = 1, #switches
			local set
			while not set
				local m = P_RandomRange(0, 2047)

				if server.map[m] == T_EMPTY
					DNG_tpmobj(switches[i], m)
					switches[i].flags = $ & ~MF_NOCLIPTHING
					set = true
				end
			end
		end
	end

	if server.gamemode == GM_VOIDRUN
	and server.P_DungeonStatus.VR_type == VC_INFILTRATION
		server.P_DungeonStatus.VR_target = max(1, numitems-1)
	end
end

local function DNG_updateMap()
	dprint("Updating map data...")
	local mapn = 1
	for i = 1, server.P_DungeonStatus.floor
		if (server.gamemode == GM_VOIDRUN and VR_floorData[i])
		or (server.cdungeon and server.cdungeon.floordata[i])
		or (not server.cdungeon and server.gamemode == GM_COOP and DNG_floorData[i])
			mapn = i
		end
	end
	-- choose preset at random in there
	if server.gamemode == GM_VOIDRUN	-- voidrun
		return VR_floorData[mapn][P_RandomRange(1, #DNG_floorData[mapn])]
	elseif server.cdungeon	-- custom dungeon
		return mapn
	else					-- tartarus
		return DNG_floorData[mapn][P_RandomRange(1, #DNG_floorData[mapn])]
	end
end

-- copies the wave table (yes the copy part is important or we fuck up a lot of stuff)
local function DNG_setWaves(waves)
	server.waves = {}
	for i = 1, #waves do
		server.waves[i] = copyTable(waves[i])
	end
end

rawset(_G, "DNG_updateWave", function()

	if mapheaderinfo[gamemap].tartarus	-- normal gameplay
	or server.gamemode == GM_VOIDRUN
	or server.cdungeon

		local flr = server.P_DungeonStatus.floor
		-- we don't actually care about floor # in Void Run, only challenge #.
		if server.gamemode == GM_VOIDRUN
			flr = server.P_DungeonStatus.VR_challenge or 1
		end

		for i = 0, flr

			if server.cdungeon	-- custom dungeons

				if server.cdungeon.enemies[i]
					DNG_setWaves(server.cdungeon.enemies[i])
				end

				server.items = server.cdungeon.itemdrops	-- items cannot change per floor

			elseif server.gamemode == GM_COOP	-- tartarus

				if DNG_waves[i]
					DNG_setWaves(DNG_waves[i])
				end
				if mapheaderinfo[gamemap].tartarus and tartarus_items[i]
					server.items = tartarus_items[i]
				end
			elseif server.gamemode == GM_VOIDRUN	-- void run

				-- same updates with the VR tables
				if VR_waves[i]
					DNG_setWaves(VR_waves[i])
				end
				if VR_items[i]
					server.items = VR_items[i]
				end
			end
		end
		if not server.waves
			server.waves = DNG_waves[1]
		end

		if not server.items
			server.items = tartarus_items[1]	-- fallback
		end
	elseif server.P_DungeonStatus
	and DNG_dungeonwaves[gamemap]
		-- normal waves
		DNG_setWaves(DNG_dungeonwaves[gamemap][server.P_DungeonStatus.section])
		--server.waves = DNG_dungeonwaves[gamemap][server.P_DungeonStatus.section]
	end

	if server.roguemode	-- hahahahaha....
	and server.waves
		for i = 1, #server.waves
			for j = 1, #server.waves[i]
				--print(server.waves[i][j])
				server.waves[i][j] = ROGUE_initEnemyStats($) or $	-- keep the original enemy if we failed to generate the new enemy
			end
		end
	end
end)

rawset(_G, "DNG_setFloor", function(f)

	--climblines = {}
	SRB2P_runHook("DungeonNextFloor")

	if server.savelights
		for i = 0, 2047
			 sectors[i].lightlevel = server.savelights[i]
		end
		server.savelights = nil
	end

	-- make players invincible:
	for p in players.iterate do
		p.powers[pw_flashing] = TICRATE*3 -1
		local mo = p.mo
		if not mo continue end
		mo.eventclear = nil	-- reset this
		mo.spr_nfloor = nil	-- reset this too

		-- TODO: FOR SP CHECK SAVE FOR ALREADY BEATEN EVENTS
	end

	server.P_DungeonStatus.floor = f
	server.rendermap = {}
	for i = 1, 4
		server.rendermap[i] = {}
	end

	-- clear old entities if possible
	if server.DNG_entities and #server.DNG_entities
		local i = #server.DNG_entities
		while i
			local m = server.DNG_entities[i]
			if m and m.valid
				P_RemoveMobj(m)
			end
			i = $-1
		end
	end

	-- If the floor we're supposed to set is a transitional floor, then act accordingly;
	local transitionfloors = {10, 24, 44, 64, 89}
	if server.gamemode == GM_COOP
	and mapheaderinfo[gamemap].tartarus
		for i = 1, #transitionfloors do
			if f == transitionfloors[i]

				server.blocktrans = 1
				-- This timer will go up and take care of the rest.
				dprint("Beginning block transition")

				-- Change music
				S_ChangeMusic("BLCKT", false, nil, nil, nil, MUSICRATE/2)
				return	-- Don't bother generating the floor
			end
		end
	end

	DNG_updateWave()
	server.curpreset = DNG_updateMap()

	DNG_generatefloor(server.curpreset, f)

	-- set titlecard
	local t = {}
	if mapheaderinfo[gamemap].entryname
		t[1] = mapheaderinfo[gamemap].entryname
	end

	-- in the case of dungeons...
	if gamemap == srb2p.tartarus_play
		local block = DNG_returnBlock(server.P_DungeonStatus.floor)
		t[1] = "Tartarus, "..blocknames[block]

		-- should we change the music?
		if leveltime < 10	-- level has just started, so yes
		or blockfloor[block]	-- we just started a new block (shouldn't happen in MP in theory?)
			--S_ChangeMusic("BLOCK"..block, true)

			for p in players.iterate do
				COM_BufInsertText(p, "tunes "..DNG_getTartarusMusic(block))
			end
			-- this sets the "default map tune".
			-- yes this is positively stupid.
		end

	elseif server.cdungeon
		t[1] = server.cdungeon.name

		--if leveltime < 10
			for p in players.iterate do
				COM_BufInsertText(p, "tunes "..server.cdungeon.dungeonmusic)
			end
		--end



	elseif server.gamemode == GM_VOIDRUN
	and server.P_DungeonStatus.VR_timer

		local challengemus = (((server.P_DungeonStatus.VR_challenge-1)/3) +1 )%5

		if not (challengemus%5)
			challengemus = 5
		end

		challengemus = $ or 1

		local cmusic = "VRCH"..challengemus
		--S_ChangeMusic(cmusic, true, p, 0, 0, 300)
		for p in players.iterate do
			COM_BufInsertText(p, "tunes "..cmusic)
		end
	end

	if server.P_DungeonStatus.floor

		if server.P_DungeonStatus.floor > (FRACUNIT-1)	-- kind of a hack
			t[2] = "B"..(server.P_DungeonStatus.floor - (FRACUNIT-1)).."F"

		elseif server.gamemode == GM_VOIDRUN
			local challenge = (server.P_DungeonStatus.VR_challenge /3) + 1

			local mission = server.P_DungeonStatus.VR_challenge%3 or 3
			t[1] = "VOID RUN"

			if mission%3 == 0
				challenge = $-1
			end

			if server.P_DungeonStatus.VR_timer == nil
				t[2] = mission == 1 and "Starting Area" or "Safe Zone"
			else
				t[2] = "Challenge "..challenge..", Mission "..mission
			end

		else
			t[2] = (server.P_DungeonStatus.floor).."F"
		end
	end
	if #t
		DNG_entryCard(t)
	end

	local reapertimer = 0
	if reapertimers[server.difficulty]
		reapertimer = reapertimers[server.difficulty]
	end

	--if cv_reaper.value
	if server.gamemode == GM_COOP
	and reapertimer
		server.P_DungeonStatus.reapertimer = (reapertimer)*TICRATE*60

		if server.gentype == GEN_DREAD
			server.P_DungeonStatus.reapertimer = TICRATE*30
		elseif server.gentype == GEN_DARK
		or server.gentype == GEN_INTERFERENCE
			server.P_DungeonStatus.reapertimer = $*3/2	-- x1.5
		elseif server.gentype == GEN_GOLD
		or server.gentype == GEN_STRONG
			server.P_DungeonStatus.reapertimer = $/2	-- faster
		end
	end

	if finalbossfloor and server.gamemode ~= GM_VOIDRUN
		S_FadeOutStopMusic(MUSICRATE*2)
		finalbossfloor = nil
	end

	if server.gentype ~= GEN_NORMAL	-- special floor?

		local notes = {
		[GEN_PERFORATED] = "Better watch your step...",
		[GEN_STRONG] = "The shadows are restless...",
		[GEN_GOLD] = "Glimmering sparkles echo in the halls...",
		[GEN_DREAD] = "The atmosphere is extremely heavy...",
		[GEN_INTERFERENCE] = "I t    re ce, c  't   p  u    e f  o . .",
		[GEN_DARK] = "Tread carefully...",
		[GEN_CLEAR] = "All clear, floor all mapped out!",
		}

		DNG_logMessage("\x82"..notes[server.gentype])
	end

	dprint("Floor set.")
end)