if CV_FindVar("enemyhealchance") then return end

local enemyhealchance = CV_RegisterVar({
  name = "enemyhealchance",
  defaultvalue = 0,
  flags = CV_NETVAR,
  PossibleValue = {MIN = 0, MAX = 100}
})

//Fixed smartAttackSelect with a few changes
rawset(_G, "smartAttackSelect", function(mo, forceheal)

	-- ally under 50% health, see if we can help them out with our best healing skill!
	-- though, always prioritize the ally with the lowest health.
	local onemore = mo.batontouch
	-- this may seem silly, but this is an effective way to check if we're acting out of a 1more!

	-- Last resort skills: Always use those if our HP is 25% or less.

	if mo.hp < mo.maxhp/4
		for i = 1, #mo.skills
			if not attackDefs[mo.skills[i]] continue end
			if attackDefs[mo.skills[i]].lastresort and (not attackDefs[mo.skills[i]].cost or attackDefs[mo.skills[i]].costtype ~= CST_SP or (attackDefs[mo.skills[i]].cost <= mo.sp))
				return attackDefs[mo.skills[i]]
			end
		end
	end

	local heal
	local healcount = 0	-- used to know if we should prioritize using single target heal or multi target heal
	local healskill

	for i = 1, #mo.allies
		local a = mo.allies[i]
		if a.hp < a.maxhp/2
			--dprint("ENEMY LOGIC: Weakened ally, searching for healing skills...")
			healcount = $+1	-- # of allies we have to heal
			if (not heal) or a.hp < heal.hp
				heal = a //Now heal can be non-nil
			end
		end
	end
	
	local healChance = P_RandomRange(0, 99) //Well, if you really wanted it to be 25% chance

	if heal	-- we have to try to heal someone!
	and (forceheal or healChance < enemyhealchance.value)	-- 25% chance of healing, to avoid stall fests
	//customisable enemyhealchance, since people didn't like this
		-- check if we have a skill for that
		for i = 1, #mo.skills
			local a = attackDefs[mo.skills[i]]
			if not a then continue end //To avoid Lua warnings for shadows with invalid skills
			if a.type == ATK_HEAL and a.power and (not a.cost or a.costtype ~= CST_SP or (a.cost <= mo.sp))	-- this is a healing skill
				if healskill	-- we already have a healing skill chosen... let's see if this new skill is better suited
					if healskill.target == TGT_ALLY and a.target == TGT_ALLALLIES and healcount > 1
						healskill = a
						continue
						-- we need to heal multiple targets, and this skill heals more!
					elseif healskill.target == TGT_ALLALLIES and a.target == TGT_ALLY and healcount <= 1
						healskill = a
						continue
						-- don't needlessly waste SP using multi heal when we could instead heal only a single target
					elseif healskill.power < a.power and healskill.target == a.target
						healskill = a
						continue
						-- same target type, but more power. Tell you what, let's replace it!
					end
				else
					healskill = a
				end
			end
		end
	end

	if healskill
		--dprint("ENEMY LOGIC: Healing skill found")
		if healskill.target == TGT_ALLY //Are we healing one ally or all our allies?
			return healskill, heal
		else
			return healskill
		end
	end

	//Haha, copying the fixed heal code for Patra for one boss who has Patra but can't otherwise use it
	local patra
	local patracount = 0	-- used to know if we should prioritize using single target patra or multi target patra
	local patraskill

	for i = 1, #mo.allies
		local a = mo.allies[i]
		if a.status_condition and a.status_condition < COND_HYPER //For if a custom enemy gets Hyper mode and Patra lmao
			--dprint("ENEMY LOGIC: Statused ally, searching for patra skills...")
			patracount = $+1	-- # of allies we have to patra
			if (not patra) or a.hp < patra.hp //Might as well cure the ally with the lowest HP first?
				patra = a
				continue
			end
		end
	end
	
	local patraChance = P_RandomRange(0, 99) //Well, if you really wanted it to be 25% chance

	if patra	-- we have to try to patra someone!
	and (forceheal or patraChance < enemyhealchance.value)	//25% chance of patra, like healing
		-- check if we have a skill for that
		for i = 1, #mo.skills
			local a = attackDefs[mo.skills[i]]
			if not a then continue end //To avoid Lua warnings for shadows with invalid skills
			if a.type == ATK_HEAL and not a.power and (a.target == TGT_ALLALLIES or a.target == TGT_ALLY) and (not a.cost or a.costtype ~= CST_SP or (a.cost <= mo.sp))	-- this is a patra skill, right?
				if patraskill	-- we already have a patra skill chosen... let's see if this new skill is better suited
					if patraskill.target == TGT_ALLY and a.target == TGT_ALLALLIES and patracount > 1
						patraskill = a
						continue
						-- we need to patra multiple targets, and this skill patra more!
					elseif patraskill.target == TGT_ALLALLIES and a.target == TGT_ALLY and patracount <= 1
						patraskill = a
						continue
						-- don't needlessly waste SP using multi patra when we could instead patra only a single target
					end

				else
					patraskill = a
				end
			end
		end
	end

	if patraskill
		--dprint("ENEMY LOGIC: patra skill found")
		if patraskill.target == TGT_ALLY //Are we patra-ing one ally or all our allies?
			return patraskill, patra
		else
			return patraskill
		end
	end

	local dekunda
	local dekundaskill
	local dekaja
	local dekajaskill

	-- we are affected by debuffs...
	-- see if we can use dekunda!

	if onemore
		--dprint("ENEMY LOGIC: 1MORE! Checking for actions...")
		for i = 1, #mo.allies do
			local a = mo.allies[i]
			for k, v in pairs(a.buffs) do

				if v[1] < 0	-- v[1] is a.buffs[key][1]
					--dprint("ENEMY LOGIC: Affected by debuffs, trying to find dekunda...")
					-- this stat has been lowered! I don't like this one bit!
					dekunda = 1
					break
				end
			end
		end

		if dekunda	-- search for dekunda in our skill list...
			for i = 1, #mo.skills
				local a = attackDefs[mo.skills[i]]
				if a and a.dekunda and (not a.cost or a.costtype ~= CST_SP or (a.cost <= mo.sp))
					dekundaskill = a
					break
				end
			end
		end

		if dekundaskill
			--dprint("ENEMY LOGIC: Found dekunda.")
			return dekundaskill
		end

		-- less important, try and use dekaja if the enemy party is buffed
		for i = 1, #mo.enemies do
			local a = mo.enemies[i]
			for k, v in pairs(a.buffs) do

				if v[1] > 0	-- v[1] is a.buffs[key][1]
					--dprint("ENEMY LOGIC: Found enemy affected by buff! I don't like this!")
					-- this stat has been increased! I don't like this one bit!
					dekaja = 1 //It's dekaja, not dekunda
					break
				end
			end
		end

		if dekaja	-- search for dekaja in our skill list...
			for i = 1, #mo.skills
				local a = attackDefs[mo.skills[i]]
				if a and a.dekaja and (not a.cost or a.costtype ~= CST_SP or (a.cost <= mo.sp))
					dekajaskill = a
					break
				end
			end
		end

		if dekajaskill
			--dprint("ENEMY LOGIC: Found dekaja.")
			return dekajaskill
		end

		--dprint("ENEMY LOGIC: Nothing better to do, see if we can buff ourselves or debuff the enemy!")

		-- if none of that can be done, let's see if we can use this to buff ourselves, perhaps?
		-- or debuff the enemy, one of the other!
		local superbuffs = {}
		local buffs = {}
		local superdebuffs = {}
		local debuffs = {}

		-- get everything we can:
		for i = 1, #mo.skills
			local a = attackDefs[mo.skills[i]]
			if not a or (a.cost and a.costtype == CST_SP and (a.cost > mo.sp))
				--dprint(mo.skills[i].." is invalid!")
				continue
			end

			//Copied from another part of the function for the same purpose
			local last_turn = server.P_BattleStatus[mo.battlen].turnorder[2] ~= mo
			-- if we don't have a turn after this one, we CAN use mind/power charge
			
			if a.superbuff
			and not (a.tetrakarn and mo.tetrakarn)
			and not (a.makarakarn and mo.makarakarn)
			and (last_turn or not (a.powercharge or a.mindcharge)) //This now should actually prevent multi-turn enemies from using Mind/Power Charge outside of their last turn
				superbuffs[#superbuffs+1] = a
			elseif a.buff
				buffs[#buffs+1] = a
			elseif a.superdebuff
				superdebuffs[#superdebuffs+1] = a
			elseif a.debuff
				debuffs[#debuffs+1] = a
			end
		end

		-- depending on what we have, prioritize buffing ourselves in that situation!
		if #superbuffs and P_RandomRange(0, 4)
			return superbuffs[P_RandomRange(1, #superbuffs)]
		elseif #buffs and P_RandomRange(0, 1)
			return buffs[P_RandomRange(1, #buffs)]
		elseif #superdebuffs and P_RandomRange(0, 4)
			return superdebuffs[P_RandomRange(1, #superdebuffs)]
		elseif #debuffs and P_RandomRange(0, 1)
			return debuffs[P_RandomRange(1, #debuffs)]
		end
	end

	-- ghastly wail is a tool of mass destruction!
	-- check if targets are fearful!
	local gtarget

	for i = 1, #mo.enemies
		local a = mo.enemies[i]
		if a.status_condition == COND_HEX
			gtarget = a
			--dprint("ENEMY LOGIC: Found a fearful enemy... Checking for Ghastly Wail...")
			break
		end
	end

	local btl = server.P_BattleStatus[mo.battlen]

	if gtarget
	and btl.turnorder[mo.turns or 1] == mo		-- double-turn enemies: only use ghastly wail on our first turn
	and not onemore								-- WARNING: THIS CODE DOESN'T WORK FOR ENEMIES WITH > 2 TURNS
												//LMAO now it should
	
		for i = 1, #mo.skills
			local a = attackDefs[mo.skills[i]]
			if a and a.ghastlywail and (not a.cost or a.costtype ~= CST_SP or (a.cost <= mo.sp))
				--dprint("ENEMY LOGIC: Found Ghastly Wail")
				return a, gtarget
			end
		end
	end

	-- looks like we're out of cool options, huh!
	-- build a skill list without the specific skills we can't use at all.

	--dprint("ENEMY LOGIC: No special action, just select a random skill")

	local usable_skills = {}

	local last_turn = server.P_BattleStatus[mo.battlen].turnorder[2] ~= mo
	-- if we don't have a turn after this one, we CAN use mind/power charge
	local first_turn = server.P_BattleStatus[mo.battlen].turnorder[mo.turns or 1] == mo and not onemore 
	//Imagine if someone put Fitness/Kannon/Teddeh and Samsara/DFM together on a boss lmao
	//If this is our first turn, we can use insta-kills

	for i = 1, #mo.skills
		local s = mo.skills[i]
		local a = attackDefs[s]

		if a
		and (not a.cost or a.costtype ~= CST_SP or (a.cost <= mo.sp))
		and not a.dekunda
		and not a.dekaja
		and not a.ghastlywail
		and (last_turn or not (a.powercharge or a.mindcharge)) //This now should actually prevent multi-turn enemies from using Mind/Power Charge outside of their last turn
		and not (a.type == ATK_HEAL)
		and not (mo.mindcharge and isAttackPhysical(a))
		and not (mo.powercharge and not isAttackPhysical(a))
		and not ((mo.mindcharge or mo.powercharge) and (not a.power or a.instakill))
		and (first_turn or not (a.instakill)) //So multi-turn enemies don't use insta-kill skills immediately after destroying players' barriers
			usable_skills[#usable_skills+1] = s
		end
	end

	local atk
	if not #usable_skills
		atk = (enemyList[mo.enemy].melee_natk or "slash_1")	-- default attack
	else
		atk = usable_skills[P_RandomRange(1, #usable_skills)]
	end

	return attackDefs[atk]
end)

//Fixing generalEnemyThinker too, if I can
rawset(_G, "newEnemyThinker", function(mo)
	-- we are a retarded enemy and we're too generic to do anything specific!
	//A bit smarter than vanilla though now.
	--dprint("Enemy thinker for "..mo.name)
	-- do we use a skill or our normal attack?
	local skillchance = enemyList[mo.enemy].skillchance or 50
	local attack, atarget = smartAttackSelect(mo)
	local targets

	if not (attack and P_RandomRange(1, 100) <= skillchance and mo.skills and #mo.skills
	and mo.status_condition ~= COND_RAGE
	and mo.status_condition ~= COND_SILENCE)	-- no skills or not using skills
		attack = attackDefs[(enemyList[mo.enemy].melee_natk or "slash_1")]	-- default attack
		atarget = nil
	end

	if not atarget	-- nothing from smart select, do it the yolo way!
		targets = {mo.enemies[P_RandomRange(1, #mo.enemies)]}

		-- get the target(s) of the attack
		if not attack
			attack = attackDefs[(enemyList[mo.enemy].melee_natk or "slash_1")]
		end
		local skill = attack

		if skill.target == TGT_ENEMY	-- target random enemy
			targets = {mo.enemies[P_RandomRange(1, #mo.enemies)]}
		elseif skill.target == TGT_ALLENEMIES
			targets = copyTable(mo.enemies)	-- target all enemies
		elseif skill.target == TGT_ALLY	-- target random ally
			targets = {mo.allies[P_RandomRange(1, #mo.allies)]}
		elseif skill.target == TGT_ALLALLIES -- target all allies
			targets = copyTable(mo.allies)
		elseif skill.target == TGT_CASTER
			targets = {mo}
		elseif skill.target == TGT_DEAD
			print("\x82".."WARNING:".."\x80".." Enemies shouldn't use skills targetting dead entities.")
			attack = "slash_1"
			targets = {mo.enemies[P_RandomRange(1, #mo.enemies)]}	-- fallback
		elseif skill.target == TGT_EVERYONE
			targets = {}
			for i = 1, #mo.allies
				targets[#targets+1] = mo.allies[i]
			end
			for i = 1, #mo.enemies
				targets[#targets+1] = mo.enemies[i]
			end
		end
	else
		targets = {atarget}	-- lol.
	end

	return attack, targets
end)

for k,v in pairs(enemyList)
	if v.thinker == generalEnemyThinker
		v.thinker = newEnemyThinker
	end
end

rawset(_G, "generalEnemyThinker", function(mo)
	return newEnemyThinker(mo)
end)

enemyList["maya_gold"].thinker = function(mo)

							mo.waitturns = $ or 0
							if P_RandomRange(0, 100) < mo.waitturns
								return attackDefs["run"], {mo}
							end

							mo.waitturns = $+10

							return newEnemyThinker(mo)
						end

enemyList["angel"].thinker = function(mo)
						-- Kanade thinker

						local enemies = mo.enemies
						local btl = server.P_BattleStatus[mo.battlen]

						if mo.status_condition == COND_SILENCE
							mo.use_howling = nil
							return newEnemyThinker(mo)
						end

						if mo.use_howling
							mo.use_howling = nil	-- Don't forget to undo that.
							return attackDefs["howling"], mo.enemies
						end

						-- first 2 turns: always go for harmonics and then hand sonic.
						if btl.turn == 1
							return attackDefs["harmonics"], {mo}
						elseif btl.turn == 2
							return attackDefs["hand sonic"], {enemies[P_RandomRange(1, #enemies)]}
						end

						-- make a clone if we're severely outnumbered and that my health is low!!
						if mo.hp < mo.maxhp/2
						and #mo.allies < 3
							return attackDefs["harmonics"], {mo}
						end

						-- under other circumstances just use a random attack in our arsenal

						-- Random chance to use distortion: (1/8)
						if not P_RandomRange(0, 7)

							-- before we do, check if our allies aren't using it either, because it will lead to a guaranteed howling:
							for i = 1, #mo.allies
								if mo.allies[i] and mo.allies[i].valid
								and (mo.allies[i].guaranteedevasion or mo.allies[i].use_howling)

									return newEnemyThinker(mo)	-- well too bad.
								end
							end

							mo.use_howling = true	-- next time we can act for real, use howling!
							return attackDefs["distortion"], {mo}
						end

						return newEnemyThinker(mo)
					end

enemyList["angel_vr"].thinker = function(mo)
						-- Kanade thinker

						local enemies = mo.enemies
						local btl = server.P_BattleStatus[mo.battlen]

						if mo.status_condition == COND_SILENCE
							mo.use_howling = nil
							return newEnemyThinker(mo)
						end

						if mo.use_howling
							mo.use_howling = nil	-- Don't forget to undo that.
							return attackDefs["howling-0"], mo.enemies
						end

						-- first 2 turns: always go for harmonics and then hand sonic.
						if btl.turn == 1
							return attackDefs["harmonics-0"], {mo}
						elseif btl.turn == 2
							return attackDefs["hand sonic"], {enemies[P_RandomRange(1, #enemies)]}
						end

						-- make a clone if we're severely outnumbered and that my health is low!!
						if mo.hp < mo.maxhp/2
						and #mo.allies < 3
							return attackDefs["harmonics-0"], {mo}
						end

						-- under other circumstances just use a random attack in our arsenal

						-- Random chance to use distortion: (1/8)
						if not P_RandomRange(0, 7)

							-- before we do, check if our allies aren't using it either, because it will lead to a guaranteed howling:
							for i = 1, #mo.allies
								if mo.allies[i] and mo.allies[i].valid
								and (mo.allies[i].guaranteedevasion or mo.allies[i].use_howling)

									return newEnemyThinker(mo)	-- well too bad.
								end
							end

							mo.use_howling = true	-- next time we can act for real, use howling!
							return attackDefs["distortion"], {mo}
						end

						return newEnemyThinker(mo)
					end

enemyList["angel_vr_2"].thinker = function(mo)
						-- Kanade thinker

						local enemies = mo.enemies
						local btl = server.P_BattleStatus[mo.battlen]

						if mo.status_condition == COND_SILENCE
							mo.use_howling = nil
							return newEnemyThinker(mo)
						end

						if mo.use_howling
							mo.use_howling = nil	-- Don't forget to undo that.
							return attackDefs["howling-0"], mo.enemies
						end

						-- first 2 turns: always go for harmonics and then hand sonic.
						if btl.turn == 1
							return attackDefs["harmonics-0"], {mo}
						elseif btl.turn == 2
							return attackDefs["hand sonic"], {enemies[P_RandomRange(1, #enemies)]}
						end

						-- make a clone if we're severely outnumbered and that my health is low!!
						if mo.hp < mo.maxhp/2
						and #mo.allies < 3
							return attackDefs["harmonics-0"], {mo}
						end

						-- under other circumstances just use a random attack in our arsenal

						-- Random chance to use distortion: (1/8)
						if not P_RandomRange(0, 7)

							-- before we do, check if our allies aren't using it either, because it will lead to a guaranteed howling:
							for i = 1, #mo.allies
								if mo.allies[i] and mo.allies[i].valid
								and (mo.allies[i].guaranteedevasion or mo.allies[i].use_howling)

									return newEnemyThinker(mo)	-- well too bad.
								end
							end

							mo.use_howling = true	-- next time we can act for real, use howling!
							return attackDefs["distortion"], {mo}
						end

						return newEnemyThinker(mo)
					end

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
							return newEnemyThinker(mo)
						end
						
						if mo.thinkturns == 1
							return attackDefs["dekaja"], mo.enemies
						elseif mo.thinkturns == 2	
						or mo.thinkturns%6 == 0
							return attackDefs["overdrive boost"], {mo}
						end
						
						return newEnemyThinker(mo)
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
						"psy boost", //psy boost, not psi boost
						"bless boost",
						"curse boost",
						"god hand", //god hand, not god's hand
						"god hand", //Oh cool, now it's in V1.3.2
						"god hand",
						"deathbound",
						"deathbound",
						"heat riser",
						"dekaja",
						"dekunda",
					}	-- that's a lot a skills.
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

enemyList["batkan"].thinker = function(mo)
						-- KANTHINK!!!!!!!

						local enemies = mo.enemies
						local btl = server.P_BattleStatus[mo.battlen]

						if mo.hp < mo.maxhp*3/4
						and not mo.bean_summon
						and not (mo.mindcharge or mo.powercharge)
							mo.bean_summon = true
							if btl.turnorder[2] == mo
								table.remove(btl.turnorder, 2)	//remove self from turn order
							end

							return attackDefs["summon bean"], {mo}
						end

						if mo.guaranteedevasion
							if btl.turnorder[2] == mo
								table.remove(btl.turnorder, 2)	//remove self from turn order
							end

							return attackDefs["batkan buster"], mo.enemies
						end

						return newEnemyThinker(mo)
					end
