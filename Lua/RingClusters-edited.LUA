freeslot("MT_RINGCLUSTER", "MT_FOLLOWRING")
mobjinfo[MT_RINGCLUSTER] = {
	851,
	S_INVISIBLE,
	1000,
	S_INVISIBLE,
	sfx_None,
	0,
	sfx_None,
	S_INVISIBLE,
	0,
	sfx_None,
	S_NULL,
	S_NULL,
	S_NULL,
	S_NULL,
	sfx_None,
	0,
	32 * FRACUNIT,
	32 * FRACUNIT,
	0,
	100,
	0,
	sfx_None,
	MF_NOGRAVITY,	-- MF_ENEMY is useful to prevent it from falling on block enemy lines
	S_NULL
}

mobjinfo[MT_FOLLOWRING] = {
	doomednum = -1,
	spawnstate = S_RING,
	spawnhealth = 1000,
	deathsound = sfx_itemup,
	deathstate = S_SPRK1,
	height = 32 * FRACUNIT,
	radius = 32 * FRACUNIT,
	flags = MF_SPECIAL|MF_NOGRAVITY,	-- MF_ENEMY is useful to prevent it from falling on block enemy lines
}

addHook("MobjThinker", function(mo)
	if not mo or not mo.valid return end

	if not mo.rang
		mo.rang = {}
		for i = 1, 16
			mo.rang[i] = P_RandomRange(-90, 90)*ANG1
		end
	end

	local rings = {}

	local dp = displayplayer or players[0]
	if not dp or not dp.valid then return end

	-- make rings rotate
	local f2 = R_PointToDist2(mo.x, mo.y, dp.mo.x, dp.mo.y) > 768*FRACUNIT and MF2_DONTDRAW or 0

	for i = 1, 16
		local hang = leveltime*ANG1*10 + (33*(i-1))*ANG1
		local x = mo.x + 100*FixedMul(cos(hang), cos(mo.rang[i]))
		local y = mo.y + 100*FixedMul(sin(hang), cos(mo.rang[i]))
		local z = mo.z + 100*FixedMul(sin(hang), sin(mo.rang[i]))

		local r = P_SpawnMobj(x, y, z, MT_DUMMY)
		r.state = S_RING
		r.fuse = 2
		r.frame = (leveltime%23)
		rings[#rings+1] = r

		if leveltime%3 == 0
			r = P_SpawnMobj(x, y, z, MT_DUMMY)
			r.state = S_SPRK3
			r.frame = C
			r.destscale = 1
			r.fuse = 12
			r.flags2 = $|f2
		end
	end

	-- cute spark
	if not (leveltime%10) == 0
		local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_SUPERSPARK)
		--s.state = S_SSPK1
	end

	for p in players.iterate do
		local pmo = p.mo
		if not pmo continue end

		if server.P_BattleStatus[p.P_party] and server.P_BattleStatus[p.P_party].running continue end	-- no!

		if pmo.subsector.sector == mo.subsector.sector
		local five = #server.plentities[p.P_party]+1 //Well, it's five for the default, but you never know?
		local nine = #server.plentities[p.P_party]*2+1
			for i = 1, nine

				local check = (i<=five) and server.plentities[p.P_party][i-1] or server.plentities[p.P_party][i-five]
				if not check	-- i == 1
					check = p.maincontrol	-- be a little bitch and check MYSELF first!
				end

				if check and check.valid and (check.control == p or (i>five and check.control.quittime))	-- this has to be us. //Heal rejoin ghosts last
				and check.hp < check.maxhp
					for j = 1, #rings do
						local r = rings[j]
						local r2 = P_SpawnMobj(r.x, r.y, r.z, MT_FOLLOWRING)
						r2.target = pmo
					end

					DNG_Damage(check, -check.maxhp/10)
					if i == 1
						VFX_Play(p.mo, VFX_HEALSELF)
					end

					S_StartSound(p.mo, sfx_heal)
					P_RemoveMobj(mo)
					return
				end
			end
		end
	end
end, MT_RINGCLUSTER)

addHook("MobjThinker", function(mo)
	if not mo or not mo.valid return end
	if not mo.target or not mo.target.valid
		P_RemoveMobj(mo)
		return
	end

	local r = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
	r.state = S_SPRK1

	if mo.health
		P_TeleportMove(mo, (mo.target.x + mo.x)/2, (mo.target.y + mo.y)/2, (mo.target.z + mo.z)/2)
	end
end, MT_FOLLOWRING)