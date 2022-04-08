
local entity_pos = {}
-- {x, y, z, angle, strong}

local function DNG_check_stairs_uncovered(p, n)
	if server.map[n] == T_EXIT
	and not server.P_DungeonStatus.stairsfound
		server.P_DungeonStatus.stairsfound = true
		DNG_logMessage("\x82"..p.name.."\x80".." found the ".."\x83".."Spring".."\x80".."!")
	end
end


-- have players fill the map by walking
local function DNG_fillmap()

	if server.gentype == GEN_INTERFERENCE
		return	-- No minimap filling during interference!
	end

	for p in players.iterate do
		local mo = p.mo
		if not mo continue end

		local map = server.map
		-- this is the map index we are in

		local w, h = 48,48	-- width and height of the map borders

		local sec = mo.subsector.sector
		local t = server.map

		local up,down,left,right,diag1,diag2,diag3,diag4
		local upn,downn,leftn,rightn,diag1n,diag2n,diag3n,diag4n

		if not t or not #t return end	-- oops

		for k,v in ipairs(t)
			if k == #sec

				local i = k+1

				if t[i-48] ~= nil
					up = t[i-48]
					upn = i-48
				end

				if t[i+48] ~= nil
					down = t[i+48]
					downn = i+48
				end

				if t[i-1] ~= nil
				and i%48 ~= 1
					left = t[i-1]
					leftn = i-1
				end

				if t[k+1] ~= nil
				and i%48 ~= 0
					right = t[i+1]
					rightn = i+1
				end

				if t[i-49] ~= nil
				and i%48 ~= 1
					diag1 = t[i-49]
					diag1n = i-49
				end

				if t[i-47] ~= nil
				and i%48 ~= 0
					diag2 = t[i-47]
					diag2n = i-47
				end

				if t[i+49] ~= nil
				and i%48 ~= 0
					diag3 = t[i+49]
					diag3n = i+49
				end

				if t[i+47] ~= nil
				and i%48 ~= 1
					diag4 = t[i+47]
					diag4n = i+47
				end
			end
		end

		local n = tonumber(#sec+1)

		-- always check for all squares around the player to make map filling easier.

		local m = server.rendermap[p.P_party]
		if not m continue end

		if n
			if m[n] == nil
				m[n] = map[n]
				DNG_check_stairs_uncovered(p, n)
			end
		end

		if tonumber(upn)
			if m[tonumber(upn)] == nil
				m[tonumber(upn)] = tonumber(up)
				DNG_check_stairs_uncovered(p, upn)
			end
		end

		if tonumber(downn)
			if m[tonumber(downn)] == nil
				m[tonumber(downn)] = tonumber(down)
				DNG_check_stairs_uncovered(p, downn)
			end
		end

		if tonumber(leftn)
		if m[tonumber(leftn)] == nil
				m[tonumber(leftn)] = tonumber(left)
				DNG_check_stairs_uncovered(p, leftn)
			end
		end

		if tonumber(rightn)
			if m[tonumber(rightn)] == nil
				m[tonumber(rightn)] = tonumber(right)
				DNG_check_stairs_uncovered(p, rightn)
			end
		end

		if tonumber(diag1n)
			if m[tonumber(diag1n)] == nil
				m[tonumber(diag1n)] = tonumber(diag1)
				DNG_check_stairs_uncovered(p, diag1n)
			end
		end

		if tonumber(diag2n)
			if m[tonumber(diag2n)] == nil
				m[tonumber(diag2n)] = tonumber(diag2)
				DNG_check_stairs_uncovered(p, diag2n)
			end
		end

		if tonumber(diag3n)
			if m[tonumber(diag3n)] == nil
				m[tonumber(diag3n)] = tonumber(diag3)
				DNG_check_stairs_uncovered(p, diag3n)
			end
		end

		if tonumber(diag4n)
			if m[tonumber(diag4n)] == nil
				m[tonumber(diag4n)] = tonumber(diag4)
				DNG_check_stairs_uncovered(p, diag4n)
			end
		end
	end
end

local function DNG_tartarusSynch()
	-- ready synch shit (EXPERIMENTAL)
	for i = 1, #server.DNG_entities
		local e = server.DNG_entities[i]
		if e and e.valid and DNG_isShadow(e)
			entity_pos[i] = {e.x, e.y, e.z, e.angle, e.shadowflags, e.type}
		end
	end

	if server.mustresetentities
		DNG_resetEntitiesForJoiner()
		server.mustresetentities = nil
	end
end

local function DNG_tartarusReaper()
	-- reaper stuff:
	local d = server.P_DungeonStatus
	if d.reapertimer ~= nil
	and not (d.noreaper)
	--and cv_reaper.value
	and server.gamemode == GM_COOP
		d.reapertimer = $-1

		if d.reapertimer <= 0
		and not (server.reaper and server.reaper.valid)

			-- check if NO ONE is in a battle
			local run
			for i = 1, 4
				if server.P_BattleStatus[i].running
				and #server.P_BattleStatus[i].fighters
					run = true
					break
				end
			end

			if not run
				D_spawnReaper()
			end
		end
	end

	if server.gamemode == GM_VOIDRUN
	and d.VR_type == VC_INFILTRATION
	and d.VR_timer ~= nil
	and not server.reaper
		D_spawnReaper()
	end
end

-- tartarus dungeon crawling (and VR)
rawset(_G, "D_tartarusCrawler", function()
	if not (DNG_isTartarusMap()) return end
	if not server.map or not #server.map return end	-- map hasn't fully generated yet, just wait a bit.
	local d = server.P_DungeonStatus

	DNG_tartarusSynch()

	if server.blocktrans
		-- Do block transition
		for p in players.iterate do
			PLAY_nomove(p)
		end


		server.blocktrans = $+1

		if server.blocktrans == TICRATE*2
			server.difficulty = $+1	-- increase difficulty.
			-- Raise everyone's levelcaps

			for i = 1, #server.plentities do
				for j = 1, server.P_netstat.teamlen
					if server.plentities[i][j]
					and server.plentities[i][j].valid
						server.plentities[i][j].levelcap = difficulty_cap[server.difficulty] or 99	-- ???
					end
				end
			end

			S_StartSound(nil, sfx_lvup)
		end

		if server.blocktrans == TICRATE*5
			S_FadeOutStopMusic(MUSICRATE)	-- stop the transition music for the next block
		end

		if server.blocktrans == TICRATE*6
			server.blocktrans = nil
			server.P_DungeonStatus.floor = $+1
			server.P_DungeonStatus.stairsfound = nil
			server.P_DungeonStatus.savefloor = server.P_DungeonStatus.floor
			DNG_setFloor(server.P_DungeonStatus.floor)
			for p in players.iterate do
				PLAY_move(p)
			end

			-- raise emerald pow cap
			for i = 1, 4
				local btl = server.P_BattleStatus[i]
				if btl
					btl.emeraldpow_max = $+1
				end
			end

		end
		return
	end

	DNG_fillmap()			-- map out the floor
	DNG_tartarusReaper()	-- handle reaper spawning


	-- check if we've reached the stairs
	local stairplayers, totalplayers = 0, 0
	local i = 0	-- # of iterarions

	for p in players.iterate
		if p.mo and p.mo.valid

			if not p.P_party continue end
			if server.P_BattleStatus[p.P_party].gameover continue end	-- don't count gameover'd players
			totalplayers = $+1

			if not (server.P_BattleStatus[p.P_party] and server.P_BattleStatus[p.P_party].running)
			and (server.map[#p.mo.subsector.sector+1] == T_EXIT or p.quittime)
				stairplayers = $+1
			end
		end
	end

	for p in players.iterate
		local mo = p.mo
		if not mo continue end

		if p.charability ~= CA_GLIDEANDCLIMB	-- leave that on
		and p.charability ~= CA_TWINSPIN
			p.charability = 0
		end
		--CA_ClimbHack(p)	-- see above, prevents climbing non-pit lines
		-- @FIXME: fuck this

		-- flashtics
		if P_IsObjectOnGround(mo)
		and mo.spikehits
			p.powers[pw_flashing] = TICRATE*3 -1
			mo.spikehits = nil
		end

		if server.P_BattleStatus[p.P_party] and server.P_BattleStatus[p.P_party].running

			-- spawn smoke etc etc
			if leveltime%2 == 0
				for i=1,4
					local smoke = P_SpawnMobj(mo.x + P_RandomRange(-80, 80)*FRACUNIT, mo.y + P_RandomRange(-80, 80)*FRACUNIT, mo.z + P_RandomRange(0, 150)*FRACUNIT, MT_DUMMY)
					smoke.state = S_AOADUST1
					smoke.scale = FRACUNIT*3
					smoke.destscale = FRACUNIT*5
					smoke.momz = P_RandomRange(0, 2)*FRACUNIT
					P_InstaThrust(smoke, P_RandomRange(0, 359)*ANG1, P_RandomRange(0, 2)*FRACUNIT)
				end
			end

			if (leveltime%10) == 0
				local h = P_SpawnMobj(mo.x + P_RandomRange(-100, 100)<<FRACBITS, mo.y + P_RandomRange(-100, 100)<<FRACBITS, mo.z + P_RandomRange(0, 40)<<FRACBITS, MT_DUMMY)
				h.state = S_HURTB1
				h.scale = FRACUNIT*4 + P_RandomRange(-FRACUNIT/4, FRACUNIT/2)
				h.eflags = $ | MFE_VERTICALFLIP*P_RandomRange(0, 1)
			end

			if leveltime%16 == 0
				S_StartSoundAtVolume(mo, sfx_hit2, 127)
			end
			continue
		end

		if D_ReadyBattle(p) continue end

		-- player initialization: (A hack if anything weird happens to the player)
		if not mo.pinit
			-- get them to the floor entrance if we're in tartarus

			for i = 1, 2048
				local block = server.map[i]
				if block == 4
					DNG_tpmobj(mo, i)
					break
				end
			end
			mo.scale = server.mo.scale
			mo.angle = server.mo.angle
			p.powers[pw_flashing] = TICRATE*3-1
			mo.pinit = true
			-- this teleports the p to the server and gives em everything they should have~
		end

		local evt_startbattle
		-- someone standing on event space:
		if server.map[#mo.subsector.sector+1] == T_BOSS	-- miniboss event space
		and not mo.eventclear
		--and not (d.savefloor >= d.floor)
			/*local donealready
			for p2 in players.iterate do
				-- if anyone else in the party has stepped here, don't let me step here

				if p2 and p2.mo and p2.mo.valid and p2.P_party == mo.player.P_party
				and p2.mo.evt_startbattle
					donealready = true
					break
				end
			end

			-- if we don't do that we can actually softlock the game by having multiple players step on here, oops!
			if not donealready*/
			evt_startbattle = true
			--end
		end

		if evt_startbattle
			for p2 in players.iterate
				if p.P_party ~= p2.P_party continue end	-- only my party
				local mo2 = p2.mo
				if not mo2 continue end
				PLAY_nomove(p2)
				P_InstaThrust(mo2, 0, 0)
				if mo2.evt_startbattle
					mo2.evt_startbattle = max($, mo.evt_startbattle)
				else
					mo2.evt_startbattle = mo.evt_startbattle or 0
				end
			end

			if not mo.evt_startbattle
				mo.evt_startbattle = 0
			end
			mo.evt_startbattle = $+1

			if mo.evt_startbattle > TICRATE*2

				evt_startbattle = nil	-- don't start 2 battles, lol
				-- select wave:
				local wave

				-- remove the boss thing
				for k,v in ipairs(server.DNG_entities)
					if v and v.valid and v.eventwave
						wave = v.eventwave
						local cur = v.hnext
						local cnext
						-- remove hnext list
						while cur
							cnext = cur.hnext
							--P_RemoveMobj(cur)
							if consoleplayer.P_party == p.P_party
								cur.flags2 = $|MF2_DONTDRAW	-- multiparty
							end
							cur = cnext
						end

						--P_RemoveMobj(v)
						if consoleplayer.P_party == p.P_party
							v.flags2 = $|MF2_DONTDRAW
						end
						break
					end
				end

				if not wave	-- this shouldn't happen, ever
					wave = DNG_getRandomWave()
				end

				-- start the battle from the players

				local mus = MUS_PlayRandomBattleMusic("mus_battle_mb")
				local party = p.P_party
				BTL_start(party, wave, 2, mus, nil, true)

				-- Clear the event garbage
				for p2 in players.iterate
					if p2.P_party ~= p.P_party continue end
					local mo2 = p2.mo
					if not mo2 continue end
					mo2.eventclear = true	-- used to not trigger the event after battle again
					mo2.evt_startbattle = nil	-- reset this for everyone just in case
				end
			end
		end

		i = $+1

		if mo.spr_floorbuf
			mo.spr_floorbuf = $-1
			if mo.spr_nfloor
				mo.spr_nfloor = nil
				mo.p_battlebuf = nil
				mo.startbattle = nil
				PLAY_move(mo.player)
				mo.spr_floorbuf = 0
			end
		end

		if mo.spr_nfloor
			mo.spr_nfloor = $+1
			if totalplayers > stairplayers
				mo.spr_nfloor = min(2, $)	-- do not progress furhter.
			end
		end

		local teamplayers = 0
		local teamonstairs = 0

		for p2 in players.iterate do
			if p2.P_party ~= p.P_party continue end
			if not (p2.mo and p2.mo.valid) or p2.quittime continue end

			teamplayers = $+1
			if server.map[#p2.mo.subsector.sector+1] == 5
				teamonstairs = $+1
			end
		end

		if teamplayers and teamonstairs >= teamplayers or stairplayers >= totalplayers		--stairplayers >= totalplayers	-- everyone is on the "stairs"

			for p2 in players.iterate do
				local mo2 = p2.mo
				if not mo2 continue end
				
				//Just in case, because of what I'm doing with p.quittime
				if server.map[#p2.mo.subsector.sector+1] == 5 and server.map[#p.mo.subsector.sector+1] ~= 5
					P_TeleportMove(p.mo, p2.mo.x, p2.mo.y, p2.mo.z)
				end

				if not p2.P_party continue end
				if server.P_BattleStatus[p2.P_party].gameover continue end
				if p2.P_party ~= p.P_party continue end


				mo2.d_f12text = stairplayers < totalplayers

				if not mo2.spr_nfloor	-- dumb timer
					mo2.spr_nfloor = 1
					P_DoPlayerPain(p2)
					P_InstaThrust(mo2, 0, 0)
					PLAY_nomove(p2)
					mo2.flags2 = $|MF2_DONTDRAW
					p2.pflags = $|PF_GODMODE
					p2.pflags = $ & ~(PF_JUMPED|PF_THOKKED)

					-- start animation; a fake player that looks like it's springing
					local fake = P_SpawnMobj(mo2.x, mo2.y, mo2.z, MT_DUMMY)
					fake.flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT
					fake.fuse = TICRATE
					fake.color = mo2.color
					fake.skin = mo2.skin
					fake.angle = mo2.angle
					fake.state = S_PLAY_SPRING
					fake.momz = 32<<FRACBITS

					if p2 == p	-- only do this once pls
						for j = 1, #server.DNG_entities do
							local m = server.DNG_entities[j]
							if m and m.valid and m.type == MT_REDSPRING
								m.state = S_REDSPRING2
								S_StartSound(m, sfx_spring)
								break
							end
						end
					end

				elseif mo2.spr_nfloor >= TICRATE
					if stairplayers >= totalplayers
						-- goto next floor

						-- SPECIAL CASE FOR TARTARUS ONLY
						if (server.gamemode == GM_COOP and gamemap == srb2p.tartarus_play and server.P_DungeonStatus.floor+1) == 112	-- this may need to be a constant
							DNG_loadNewMap(5)

							return
						end

						if p2 == p
							for i = 1, 4
								server.P_BattleStatus[i].netstats.floors = $+1

								-- case of a game over:
								if server.P_BattleStatus[i].gameover
									local btl = server.P_BattleStatus[i]
									btl.r_wipe = 1
									BTL_finish(i)
									for j = 1, 4
										if server.plentities[i][j] and server.plentities[i][j].valid
											server.plentities[i][j].hp = server.plentities[i][j].maxhp
											server.plentities[i][j].sp = server.plentities[i][j].maxsp
										end
									end
								end
							end
							server.P_DungeonStatus.floor = $+1
							server.P_DungeonStatus.stairsfound = nil
							DNG_setFloor(server.P_DungeonStatus.floor)
							server.reaper = nil
						end

						PLAY_move(p2)
						mo2.spr_nfloor = nil
						mo2.flags2 = $ & ~MF2_DONTDRAW
						p2.pflags = $ & ~PF_GODMODE

						for p3 in players.iterate
							if p3.mo and p3.mo.valid
								PLAY_move(p3)	-- bruh
								p3.mo.p_battlebuf = nil
								p3.mo.startbattle = nil
								p3.mo.spr_nfloor = nil
								p3.mo.spr_floorbuf = TICRATE
							end
						end

					else
						mo2.spr_nfloor = TICRATE
					end
				else
					mo2.momz = 0
					mo2.flags2 = $|MF2_DONTDRAW
					PLAY_nomove(p2)
				end
			end
		end

		if server.map[#mo.subsector.sector+1] and server.map[#mo.subsector.sector+1] <= T_START
			mo.dng_savesector = #mo.subsector.sector+1
		end

		-- the shop / item lab
		if server.map[#mo.subsector.sector+1] == T_SHOP
		and mo.d_lastmapspace ~= T_SHOP	-- we weren't already on a shop last frame.
			/*local shoptype = "velvet_shop_mp1"

			if server.gamemode == GM_VOIDRUN
				shoptype = "void_shop"
			end

			DNG_startShop(mo, shoptype)*/
			M_openMenu(mo, "m_selectfacility")
		end

		-- star post:
		if server.map[#mo.subsector.sector+1] == T_CHECKPOINT
			if d.savefloor < d.floor

				for j = 1, #server.DNG_entities do
					local m = server.DNG_entities[j]
					if m and m.valid and m.type == MT_STARPOST
						m.state = S_STARPOST_STARTSPIN
						S_StartSound(m, sfx_strpst)
						d.savefloor = d.floor
						d.savepos = #mo.subsector.sector+1
						DNG_logMessage("\x82".."Checkpoint activated!")
					end
				end
			end

			-- allow saving...
			if server.marathon
				if mo.P_inputs[BT_BTNC] == 1
					M_openMenu(mo, "mp_qsave")
				end
				mo.m_savebutton = $ and $+1 or 1
				if mo.m_savebutton == 1
					S_StartSound(nil, sfx_select, mo.player)
				end
			end
		else
			mo.m_savebutton = 0
		end

		-- spikes:
		if server.map[#mo.subsector.sector+1] == T_SPIKES
		and mo.z < 0	-- big pain!
		and not mo.spr_pain

			S_StartSound(mo, sfx_spkdth)	-- spikes
			S_StartSound(mo, sfx_s3kb9)		-- rings

			-- spill fake rings
			for i = 1, 8
				local ring = P_SpawnMobj(mo.x, mo.y, mo.z, MT_FLINGRING)
				ring.momx = P_RandomRange(-16, 16)*FRACUNIT
				ring.momy = P_RandomRange(-16, 16)*FRACUNIT
				ring.momz = P_RandomRange(0, 16)*FRACUNIT
				ring.flags = $ & ~MF_SPECIAL
				ring.fuse = TICRATE
			end

			VFX_Play(mo, VFX_DIE)			-- big pain
			DNG_Damage(p.maincontrol, p.maincontrol.maxhp/10)

			local h = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
			h.flags = mo.flags|MF_NOCLIPHEIGHT
			h.angle = mo.angle
			h.scale = mo.scale
			h.skin = mo.skin
			h.color = mo.color
			h.momz = FRACUNIT*18
			h.fuse = TICRATE
			h.state = S_PLAY_PAIN
			--P_InstaThrust(mo, 0, 0)
			mo.momz = 0
			mo.flags2 = $|MF2_DONTDRAW
			PLAY_nomove(p)
			mo.spr_pain = TICRATE
		end

		if mo.spr_pain
			mo.spr_pain = $-1
			P_InstaThrust(mo, 0, 0)
			mo.momz = 0
			mo.flags2 = $|MF2_DONTDRAW

			if not mo.spr_pain
				-- teleport me back:
				PLAY_move(p)
				mo.flags2 = $ & ~MF2_DONTDRAW
				p.powers[pw_flashing] = TICRATE*3 -1

				local s = mo.dng_savesector
				while s == nil or server.map[s] == T_PIT or server.map[s] == T_SPIKES or not server.map[s]	-- !!!
					local tmp = P_RandomRange(1, #server.map)
					if map[tmp] == 1
						s = tmp
					end
				end
				mo.z = 0
				DNG_tpmobj(mo, s)
				p.pflags = $ & ~(PF_JUMPED|PF_SPINNING)
				mo.state = S_PLAY_STND
			end
		end


		-- death pits:
		if server.map[#mo.subsector.sector+1] == T_PIT
		and mo.z < -((p.pflags & PF_JUMPED or mo.p_abl or p.climbing) and 128 or 2)*FRACUNIT -- you fell (tm)
		and not mo.spr_pit
			S_StartSound(mo, sfx_s3k51)
			VFX_Play(mo, VFX_DIE)
			mo.spr_pit = TICRATE

			emotionBubble(mo, EMOTE_SURPRISED, 128*FRACUNIT)

			local h = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
			h.flags = mo.flags|MF_NOCLIPHEIGHT
			h.angle = mo.angle
			h.scale = mo.scale
			h.skin = mo.skin
			h.color = mo.color
			h.state = S_PLAY_PAIN
			h.momx = mo.momx*2/3
			h.momy = mo.momy*2/3
			h.momz = mo.momz
			h.fuse = TICRATE
			--P_InstaThrust(mo, 0, 0)
			mo.momz = 0
			mo.flags2 = $|MF2_DONTDRAW
			PLAY_nomove(p)
		end
		if mo.spr_pit
			mo.spr_pit = $-1
			P_InstaThrust(mo, 0, 0)
			mo.momz = 0
			mo.flags2 = $|MF2_DONTDRAW

			if not mo.spr_pit
				-- teleport me back:
				PLAY_move(p)
				mo.flags2 = $ & ~MF2_DONTDRAW
				p.powers[pw_flashing] = TICRATE*3 -1

				local s = mo.dng_savesector
				while s == nil or server.map[s] == T_PIT or server.map[s] == T_SPIKES	-- !!!
					local tmp = P_RandomRange(1, #server.map)
					if server.map[tmp] == 1
						s = tmp
					end
				end
				mo.z = 0
				DNG_tpmobj(mo, s)
				p.pflags = $ & ~(PF_JUMPED|PF_SPINNING)
				mo.state = S_PLAY_STND
				DNG_Damage(p.maincontrol, p.maincontrol.maxhp/10)
				S_StartSound(nil, sfx_hit2, p)
			end
		end

		mo.d_lastmapspace = server.map[#mo.subsector.sector+1]
	end
end)
