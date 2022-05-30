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

							local pp = v.cachePatch(charStats[mo.stats] and charStats[mo.stats].hudaoa or enemyList[mo.enemy] and enemyList[mo.enemy].hudaoa)
							if mo.status_condition == COND_SUPER
							and (charStats[mo.stats] and charStats[mo.stats].hudsaoa or enemyList[mo.enemy] and enemyList[mo.enemy].hudsaoa)
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
enemyList["alt"].hudaoa = "H_ALTAOA"
enemyList["alt"].anim_aoa_end = {SPR_VALT, G, H, 10}
enemyList["alt"].anim_atk = {SPR_VALT, A, 2}
//Thanks to SpringFox for this line
enemyList["alt"].aoa_quote = "Mh? Is that it? \nHow disappointing~"

enemyList["alt"].thinker = function(mo)

					-- Alt thinker
					-- This thinker kinda sucks and could maybe use some optimization, but it does its job, I suppose...

					mo.deathanim = true	-- hack since there are isolated cases of this not working?

					local function alt_changePersona(alt, persona)

						local pinch = (alt.phase == 3)

						alt.persona = personaList[persona]
						local p = alt.persona
						alt.weak = p.weak or 0
						alt.resist = p.resist or 0
						alt.drain = p.drain or 0
						alt.block = p.block or 0

						-- set skill lists:
						local pskills

						if not pinch
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
									"almighty amp",
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
									"almighty amp",
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
						else	-- harder moves

							pskills = {

								["pixie_alt"] = {
									"panta rhei",
									"thunder reign",
									"megidolaon",
									"magarudyne",
									"maziodyne",
									"megidolaon",
									"magarudyne",
									"maziodyne",
									"mind charge",
									"elec amp",
									"wind amp",
									"almighty amp",
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
									"black viper",
									"black viper",
									"almighty amp",
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
						//Alt AOAs lol
						local enemies = mo.enemies
						mo.knockeddown = 0
						for i,j in ipairs(enemies)
							if j.down or (j.hp == 0)
								mo.knockeddown = $+1
							end
						end
						if mo.knockeddown >= #enemies and not BTL_noAOAStatus(mo) and mo.hp
							return attackDefs["all_out-alt"], enemies
						end
						return generalEnemyThinker(mo)
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

					-- if there are barriers or players are super, use some targetted almighty...~
					local numbarriers = 0
					local barriertarget

					for i = 1, #enemies do
						local en = enemies[i]
						if en.tetrakarn or en.makarakarn or en.status_condition == COND_SUPER
							barriertarget = en
							numbarriers = $+1
						end
					end

					if numbarriers
					-- check to make sure it's our first turn
					and btl.turnorder[2] == mo
					and (P_RandomRange(0, 1) or numbarriers > 1)

					-- don't do that when we should switch phases
					and not (mo.hp < mo.maxhp*3/4 and mo.phase == 1)
					and not (mo.hp < mo.maxhp/2 and mo.phase == 2)

						mo.thinkercalls = $+1	-- advance thinker anyway

						if numbarriers > 1
						or P_RandomRange(0, 1)
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["megidolaon"], enemies
						else
							alt_changePersona(mo, "alice_alt")
							return attackDefs["black viper"], {barriertarget}
						end
					end

					-- MODE 1: HP > 75%
					/*
						In this phase, go soft on the player, do highly telegraphed attacks and only go haywire after 6 turns.
					*/

					if mo.phase == 1

						-- phase shift
						if mo.hp < mo.maxhp*3/4	-- under 75% HP
						and btl.turnorder[2] ~= mo
							alt_changePersona(mo, "pixie_alt")
							mo.phase = 2
							mo.thinkercalls = 2

							if mo.buffs["atk"][1] <= 0
							and mo.buffs["def"][1] <= 0
							and mo.buffs["agi"][1] <= 0
								return attackDefs["turntables"], btl.fighters
							else
								return attackDefs["heat riser"], {mo}
							end
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
							alt_changePersona(mo, "alice_alt")
							return attackDefs["trisagion"], {unfortunate_victim}

						elseif calls == 8

							return attackDefs["mudoon"], {unfortunate_victim}

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
							return generalEnemyThinker(mo)
						end

					-- MODE 2: condition bitch
					/*
						In this phase, harass the player with skills that can potential inflict statuses and follow up with skills
						that can gain technical damage off of it, after opening with strong mind charged severe damaging spells
					*/

					elseif mo.phase == 2

						-- phase shift
						if mo.hp < mo.maxhp/2	-- under 50% HP
						and btl.turnorder[2] ~= mo
							alt_changePersona(mo, "pixie_alt")
							mo.phase = 3
							mo.thinkercalls = 2

							if mo.buffs["atk"][1] <= 0
							and mo.buffs["def"][1] <= 0
							and mo.buffs["agi"][1] <= 0
								return attackDefs["turntables"], btl.fighters
							else
								return attackDefs["heat riser"], {mo}
							end
						end

						-- Turn 1: Mind Chage -> Panta Rhei
						if calls == 3
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["mind charge"], {mo}

						elseif calls == 4
							return attackDefs["panta rhei"], {unfortunate_victim}

						-- Turn 2: Mabufudyne -> Vicious Strike
						elseif calls == 5
							alt_changePersona(mo, "kfrost_alt")
							return attackDefs["mabufudyne"], enemies

						elseif calls == 6
							alt_changePersona(mo, "metatron_alt")
							return attackDefs["vicious strike"], enemies

						-- Turn 3: Metatron Mahama, Alice Mamudo... yikes!
						elseif calls == 7
							return attackDefs["mahama"], enemies

						elseif calls == 8
							alt_changePersona(mo, "alice_alt")
							return attackDefs["mamudo"], enemies

						-- Turn 4: Mind Charge -> Thunder Reign
						elseif calls == 9
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["mind charge"], {mo}

						elseif calls == 10
							return attackDefs["thunder reign"], {unfortunate_victim}

						-- Turn 5: Maragidyne -> Magarudyne
						elseif calls == 11
							alt_changePersona(mo, "alice_alt")
							return attackDefs["maragidyne"], enemies

						elseif calls == 12
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["magarudyne"], enemies

						-- Turn 6: Mind Charge -> Niflheim
						elseif calls == 13
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["mind charge"], {mo}

						elseif calls == 14
							alt_changePersona(mo, "kfrost_alt")
							return attackDefs["niflheim"], {unfortunate_victim}

						-- Turn 7: Trisagion -> Panta Rhei'
						elseif calls == 15
							alt_changePersona(mo, "alice_alt")
							return attackDefs["trisagion"], {unfortunate_victim}

						elseif calls == 16
							alt_changePersona(mo, "pixie_alt")
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
							mo.thinkercalls = 3	-- repeat thinker
							return attackDefs["megidolaon"], enemies

						end

					-- Final phase: be ungodly
					elseif mo.phase == 3

						-- Turn 1: Virus Breath -> Blade of Fury
						if calls == 3
							alt_changePersona(mo, "alice_alt")
							return attackDefs["virus breath"], enemies

						elseif calls == 4
							alt_changePersona(mo, "metatron_alt")
							return attackDefs["blade of fury"], enemies

						-- Turn 2: Mahamaon, Mamudoon
						elseif calls == 5
							return attackDefs["mahamaon"], enemies

						elseif calls == 6
							alt_changePersona(mo, "alice_alt")
							return attackDefs["mamudoon"], enemies

						-- Turn 3+: Free wheeling. Change Personas every 2nd turn as usual
						-- Continue the fight like this
						elseif calls > 6

							if (calls%2)
								local personas = {"pixie_alt", "alice_alt", "kfrost_alt", "metatron_alt"}
								alt_changePersona(mo, personas[P_RandomRange(1, #personas)], true)	-- use pinch phase moves
							end
							return generalEnemyThinker(mo)

						end
					end





					alt_changePersona(mo, "alice_alt")
					return generalEnemyThinker(mo)	--attackDefs["mamudoon"], enemies
				end
