-- do level up animation
//(edited from Battle.lua)
rawset(_G, "BTL_levelupAnimation", function(mo)
	local btl = server.P_BattleStatus[mo.battlen]
	local pn = mo.battlen

	if not mo return end

	local mynum	-- our player num:
	for i = 1, #server.plentities[pn] do
		if server.plentities[pn][i] == mo
			mynum = i
			break
		end
	end

	if mo.r_levelupenter
		mo.r_levelupenter = $-1
		return
	end

	local save_checkouts = 0
	local stats = {mo.strength, mo.magic, mo.endurance, mo.agility, mo.luck}

	for i = 1, 5
		if mo.savestats[i] >= stats[i]
			save_checkouts = $+1
		end
	end

	if save_checkouts >= 5	-- that means all our stats are good!
		return true			-- since we handle stats last, that means we're good!
	end

	-- first off, we will be handling skills

	if btl.r_newskillsqueue[mynum] and btl.r_newskillsqueue[mynum][1]

		if #mo.skills < 8 or mo.justgotskill	-- less than 8 skills, so we just learn the new skill in the next slot (justgotskill is to avoid the 8th skill triggering the 2nd behavior)

			if mo.r_nskilltimer == nil
				mo.r_nskilltimer = 0
			end
			mo.r_nskilltimer = $+1

			if mo.r_nskilltimer == 20
				mo.skills[#mo.skills+1] = btl.r_newskillsqueue[mynum][1][1]
				mo.newskillnum = #mo.skills	-- we use this to know which skill to flash in HUD rendering
				mo.justgotskill = true
				S_StartSound(nil, sfx_nskill, mo.control)
				--dprint("PN "..pn..": Skill learnt: "..btl.r_newskillsqueue[mynum][1][1])
			end

			if mo.r_nskilltimer >= TICRATE*3/2
				mo.r_nskilltimer = nil	-- set timer to nil so we will restart if we need to.
				table.remove(btl.r_newskillsqueue[mynum], 1)	-- remove first skill.
				mo.newskillnum = nil
				mo.justgotskill = nil
			end
		else				-- more than 8 skills, we need to let the player forget one.

			if mo.newskillnum	-- we have selected a skill
				if mo.r_nskilltimer == nil
					mo.r_nskilltimer = 0
				end
				mo.r_nskilltimer = $+1

				if mo.r_nskilltimer == 20
					mo.skills[mo.newskillnum] = btl.r_newskillsqueue[mynum][1][1]
					S_StartSound(nil, sfx_nskill, mo.control)
					--dprint("PN "..pn..": Skill learnt: "..btl.r_newskillsqueue[mynum][1][1])
				end

				if mo.r_nskilltimer >= TICRATE*3/2
					mo.r_nskilltimer = nil	-- set timer to nil so we will restart if we need to.
					table.remove(btl.r_newskillsqueue[mynum], 1)	-- remove first skill.
					mo.newskillnum = nil
				end

				return	-- no need to process button inputs anymore or w/e,
			end

			if not mo.r_forgetselect
				mo.r_forgetselect = 1	-- start at skill 1 that we will forget
				//look for a similar skill to forget
				for i=1, #mo.skills
					if attackDefs[mo.skills[i]].type == attackDefs[btl.r_newskillsqueue[mynum][1][1]].type //Look for a similar skill
						mo.r_forgetselect = i //Start the player on a similar skill
						if attackDefs[mo.skills[i]].target == attackDefs[btl.r_newskillsqueue[mynum][1][1]].target
						and attackDefs[mo.skills[i]].costtype == attackDefs[btl.r_newskillsqueue[mynum][1][1]].costtype
						and attackDefs[mo.skills[i]].passive == attackDefs[btl.r_newskillsqueue[mynum][1][1]].passive
							break
						end
					end
				end
				-- double check to see if we can't select the skill to forget by default:
				if btl.r_newskillsqueue[mynum][1][3]
					for i = 1, #mo.skills
						if mo.skills[i] == btl.r_newskillsqueue[mynum][1][3]
							mo.r_forgetselect = i -- tell the player to forget *this* skill instead
							break
						end
					end
				end

			end

			-- handle the inputs here:
			local inpt = mo.control.mo.P_inputs

			-- check if we want to confirm our choice...
			if mo.r_askconfirm

				if inpt[BT_USE] == 1
					S_StartSound(nil, sfx_cancel, mo.control)
					mo.r_askconfirm = nil

				elseif inpt[BT_JUMP] == 1

					if mo.r_askconfirm == 1	-- new skill
						mo.newskillnum = mo.r_forgetselect
						mo.r_forgetselect = nil
					else	-- don't learn new skill
						mo.r_nskilltimer = nil	-- set timer to nil so we will restart if we need to.
						table.remove(btl.r_newskillsqueue[mynum], 1)	-- remove first skill.
						mo.newskillnum = nil
						mo.r_forgetselect = nil	-- remove both of these to prevent skill flashing
					end
					mo.r_askconfirm = nil

					S_StartSound(nil, sfx_hover, mo.control)
				end

				return
			end


			if inpt["down"] ==1
				if not (mo.r_forgetselect%4)	-- at bottom.
					mo.r_forgetselect = $-3
				else
					mo.r_forgetselect = $+1
				end
				S_StartSound(nil, sfx_hover, mo.control)
			elseif inpt["up"] ==1
				mo.r_forgetselect = $-1
				if not (mo.r_forgetselect%4)	-- at top
					mo.r_forgetselect = $+4
				end
				S_StartSound(nil, sfx_hover, mo.control)
			elseif inpt["right"] ==1 or inpt["left"] ==1
				if mo.r_forgetselect > 4
					mo.r_forgetselect = $-4
				else
					mo.r_forgetselect = $+4
				end
				S_StartSound(nil, sfx_hover, mo.control)
			elseif inpt[BT_JUMP] ==1	-- confirm forget
				S_StartSound(nil, sfx_hover, mo.control)
				mo.r_askconfirm = 1



			elseif inpt[BT_USE] ==1		-- I don't want new skills!
				S_StartSound(nil, sfx_cancel, mo.control)
				mo.r_askconfirm = 2


			end
		end
		return	-- don't proceed for as long as we have got skills to learn
	end

	-- when we're done, handle stats, because when stats are done, we can press the button and continue
	if not mo.r_stattimer
		mo.r_stattimer = 0
	end
	mo.r_stattimer = $+1

	if mo.r_stattimer > 15

		if mo.r_stattimer%2
			local playsound	-- don't earrape 5 times / tic

			for i = 1, 5
				if mo.savestats[i] < stats[i]
					mo.savestats[i] = $+1
					playsound = true
				elseif mo.savestats[i] > stats[i]	-- ?????
					mo.savestats[i] = $-1
					playsound = true
				end
			end

			if playsound and consoleplayer == mo.control
				S_StartSound(nil, sfx_menu1)
			end
		end
	end
end)
