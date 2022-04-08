attackDefs["super pralaya"] = {
		name = "Super Pralaya",
		type = ATK_ALMIGHTY,
		power = 1360,
		accuracy = 100,
		costtype = CST_HPPERCENT,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 36,
		critical = 15,
		desc = "Severe Almighty Pierce damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15	-- sound
				playSound(mo.battlen, sfx_bufu5)
			elseif timer >= 15 and timer <= 40

				for i = 1, 4
					local angle = target.angle + P_RandomRange(-30, 30)*ANG1
					local x = target.x + FixedMul(mo.scale, 256*cos(angle))
					local y = target.y + FixedMul(mo.scale, 256*sin(angle))
					local z = target.z + P_RandomRange(0, 256)*mo.scale

					local p = P_SpawnMobj(x, y, z, MT_DUMMY)
					p.flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
					p.state = S_SSPK1
					p.scale = mo.scale
					p.colorized = true
					p.color = SKINCOLOR_ORANGE
					p.angle = target.angle + P_RandomRange(-30, 30)*ANG1
					p.fuse = 10

					p.momx = (target.x - p.x)/10
					p.momy = (target.y - p.y)/10
					p.momz = (target.z - p.z)/10

				end

			elseif timer == 41
				playSound(mo.battlen, sfx_bufu6)
				createSplat(mo)
				createSplat(mo)
				localquake(mo.battlen, FRACUNIT*32, 10)
				if ((target.enemy and enemyList[target.enemy].weak & ATK_PIERCE) or (target.persona and target.persona.weak & ATK_PIERCE)) and not (target.weak & ATK_ALMIGHTY)
					target.weak = $|ATK_ALMIGHTY //temporarily make them weak to Almighty for this hit
					damageObject(target)
					target.weak = $ & ~ATK_ALMIGHTY
				else
					damageObject(target)
				end
				
				for i = 1, 32 do
					local p = P_SpawnMobj(target.x, target.y, target.z+FRACUNIT*20, MT_DUMMY)
					p.flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
					p.state = S_SSPK1
					p.scale = mo.scale
					p.colorized = true
					p.color = SKINCOLOR_ORANGE
					p.angle = target.angle + P_RandomRange(-30, 30)*ANG1
					p.momz = P_RandomRange(-24, 24)*mo.scale
					P_InstaThrust(p, p.angle, mo.scale*64)
				end

				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = A|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*6
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

			elseif timer >= 41 and timer < 80

				for i = 1, 8 do
					local p = P_SpawnMobj(target.x, target.y, target.z+FRACUNIT*20, MT_DUMMY)
					p.flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
					p.state = S_SSPK1
					p.scale = mo.scale
					p.colorized = true
					p.color = SKINCOLOR_ORANGE
					p.angle = target.angle + P_RandomRange(-30, 30)*ANG1
					p.momz = P_RandomRange(-12, 12)*mo.scale
					P_InstaThrust(p, p.angle, mo.scale*32)
				end

				local p = P_SpawnMobj(target.x + P_RandomRange(-12, 12)*mo.scale, target.y + P_RandomRange(-12, 12)*mo.scale, target.z + P_RandomRange(0, 12)*mo.scale, MT_DUMMY)
				p.flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
				p.state = S_SSPK1
				p.scale = mo.scale*2
				p.colorized = true
				p.color = SKINCOLOR_ORANGE
				P_InstaThrust(p, target.angle, -mo.scale*64)

			elseif timer == 80
				return true
			end
		end,
	}

attackDefs["super god hand"] = {
		name = "Super God's hand",
		type = ATK_ALMIGHTY,
		power = 1560,
		accuracy = 100,
		costtype = CST_HPPERCENT,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 50,
		critical = 33,
		desc = "Severe Almighty Strike damage to \none enemy. Very high critical rate.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 16

				playSound(mo.battlen, sfx_becrsh)
				for i = 1, 16 do
					local atk = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					atk.momz = -1*FRACUNIT
					atk.state = S_AOADUST1
					atk.scale = FRACUNIT*1
					atk.destscale = FRACUNIT*2
					atk.angle = ANG1*360 / 16	* (i-1)
					P_InstaThrust(atk, atk.angle, 10*FRACUNIT)
				end

				target.hand = P_SpawnMobj(target.x, target.y, target.z + 500*FRACUNIT, MT_DUMMY)
				target.hand.momz = -25*FRACUNIT
				target.hand.tics = -1
				target.hand.sprite = SPR_HAND
				target.hand.frame = A
				target.hand.scale = FRACUNIT*4
				target.hand.fuse = TICRATE*8
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
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				localquake(mo.battlen, FRACUNIT*8, 1)
				j = $-1
			end

			if target.hand and target.hand.valid
				local h = target.hand

				if leveltime%4 == 0
					for i = 1, 16 do
						local atk = P_SpawnMobj(h.x, h.y, h.z, MT_DUMMY)
						atk.momz = -1*FRACUNIT
						atk.state = S_AOADUST1
						atk.scale = FRACUNIT*2
						atk.destscale = FRACUNIT*4
						atk.angle = ANG1*360 / 16	* (i-1)
						P_InstaThrust(atk, atk.angle, 30*FRACUNIT)
					end
				end

				for i = 1, 2
					local f = P_SpawnMobj(h.x + P_RandomRange(-32, 32)*FRACUNIT, h.y + P_RandomRange(-32, 32)*FRACUNIT, h.z + FRACUNIT*60, MT_DUMMY)
					f.state = S_QUICKBOOM1
					f.color = SKINCOLOR_RED
					f.scale = FRACUNIT*3
				end

				if timer == 16 + 20
					-- delet old shit:
					mo.fangle = (R_PointToAngle(target.x, target.y)) + ANG1*180
					mo.columns = {}

					local a = mo.fangle - ANG1*80

					for i = 1, 16
						local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						P_InstaThrust(m, a, FRACUNIT*48)
						mo.columns[#mo.columns+1] = m
						m.state = S_INVISIBLE
						m.tics = TICRATE
						a = $+ ANG1*10
					end

					if ((target.enemy and enemyList[target.enemy].weak & ATK_STRIKE) or (target.persona and target.persona.weak & ATK_STRIKE)) and not (target.weak & ATK_ALMIGHTY)
						target.weak = $|ATK_ALMIGHTY //temporarily make them weak to Almighty for this hit
						damageObject(target)
						target.weak = $ & ~ATK_ALMIGHTY
					else
						damageObject(target)
					end

					localquake(mo.battlen, FRACUNIT*50, 10)
					for i = 1, 4
						createSplat(mo)
					end
				end

				if timer == 16 + 20 + TICRATE
					mo.columns = nil
					mo.fangle = nil
					return true
				end
			end
		end,
	}

attackDefs["super brave blade"] = {
		name = "Super Brave Blade",
		type = ATK_ALMIGHTY,
		power = 1200,
		accuracy = 97,
		costtype = CST_HPPERCENT,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		technical = COND_FREEZE,
		cost = 34,
		critical = 7,
		desc = "Severe Almighty Slash damage to \none enemy. \nHigh critical rate",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.state = S_SLASHING_2_1
				s.color = SKINCOLOR_ORANGE
				s.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_slash)
				s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.state = S_SLASHING_1_1
				s.color = SKINCOLOR_ORANGE
				s.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_slash)

			elseif timer == 17
				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = C|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE
				playSound(mo.battlen, sfx_slash)

			elseif timer == 19

					if ((target.enemy and enemyList[target.enemy].weak & ATK_SLASH) or (target.persona and target.persona.weak & ATK_SLASH)) and not (target.weak & ATK_ALMIGHTY)
					target.weak = $|ATK_ALMIGHTY //temporarily make them weak to Almighty for this hit
					damageObject(target)
					target.weak = $ & ~ATK_ALMIGHTY
				else
					damageObject(target)
				end
				playSound(mo.battlen, sfx_bexpld)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,10
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-35, 35)*FRACUNIT
					b.momy = P_RandomRange(-35, 35)*FRACUNIT
					b.momz = P_RandomRange(-35, 35)*FRACUNIT
					b.color = SKINCOLOR_RED
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT/2
					b.destscale = FRACUNIT/12
					b.tics = 35
				end

				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_ORANGE

				s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*8
				s.scalespeed = FRACUNIT/2
				s.color = SKINCOLOR_ORANGE

				s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = G|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.tics = TICRATE/2
				s.fuse = s.tics
				s.destscale = FRACUNIT*10
				s.scalespeed = FRACUNIT/4
				s.color = SKINCOLOR_ORANGE

			elseif timer == 45
				target.slashsprite = nil
				return true
			end
		end,
	}

attackDefs["super psycho force"] = {
		name = "Super Psycho Force",
		type = ATK_ALMIGHTY,
		power = 1300,
		accuracy = 95,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 48,
		desc = "Severe Almighty Psy dmg to one enemy.",
		target = TGT_ENEMY,
		-- Animation courtesy of @GlithcedPhoenix
		-- Modified to be slightly shorter

		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			local psiocolors = {SKINCOLOR_TEAL, SKINCOLOR_YELLOW, SKINCOLOR_PINK, SKINCOLOR_BLACK, SKINCOLOR_WHITE}

			if timer == 1
				target.diamonds = {}
				target.psiodyne = {}
				target.diamspeed = 0
				target.diammom = 0
				target.diamdist = 100
				for i = 1,40
					target.diamonds[i] = "a"
				end
				playSound(mo.battlen, sfx_s3k74)

			elseif timer >= 20 and timer < 60 -- spawn the diamonds in a pattern

				if timer == 55
					playSound(mo.battlen, sfx_s3k74)
				end

				local place = P_RandomRange(1,40)
				while target.diamonds[place] != "a"
					place = P_RandomRange(1,40)
				end
				local ang = ANG1*18*(place)
				local z
				if place <= 20 and place%2 == 0
					z = 84
				elseif place%2 == 0
					z = 40
				elseif place <= 20
					z = 68
				else
					z = 24
				end
				local diam = P_SpawnMobj(target.x - target.diamdist*cos(ang), target.y - target.diamdist*sin(ang), target.z + z*FRACUNIT + target.height/2, MT_DUMMY)
				diam.sprite = SPR_PSID
				diam.frame = B|FF_FULLBRIGHT|TR_TRANS20
				diam.color = psiocolors[P_RandomRange(1,5)]
				diam.scale = FRACUNIT*3/2
				diam.angle = ang
				diam.tics = 110-timer
				diam.extravalue1 = 20
				target.diamonds[place] = diam

			elseif timer >= 60 and timer < 110 -- https://www.youtube.com/watch?v=l4mTNQLsD0c
				if timer == 60
					playSound(mo.battlen, sfx_s3kc5l)
				elseif timer == 110
					playSound(mo.battlen, sfx_s3k74)
				end

				for j = 1, #target.diamonds
					local m = target.diamonds[j]
					if not m or not m.valid
						j = $-1
						continue
					end

					local f = target.diamonds[j]
					if timer <= 83
						target.diamspeed = (timer - 59)
					else
						target.diamspeed = 24
					end
					f.angle = $ + ANG1*target.diamspeed

				end
			elseif timer == 110
				for k,v in ipairs(mo.allies)
					if v and v.control and v.control.valid
						P_StartQuake(FRACUNIT*20, 40)
						playSound(mo.battlen, sfx_psi)
						P_FlashPal(v.control, 5, 10) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
					end
				end

				for k,v in ipairs(mo.enemies)	-- Also perform the check on enemies.
					if v and v.control and v.control.valid
						P_StartQuake(FRACUNIT*20, 40)
						playSound(mo.battlen, sfx_psi)
						P_FlashPal(v.control, 5, 10) //v.control, pallette, tics active, 5 is the inverted palette, 4 is the Arma's red flash pal, rest are just white flash excl 0
					end
				end

					if ((target.enemy and enemyList[target.enemy].weak & ATK_PSY) or (target.persona and target.persona.weak & ATK_PSY)) and not (target.weak & ATK_ALMIGHTY)
					target.weak = $|ATK_ALMIGHTY //temporarily make them weak to Almighty for this hit
					damageObject(target)
					target.weak = $ & ~ATK_ALMIGHTY
				else
					damageObject(target)
				end
			elseif timer > 110 and timer <= 126 and timer%2 == 0 -- spawn the spiral
				if timer == 111
					for i = 1,4
						playSound(mo.battlen, sfx_s3k4e)
					end
				end
				local cam = server.P_BattleStatus[mo.battlen].cam
				local hang = cam.angle + ANG1*90
				for i = 1, 6
					local place = ((timer-109)/2)
					local vang = ANG60*(i-1)+place*place*ANG1
					local dist = 70*place
					local x = target.x + dist*FixedMul(cos(hang), cos(vang))
					local y = target.y + dist*FixedMul(sin(hang), cos(vang))
					local z = (target.z + 100*FRACUNIT) + dist*FixedMul(sin(ANGLE_270), sin(vang))
					local ol = P_SpawnMobj(x, y, z, MT_THOK)
					ol.sprite = SPR_NTHK
					ol.color = psiocolors[place%5+1]
					ol.scale = 1
					ol.destscale = FRACUNIT*2
					ol.frame = A|FF_FULLBRIGHT
					ol.tics = 15
					ol = P_SpawnMobj(x, y, z, MT_THOK)
					ol.sprite = SPR_NTHK
					ol.color = psiocolors[place%5+1]
					ol.scale = 1
					ol.destscale = FRACUNIT*2
					ol.frame = B|FF_FULLBRIGHT
					ol.tics = 20
				end
			elseif timer == 150
				return true
			end

			local j = #target.diamonds
			while j
				local diam = target.diamonds[j]
				if not diam or not diam.valid
					j = $-1
					continue
				end
				if diam.extravalue1 > 1 and timer%4 == 0 -- this handles the diamonds' blink effect when spawned
					diam.frame = C|FF_FULLBRIGHT|TR_TRANS20
					diam.color = psiocolors[P_RandomRange(1,5)]
					diam.extravalue1 = $ - 1
				elseif diam.extravalue1 > 1 and timer%2 == 0
					diam.frame = D|FF_FULLBRIGHT|TR_TRANS20
					diam.color = psiocolors[P_RandomRange(1,5)]
					diam.extravalue1 = $ - 1
				elseif diam.extravalue1 == 1
					diam.frame = A|FF_FULLBRIGHT|TR_TRANS20
					diam.color = psiocolors[P_RandomRange(1,5)]
					diam.extravalue1 = $ - 1
				end
				local x, y
				x = target.x - target.diamdist*cos(diam.angle)
				y = target.y - target.diamdist*sin(diam.angle)
				P_TeleportMove(diam, x, y, diam.z)

				j = $-1
			end

			target.diamdist = $ + target.diammom

			if target.diamdist > 200
				target.diammom = $ - 1
			elseif target.diamdist < 200 and timer <= 100
				target.diammom = $ + 1
				if target.diamdist < 118 -- spawn a bunch of psiodyne particles when the ring gets close to the target
					local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					ol.sprite = SPR_NTHK
					ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
					ol.scale = 1
					ol.destscale = FRACUNIT/2
					ol.frame = A|FF_FULLBRIGHT
					ol.tics = 115-timer
					ol.angle = P_RandomRange(0, 359)*ANG1
					ol.extravalue1 = 40

					local hthrust = P_RandomRange(0, 128)
					local vthrust = 128-hthrust
					P_InstaThrust(ol, ol.angle, hthrust*FRACUNIT)
					ol.momz = vthrust*FRACUNIT
					ol.savemoms = {ol.momx, ol.momy, ol.momz}
					target.psiodyne[#target.psiodyne+1] = ol
				end
			end

			local m = #target.psiodyne
			while m
				local ol = target.psiodyne[m]
				if not ol or not ol.valid
					m = $-1
					continue
				end

				if ol.extravalue1 == -10
					local x = target.x + P_RandomRange(-128, 128)*FRACUNIT
					local y = target.y + P_RandomRange(-128, 128)*FRACUNIT
					local z = target.z + P_RandomRange(0, 128)*FRACUNIT

					playSound(mo.battlen, sfx_s3k77)
					P_StartQuake(FRACUNIT*10, 10)

					local ai = P_SpawnMobj(x, y, z, MT_DUMMY)
					ai.sprite = SPR_NTHK
					ai.color = psiocolors[P_RandomRange(1, #psiocolors)]
					ai.scale = 1
					ai.destscale = FRACUNIT*32
					ai.scalespeed = FRACUNIT/3
					ai.frame = B|FF_FULLBRIGHT
					ai.tics = 20
					P_StartQuake(FRACUNIT*10, 10)

					ai = P_SpawnMobj(x, y, z, MT_DUMMY)
					ai.sprite = SPR_NTHK
					ai.color = psiocolors[P_RandomRange(1, #psiocolors)]
					ai.scale = 1
					ai.destscale = FRACUNIT*32
					ai.scalespeed = FRACUNIT
					ai.frame = B|FF_FULLBRIGHT|TR_TRANS50
					ai.tics = 8
				elseif ol.extravalue1 < 0
					ol.momx = $ + (target.x-ol.x)/64
					ol.momy = $ + (target.y-ol.y)/64
					ol.momz = $ + (target.z-ol.z)/64
					ol.extravalue1 = $ - 1
				elseif ol.extravalue1 == 0
					ol.fuse = 11
					ol.extravalue1 = $ - 1
				else
					ol.extravalue1 = $ - 1
					ol.momx = $*80/100
					ol.momy = $*80/100
					ol.momz = $*80/100
				end

				m = $-1
			end
		end,
	}

attackDefs["super atomic flare"] = {
		name = "Super Atomic Flare",
		type = ATK_ALMIGHTY,
		power = 1300,
		accuracy = 95,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 48,
		technical = COND_BURN|COND_FREEZE|COND_SHOCK,
		desc = "Severe Almighty Nuke dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20

				local s = P_SpawnMobj(target.x, target.y, target.z + mo.scale*64, MT_DUMMY)
				s.color = SKINCOLOR_WHITE
				s.state = S_MEGISTAR1
				s.scale = FRACUNIT*4
				playSound(mo.battlen, sfx_hamas2)

			elseif timer == 40
				localquake(mo.battlen, FRACUNIT*32, 100)
				playSound(mo.battlen, sfx_frei1)

			elseif timer > 40
			and timer < 130

				if leveltime & 1
					for i = 1, 2

						local s = P_SpawnMobj(target.x, target.y, target.z + mo.scale*64, MT_DUMMY)
						if i == 1
							s.z = $ - mo.scale*64
						else
							s.z = $ + mo.scale*128
						end

						s.sprite = SPR_SLAS
						s.frame = K+(i-1) | FF_FULLBRIGHT | TR_TRANS30
						s.color = SKINCOLOR_TEAL
						s.scale = FRACUNIT/8
						s.destscale = FRACUNIT*9
						s.scalespeed = FRACUNIT/2
						s.tics = TICRATE/2

						s.momx = P_RandomRange(-2, 2)*FRACUNIT
						s.momy = P_RandomRange(-2, 2)*FRACUNIT
						s.momz = P_RandomRange(-2, 2)*FRACUNIT

					end
				end

				local ang = R_PointToAngle(target.x, target.y)
				local angs = {ang + ANG1*120, ang - ANG1*60}
				local momzs = {-1, 1}

				for i = 1, 2
					for j = 1, 16

						local boom = P_SpawnMobj(target.x, target.y, target.z + 64*mo.scale, MT_DUMMY)
						boom.state = S_CQUICKBOOM1
						boom.color = SKINCOLOR_TEAL
						boom.angle = angs[i]
						P_InstaThrust(boom, boom.angle, P_RandomRange(16, 64)*FRACUNIT)
						boom.momz = P_RandomRange(6, 16)*momzs[i]*FRACUNIT
						boom.scale = FRACUNIT*3/2
					end
				end
			end

			if timer == 110
				if ((target.enemy and enemyList[target.enemy].weak & ATK_NUCLEAR) or (target.persona and target.persona.weak & ATK_NUCLEAR)) and not (target.weak & ATK_ALMIGHTY)
					target.weak = $|ATK_ALMIGHTY //temporarily make them weak to Almighty for this hit
					damageObject(target)
					target.weak = $ & ~ATK_ALMIGHTY
				else
					damageObject(target)
				end
			elseif timer == 140
				return true
			end
		end,
	}

attackDefs["super thunder reign"] = {
		name = "Super Thunder Reign",
		type = ATK_ALMIGHTY,
		power = 1300,
		accuracy = 100,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		status = COND_SHOCK,
		statuschance = 10,
		cost = 64,
		desc = "Severe Almighty Elec dmg to one enemy. \nHigh chance of shock.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				playSound(mo.battlen, sfx_zio5)
			end

			if timer >= 16
			and timer <= 20
				local s = P_SpawnMobj(target.x, target.y, target.z + target.height/2, MT_THOK)
				s.tics = -1
				s.sprite = SPR_LZI1
				s.frame = F|FF_FULLBRIGHT|FF_TRANS70
				s.scale = mo.scale/2
				s.destscale = mo.scale*16
				s.scalespeed = mo.scale/(12-((timer-16)*2))
				s.blendmode = AST_ADD
				s.fuse = 70 - timer
			end

			if timer >= 16
			and timer <= 70
			and leveltime%3 == 0


				local range = 60
				if timer >= 50
					range = 100
				end

				local s = P_SpawnMobj(target.x + P_RandomRange(-range, range)*mo.scale, target.y + P_RandomRange(-range, range)*mo.scale, target.z + P_RandomRange(0, 100)*mo.scale, MT_SUPERSPARK)
			end

			if timer == 50
			or timer == 70
				for i = 1, #server.playerlist[mo.battlen]
					if server.playerlist[mo.battlen][i]
						P_FlashPal(server.playerlist[mo.battlen][i], 1, 2)
					end
				end
				localquake(mo.battlen, FRACUNIT*(timer == 50 and 16 or 32), 10)
			end

			if timer == 70
				lightningblast(target, SKINCOLOR_GOLD, FRACUNIT*3)
				if ((target.enemy and enemyList[target.enemy].weak & ATK_ELEC) or (target.persona and target.persona.weak & ATK_ELEC)) and not (target.weak & ATK_ALMIGHTY)
					target.weak = $|ATK_ALMIGHTY //temporarily make them weak to Almighty for this hit
					damageObject(target)
					target.weak = $ & ~ATK_ALMIGHTY
				else
					damageObject(target)
				end

				for i = 1, 10
					local range = 1024
					local z1 = P_SpawnMobj(target.x + P_RandomRange(-range, range)*mo.scale, target.y + P_RandomRange(-range, range)*mo.scale, target.z, MT_DUMMY)
					z1.state, z1.scale, z1.color = S_LZIO11, target.scale*9/4, SKINCOLOR_GOLD
					z1.destscale = target.scale
					z1.tics = $ + P_RandomRange(-1, 12)
				end

			elseif timer == 120
				return true
			end

		end,
	}

attackDefs["super panta rhei"] = {
		name = "Super Panta Rhei",
		type = ATK_ALMIGHTY,
		power = 1300,
		accuracy = 95,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 48,
		desc = "Severe Almighty Wind dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)

				local target = hittargets[1]

				if timer == 1
					mo.blades = {}
					-- blades have an addtional vangle property.
					-- extravalue1 determines whether they spin forward or backwards

				elseif timer == 20

					-- spawn blades:

					local an = target.angle + ANG1*90
					playSound(mo.battlen, sfx_wind4)

					local b = P_SpawnMobj(target.x + 1024*cos(an), target.y + 1024*sin(an), target.z + 512*FRACUNIT, MT_DUMMY)
					b.vangle = ANG1*60
					b.state = S_INVISIBLE
					b.extravalue1 = 1
					b.extravalue2 = 16
					mo.blades[#mo.blades+1] = b
					b.momx = -(b.x - target.x)/b.extravalue2
					b.momy = -(b.y - target.y)/b.extravalue2
					b.momz = -(b.z - (target.z + 96*FRACUNIT))/b.extravalue2
					b.fuse = TICRATE*3

					b = P_SpawnMobj(target.x - 1024*cos(an), target.y - 1024*sin(an), target.z + 320*FRACUNIT, MT_DUMMY)
					b.vangle = -ANG1*30
					b.state = S_INVISIBLE
					b.extravalue1 = -1
					b.extravalue2 = 16
					mo.blades[#mo.blades+1] = b
					b.momx = -(b.x - target.x)/b.extravalue2
					b.momy = -(b.y - target.y)/b.extravalue2
					b.momz = -(b.z - (target.z + 96*FRACUNIT))/b.extravalue2
					b.fuse = TICRATE*3

				elseif timer == TICRATE*3 + 20
					if ((target.enemy and enemyList[target.enemy].weak & ATK_WIND) or (target.persona and target.persona.weak & ATK_WIND)) and not (target.weak & ATK_ALMIGHTY)
						target.weak = $|ATK_ALMIGHTY //temporarily make them weak to Almighty for this hit
						damageObject(target)
						target.weak = $ & ~ATK_ALMIGHTY
					else
						damageObject(target)
					end

				elseif timer == TICRATE*5
					return true
				end

				local i = #mo.blades
				while i
					local b = mo.blades[i]
					if not b or not b.valid
						table.remove(mo.blades, i)
						i = $-1
						continue
					end

					if R_PointToDist2(b.x, b.y, target.x, target.y) < 192*FRACUNIT
						b.momx = 0
						b.momy = 0
						b.momz = 0

						localquake(mo.battlen, FRACUNIT*10, 2)

						if leveltime%2 and i == 1

							for i=1,10
								local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
								b.momx = P_RandomRange(-35, 35)*FRACUNIT
								b.momy = P_RandomRange(-35, 35)*FRACUNIT
								b.momz = P_RandomRange(-35, 35)*FRACUNIT
								b.color = SKINCOLOR_RED
								b.frame = A|FF_FULLBRIGHT
								b.scale = FRACUNIT/2
								b.destscale = FRACUNIT/12
								b.tics = TICRATE/4
							end

							local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							s.scale = FRACUNIT/4
							s.sprite = SPR_SLAS
							s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
							s.destscale = FRACUNIT*9
							s.scalespeed = FRACUNIT
							s.tics = TICRATE/3

						end
						if leveltime%8 == 0
							playSound(target.battlen, sfx_hit2)
							localquake(mo.battlen, FRACUNIT*32, 8)
						end
					end
					b.angle = $ + ANG1*24*b.extravalue1
					local addang = 360/6
						for j = 1, 6
							local sang = b.angle
							for k = 1, 4

								local sx = b.x + (k-1)*8*cos(sang + (j-1)*addang*ANG1)
								local sy = b.y + (k-1)*8*sin(sang + (j-1)*addang*ANG1)
								local sz = b.z + (k-1)*8*FixedMul(cos(sang + (j-1)*addang*ANG1), sin(b.vangle))

								local p = P_SpawnMobj(sx, sy, sz, MT_DUMMY)
								p.tics = TICRATE
								p.scale = FRACUNIT*3/4
								p.destscale = 1
								p.frame = FF_FULLBRIGHT
								p.color = j%2 and SKINCOLOR_EMERALD or SKINCOLOR_WHITE

								p.angle = sang + (j-1)*addang*ANG1
								P_InstaThrust(p, p.angle, 32*FRACUNIT)
								p.momz = 32*FixedMul(cos(p.angle), sin(b.vangle))

								sang = $-(ANG1*6)

							end
						end
					i = $-1
				end

		end,
	}

attackDefs["super trisagion"] = {
		name = "Super Trisagion",
		type = ATK_ALMIGHTY,
		power = 1300,
		accuracy = 95,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		status = COND_BURN,
		statuschance = 10,
		cost = 64,
		desc = "Severe Almighty Fire dmg to one enemy. \nHigh chance of burn.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 1
				mo.fangle = 0
				mo.fdist = 400
				mo.columns = {}

			elseif timer >= 15
			and timer <= 30
				for i = 1, 12
					local boom = P_SpawnMobj(target.x + P_RandomRange(-48, 48)*FRACUNIT, target.y + P_RandomRange(-48, 48)*FRACUNIT, target.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.flags = $ & ~MF_NOGRAVITY
					boom.momz = 8*FRACUNIT

				end

			elseif timer == 31
				
				DoExplosion(target)
				for i = 1, 3 do
					local an = (mo.fangle + (i-1)*120)*ANG1
					local h = P_SpawnMobj(target.x + mo.fdist*cos(an), target.y + mo.fdist*sin(an), target.z, MT_DUMMY)
					h.state = S_INVISIBLE
					h.tics = -1
					mo.columns[#mo.columns+1] = h
				end
			end

			--if timer%2 == 0
			--	playSound(mo.battlen, sfx_fire1)
			--end

			local j = #mo.columns
			while j

				local m = mo.columns[j]
				if not m or not m.valid
					j = $-1
					continue
				end

				for i = 1, 5
					local boom = P_SpawnMobj(m.x + P_RandomRange(-48, 48)*FRACUNIT, m.y + P_RandomRange(-48, 48)*FRACUNIT, m.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				localquake(mo.battlen, FRACUNIT*8, 1)

				if timer <= 140
					local an = (mo.fangle + (j-1)*120)*ANG1
					P_TeleportMove(m, target.x + mo.fdist*cos(an), target.y + mo.fdist*sin(an), target.z)
				end

				j = $-1

			end

			if timer >= 31
				mo.fangle = $ + min(14, ((timer-31)/4))
				mo.fdist = max(96, $- 4)
			end

			if timer == 120
				DoExplosion(target)
			elseif timer >= 120 and timer < 140
				for i = 1, 12
					local boom = P_SpawnMobj(target.x + P_RandomRange(-64, 64)*FRACUNIT, target.y + P_RandomRange(-64, 64)*FRACUNIT, target.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.momz = P_RandomRange(0, 80)*FRACUNIT
					boom.scale = FRACUNIT*5
				end
			elseif timer == 140
				-- delet old shit:
				mo.fangle = (R_PointToAngle(target.x, target.y)) + ANG1*180
				mo.columns = {}

				local a = mo.fangle - ANG1*80

				for i = 1, 16
					local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					P_InstaThrust(m, a, FRACUNIT*48)
					mo.columns[#mo.columns+1] = m
					m.state = S_INVISIBLE
					m.tics = TICRATE
					a = $+ ANG1*10
				end

				if ((target.enemy and enemyList[target.enemy].weak & ATK_FIRE) or (target.persona and target.persona.weak & ATK_FIRE)) and not (target.weak & ATK_ALMIGHTY)
					target.weak = $|ATK_ALMIGHTY //temporarily make them weak to Almighty for this hit
					damageObject(target)
					target.weak = $ & ~ATK_ALMIGHTY
				else
					damageObject(target)
				end
			elseif timer == 180
				mo.fangle = nil
				mo.columns = nil
				return true
			end
		end,
	}

attackDefs["super niflheim"] = {
		name = "Super Niflheim",
		type = ATK_ALMIGHTY,
		power = 1300,
		accuracy = 100,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		costtype = CST_SP,
		cost = 64,
		status = COND_FREEZE,
		statuschance = 10,
		desc = "Severe Almighty Ice dmg to one enemy. \nHigh chance of freeze.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if (timer >= 20 and timer <= 150) and (target.bd and target.bd.valid)

				local bs = P_SpawnMobj(target.bd.x+(P_RandomRange(-512, 512)*mo.scale), target.bd.y+(P_RandomRange(-512, 512)*mo.scale), target.bd.z+(P_RandomRange(0, 512)*mo.scale), MT_BUFU)
				bs.state, bs.color = S_BUFU_PARTICLE_D, SKINCOLOR_CYAN
				bs.momz = P_RandomRange(-1, 1)*FRACUNIT

				if (timer <= 150)
					local baseangle = P_RandomRange(1, 360)*ANG1
					local dist = 48
					for i = 0, 12
						local angle = baseangle + i*6*ANG1
						local x, y = target.bd.x + dist*cos(angle), target.bd.y + dist*sin(angle)

						local aura = P_SpawnMobj(x, y, target.z+i*FRACUNIT*3, MT_DUMMY)
						aura.state = S_BUFUDYNE_AURA1
						aura.angle = angle - ANGLE_90
						aura.color = SKINCOLOR_WHITE
						aura.momz = P_RandomRange(2, 9)*FRACUNIT
						aura.scale = FRACUNIT*3/4
						aura.destscale = FRACUNIT*2
						P_InstaThrust(aura, angle, FRACUNIT*P_RandomRange(5, 8))
					end
				end
			end
			if (timer == 40)
				playSound(mo.battlen, sfx_bufu5)
				target.bd = P_SpawnMobj(target.x, target.y, target.z + mo.scale*128, MT_DUMMY)
				target.bd.tics = -1
				target.bd.scale = FRACUNIT/6
				target.bd.destscale = FRACUNIT*2
				target.bd.scalespeed = FRACUNIT/48
				target.bd.sprite = SPR_BFDA
				target.bd.frame = J|FF_FULLBRIGHT

			elseif (timer == 65)
				playSound(mo.battlen, sfx_bufu2)
				target.bd.scale = FRACUNIT*2 + FRACUNIT/16
				target.bd.destscale = target.bd.scale
				target.bd.frame = K|FF_FULLBRIGHT

				local g = P_SpawnGhostMobj(target.bd)
				g.destscale = FRACUNIT*4
				g.scalespeed = FRACUNIT/6

			elseif (timer == 67)
				target.bd.scale = FRACUNIT*2
				target.bd.frame = J|FF_FULLBRIGHT

			elseif (timer >= 80 and timer < 90)
				P_TeleportMove(target.bd, target.x + P_RandomRange(-8, 8)*mo.scale, target.y + P_RandomRange(-8, 8), target.z + 128*mo.scale + P_RandomRange(-8, 8)*mo.scale)


			elseif (timer == 90)

				local g = P_SpawnGhostMobj(target.bd)
				g.destscale = FRACUNIT*4
				g.scalespeed = FRACUNIT/4
				localquake(mo.battlen, FRACUNIT*32, 16)

				for i = 1, P_RandomRange(17, 32)
					local ba = P_SpawnMobj(target.bd.x+(P_RandomRange(-50, 50)*target.bd.scale), target.bd.y+(P_RandomRange(-50, 50)*target.bd.scale), target.bd.z+(P_RandomRange(0, 128)*target.bd.scale), MT_BUFU_PARTICLE)
					ba.state, ba.scale = S_BUFU_PARTICLE_A, FRACUNIT*7/4
					ba.momx, ba.momy, ba.momz = P_RandomRange(-13, 13)*FRACUNIT, P_RandomRange(-13, 13)*FRACUNIT, P_RandomRange(6, 19)*FRACUNIT
				end
				for i = 1, P_RandomRange(11, 32)
					local bb = P_SpawnMobj(target.bd.x+(P_RandomRange(-50, 50)*target.bd.scale), target.bd.y+(P_RandomRange(-50, 50)*target.bd.scale), target.bd.z+(P_RandomRange(0, 128)*target.bd.scale), MT_BUFU_PARTICLE)
					bb.state, bb.scale = S_BUFU_PARTICLE_B, FRACUNIT*7/4
					bb.momx, bb.momy, bb.momz = P_RandomRange(-9, 9)*FRACUNIT, P_RandomRange(-9, 9)*FRACUNIT, P_RandomRange(9, 23)*FRACUNIT
				end
				for i = 1, 9
					local curangle = ANG1*40*i

					local dust = P_SpawnMobj(target.bd.x+(24*cos(curangle)), target.bd.y+(24*sin(curangle)), target.bd.z, MT_DUMMY)
					dust.flags = $|MF_NOGRAVITY|MF_NOCLIPHEIGHT
					dust.state, dust.scale, dust.angle = S_BUFUDYNE_DUST1, FRACUNIT*5/4, curangle
					dust.destscale = FRACUNIT*5/2
					dust.scalespeed = FRACUNIT/18
					P_InstaThrust(dust, dust.angle, 12*FRACUNIT)
					dust.momz = 4*FRACUNIT
				end
				P_RemoveMobj(target.bd)
				playSound(mo.battlen, sfx_bufu6)
				if ((target.enemy and enemyList[target.enemy].weak & ATK_ICE) or (target.persona and target.persona.weak & ATK_ICE)) and not (target.weak & ATK_ALMIGHTY)
					target.weak = $|ATK_ALMIGHTY //temporarily make them weak to Almighty for this hit
					damageObject(target)
					target.weak = $ & ~ATK_ALMIGHTY
				else
					damageObject(target)
				end
				localquake(mo.battlen, FRACUNIT*20, 10)
			elseif (timer == 160)
				target.bd = nil
				return true
			end
		end,
	}

attackDefs["super eggion"] = {
		name = "Super Eggion",
		type = ATK_ALMIGHTY,
		power = 1000,
		accuracy = 95,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 36,
		desc = "Mega Almighty Curse dmg to one sammt",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 25
				playSound(mo.battlen, sfx_eih3)
			end

			if timer >= 20 and timer <= 50
				for i = 1,6
					local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z + P_RandomRange(30, 60)<<FRACBITS, MT_DUMMY)
					thok.flags = MF_NOBLOCKMAP
					thok.color = SKINCOLOR_RED
					if timer%2 then thok.color = SKINCOLOR_BLACK end
					thok.tics = 35
					thok.scalespeed = FRACUNIT/32
					thok.destscale = 1
					thok.momz = P_RandomRange(-3, -1)*FRACUNIT
				end
			elseif timer >= 51 and timer <= 60
				if timer == 52
					if ((target.enemy and enemyList[target.enemy].weak & ATK_CURSE) or (target.persona and target.persona.weak & ATK_CURSE)) and not (target.weak & ATK_ALMIGHTY)
						target.weak = $|ATK_ALMIGHTY //temporarily make them weak to Almighty for this hit
						damageObject(target)
						target.weak = $ & ~ATK_ALMIGHTY
					else
						damageObject(target)
					end
					for i = 1,16
						local thok = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						if i%2 then thok.color = SKINCOLOR_RED else thok.color = SKINCOLOR_BLACK end
						thok.frame = A
						thok.scale = FRACUNIT*2
						thok.destscale = 1
						thok.tics = 30
						thok.scalespeed = FRACUNIT/6
						thok.angle = ANGLE_22h*(i-1)
						P_InstaThrust(thok, thok.angle, 69*FRACUNIT)
					end
				end
				for i = 1,8
					local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z, MT_DUMMY)
					thok.color = SKINCOLOR_RED
					if timer%2 then thok.color = SKINCOLOR_BLACK end
					if i == 1
						thok.color = SKINCOLOR_WHITE
					end
					thok.scale = FRACUNIT*2
					thok.frame = A
					thok.tics = 35
					thok.scalespeed = FRACUNIT/32
					thok.destscale = 1
					thok.momz = P_RandomRange(20, 35)*FRACUNIT
				end

			elseif timer == 90
				return true
			end
		end,
	}

attackDefs["super megagarula"] = {
		name = "Super Megagarula",
		type = ATK_ALMIGHTY,
		power = 1000,
		accuracy = 90,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 64,
		desc = "Mega Almighty Wind dmg to all sammts.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,e in ipairs(hittargets)
			local target = e
			local time = timer - 5*(k-1)

				if time == 20
					playSound(mo.battlen, sfx_wind3)
					local barrier = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					target.elec = barrier
					barrier.scale = FRACUNIT*2
					barrier.state = S_PLAY_STND
					barrier.tics = -1
					barrier.sprite = SPR_ELEC
					barrier.fuse = 40
					for i = 1, 10
						local g = P_SpawnMobj(target.x, target.y, target.z + P_RandomRange(0, 120)*FRACUNIT, MT_GARU)
						g.target = target
						g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
						if i == 1 or i == 8
							g.jizzcolor = true
						end
						if i%2
							g.invertrotation = true
						end
						g.dist = P_RandomRange(45, 140)
						g.tics = 35
						g.lowquality = true
					end
				elseif time == 50
					target.elec = nil
					if ((target.enemy and enemyList[target.enemy].weak & ATK_WIND) or (target.persona and target.persona.weak & ATK_WIND)) and not (target.weak & ATK_ALMIGHTY)
						target.weak = $|ATK_ALMIGHTY //temporarily make them weak to Almighty for this hit
						damageObject(target)
						target.weak = $ & ~ATK_ALMIGHTY
					else
						damageObject(target)
					end
					localquake(mo.battlen, FRACUNIT*8, 8)
				end

				if target.elec
				and target.elec.valid
				and not (leveltime%2)
					target.elec.frame = P_RandomRange(A, L)
				end

			end
			if timer == 85 + 5*(#hittargets-1)
				return true
			end
		end,
	}