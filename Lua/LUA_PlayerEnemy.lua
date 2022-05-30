local numberofskins = #skins

rawset(_G, "playerenemythinker", function(mo)
	local enemies = mo.enemies
	local allies = mo.allies
	local btl = server.P_BattleStatus[mo.battlen]
	mo.turn = btl.turn
	mo.knockeddown = 0
	mo.condcount = 0
	if mo.batontouch and server.gamemode ~= GM_CHALLENGE //Would be unfair to let them use AOAs in challenge mode
		for i,j in ipairs(enemies)
			if j.down or (j.hp == 0)
				mo.knockeddown = $+1
			end
		end
		for i,j in ipairs(allies)
			if not BTL_noAOAStatus(j)
				mo.condcount = $+1
			end
		end
		if mo.knockeddown >= #enemies and mo.condcount > 1 and #allies > 1 and mo.hp
			return attackDefs["all_out"], enemies
		end
	end
	local knockdowntarget = nil
	local knockdownskill = nil
	local knockdownskills = 0
	for i,j in ipairs(enemies)
		if #mo.skills
			for k,l in ipairs(mo.skills)
				local a = attackDefs[l]
				if (getAttackAff(j, a) == DMG_WEAK) //Is the enemy weak to this attack?
				and not j.down and not j.guard //Can they be knocked down?
				and not (mo.mindcharge and isAttackPhysical(a)) //Would this waste a mind charge?
				and not (mo.powercharge and not isAttackPhysical(a)) //Or a Power Charge?
				and not ((mo.mindcharge or mo.powercharge) and (not a.power or a.instakill))
				and j.status_condition ~= COND_HYPER //I know, this won't happen in vision quest, but whatever
					knockdownskills = $ and $+1 or 1
					if P_RandomChance(FRACUNIT/(knockdownskills))
						knockdownskill = a
						knockdowntarget = j
					end
				end
			end
		end
		local a = attackDefs[mo.melee_natk]
		if (getAttackAff(j, a) == DMG_WEAK) //Is the enemy weak to this attack?
		and not j.down and not j.guard //Can they be knocked down?
		and not (mo.mindcharge and isAttackPhysical(a)) //Would this waste a mind charge?
		and not (mo.powercharge and not isAttackPhysical(a)) //Or a Power Charge?
		and not ((mo.mindcharge or mo.powercharge) and (not a.power or a.instakill))
		and j.status_condition ~= COND_HYPER //I know, this won't happen in vision quest, but whatever
			knockdownskills = $ and $+1 or 1
			if P_RandomChance(FRACUNIT/(knockdownskills))
				knockdownskill = a
				knockdowntarget = j
			end
		end
	end
	if knockdownskill and P_RandomChance(FRACUNIT/2) and mo.status_condition ~= COND_DIZZY
		if knockdownskill.target == TGT_ENEMY
			//print("Using "..knockdownskill.name.." on "..knockdowntarget.name)
			return knockdownskill, {knockdowntarget}
		elseif knockdownskill.target == TGT_ALLENEMIES
			//print("Using "..knockdownskill.name.." on all enemies.")
			return knockdownskill, enemies
		end
	end
	if mo.batontouch and P_RandomChance(FRACUNIT/4)
		local batonpasstarget = nil
		local batonpasstargets = 0
		for i,j in ipairs(allies)
			if mo ~= j and (not j.turn or j.turn < mo.turn)
				batonpasstargets = $ and $+1 or 1
				if P_RandomChance(FRACUNIT/(batonpasstargets))
					batonpasstarget = j
				end
			end
		end
		if batonpasstarget
			return attackDefs["baton pass"], {batonpasstarget}
		end
	end
	local knockdowntarget = nil
	local knockdownskill = nil
	local knockdownskills = 0
	for i,j in ipairs(enemies)
		if #mo.skills
			for k,l in ipairs(mo.skills)
				local a = attackDefs[l]
				if (getAttackAff(j, a) == DMG_TECHNICAL) //Could this attack technical?
				and not j.down and not j.guard //Can they be knocked down?
				and not (mo.mindcharge and isAttackPhysical(a)) //Would this waste a mind charge?
				and not (mo.powercharge and not isAttackPhysical(a)) //Or a Power Charge?
				and not ((mo.mindcharge or mo.powercharge) and (not a.power or a.instakill))
				and j.status_condition ~= COND_HYPER //I know, this won't happen in vision quest, but whatever
					knockdownskills = $ and $+1 or 1
					if P_RandomChance(FRACUNIT/(knockdownskills))
						knockdownskill = a
						knockdowntarget = j
					end
				end
			end
		end
		local a = attackDefs[mo.melee_natk]
		if (getAttackAff(j, a) == DMG_TECHNICAL) //Could this attack technical?
		and not j.down and not j.guard //Can they be knocked down?
		and not (mo.mindcharge and isAttackPhysical(a)) //Would this waste a mind charge?
		and not (mo.powercharge and not isAttackPhysical(a)) //Or a Power Charge?
		and not ((mo.mindcharge or mo.powercharge) and (not a.power or a.instakill))
		and j.status_condition ~= COND_HYPER //I know, this won't happen in vision quest, but whatever
			knockdownskills = $ and $+1 or 1
			if P_RandomChance(FRACUNIT/(knockdownskills))
				knockdownskill = a
				knockdowntarget = j
			end
		end
	end
	if knockdownskill and P_RandomChance(FRACUNIT/2) and mo.status_condition ~= COND_DIZZY
		if knockdownskill.target == TGT_ENEMY
			//print("Using "..knockdownskill.name.." on "..knockdowntarget.name)
			return knockdownskill, {knockdowntarget}
		elseif knockdownskill.target == TGT_ALLENEMIES
			//print("Using "..knockdownskill.name.." on all enemies.")
			return knockdownskill, enemies
		end
	end
	return generalEnemyThinker(mo)
end)

enemyList["player_enemy"] = {
		name = "Player Enemy",
		skillchance = 100,	-- /100, probability of using a skill
		level = 99,
		hp = 1,
		sp = 1,
		strength = 1,
		magic = 1,
		endurance = 1,
		agility = 1,
		luck = 1,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		r_exp = 6000,
		noroguerandom = true,	-- Don't randomize affinities with rogue mode
		
		skills = {},
		thinker = playerenemythinker,
}

enemyList["player_enemy_boss"] = {
		name = "Player Enemy",
		skillchance = 100,	-- /100, probability of using a skill
		level = 99,
		hp = 1,
		sp = 1,
		strength = 1,
		magic = 1,
		endurance = 1,
		agility = 1,
		luck = 1,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		r_exp = 60000,
		boss = true,
		noroguerandom = true,	-- Don't randomize affinities with rogue mode
		nopvp = true,

		skills = {},
		thinker = playerenemythinker,
}

for i=1,numberofskins
	local skin = skins[i-1].name
	local data = charStats[skin]
	enemyList["player_enemy" + tostring(i)] = copyTable(enemyList["player_enemy"])
	addTables(enemyList["player_enemy" + tostring(i)], personaList[data.persona])
	addTables(enemyList["player_enemy" + tostring(i)], data)
	enemyList["player_enemy" + tostring(i)].skin = skins[i-1].name
	enemyList["player_enemy" + tostring(i)].color = skins[i-1].prefcolor
	/*enemyList["player_enemy" + tostring(i)].vfx_summon = data.vfx_summon
	enemyList["player_enemy" + tostring(i)].vfx_skill = data.vfx_skill
	enemyList["player_enemy" + tostring(i)].vfx_item = data.vfx_item
	enemyList["player_enemy" + tostring(i)].vfx_hurt = data.vfx_hurt
	enemyList["player_enemy" + tostring(i)].vfx_hurtx = data.vfx_hurtx
	enemyList["player_enemy" + tostring(i)].vfx_die = data.vfx_die
	enemyList["player_enemy" + tostring(i)].vfx_killconfirm = data.vfx_killconfirm
	enemyList["player_enemy" + tostring(i)].vfx_heal = data.vfx_heal
	enemyList["player_enemy" + tostring(i)].vfx_healself = data.vfx_healself
	enemyList["player_enemy" + tostring(i)].vfx_kill = data.vfx_kill
	enemyList["player_enemy" + tostring(i)].vfx_1more = data.vfx_1more
	enemyList["player_enemy" + tostring(i)].vfx_crit = data.vfx_crit
	enemyList["player_enemy" + tostring(i)].vfx_aoaask = data.vfx_aoaask
	enemyList["player_enemy" + tostring(i)].vfx_aoado = data.vfx_aoado
	enemyList["player_enemy" + tostring(i)].vfx_aoarelent = data.vfx_aoarelent
	enemyList["player_enemy" + tostring(i)].vfx_miss = data.vfx_miss
	enemyList["player_enemy" + tostring(i)].vfx_dodge = data.vfx_dodge
	enemyList["player_enemy" + tostring(i)].vfx_win = data.vfx_win
	enemyList["player_enemy" + tostring(i)].vfx_levelup = data.vfx_levelup
	enemyList["player_enemy" + tostring(i)].skin = skins[i-1].name
	enemyList["player_enemy" + tostring(i)].anim_stand = data.anim_stand
	enemyList["player_enemy" + tostring(i)].name = data.name
	enemyList["player_enemy" + tostring(i)].melee_natk = data.melee_natk
	enemyList["player_enemy" + tostring(i)].weak = data.persona.weak
	enemyList["player_enemy" + tostring(i)].resist = data.persona.resist
	enemyList["player_enemy" + tostring(i)].block = data.persona.block
	enemyList["player_enemy" + tostring(i)].drain = data.persona.drain
	enemyList["player_enemy" + tostring(i)].repel = data.persona.repel*/
end

for i=1,numberofskins
	local skin = skins[i-1].name
	local data = charStats[skin]
	enemyList["player_enemy_boss" + tostring(i)] = copyTable(enemyList["player_enemy_boss"])
	addTables(enemyList["player_enemy_boss" + tostring(i)], personaList[data.persona])
	addTables(enemyList["player_enemy_boss" + tostring(i)], data)
	enemyList["player_enemy_boss" + tostring(i)].skin = skins[i-1].name
	enemyList["player_enemy_boss" + tostring(i)].color = skins[i-1].prefcolor
	/*enemyList["player_enemy_boss" + tostring(i)].vfx_summon = data.vfx_summon
	enemyList["player_enemy_boss" + tostring(i)].vfx_skill = data.vfx_skill
	enemyList["player_enemy_boss" + tostring(i)].vfx_item = data.vfx_item
	enemyList["player_enemy_boss" + tostring(i)].vfx_hurt = data.vfx_hurt
	enemyList["player_enemy_boss" + tostring(i)].vfx_hurtx = data.vfx_hurtx
	enemyList["player_enemy_boss" + tostring(i)].vfx_die = data.vfx_die
	enemyList["player_enemy_boss" + tostring(i)].vfx_killconfirm = data.vfx_killconfirm
	enemyList["player_enemy_boss" + tostring(i)].vfx_heal = data.vfx_heal
	enemyList["player_enemy_boss" + tostring(i)].vfx_healself = data.vfx_healself
	enemyList["player_enemy_boss" + tostring(i)].vfx_kill = data.vfx_kill
	enemyList["player_enemy_boss" + tostring(i)].vfx_1more = data.vfx_1more
	enemyList["player_enemy_boss" + tostring(i)].vfx_crit = data.vfx_crit
	enemyList["player_enemy_boss" + tostring(i)].vfx_aoaask = data.vfx_aoaask
	enemyList["player_enemy_boss" + tostring(i)].vfx_aoado = data.vfx_aoado
	enemyList["player_enemy_boss" + tostring(i)].vfx_aoarelent = data.vfx_aoarelent
	enemyList["player_enemy_boss" + tostring(i)].vfx_miss = data.vfx_miss
	enemyList["player_enemy_boss" + tostring(i)].vfx_dodge = data.vfx_dodge
	enemyList["player_enemy_boss" + tostring(i)].vfx_win = data.vfx_win
	enemyList["player_enemy_boss" + tostring(i)].vfx_levelup = data.vfx_levelup
	enemyList["player_enemy_boss" + tostring(i)].name = data.name
	enemyList["player_enemy_boss" + tostring(i)].anim_stand = data.anim_stand
	enemyList["player_enemy_boss" + tostring(i)].melee_natk = data.melee_natk
	enemyList["player_enemy_boss" + tostring(i)].weak = data.persona.weak
	enemyList["player_enemy_boss" + tostring(i)].resist = data.persona.resist
	enemyList["player_enemy_boss" + tostring(i)].block = data.persona.block
	enemyList["player_enemy_boss" + tostring(i)].drain = data.persona.drain
	enemyList["player_enemy_boss" + tostring(i)].repel = data.persona.repel*/
end

local function DifferentSkin(mo)
	for i,j in ipairs(mo.allies)
		if j ~= mo and j.skin == mo.skin
			return false
		end
	end
	return true
end

addHook("MobjThinker", function(mo)
	if not mo.valid or not mo.enemy or string.sub(mo.enemy, 1, 12) ~= "player_enemy" or mo.hp == 0 then return end
	if not mo.initialised
		if mo.enemy == "player_enemy" or mo.enemy == "player_enemy_boss"
			local skinnumber = P_RandomRange(0, numberofskins-1)
			mo.skin = skins[skinnumber].name
			repeat
				skinnumber = P_RandomRange(0, numberofskins-1)
				mo.skin = skins[skinnumber].name
			until DifferentSkin(mo)
			BTL_changeEnemy(mo, mo.enemy + tostring(skinnumber+1))
		end
		local skin = mo.skin
		local data = charStats[skin]
		mo.name = data.name
		mo.melee_natk = data.melee_natk
		if mo.boss //giving rogue mode's buffs to the bosses
			mo.color = skins[skin].prefcolor
			mo.maxhp = $*11/10
			mo.hp = mo.maxhp
			mo.maxsp = $*4
			mo.sp = mo.maxsp
			mo.strength = $*115/100
			mo.magic = $*115/100
			mo.agility = $*115/100
			mo.endurance = $*115/100
			mo.luck = $*115/100
		else
			mo.color = P_RandomRange(1, 62)
		end
		PLYR_initPersona(mo, data.persona or "orpheus", skin)
		BTL_splitSkills(mo)
		PLYR_initAnims(mo, skin)
		BTL_readybuffs(mo)
		if data.overlay
			local o = P_SpawnMobjFromMobj(mo, 0, 0, 0, data.overlay)
			o.target = mo
			mo.overlay = o
			--dprint("Spawned overlay for skin "..mo.skin)
		end
		mo.coreentity = true
		mo.stats = mo.skin
		local wpn = data.wep
		if not weaponsList[wpn]
			wpn = "shoes_01"
		end	-- you never know...
		equipWeapon(mo, makeWeapon(wpn), true)
		equipRing(mo, makeRing("ring_01"), true)
		mo.initialised = 1
	end
end, MT_PFIGHTER)