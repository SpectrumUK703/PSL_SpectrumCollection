if attackDefs["mnemesis_patk"].desc == "Medium slash damage to \nall enemies up to\n2 times" //R.E.D. noticed it first lol
	attackDefs["mnemesis_patk"].desc = "Heavy Almighty slash damage to \nall enemies" //It's stronger than some heavy damage skills
end

enemyList["mnemesis_2"].thinker = function(mo)
						
						mo.thinkturns = $ and $+1 or 1
						if mo.mindcharge or mo.powercharge //don't waste it
							if mo.thinkturns == 1 or mo.thinkturns == 2
							or mo.thinkturns%6 == 0
								mo.thinkturns = $ and $-1 or 0 //don't skip dekaja or overdrive boost
							end
							return generalEnemyThinker(mo)
						end
						
						if mo.thinkturns == 1
							return attackDefs["dekaja"], mo.enemies
						elseif mo.thinkturns == 2	
						or mo.thinkturns%6 == 0
							return attackDefs["overdrive boost"], {mo}
						end
						
						return generalEnemyThinker(mo)
					end

attackDefs["batkan buster"].anim = function(mo, targets, hittargets, timer)

			if timer == 1
				BTL_logMessage(mo.battlen, mo.name.." is charging a powerful attack...")
				mo.kanbuster = $ and $+1 or 1
			end


			local j = mo.columns and #mo.columns or 0
			while j
				local m = mo.columns[j]
				if not m or not m.valid
					j = $-1
					continue
				end

				for i = 1, 5
					local boom = P_SpawnMobj(m.x + P_RandomRange(-48, 48)*FRACUNIT, m.y + P_RandomRange(-48, 48)*FRACUNIT, m.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.colorized = true
					boom.color = SKINCOLOR_PURPLE
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				localquake(mo.battlen, FRACUNIT*8, 1)
				j = $-1
			end

			if #mo.allies == 1	-- bean defeated

				if timer == 1
					BTL_logMessage(mo.battlen, mo.name.." is no longer sustained by the Master of Teddehs!")
					playSound(mo.battlen, sfx_batk4) //From QOLv3
					local btl = server.P_BattleStatus[mo.battlen]
				end

				if timer >= 10
				and timer <= TICRATE*2
				and leveltime%5 == 0

					local bx = mo.x + P_RandomRange(-192, 192)*FRACUNIT
					local by = mo.y + P_RandomRange(-129, 192)*FRACUNIT
					local bz = mo.z + P_RandomRange(0, 256)*FRACUNIT

					for i = 1, 32
						local boom = P_SpawnMobj(bx + P_RandomRange(-20, 20)*FRACUNIT, by + P_RandomRange(-20, 20)*FRACUNIT, bz + 10*FRACUNIT, MT_DUMMY)
						boom.state = S_CQUICKBOOM1
						boom.color = SKINCOLOR_PURPLE
						boom.momx = P_RandomRange(-20, 20)*FRACUNIT
						boom.momy = P_RandomRange(-20, 20)*FRACUNIT
						boom.momz = P_RandomRange(-20, 20)*FRACUNIT
						boom.scale = FRACUNIT*3/2
					end
					local sm = P_SpawnMobj(bx, by, bz, MT_SMOLDERING)
					sm.fuse = TICRATE

					playSound(mo.battlen, sfx_megi6)
					localquake(mo.battlen, FRACUNIT*32, 10)
				end

				if timer == TICRATE*3
					-- delet old shit:
					mo.fangle = (R_PointToAngle(mo.x, mo.y)) + ANG1*180
					mo.columns = {}
					playSound(mo.battlen, sfx_megi5)

					local a = mo.fangle - ANG1*80

					for i = 1, 16
						local m = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						P_InstaThrust(m, a, FRACUNIT*48)
						mo.columns[#mo.columns+1] = m
						m.state = S_INVISIBLE
						m.tics = TICRATE
						a = $+ ANG1*10
					end


					for i = 1, #hittargets
						if hittargets[i] ~= mo
							damageObject(hittargets[i], hittargets[i].hp-1)
							cureStatus(hittargets[i])

							hittargets[i].strength = $-25
							hittargets[i].magic = $-25
							hittargets[i].endurance = $-25
							hittargets[i].agility = $-25
							hittargets[i].luck = $-25

						end
					end

					-- target: mo.maxhp/4
					-- diff: mo.hp - mo.maxhp/4
					mo.guaranteedevasion = nil	-- remove guaranteed evasion
					damageObject(mo, (mo.hp - mo.maxhp/5))
					mo.strength = 65
					mo.endurance = 8
					mo.magic = 65			-- slightly lower stats.
					mo.agility = 55			-- to make things a bit more fair

					-- change my skills:
					mo.skills = {
						"trisagion",
						"panta rhei",
						"niflheim",
						"thunder reign",
						"atomic flare",
						"psycho force",
						"kannon",
						"kannon",
						"kannon",
						"fitness",
						"fitness",
						"fitness",
						"trigonometry",
						"trigonometry",
						"maragidyne",
						"mabufudyne",
						"maziodyne",
						"magarudyne",
						"mapsiodyne",
						"mafreidyne",
						"makougaon",
						"maeigaon",
						"megidolaon",
						"fire boost",
						"ice boost",
						"elec boost",
						"wind boost",
						"nuke boost",
						"psy boost",
						"bless boost",
						"curse boost",
						"god hand",
						"god hand",
						"god hand",
						"deathbound",
						"deathbound",
						"heat riser",
						"dekaja",
						"dekunda",
					}	-- that's a lot a skills.
					if attackDefs["kan fist"] //QOLv3 support
						table.insert(mo.skills, "kan fist")
						table.insert(mo.skills, "kan fist")
						table.insert(mo.skills, "kan fist")
					end
					BTL_splitSkills(mo)	-- split skills between physical and passive.
					-- yes, it's kind of a hack to call this function r/n but w/e

					localquake(mo.battlen, FRACUNIT*50, 10)
					for i = 1, 4
						createSplat(mo)
					end
				end

				if timer == TICRATE*6
					return true
				end

				return
			end


			if timer == TICRATE/2
				local cam = server.P_BattleStatus[mo.battlen].cam

				local x = cam.x - 380*cos(cam.angle)
				local y = cam.y - 380*sin(cam.angle)
				CAM_goto(cam, x, y, cam.z + FRACUNIT*24)
			end

			if timer == TICRATE

				for i = 1, #mo.allies

					local target = mo.allies[i]
					if not target or not target.valid continue end

					playSound(mo.battlen, sfx_buff)
					buffStat(target, "atk")
					buffStat(target, "mag")
					buffStat(target, "def")
					buffStat(target, "agi")

					BTL_logMessage(targets[1].battlen, "All stats increased!")

					for i = 1,16
						local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.color = SKINCOLOR_WHITE
						dust.scale = FRACUNIT*2
					end
				end
			end

			if timer == TICRATE*3

				return true
			end
		end
