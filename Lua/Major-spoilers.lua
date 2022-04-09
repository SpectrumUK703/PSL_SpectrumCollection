//Feel free to use this skill, its code is copied from SRB2P anyway
attackDefs["all_out-alt"] = {
		name = "All-Out Attack",
		type = ATK_ALMIGHTY,
		power = -1,	-- negative power is a special case for all out attacks
		accuracy = 999,
		costtype = CST_HPPERCENT,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 100,
		desc = "Stop hacking your skills!!",
		target = TGT_ALLENEMIES,

		hudfunc = 	function(v, mo, timer)	// hud function, drawn at the same time as the attack. Use it for cool effects!
		
						//A copy of the drawHoldUp function
						if timer <= (TICRATE*2)
							local holdupstart = (TICRATE*2) - timer
							local btl = server.P_BattleStatus[mo.battlen]

							-- hud "ALL DOWN" at the start of the effect:
							local t = (TICRATE - ((holdupstart-TICRATE)*2))
							local t2 = (t<<FRACBITS) /3
							local t3 = t2
							t3 = FixedMul(t3, t3)
							t3 = $+ FixedMul(t3, t2)

							v.drawIndex((83)<<FRACBITS +t3/3, (83)<<FRACBITS +t3/8, FRACUNIT/2, v.cachePatch("H_HOLD1"), 0, 31)
							v.drawIndex((80)<<FRACBITS +t3/3, (80)<<FRACBITS +t3/8, FRACUNIT/2, v.cachePatch("H_HOLD1"), 0, 0)
							v.drawIndex((133)<<FRACBITS -t3/3, (93)<<FRACBITS -t3/7, FRACUNIT/2, v.cachePatch("H_HOLD2"), 0, 31)
							v.drawIndex((130)<<FRACBITS -t3/3, (90)<<FRACBITS -t3/7, FRACUNIT/2, v.cachePatch("H_HOLD2"), 0, 0)

							-- second half, draw the prompts
							if holdupstart > TICRATE return end

							local t = TICRATE - holdupstart
							local t2 = max(0, TICRATE-(t+20))
							/*if btl.hudtimer.aoarelent
								t = 35-(btl.hudtimer.aoarelent*5)
								t2 = 64 - btl.hudtimer.aoarelent*8
							end*/

							-- draw prompter portrait...

							local patch = "H_AOA"..min(3, (t/2)+1)
							if v.patchExists(patch)
								drawScreenwidePatch(v, v.cachePatch(patch))
							end

							local pp = v.cachePatch(charStats[mo.stats].hudaoa or enemyList[mo.enemy].hudaoa)
							if mo.status_condition == COND_SUPER
							and (charStats[mo.stats].hudsaoa or enemyList[mo.enemy].hudsaoa)
								pp = v.cachePatch(charStats[mo.stats].hudsaoa or enemyList[mo.enemy].hudsaoa)
							end

							v.drawScaled((-25 - t2*32)<<FRACBITS, (20)<<FRACBITS, FRACUNIT*2/3, pp, V_SNAPTOLEFT|V_SNAPTOBOTTOM, v.getColormap(TC_DEFAULT, mo.color))	-- draw @ full scale

							-- draw "AOA or RELENT" prompt

							local gfx = (btl.holdupfinish or SAVE_localtable.tutorial) and "2" or ""

							PDraw(v, 190 - t2*32, 50, v.cachePatch("H_AOABT"..gfx))
							v.drawIndex((190 -t2*32 +2)<<FRACBITS, 52<<FRACBITS, FRACUNIT/2, v.cachePatch("H_AOAT"..gfx), 0, 31)
							PDraw(v,  190- t2*32, 50, v.cachePatch("H_AOAT"..gfx))

							-- slide text box in your DMs:
							pp = v.cachePatch("H_AOATX")
							PDraw(v, min(0, -250 + t*32), 200, pp, V_SNAPTOLEFT|V_SNAPTOBOTTOM)
							-- get text:
							local txt = charStats[mo.stats] and charStats[mo.stats].aoa_quote or enemyList[mo.enemy] and enemyList[mo.enemy].aoa_quote or "Here's our chance!"
							V_drawString(v, 10, 158, txt, "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31, FRACUNIT*2/3)
						end

						//SRB2P's AOA hudanim, but with all the timers offset by TICRATE*2 for the drawHoldUp copy
						-- transition around 280 tics
						if timer > 275 + (TICRATE*2)
						and timer < 290 + (TICRATE*2)
							local t = timer-275 - (TICRATE*2)
							local p = "H_ATR"..t/2
							if v.patchExists(p)
								drawScreenwidePatch(v, v.cachePatch(p))
							end
						end

						-- the attack has just started: draw a fake AOA overlay like we just confirmed or w/e...
						-- draw prompter portrait...
						if timer < 70 + (TICRATE*2)

							-- draw prompter portrait...

							drawScreenwidePatch(v, v.cachePatch("H_AOA3"))
							local btl = server.P_BattleStatus[mo.battlen]

							-- draw "AOA or RELENT" prompt
							v.drawIndex((190 +2)<<FRACBITS, 52<<FRACBITS, FRACUNIT/2, v.cachePatch("H_AOAT"..((btl.holdupfinish or SAVE_localtable.tutorial) and "2" or "")), 0, 31)
							PDraw(v,  190, 50, v.cachePatch("H_AOAT"..((btl.holdupfinish or SAVE_localtable.tutorial) and "2" or "")))

							local pp = v.cachePatch(charStats[mo.stats] and charStats[mo.stats].hudaoa or enemyList[mo.enemy].hudaoa or "")
							if mo.status_condition == COND_SUPER
								if charStats[mo.stats] and charStats[mo.stats].hudsaoa
									pp = v.cachePatch(charStats[mo.stats].hudsaoa)
								elseif enemyList[mo.enemy].hudsaoa
									pp = v.cachePatch(enemyList[mo.enemy].hudsaoa)
								end
							end
							v.drawScaled((-25)<<FRACBITS, (20)<<FRACBITS, FRACUNIT*2/3, pp, V_SNAPTOLEFT|V_SNAPTOBOTTOM, v.getColormap(TC_DEFAULT, mo.color))	-- draw @ full scale

							-- slide text box in your DMs:
							pp = v.cachePatch("H_AOATX")
							PDraw(v, 0, 200, pp, V_SNAPTOBOTTOM|V_SNAPTOLEFT)
							-- get text:
							local txt = charStats[mo.skin] and charStats[mo.skin].aoa_quote or enemyList[mo.enemy].aoa_quote or "Here's our chance!"
							V_drawString(v, 10, 158, txt, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31, FRACUNIT*2/3)


							-- new shit
							local aoat = v.cachePatch("H_AOAB")
							v.drawScaled(190<<FRACBITS, 50<<FRACBITS, max(FRACUNIT/2, FRACUNIT*12 - (timer - (TICRATE*2))*FRACUNIT*3/2), aoat)

							-- glowing text
							if timer > 10 + (TICRATE*2)
								v.drawScaled(190<<FRACBITS, 50<<FRACBITS, max(1, 3*sin((timer-(TICRATE*2)-10)*6*ANG1)), aoat, V_TRANSLUCENT)
							end

							-- big fill circle
							if timer > 50 + (TICRATE*2)
								v.drawScaled(190<<FRACBITS, 50<<FRACBITS, (timer-(TICRATE*2)-50)*FRACUNIT/2, v.cachePatch("H_1M_B"))
							end
						elseif timer < 180 + (TICRATE*2)
							v.drawFill(0, 0, 999, 999, 135|V_SNAPTOTOP|V_SNAPTOLEFT)

							if timer == 51 + (TICRATE*2)
								phud.clear("allout", displayplayer)
							end

							if timer == 75 + (TICRATE*2) or timer == 76 + (TICRATE*2)
								v.drawFill(0, 0, 999, 999, 0|V_SNAPTOTOP|V_SNAPTOLEFT)
								for i = 1, 10
									local part = phud.create(mo.battlen, N_RandomRange(0, 320), N_RandomRange(30, 170), "AOAPART"..N_RandomRange(1, 7), -1, nil, "allout")
									part.momx = N_RandomRange(10, 25)
									part.momy = 2
									part.physflags = PF_NOGRAVITY
									part.scale = N_RandomRange(FRACUNIT/2 - FRACUNIT/8, FRACUNIT/2 + FRACUNIT/8)
									part.deleteoffscreen = nil
									part.fuse = TICRATE*5
								end
								if timer == 75 + (TICRATE*2)
									--S_StartSound(nil, sfx_aoasli)
								end
							end

							if timer > 76 + (TICRATE*2)
								-- black background:
								drawScreenwidePatch(v, v.cachePatch("H_ABG1"))

								if leveltime%2 == 0
									local part = phud.create(mo.battlen, -20, N_RandomRange(30, 170), "AOAPART"..N_RandomRange(1, 7), -1, nil, "allout")
									part.momx = N_RandomRange(23, 30)
									part.momy = 2
									part.flags = V_50TRANS
									part.physflags = PF_NOGRAVITY
									part.scale = N_RandomRange(FRACUNIT/8 - FRACUNIT/15, FRACUNIT/8 + FRACUNIT/15)
									part.deleteoffscreen = nil
									part.fuse = TICRATE*5
								end

								DisplayPhysHUD(v, "allout", displayplayer)	-- displayed behind the characters

								-- particles in FRONT of the characters, there's less of them...
								if leveltime%3 == 0
									local part = phud.create(mo.battlen, -30, N_RandomRange(30, 170), "AOAPART"..N_RandomRange(1, 7), -1, nil, "main")
									part.momx = N_RandomRange(26, 32)
									part.momy = 2
									part.physflags = PF_NOGRAVITY
									part.scale = N_RandomRange(FRACUNIT/6 - FRACUNIT/10, FRACUNIT/6 + FRACUNIT/10)
									part.deleteoffscreen = nil
									part.fuse = TICRATE*5
								end

								-- when leveltime is big enough to start transitionning, spanw a metric fuckton of those particles to start the transition
								if timer > 160 + (TICRATE*2)
									for i = 1, 5
										local part = phud.create(mo.battlen, N_RandomRange(-200, -100), N_RandomRange(-50, 250), "AOAPART"..N_RandomRange(1, 7), -1, nil, "main")
										part.momx = N_RandomRange(26, 32)
										part.momy = 2
										part.physflags = PF_NOGRAVITY
										part.scale = N_RandomRange(FRACUNIT/6 - FRACUNIT/10, FRACUNIT/6 + FRACUNIT/10)
										part.deleteoffscreen = nil
										part.fuse = TICRATE*5
									end
								end

								-- draw our player
								local i = #mo.allies
								local t = timer - (TICRATE*2) - 76
								while i

									local xcoord = min(52*(i-1), (i-1)*t*8) + t/8*i
									if timer > 130 + (i*2) + (TICRATE*2)
										xcoord = $ + (timer-(TICRATE*2)-(130+i*2))^2
									end

									local m = mo.allies[i]

									if BTL_noAOAStatus(m)
										i = $-1
										continue		-- Not me, I can't act!
									end

									local pp = v.cachePatch(charStats[mo.allies[i].stats] and charStats[mo.allies[i].stats].hudaoa or enemyList[mo.allies[i].enemy].hudaoa or "")
									if mo.allies[i].status_condition == COND_SUPER
										if charStats[mo.allies[i].stats] and charStats[mo.allies[i].stats].hudsaoa
											pp = v.cachePatch(charStats[mo.allies[i].stats].hudsaoa)
										elseif enemyList[mo.allies[i].enemy].hudsaoa
											pp = v.cachePatch(enemyList[mo.allies[i].enemy].hudsaoa)
										end
									end
									PDraw(v, xcoord, 30 - 4*i, pp, 0, v.getColormap(TC_DEFAULT, mo.allies[i].color))
									i = $-1
								end
							end
						end
					end,
		anim = function(mo, targets, hittargets, timer)

				local function noaoa(mo)
					return BTL_noAOAStatus(mo)
				end

				server.P_BattleStatus[mo.battlen].aoa = true

				-- damage enemies:
				local stoptimer = 280
				if timer == stoptimer + 50 + (TICRATE*2)
					for i = 1, #targets	-- er, even if there's a weird repel, damage targets instead of hittargets
						damageObject(targets[i])
						targets[i].down = false
					end
				elseif timer == stoptimer + 100 + (TICRATE*2)
					return true
				end

				local fatal
				local fatalcount = 0
				for i = 1, #targets
					if targets[i].atk_hpremaining <= 0
						fatalcount = $+1
					end
				end

				fatal = fatalcount >= #targets


				local cam = server.P_BattleStatus[mo.battlen].cam
				if timer == 1 + (TICRATE*2)
					-- save camera coords, expected to be still from target select
					cam.aoa_savecoords = {cam.x, cam.y, cam.z, cam.angle, cam.aiming}
					playSound(mo.battlen, sfx_aoado)
				elseif timer == 75 + (TICRATE*2)
					playSound(mo.battlen, sfx_aoasli)
				end


				-- average the coordinates of the targets...
				local avx, avy = 0, 0
				for i = 1, #targets
					avx = $+ targets[i].x/FRACUNIT
					avy = $+ targets[i].y/FRACUNIT
				end
				avx = ($ /#targets)*FRACUNIT
				avy = ($ /#targets)*FRACUNIT

				if timer > stoptimer + (TICRATE*2)

					-- teleport all our players somewhere close enough to the center
					for i = 1, #mo.allies do
						local m = mo.allies[i]

						if noaoa(m)
							continue	-- Not me! I can't act!
						end

						if timer == stoptimer+1 + (TICRATE*2)
							local newx = avx + 32*cos(m.aoa_savecoords[4])
							local newy = avy + 32*sin(m.aoa_savecoords[4])
							P_TeleportMove(m, newx, newy, m.floorz)
							m.angle = m.aoa_savecoords[4]
							ANIM_set(m, m.anim_aoa_end, true)

							-- reset the camera
							if cam.aoa_savecoords
								P_TeleportMove(cam, cam.aoa_savecoords[1], cam.aoa_savecoords[2], cam.aoa_savecoords[3])
								cam.angle = cam.aoa_savecoords[4]
								cam.aiming = cam.aoa_savecoords[5]
								cam.aoa_savecoords = nil
							end

						elseif timer == stoptimer+10 + (TICRATE*2)	-- send the players back where they came from (ROUGHLY)
							local dist = P_AproxDistance(m.aoa_savecoords[1] - m.x, m.aoa_savecoords[2] - m.y)
							local airtime = TICRATE*3/2
							local horizontal = dist / airtime
							local vertical = FixedMul((gravity*airtime)/2, m.scale)

							m.momx = FixedMul(-horizontal, cos(m.angle))
							m.momy = FixedMul(-horizontal, sin(m.angle))
							m.momz = vertical

							-- spawn the explosion for the first player (this avoids having to make ANOTHER check or w/e)
							-- it's different depending on whether or not all the enemies were killed or not
							if i == 1
								local all_wiped = 0
								for j = 1, #targets
									if targets[j].atk_hpremaining <= 0
										all_wiped = $+1
									end
									if all_wiped >= #targets	-- we killed all the enemies
										-- spawn this cool ass skull explosion
										-- column:
										for i = 1,16
											local dust = P_SpawnMobj(avx+P_RandomRange(-40, 40)*FRACUNIT, avy+P_RandomRange(-40, 40)*FRACUNIT, targets[1].z+P_RandomRange(0, 450)*FRACUNIT, MT_DUMMY)
											dust.state = S_AOADUST0
											dust.scale = FRACUNIT*5
											dust.destscale = FRACUNIT*15
											dust.tics = (dust.z - dust.floorz)/FRACUNIT	/ 30
										end
										-- skull:
										for j = 1,64
											local dust = P_SpawnMobj(avx+P_RandomRange(-150, 150)*FRACUNIT, avy+P_RandomRange(-150, 150)*FRACUNIT, targets[1].z+P_RandomRange(350, 600)*FRACUNIT, MT_DUMMY)
											dust.state = S_AOADUST0
											dust.scale = FRACUNIT*5
											dust.destscale = FRACUNIT*15
											dust.tics = (dust.z - dust.floorz)/FRACUNIT	/ 30
										end
										-- skull eyes
										local caman = R_PointToAngle(avx, avy) + 180*ANG1
										local coords = {	-- these coords are added to avx, avy and targets 1 z
											{avx + 70*cos(ANG1*90 + caman), avy + 70*sin(ANG1*90 + caman), 650*FRACUNIT},		-- eye 1
											{avx + 70*cos(-ANG1*90 + caman), avy + 70*sin(-ANG1*90 + caman), 650*FRACUNIT},	-- eye 2
											{avx + 8*cos(-ANG1*90 + caman), avy + 8*sin(-ANG1*90 + caman), 550*FRACUNIT},	-- nose 1
											{avx + 8*cos(ANG1*90 + caman), avy + 8*sin(ANG1*90 + caman), 550*FRACUNIT},	-- nose 2
										}
										for j = 1, #coords
											for f = 1, 5
												local d = P_SpawnMobj(coords[j][1] + P_RandomRange(-8, 8)*FRACUNIT, coords[j][2] + P_RandomRange(-8, 8)*FRACUNIT, coords[j][3] + P_RandomRange(-16, 16)*FRACUNIT, MT_DUMMY)
												d.state = S_CDUST0
												d.tics = (d.z - 530*FRACUNIT)/FRACUNIT / 5 + P_RandomRange(0, 8)
												d.color = SKINCOLOR_BLACK
												d.scale = (j < 3 and FRACUNIT*5 or FRACUNIT*2) + P_RandomRange(-FRACUNIT/4, FRACUNIT/4)
												-- move towards cam:
												local newx = d.x + 200*cos(caman)
												local newy = d.y + 200*sin(caman)
												P_TeleportMove(d, newx, newy, d.z)
											end
										end

									else						-- nvm

									end
								end
									-- spawn a ring of dust regardless
								for j = 1,16
									local dust = P_SpawnMobj(avx, avy, targets[1].z, MT_DUMMY)
									dust.angle = ANGLE_90 + ANG1* (22*(j-1))
									dust.state = S_AOADUST1
									dust.scale = FRACUNIT*5
									dust.destscale = FRACUNIT*10
									P_InstaThrust(dust, dust.angle, 36*FRACUNIT)
								end
							end
						elseif timer > stoptimer+15 + (TICRATE*2)
							if P_IsObjectOnGround(m)
							and m.aoa_savecoords
								P_InstaThrust(m, 0, 0)
								ANIM_set(m, m.anim_stand, true)
								m.aoa_savecoords = nil
							end
						end
					end

				elseif timer > 150 + (TICRATE*2)

					if timer == 180 + (TICRATE*2)	-- the camera will be moving so playing the sound from nil seems like a better idea
						S_StartSound(server.P_BattleStatus[mo.battlen].cam, sfx_aoa_1)
					end

					-- by the time the timer hits 180 we will be showing the attack
					local gox = avx + 900*cos((leveltime)*ANG1)
					local goy = avy + 900*sin((leveltime)*ANG1)
					-- simply teleport the camera, we don't need it to transition with CAM_goto

					P_TeleportMove(cam, gox, goy, targets[1].z + 350<<FRACBITS)
					cam.aiming = -ANG1*3
					cam.angle = R_PointToAngle2(gox, goy, avx, avy)

					local caman = R_PointToAngle(avx, avy) + ANG1*180

					if (leveltime%10) == 0
						local h = P_SpawnMobj(avx + P_RandomRange(-100, 100)<<FRACBITS, avy + P_RandomRange(-100, 100)<<FRACBITS, targets[1].z + P_RandomRange(0, 40)<<FRACBITS, MT_DUMMY)
						h.state = S_HURTB1
						h.scale = FRACUNIT*4 + P_RandomRange(-FRACUNIT/4, FRACUNIT/2)
						h.eflags = $ | MFE_VERTICALFLIP*P_RandomRange(0, 1)
						-- pull towards cam
						P_TeleportMove(h, h.x + 100*cos(caman), h.y + 100*sin(caman), h.z)
					end

					if leveltime%2 == 0
						for i=1,6
							local smoke = P_SpawnMobj(avx + P_RandomRange(-150, 150)*FRACUNIT, avy + P_RandomRange(-150, 150)*FRACUNIT, targets[1].z + P_RandomRange(0, 250)*FRACUNIT, MT_DUMMY)
							smoke.state = S_AOADUST1
							smoke.scale = FRACUNIT*5
							smoke.destscale = FRACUNIT*9
							smoke.momz = P_RandomRange(3, 8)*FRACUNIT
						end
					end

					local ring_rate = max(5, 15 -(timer-180-(TICRATE*2))/7)

					if leveltime%ring_rate == 0
					and not fatal
						for i=1,2
							local ring = P_SpawnMobj(avx, avy, targets[1].z + 70*FRACUNIT, MT_FLINGRING)
							ring.momz = P_RandomRange(4, 10)*FRACUNIT
							P_InstaThrust(ring, P_RandomRange(1, 359)*ANG1, P_RandomRange(4, 10)*FRACUNIT)
							ring.fuse = TICRATE*5
							ring.flags = $1 & ~MF_SPECIAL
							if i == 1
								S_StartSound(ring, sfx_s3kb9)
							end
						end
					end

					for i = 1, #mo.allies

						local m = mo.allies[i]

						if noaoa(m)
							continue	-- Not me! I can't act either!
						end

						if timer == 151 + (TICRATE*2)
							ANIM_set(m, m.anim_atk, true)
							-- save our default coordinates and our angle towards the average coord
							m.aoa_savecoords = {m.x, m.y, m.z, R_PointToAngle2(m.x, m.y, avx, avy)}
						end

						-- our "axis" is a roating point around the average coord of the targets

						local an1 = leveltime * 24*ANG1 + i*ANG1*90
						local bx = avx + 200*cos(an1)
						local by = avy + 200*sin(an1)

						-- now we have what to circle around of
						local an2 = leveltime/i + 25*ANG1 + i*45*ANG1
						local x = bx + 200*cos(an2)
						local y = by + 200*sin(an2)
						local z = targets[1].z + R_PointToDist2(x, y, avx, avy)/3 + i*3/2*18*FRACUNIT + 128*sin(i*3*leveltime*ANG1)

						P_TeleportMove(m, x, y, z)
						m.angle = an2 + ANG1*90
						P_SpawnGhostMobj(m)

						/*
						local opq = P_SpawnMobj(x, y, z, MT_DUMMY)
						opq.frame = $ & ~FF_TRANSMASK
						opq.frame = $|FF_FULLBRIGHT
						opq.color = m.color
						opq.fuse = 2*/
						-- spawn trail
						local trail = P_SpawnMobj(x, y, z, MT_DUMMY)
						trail.frame = $|FF_FULLBRIGHT
						trail.color = m.color
						trail.destscale = 1
						trail.fuse = TICRATE
					end
				end

			end,
	}

enemyList["reaper_alt"].level = 94 //Not like anyone's gonna see its actual level lol
enemyList["reaper_alt"].skills = {	"megidolaon", "power charge", "mind charge",
									"megaton raid", "vicious strike", "marakunda", "heat riser",
									"marakunda", "masukunda", "matarunda", "maragidyne", "mabufudyne",
									"fire amp", "ice amp", "elec amp", "wind amp", "psy amp", "nuke amp", "bless amp", "curse amp",
									"magarudyne", "maziodyne", "mafreidyne", "mapsiodyne", "tetrakarn", "makarakarn",
									"dekaja", "dekunda", "infinite endure"}
enemyList["alt"].noroguebuff = false //I want to make her stronger lol
enemyList["alt"].hudaoa = "H_ALT05"
enemyList["alt"].anim_aoa_end = {SPR_VALT, G, H, 10}
enemyList["alt"].anim_atk = {SPR_VALT, A, 2}
//Thanks to SpringFox for this line
enemyList["alt"].aoa_quote = "Mh? Is that it? \nHow disappointing~"

if CV_FindVar("monadrematch") then return end
local monadrematch = CV_RegisterVar({
	name = "monadrematch",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	possiblevalue = CV_OnOff
})

enemyList["reaper_alt"].thinker = function(mo)
						local btl = server.P_BattleStatus[mo.battlen]
						mo.thinkercalls = $ and $+1 or 1
						if server and server.roguemode and monadrematch.value == 1
							if mo.thinkercalls == 1
								if P_RandomChance(FRACUNIT/2)
									return attackDefs["mind charge"], {mo}
								else
									return attackDefs["power charge"], {mo}
								end
							elseif mo.thinkercalls == 2
								D_startEvent(mo.battlen, "ev_b7_start_rematch")
								return newEnemyThinker(mo)
							end
						elseif server.reaperdefeated
							D_startEvent(mo.battlen, "ev_b7_start_reaperdefeated")
						else
							D_startEvent(mo.battlen, "ev_b7_start")
						end
						return attackDefs["heat riser"], {mo}
					end

enemyList["alt"].thinker = function(mo)
		
					-- Alt thinker
					-- This thinker kinda sucks and could maybe use some optimization, but it does its job, I suppose...
					
					mo.deathanim = true	-- hack since there are isolated cases of this not working?
					
					local function alt_changePersona(alt, persona, pinch)
						alt.persona = personaList[persona]
						local p = alt.persona
						alt.weak = p.weak or 0
						alt.resist = p.resist or 0
						alt.drain = p.drain or 0
						alt.block = p.block or 0
						
						-- set skill lists:
						local pskills
						
						if not pinch and mo.name ~= "Re: Alt"
							pskills = {
								
								["pixie_alt"] = {
									"panta rhei",
									"thunder reign",
									"magarudyne",
									"maziodyne",
									"mind charge",
									"elec boost",
									"wind boost",
									"dekaja",
									"dekunda",
									"patra",
								},
								
								["alice_alt"] = {
									"evil smile",
									"maeigaon",
									"mudoon",
									"megidolaon",
									"mapsiodyne",
									"trisagion",
									"curse boost",
									"fire boost",
									"psy boost",
									"psiodyne",
									"eigaon",
								},	
								
								["kfrost_alt"] = {
									
									"ice boost",
									"nuke boost",
									"niflheim",
									"mabufudyne",
									"marakunda",
									"mafreidyne",
									"atomic flare",
								},
								
								["metatron_alt"] = {
									
									"hamaon",
									"megaton raid",
									"brave blade",
									"vicious strike",
									"makougaon",
									"kougaon",
									"bless boost",
								},
							}	
						elseif pinch and mo.name == "Re: Alt"	//Even harder skills?
								
							pskills = {
								
								["pixie_alt"] = {
									"panta rhei",
									"thunder reign",
									"megidolaon",
									"megagarula",
									"maziodyne",
									"mind charge",
									"elec amp",
									"wind amp",
									"dekaja",
									"dekunda",
									"patra",
									"elec boost",
									"wind boost",
									"heat riser",
									"shock boost",
									"resist dizzy",
									"null sleep",
								},
								
								["alice_alt"] = {
									"evil smile",
									"ghastly wail",
									"maeigaon",
									"die for me",
									"die for me",
									"die for me",
									"megidolaon",
									"psycho force",
									"mapsiodyne",
									"trisagion",
									"curse amp",
									"fire amp",
									"psy amp",
									"maragidyne",
									"eggion",
									"curse boost",
									"fire boost",
									"psy boost",
									"burn boost",
									"hex boost",
									"virus breath",
									"poison boost",
									"marakunda",
								},								

								["kfrost_alt"] = {
									
									"ice amp",
									"nuke amp",
									"niflheim",
									"mabufudyne",
									"marakunda",
									"mamakanda",
									"masukunda",
									"matarunda",
									"atomic flare",
									"mafreidyne",
									"ice boost",
									"nuke boost",
									"freeze boost",
									"resist burn",
									"megaton raid",
								},
								
								["metatron_alt"] = {
									
									"mahamaon",
									"megaton raid",
									"brave blade",
									"vicious strike",
									"akasha arts",
									"deathbound",
									"pralaya",
									"god hand",
									"myriad slashes",
									"agneyastra",
									"makougaon",
									"bless amp",
									"bless boost",
									"hard knuckle",
									"sharp edge",
									"hard stab",
									"debilitate",
									"megidolaon",
								},								
								
							}
							
						else	-- harder moves
								
							pskills = {
								
								["pixie_alt"] = {
									"panta rhei",
									"thunder reign",
									"megidolaon",
									"magarudyne",
									"maziodyne",
									"megidolaon",
									"mind charge",
									"elec amp",
									"wind amp",
									"dekaja",
									"dekunda",
									"patra",
								},
								
								["alice_alt"] = {
									"evil smile",
									"maeigaon",
									"mamudoon",
									"megidolaon",
									"mapsiodyne",
									"trisagion",
									"curse amp",
									"fire amp",
									"psy amp",
									"psiodyne",
									"eigaon",
									"die for me",
									"die for me",
								},								

								["kfrost_alt"] = {
									
									"ice amp",
									"nuke amp",
									"niflheim",
									"mabufudyne",
									"marakunda",
									"mamakanda",
									"masukunda",
									"matarunda",
									"atomic flare",
									"mafreidyne",
								},
								
								["metatron_alt"] = {
									
									"mahamaon",
									"megaton raid",
									"brave blade",
									"vicious strike",
									"deathbound",
									"pralaya",
									"god hand",
									"makougaon",
									"bless amp",
								},								
								
							}
							
						end
						
						if pskills[persona]
							alt.skills = pskills[persona]
							BTL_splitSkills(alt)
						end
						
						
					end
				
					local enemies = mo.enemies
					local unfortunate_victim = mo.enemies[P_RandomRange(1, #enemies)]
					
					local btl = server.P_BattleStatus[mo.battlen]
					local lastturn = btl.turnorder[2] ~= mo
					
					-- in case of 1mores, don't advance the AI, cast random skills with the currently equipped Persona
					if mo.batontouch 
						//Hehehe, I am evil
						if mo.name == "Re: Alt" and mo.phase and mo.phase >= 2 //She did say she can go all out haha
							local enemies = mo.enemies
							mo.knockeddown = 0
							for i,j in ipairs(enemies)
								if j.down or (j.hp == 0)
									mo.knockeddown = $+1
								end
							end
							if mo.knockeddown >= #enemies and not BTL_noAOAStatus(mo) and mo.hp
								D_startEvent(btl.n, "ev_b7_all_out")
								return attackDefs["all_out-alt"], enemies
							end
							local attack, targets = newEnemyThinker(mo)
							if (targets[1].status_condition ~= COND_SUPER)
							or attack.type == ATK_ALMIGHTY or attack.type == ATK_SUPPORT or attack.type == ATK_HEAL
								return attack, targets //Those three types of attacks are fine
							else
								local check = 0
								for i,j in pairs(targets)
									if j.status_condition ~= COND_SUPER
										check = j
									end
								end
								if check
									return attack, targets
								else
									local megipersonas = {"pixie_alt", "alice_alt", "metatron_alt"}
									if mo.persona == "kfrost_alt"
										alt_changePersona(mo, megipersonas[P_RandomRange(1, #megipersonas)], true)
									end
									return attackDefs["megidolaon"], enemies
								end
							end
						end
						
						return newEnemyThinker(mo)
					end
					
					mo.thinkercalls = $ and $+1 or 1	-- calls for current phase
					mo.totalcalls = $ and $+1 or 1		-- calls for total fight
					
					mo.phase = $ or 1	-- phase is determined by HP count
					
					
					local calls = mo.thinkercalls
					local totalcalls = mo.totalcalls
					
					-- open the battle with dekaja and heat riser
					if calls == 1
						alt_changePersona(mo, "pixie_alt")
						return attackDefs["dekaja"], enemies
					
					elseif calls == 2
						return attackDefs["heat riser"], {mo}
						
					end
					
					-- MODE 1: HP > 75%
					/*
						In this phase, go soft on the player, do highly telegraphed attacks and only go haywire after 6 turns.
					*/
					
					if mo.phase == 1
						
						-- phase shift
						if mo.hp < mo.maxhp*3/4	-- under 75% HP
						and not (mo.mindcharge or mo.powercharge) //don't waste a mind charge haha
							if mo.name == "Re: Alt"
								//Make her more powerful (129 in all stats. Yes, it's just a copy of the rogue mode buff)
								mo.strength = $*115/100
								mo.magic = $*115/100
								mo.agility = $*115/100
								mo.endurance = $*115/100
								mo.luck = $*115/100
							end
							alt_changePersona(mo, "pixie_alt")
							mo.phase = 2
							mo.thinkercalls = 2
							if btl.turnorder[2] == mo
								table.remove(btl.turnorder, 2)	-- remove self from turn order if phase shift overlaps, otherwise we'll screw everything over
							end
							return attackDefs["heat riser"], {mo}
						end
						
						-- turn 1: Metatron phys attacks
						if calls == 3
							alt_changePersona(mo, "metatron_alt")
							return attackDefs["vicious strike"], enemies
							
						elseif calls == 4
							return attackDefs["megaton raid"], {unfortunate_victim}
						
						
						-- turn 2: King Frost ice attacks, marakunda
						elseif calls == 5
							alt_changePersona(mo, "kfrost_alt")
							return attackDefs["niflheim"], {unfortunate_victim}
							
						elseif calls == 6
							return attackDefs["marakunda"], enemies
						
						-- turn 3: Alice, Fire + Death
						
						elseif calls == 7
							if mo.name == "Re: Alt"
								for i,j in pairs(mo.enemies)
									if isAttackTechnical(j, "trisagion") //Muhahaha!
										unfortunate_victim = j
										break
									end
								end
							end
							alt_changePersona(mo, "alice_alt")
							return attackDefs["trisagion"], {unfortunate_victim}
							
						elseif calls == 8	
							if mo.name ~= "Re: Alt"
								return attackDefs["mudoon"], {unfortunate_victim}
							else
								return attackDefs["mamudoon"], enemies
							end
						
						-- turn 4: Pixie, dekunda, dekaja, prepare for megidolaon next turn.
						
						
						elseif calls == 9
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["dekunda"], {mo}
							
						elseif calls == 10
							return attackDefs["dekaja"], enemies
						
						-- turn 5: Mind charge megidolaon
						
						elseif calls == 11
							return attackDefs["mind charge"], {mo}
							
						elseif calls == 12
							return attackDefs["megidolaon"], enemies
						
						-- turn 5+: random persona & attacks until 50% HP
						
						elseif calls > 12
							
							if (calls%2)
								local personas = {"pixie_alt", "alice_alt", "kfrost_alt", "metatron_alt"}
								alt_changePersona(mo, personas[P_RandomRange(1, #personas)])
							end	
							return newEnemyThinker(mo)						
						end
					
					-- MODE 2: condition bitch
					/*
						In this phase, harass the player with skills that can potential inflict statuses and follow up with skills
						that can gain technical damage off of it, after opening with strong mind charged severe damaging spells
					*/
					
					elseif mo.phase == 2

						-- phase shift
						if mo.hp < mo.maxhp/2	-- under 50% HP
						and not (mo.mindcharge or mo.powercharge) //don't waste a mind charge haha
							alt_changePersona(mo, "pixie_alt", true)
							mo.phase = 3
							mo.thinkercalls = 2
							if btl.turnorder[2] == mo
								table.remove(btl.turnorder, 2)	-- remove self from turn order if phase shift overlaps, otherwise we'll screw everything over
							end
							return attackDefs["heat riser"], {mo}
						end
						
						-- Turn 1: Mind Chage -> Panta Rhei
						if calls == 3
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["mind charge"], {mo}
						
						elseif calls == 4
							if mo.name == "Re: Alt" and not isAttackTechnical(unfortunate_victim, "panta rhei")
								for i,j in pairs(mo.enemies)
									if isAttackTechnical(j, "panta rhei") //Muhahaha!
										unfortunate_victim = j
										break
									end
								end
							end
							if mo.name == "Re: Alt"
							and unfortunate_victim.status_condition == COND_SUPER
								return attackDefs["megidolaon"], enemies
							end
							return attackDefs["panta rhei"], {unfortunate_victim}
							
						-- Turn 2: Mabufudyne -> Vicious Strike
						elseif calls == 5
							if mo.name == "Re: Alt"
								local check = 0
								for i,j in pairs(mo.enemies)
									if j.status_condition ~= COND_SUPER
										check = j
										break
									end
								end
								if not check
									return attackDefs["megidolaon"], enemies
								end
							end
							alt_changePersona(mo, "kfrost_alt")
							return attackDefs["mabufudyne"], enemies
						
						elseif calls == 6
							alt_changePersona(mo, "metatron_alt")
							if mo.name == "Re: Alt"
								local check = 0
								for i,j in pairs(mo.enemies)
									if j.status_condition ~= COND_SUPER
										check = j
										break
									end
								end
								if not check
									return attackDefs["megidolaon"], enemies
								end
							end
							return attackDefs["vicious strike"], enemies
							
						-- Turn 3: Metatron Mahama, Alice Mamudo... yikes!
						elseif calls == 7
							if mo.name ~= "Re: Alt"
								return attackDefs["mahama"], enemies
							else
								local check = 0
								for i,j in pairs(mo.enemies)
									if j.status_condition ~= COND_SUPER
										check = j
										break
									end
								end
								if not check
									return attackDefs["megidolaon"], enemies
								end
								return attackDefs["mahamaon"], enemies
							end
							
						elseif calls == 8
							alt_changePersona(mo, "alice_alt")
							if mo.name ~= "Re: Alt"
								return attackDefs["mamudo"], enemies
							else
								local check = 0
								for i,j in pairs(mo.enemies)
									if j.status_condition ~= COND_SUPER
										check = j
										break
									end
								end
								if not check
									return attackDefs["megidolaon"], enemies
								end
								return attackDefs["mamudoon"], enemies
							end
						
						-- Turn 4: Mind Charge -> Thunder Reign
						elseif calls == 9
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["mind charge"], {mo}
							
						elseif calls == 10
							if mo.name == "Re: Alt"
								for i,j in pairs(mo.enemies) and not isAttackTechnical(unfortunate_victim, "thunder reign")
									if isAttackTechnical(j, "thunder reign") //Muhahaha!
										unfortunate_victim = j
										break
									end
								end
							end
							if mo.name == "Re: Alt"
							and unfortunate_victim.status_condition == COND_SUPER
								return attackDefs["megidolaon"], enemies
							end
							return attackDefs["thunder reign"], {unfortunate_victim}
							
						-- Turn 5: Maragidyne -> Magarudyne
						elseif calls == 11
							alt_changePersona(mo, "alice_alt")
							if mo.name == "Re: Alt"
								local check = 0
								for i,j in pairs(mo.enemies)
									if j.status_condition ~= COND_SUPER
										check = j
										break
									end
								end
								if not check
									return attackDefs["megidolaon"], enemies
								end
							end
							return attackDefs["maragidyne"], enemies
							
						elseif calls == 12
							alt_changePersona(mo, "pixie_alt")
							if mo.name == "Re: Alt"
								local check = 0
								for i,j in pairs(mo.enemies)
									if j.status_condition ~= COND_SUPER
										check = j
										break
									end
								end
								if not check
									return attackDefs["megidolaon"], enemies
								end
							end
							return attackDefs["magarudyne"], enemies
							
						-- Turn 6: Mind Charge -> Niflheim
						elseif calls == 13
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["mind charge"], {mo}
							
						elseif calls == 14
							if mo.name == "Re: Alt"
							and unfortunate_victim.status_condition == COND_SUPER
								return attackDefs["megidolaon"], enemies
							end
							alt_changePersona(mo, "kfrost_alt")
							return attackDefs["niflheim"], {unfortunate_victim}
							
						-- Turn 7: Trisagion -> Panta Rhei'
						elseif calls == 15
							//Actually, this was just cruel
							//Which is just what is needed
							if mo.name == "Re: Alt" and not isAttackTechnical(unfortunate_victim, "trisagion")
								for i,j in pairs(mo.enemies)
									if isAttackTechnical(j, "trisagion") //Muhahaha!
										unfortunate_victim = j
										break
									end
								end
							end
							alt_changePersona(mo, "alice_alt")
							if mo.name == "Re: Alt"
							and unfortunate_victim.status_condition == COND_SUPER
								return attackDefs["megidolaon"], enemies
							end
							return attackDefs["trisagion"], {unfortunate_victim}
							
						elseif calls == 16
							if mo.name == "Re: Alt" and not isAttackTechnical(unfortunate_victim, "panta rhei")
								for i,j in pairs(mo.enemies)
									if isAttackTechnical(j, "panta rhei") //Muhahaha!
										unfortunate_victim = j
										break
									end
								end
							end
							alt_changePersona(mo, "pixie_alt")
							if mo.name == "Re: Alt"
							and unfortunate_victim.status_condition == COND_SUPER
								return attackDefs["megidolaon"], enemies
							end
							return attackDefs["panta rhei"], {unfortunate_victim}
							
						-- Turn 8: Dekaja, Dekunda
						elseif calls == 17
							return attackDefs["dekunda"], {mo}
						elseif calls == 18
							return attackDefs["dekaja"], enemies
							
						-- Turn 9: Mind Charge -> Megidolaon, and then repeat!
						elseif calls == 19
							return attackDefs["mind charge"], {mo}
						elseif calls == 20
							mo.thinkercalls = 2	-- repeat thinker
							return attackDefs["megidolaon"], enemies
							
						end
					
					-- Final phase: be ungodly
					elseif mo.phase == 3

						
						-- Turn 1: Virus Breath -> Blade of Fury
						if calls == 3
							alt_changePersona(mo, "alice_alt", true)
							return attackDefs["virus breath"], enemies
							
						elseif calls == 4
							alt_changePersona(mo, "metatron_alt", true) //Pinch phase skills if she gets one mores
							if mo.name == "Re: Alt"
								local check = 0
								for i,j in pairs(mo.enemies)
									if j.status_condition ~= COND_SUPER
										check = j
										break
									end
								end
								if not check
									return attackDefs["megidolaon"], enemies
								end
							end
							return attackDefs["blade of fury"], enemies
						
						-- Turn 2: Mahamaon, Mamudoon
						elseif calls == 5
							if mo.name == "Re: Alt"
								local check = 0
								for i,j in pairs(mo.enemies)
									if j.status_condition ~= COND_SUPER
										check = j
										break
									end
								end
								if not check
									return attackDefs["megidolaon"], enemies
								end
							end
							return attackDefs["mahamaon"], enemies
							
						elseif calls == 6
							alt_changePersona(mo, "alice_alt", true)
							if mo.name ~= "Re: Alt"
								return attackDefs["mamudoon"], enemies
							else
								local check = 0
								for i,j in pairs(mo.enemies)
									if j.status_condition ~= COND_SUPER
										check = j
										break
									end
								end
								if not check
									return attackDefs["megidolaon"], enemies
								end
								return attackDefs["die for me"], enemies	//The funny skill!
							end
							
						-- Turn 3+: Free wheeling. Change Personas every 2nd turn as usual
						-- Continue the fight like this
						elseif calls > 6
							if (calls%2) or mo.name == "Re: Alt" //Change every thinkercall lol
								local personas = {"pixie_alt", "alice_alt", "kfrost_alt", "metatron_alt"}
								alt_changePersona(mo, personas[P_RandomRange(1, #personas)], true)	-- use pinch phase moves
							end
							if mo.name == "Re: Alt"
								local attack, targets = newEnemyThinker(mo)
								if (targets[1].status_condition ~= COND_SUPER)
								or attack.type == ATK_ALMIGHTY or attack.type == ATK_SUPPORT or attack.type == ATK_HEAL
									return attack, targets //Those three types of attacks are fine
								else
									local check = 0
									for i,j in pairs(targets)
										if j.status_condition ~= COND_SUPER
											check = j
										end
									end
									if check
										return attack, targets
									else
										local megipersonas = {"pixie_alt", "alice_alt", "metatron_alt"}
										if mo.persona == "kfrost_alt"
											alt_changePersona(mo, megipersonas[P_RandomRange(1, #megipersonas)], true)
										end
										return attackDefs["megidolaon"], enemies
									end
								end
							end
							return newEnemyThinker(mo)
						
						end	
					end
					
					
						
					
					
					alt_changePersona(mo, "alice_alt")
					return newEnemyThinker(mo)	--attackDefs["mamudoon"], enemies
				end


local function B7_cutscenetriggers(btl)
	
	local ps = server.plentities[btl.n]
	local en = ps[1].enemies[1]	-- yep, crude assumption!
	
	if en.enemy ~= "alt" return end
	if server.P_DialogueStatus[btl.n].running return end
	
	if not en.deathanim	-- dead
		D_startEvent(btl.n, "ev_b7_end")
		
	elseif en.hp < en.maxhp
	and not en.cutstate
		D_startEvent(btl.n, "ev_b7_opening")
		en.cutstate = 1
	
	elseif en.cutstate == 1
	and en.hp < en.maxhp*3/4
		D_startEvent(btl.n, "ev_b7_75")
		en.cutstate = 2
		
	elseif en.cutstate == 2
	and en.hp < en.maxhp/2
		D_startEvent(btl.n, "ev_b7_50")
		en.cutstate = 3	

	elseif en.cutstate == 3
	and en.hp < en.maxhp/4
		D_startEvent(btl.n, "ev_b7_25")
		en.cutstate = 4	
	end
end	

local function B7_cutscenetriggers_rematch(btl)
	
	local ps = server.plentities[btl.n]
	local en = ps[1].enemies[1]	-- yep, crude assumption!
	
	if en.enemy ~= "alt" and en.enemy ~= "alt__roguemode" return end
	if server.P_DialogueStatus[btl.n].running return end
	
	if not en.deathanim	-- dead
		D_startEvent(btl.n, "ev_b7_end_rematch")
		
	elseif en.hp < en.maxhp
	and not en.cutstate
		D_startEvent(btl.n, "ev_b7_opening")
		en.cutstate = 1
	
	elseif en.cutstate == 1
	and en.hp < en.maxhp*3/4
		D_startEvent(btl.n, "ev_b7_75")
		en.cutstate = 2
		
	elseif en.cutstate == 2
	and en.hp < en.maxhp/2
		D_startEvent(btl.n, "ev_b7_50")
		en.cutstate = 3	

	elseif en.cutstate == 3
	and en.hp < en.maxhp/4
		D_startEvent(btl.n, "ev_b7_25")
		en.cutstate = 4	
	end
end	

local function hud_front(v, evt)

	local t = evt.eventindex
	
	if t == 18
		
		local tflag = 0
		if evt.animtimer
			tflag = max(0, 9 - (evt.animtimer/4))<<V_ALPHASHIFT
		end	
		if tflag < V_10TRANS
		or tflag > V_90TRANS
			tflag = 0
		end

		drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, tflag)
	end
end

eventList["ev_b7_all_out"] = { //Good luck seeing this event lmao
		[1] = {"text", "Alt", "I did say I'd be going all out!", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
}

//I'm bad at writing character dialogue, I mostly left it the same as the original lol
//Actually, I should just make it the same as the original, but with one or two lines about how similar it is lol
eventList["ev_b7_end_rematch"] = {

		["hud_front"] = hud_front,

		[1] = {"text", "Alt", "...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[2] = {"text", "Alt", "I lost...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		
		[3] = {"function", function(evt, btl)

								local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
								ANIM_set(t, t.anim_special1, true)
								return true
							end},
		
		[4] = {"text", "Alt", "Well, I suppose that's what I get for being such a slacker!", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},

		[5] = {"function", function(evt, btl)

								local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
								ANIM_set(t, t.anim_stand, true)
								evt.animtimer = nil
								return true
							end},
		
		[6] = {"text", "Alt", "As for you lot...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		[7] = {"text", "Alt", "You have incredible strength, I'm sure you'll be able to overcome anything.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		[8] = {"text", "Alt", "Though it doesn't mean you get to be as lazy as I am from now on.", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
		[9] = {"text", "Alt", "Someday, you might just find yourselves facing an even greater power... ", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[10] = {"text", "Alt", "So don't stop honing your skills!", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		[11] = {"text", "Alt", "(Hm, déjà vu?)", nil, nil, nil, {"H_ALT05", SKINCOLOR_BLUE}},
		[12] = {"text", "Alt", "...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[13] = {"text", "Alt", "Now then.", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[14] = {"text", "Alt", "I've worked up quite an appetite with all that fighting...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		[15] = {"text", "Alt", "Remember the deal? 2 million cookies. Give em to me!", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
		[16] = {"text", "Alt", "What do you mean the deal was 1 million cookies if you lost?", nil, nil, nil, {"H_ALT05", SKINCOLOR_BLUE}},
		[17] = {"text", "Alt", "I kid, I kid...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[18] = {"text", "Alt", "Let's just leave this dumpster already. I'm hungry.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		
		
		[19] = {"function", function(evt, btl)
								
								local t = server.plentities[btl.n][1].enemies[1]
								
								evt.animtimer = $ and $+1 or 1
								if evt.animtimer == TICRATE
									-- lol hack
									btl.battlestate = BS_MPFINISH
									btl.hudtimer.mpfinish = 1
									t.hp = 0
									t.fuse = 2
									
									return true
								end
							end},
		
}

eventList["ev_b7_start_rematch"] = {
		
	[1] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1
							if evt.animtimer == 1
								for p in players.iterate do
									if p and p.valid and p.control and p.control.valid and p.control.battlen == btl.n
										S_FadeOutStopMusic(250, p)
									end	
								end
								
								local destx = cam.x - 128*cos(cam.angle)
								local desty = cam.y - 128*sin(cam.angle)
								CAM_goto(cam, destx, desty, cam.z + FRACUNIT*32)
								
							end
							
							
							
							if evt.animtimer >= 20
							and evt.animtimer <= 60
							and evt.animtimer % 3 == 0


								local s = P_SpawnMobj(t.x + P_RandomRange(-128, 128)<<FRACBITS, t.y + P_RandomRange(-128, 128)<<FRACBITS, t.z + P_RandomRange(0, 192)<<FRACBITS, MT_DUMMY)
								s.color = SKINCOLOR_WHITE
								s.state = S_MEGISTAR1
								s.scale = $*2 + P_RandomRange(0, 65535)
								playSound(t.battlen, sfx_hamas1)
							end
							
							if evt.animtimer == 60
								evt.animtimer = nil
								return true
							end	
						end},

	[2] = {"text", "Alt", "Still lame...", nil, nil, nil, {"H_ALT04", SKINCOLOR_BLUE}},	

	[3] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1
							
							if evt.animtimer == TICRATE/2
							
								-- !?
								local excl = P_SpawnMobj(t.x, t.y, t.z+90*FRACUNIT, MT_DUMMY)
								excl.flags = MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_NOBLOCKMAP
								excl.scale = 1
								excl.destscale = FRACUNIT*2
								excl.scalespeed = FRACUNIT/2
								excl.sprite = SPR_XCLA
								excl.frame = A|FF_FULLBRIGHT
								excl.fuse = 20
								excl.momx = P_RandomRange(-3, 3)*FRACUNIT
								excl.momy = P_RandomRange(-3, 3)*FRACUNIT
								
								t.passiveskills = {}	-- remove inf endure
								
								playSound(t.battlen, sfx_megi6)
								local an = 0
								for i = 1, 32

									local s = P_SpawnMobj(t.x, t.y, t.z + FRACUNIT*32, MT_DUMMY)
									s.color = SKINCOLOR_WHITE
									s.state = S_MEGITHOK
									s.scale = $/2
									s.fuse = TICRATE*2
									P_InstaThrust(s, an*ANG1, 50<<FRACBITS)

									s = P_SpawnMobj(t.x, t.y, t.z + FRACUNIT*32, MT_DUMMY)
									s.color = SKINCOLOR_WHITE
									s.state = S_MEGITHOK
									s.scale = $/4
									s.fuse = TICRATE*2
									P_InstaThrust(s, an*ANG1, 30<<FRACBITS)

									an = $ + (360/32)
								end

								local ne = BTL_spawnEnemy(t, ROGUE_initEnemyStats("alt"), false, t.x, t.y, t.z) //I want to make her stronger lol
								ne.name = "Re: Alt"
								ne.flags = $|MF_NOGRAVITY
								ANIM_set(ne, ne.anim_special1, true)
								
								ne.z = ne.floorz + 2048*FRACUNIT
								
								damageObject(t, 9999)
								
							end
							
							if evt.animtimer == 100
								return true
							end	
						end},
	
	
	[4] = {"text", "Alt", "Man, that clown's still the strongest thing this place has?", nil, nil, nil, {"H_ALT04", SKINCOLOR_BLUE}},
	[5] = {"text", "Alt", "That sucks.", nil, nil, nil, {"H_ALT04", SKINCOLOR_BLUE}},
	[6] = {"text", "Alt", "(Wait, did I say still?)", nil, nil, nil, {"H_ALT05", SKINCOLOR_BLUE}},
	
	[7] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[2]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1	
							
							if evt.animtimer >= TICRATE/2
								t.momz = -(t.z - t.floorz)/4
							end
							
							if evt.animtimer == TICRATE*6
								evt.animtimer = nil
								t.flags = $ & ~MF_NOGRAVITY
								return true
							end
						end},

	[8] = {"text", "Alt", "We can't have things end this way now can we?", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[9] = {"text", "Alt", "I had the cookies ready to watch you lot have a nice fight, but it got boring instantly!", nil, nil, nil, {"H_ALT04", SKINCOLOR_BLUE}},
	[10] = {"text", "Alt", "...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[11] = {"text", "Alt", "Long story short...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[12] = {"text", "Alt", "Try not to bore me as much as that clown I just erased.", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
	
	[13] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[2]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1	
							
							if evt.animtimer == TICRATE/2
								ANIM_set(t, t.anim_stand, true)
								evt.animtimer = nil
								
								btl.turnorder = {}
								BTL_fullCleanse(btl)
								btl.func = B7_cutscenetriggers_rematch
								
								for p in players.iterate do
									if p and p.control and p.control.valid and p.control.battlen == btl.n
										S_ChangeMusic("CTWR", true, p)
									end	
								end	
								
								return true
							end
							
						end},		
	
}

//lol I want Alt to notice if you've defeated the reaper in the current server
eventList["ev_b7_start_reaperdefeated"] = {
		
	[1] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1
							if evt.animtimer == 1
								for p in players.iterate do
									if p and p.valid and p.control and p.control.valid and p.control.battlen == btl.n
										S_FadeOutStopMusic(250, p)
									end	
								end
								
								local destx = cam.x - 128*cos(cam.angle)
								local desty = cam.y - 128*sin(cam.angle)
								CAM_goto(cam, destx, desty, cam.z + FRACUNIT*32)
								
							end
							
							
							
							if evt.animtimer >= 20
							and evt.animtimer <= 60
							and evt.animtimer % 3 == 0


								local s = P_SpawnMobj(t.x + P_RandomRange(-128, 128)<<FRACBITS, t.y + P_RandomRange(-128, 128)<<FRACBITS, t.z + P_RandomRange(0, 192)<<FRACBITS, MT_DUMMY)
								s.color = SKINCOLOR_WHITE
								s.state = S_MEGISTAR1
								s.scale = $*2 + P_RandomRange(0, 65535)
								playSound(t.battlen, sfx_hamas1)
							end
							
							if evt.animtimer == 60
								evt.animtimer = nil
								return true
							end	
						end},

	[2] = {"text", "???", "Lame..."},	

	[3] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1
							
							if evt.animtimer == TICRATE/2
							
								-- !?
								local excl = P_SpawnMobj(t.x, t.y, t.z+90*FRACUNIT, MT_DUMMY)
								excl.flags = MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_NOBLOCKMAP
								excl.scale = 1
								excl.destscale = FRACUNIT*2
								excl.scalespeed = FRACUNIT/2
								excl.sprite = SPR_XCLA
								excl.frame = A|FF_FULLBRIGHT
								excl.fuse = 20
								excl.momx = P_RandomRange(-3, 3)*FRACUNIT
								excl.momy = P_RandomRange(-3, 3)*FRACUNIT
								
								t.passiveskills = {}	-- remove inf endure
								
								playSound(t.battlen, sfx_megi6)
								local an = 0
								for i = 1, 32

									local s = P_SpawnMobj(t.x, t.y, t.z + FRACUNIT*32, MT_DUMMY)
									s.color = SKINCOLOR_WHITE
									s.state = S_MEGITHOK
									s.scale = $/2
									s.fuse = TICRATE*2
									P_InstaThrust(s, an*ANG1, 50<<FRACBITS)

									s = P_SpawnMobj(t.x, t.y, t.z + FRACUNIT*32, MT_DUMMY)
									s.color = SKINCOLOR_WHITE
									s.state = S_MEGITHOK
									s.scale = $/4
									s.fuse = TICRATE*2
									P_InstaThrust(s, an*ANG1, 30<<FRACBITS)

									an = $ + (360/32)
								end

								local ne = BTL_spawnEnemy(t, "alt", false, t.x, t.y, t.z)
								ne.flags = $|MF_NOGRAVITY
								ANIM_set(ne, ne.anim_special1, true)
								
								ne.z = ne.floorz + 2048*FRACUNIT
								
								damageObject(t, 9999)
								
							end
							
							if evt.animtimer == 100
								return true
							end	
						end},
	
	
	[4] = {"text", "???", "Man, you made it all the way down there and this is the strongest thing this place has?"},
	[5] = {"text", "???", "Didn't you already beat it before?"},
	[6] = {"text", "???", "That sucks."},
	
	[7] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[2]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1	
							
							if evt.animtimer >= TICRATE/2
								t.momz = -(t.z - t.floorz)/4
							end
							
							if evt.animtimer == TICRATE*6
								evt.animtimer = nil
								t.flags = $ & ~MF_NOGRAVITY
								return true
							end
						end},

	[8] = {"text", "Alt", "We can't have things end this way now can we?", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[9] = {"text", "Alt", "I had the cookies ready to watch you lot have a nice fight, but it got boring instantly!", nil, nil, nil, {"H_ALT04", SKINCOLOR_BLUE}},
	[10] = {"text", "Alt", "...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[11] = {"text", "Alt", "Long story short...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[12] = {"text", "Alt", "Try not to bore me as much as that clown I just erased.", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
	
	[13] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[2]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1	
							
							if evt.animtimer == TICRATE/2
								ANIM_set(t, t.anim_stand, true)
								evt.animtimer = nil
								
								btl.turnorder = {}
								BTL_fullCleanse(btl)
								btl.func = B7_cutscenetriggers
								
								for p in players.iterate do
									if p and p.control and p.control.valid and p.control.battlen == btl.n
										S_ChangeMusic("CTWR", true, p)
									end	
								end	
								
								return true
							end
							
						end},		
	
}

//I don't like this enough to use it, but I don't dislike it enough to completely delete it
/*eventList["ev_b7_opening_rematch"] = {
	[1] = {"text", "Alt", "You may have beaten me before, but this will be different if you underestimate me.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
}

eventList["ev_b7_75_rematch"] = {
	[1] = {"text", "Alt", "You've gotten stronger too, I see?", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
	[2] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
							local cam = btl.cam
							ANIM_set(t, t.anim_special1)
							return true
							
			end},				
	[3] = {"text", "Alt", "I suppose that just means I can still go all out myself!", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
}

eventList["ev_b7_50_rematch"] = {
	[1] = {"text", "Alt", "Alright, I'm interested...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[2] = {"text", "Alt", "Very well, show me...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[3] = {"text", "Alt", "Show me how powerful you've become!", nil, nil, nil, {"H_ALT06", SKINCOLOR_BLUE}},
}

eventList["ev_b7_25_rematch"] = {
	[1] = {"text", "Alt", "Haha, man... \nDid I not get strong enough?", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	//[2] = {"text", "Alt", "And I was gonna force you to buy me 4 million cookies this time...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
}*/

/*eventList["ev_b7_end"] = {

		["hud_front"] = hud_front,

		[1] = {"text", "Alt", "...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[2] = {"text", "Alt", "I lost...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		
		[3] = {"function", function(evt, btl)

								local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
								ANIM_set(t, t.anim_special1, true)
								return true
							end},
		
		[4] = {"text", "Alt", "Well, I suppose that's what I get for being such a slacker!", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},

		[5] = {"function", function(evt, btl)

								local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
								ANIM_set(t, t.anim_stand, true)
								evt.animtimer = nil
								return true
							end},
		
		[6] = {"text", "Alt", "As for you lot...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		[7] = {"text", "Alt", "You have incredible strength, I'm sure you'll be able to overcome anything.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		[8] = {"text", "Alt", "Though it doesn't mean you get to be as lazy as I am from now on.", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
		[9] = {"text", "Alt", "Someday, you might just find yourselves facing an even greater power... ", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[10] = {"text", "Alt", "So don't stop honing your skills!", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		[11] = {"text", "Alt", "...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[12] = {"text", "Alt", "Now then.", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[13] = {"text", "Alt", "I've worked up quite an appetite with all that fighting...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		[14] = {"text", "Alt", "Remember the deal? 2 million cookies. Give em to me!", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
		[15] = {"text", "Alt", "What do you mean the deal was 1 million cookies if you lost?", nil, nil, nil, {"H_ALT05", SKINCOLOR_BLUE}},
		[16] = {"text", "Alt", "I kid, I kid...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[17] = {"text", "Alt", "Let's just leave this dumpster already. I'm hungry.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		[18] = {"text", "Spectrum", "Congrats, you beat Alt!\nTurn monadrematch on in the console next time for a stronger Alt rematch.", nil, nil, nil, {"H_TALAOA", SKINCOLOR_CRIMSON}},
		
		[19] = {"function", function(evt, btl)
								
								local t = server.plentities[btl.n][1].enemies[1]
								
								evt.animtimer = $ and $+1 or 1
								if evt.animtimer == TICRATE
									-- lol hack
									btl.battlestate = BS_MPFINISH
									btl.hudtimer.mpfinish = 1
									t.hp = 0
									t.fuse = 2
									
									return true
								end
							end},
		
}*/

/*eventList["ev_b7_start_nicetry"] = {
		
	[1] = {"text", "Spectrum", "Nice try, but you have to beat Monad normally first to unlock monadrematch now, so on with the normal boss!", nil, nil, nil, {"H_TALAOA", SKINCOLOR_CRIMSON}},
	[2] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1
							if evt.animtimer == 1
								for p in players.iterate do
									if p and p.valid and p.control and p.control.valid and p.control.battlen == btl.n
										S_FadeOutStopMusic(250, p)
									end	
								end
								
								local destx = cam.x - 128*cos(cam.angle)
								local desty = cam.y - 128*sin(cam.angle)
								CAM_goto(cam, destx, desty, cam.z + FRACUNIT*32)
								
							end
							
							
							
							if evt.animtimer >= 20
							and evt.animtimer <= 60
							and evt.animtimer % 3 == 0


								local s = P_SpawnMobj(t.x + P_RandomRange(-128, 128)<<FRACBITS, t.y + P_RandomRange(-128, 128)<<FRACBITS, t.z + P_RandomRange(0, 192)<<FRACBITS, MT_DUMMY)
								s.color = SKINCOLOR_WHITE
								s.state = S_MEGISTAR1
								s.scale = $*2 + P_RandomRange(0, 65535)
								playSound(t.battlen, sfx_hamas1)
							end
							
							if evt.animtimer == 60
								evt.animtimer = nil
								return true
							end	
						end},

	[3] = {"text", "???", "Lame..."},	

	[4] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1
							
							if evt.animtimer == TICRATE/2
							
								-- !?
								local excl = P_SpawnMobj(t.x, t.y, t.z+90*FRACUNIT, MT_DUMMY)
								excl.flags = MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_NOBLOCKMAP
								excl.scale = 1
								excl.destscale = FRACUNIT*2
								excl.scalespeed = FRACUNIT/2
								excl.sprite = SPR_XCLA
								excl.frame = A|FF_FULLBRIGHT
								excl.fuse = 20
								excl.momx = P_RandomRange(-3, 3)*FRACUNIT
								excl.momy = P_RandomRange(-3, 3)*FRACUNIT
								
								t.passiveskills = {}	-- remove inf endure
								
								playSound(t.battlen, sfx_megi6)
								local an = 0
								for i = 1, 32

									local s = P_SpawnMobj(t.x, t.y, t.z + FRACUNIT*32, MT_DUMMY)
									s.color = SKINCOLOR_WHITE
									s.state = S_MEGITHOK
									s.scale = $/2
									s.fuse = TICRATE*2
									P_InstaThrust(s, an*ANG1, 50<<FRACBITS)

									s = P_SpawnMobj(t.x, t.y, t.z + FRACUNIT*32, MT_DUMMY)
									s.color = SKINCOLOR_WHITE
									s.state = S_MEGITHOK
									s.scale = $/4
									s.fuse = TICRATE*2
									P_InstaThrust(s, an*ANG1, 30<<FRACBITS)

									an = $ + (360/32)
								end

								local ne = BTL_spawnEnemy(t, "alt", false, t.x, t.y, t.z)
								ne.flags = $|MF_NOGRAVITY
								ANIM_set(ne, ne.anim_special1, true)
								
								ne.z = ne.floorz + 2048*FRACUNIT
								
								damageObject(t, 9999)
								
							end
							
							if evt.animtimer == 100
								return true
							end	
						end},
	
	
	[5] = {"text", "???", "Man, you made it all the way down there and this is the strongest thing this place has?"},	
	[6] = {"text", "???", "That sucks."},
	
	[7] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[2]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1	
							
							if evt.animtimer >= TICRATE/2
								t.momz = -(t.z - t.floorz)/4
							end
							
							if evt.animtimer == TICRATE*6
								evt.animtimer = nil
								t.flags = $ & ~MF_NOGRAVITY
								return true
							end
						end},

	[8] = {"text", "Alt", "We can't have things end this way now can we?", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[9] = {"text", "Alt", "I had the cookies ready to watch you lot have a nice fight, but it got boring instantly!", nil, nil, nil, {"H_ALT04", SKINCOLOR_BLUE}},
	[10] = {"text", "Alt", "...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[11] = {"text", "Alt", "Long story short...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[12] = {"text", "Alt", "Try not to bore me as much as that clown I just erased.", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
	
	[13] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[2]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1	
							
							if evt.animtimer == TICRATE/2
								ANIM_set(t, t.anim_stand, true)
								evt.animtimer = nil
								
								btl.turnorder = {}
								BTL_fullCleanse(btl)
								btl.func = B7_cutscenetriggers
								
								for p in players.iterate do
									if p and p.control and p.control.valid and p.control.battlen == btl.n
										S_ChangeMusic("CTWR", true, p)
									end	
								end	
								
								return true
							end
							
						end},		
	
}*/
