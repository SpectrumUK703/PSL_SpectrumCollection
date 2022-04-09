-- Weapon/Ring enhancing, desynthetizing, fusion!

-- states
local sts = {
	"ELS_MAIN",			-- main selection menu
	"ELS_LEAVE",		-- leaving

	"ELS_GRIND_SELECTWEP",		-- selecting whose equipment to grind
	"ELS_GRIND_CONFIRM",		-- confirming grind
	"ELS_GRIND_SUCCESS",		-- grind successful
	"ELS_GRIND_BROKE",			-- not enough mats/macca
	"ELS_GRIND_MAXLEVEL",		-- equip was already level 10

	"ELS_DESYNTH_SELECTWEP",	-- selecting what equip to dismantle
	"ELS_DESYNTH_CONFIRM",		-- confirming what materials you'll get out of desynth
	"ELS_DESYNTH_SUCCESS",		-- equip dismantled
	"ELS_DESYNTH_FAIL",			-- something went wrong (equip vanished during confirmation?)

	"ELS_FUSION_SELECTTYPE",
	-- FREE FUSION
	"ELS_FUSION_NOPERSONA", 	-- No Sub-Persona...?
	"ELS_FUSION_NOFRAME",		-- No Nihil Frame...?
	"ELS_FUSION_SELECTPERSONA",	-- Select a sacrifice
	"ELS_FUSION_CONFIRM",		-- Confirm fusion
	"ELS_FUSION_SUCCESS",		-- Fusion succesful
	"ELS_FUSION_FAIL",			-- Insufficient materials
	"ELS_FUSION_ASKUNEQUIP",	-- Ask to unequip subp if it's on a character you control
	"ELS_FUSION_NOTYOURS",		-- subp equipped on another player's character
	-- RECIPE FUSION
	"ELS_RFUSION_SELECT",
	"ELS_RFUSION_CONFIRM",
	"ELS_RFUSION_SUCCESS",
	"ELS_RFUSION_FAIL",
}

for i = 1, #sts
	rawset(_G, sts[i], i)
end

rawset(_G, "equipGrindTiers", {

		-- format:
		/*
			{	macca,
				{material, amount},
				{material, amount},
				...
			}
		*/

		-- tier 1:
		{
			25,
			{"amethyst", 1},
		},

		-- tier 2:
		{
			40,
			{"onyx", 1},
		},

		-- tier 3:
		{
			80,
			{"sapphire", 1},
			{"amethyst", 2},
		},

		-- tier 4:
		{
			120,
			{"emerald", 1},
			{"sapphire", 2},
		},

		-- tier 5:
		{
			180,
			{"diamond", 2},
			{"emerald", 3},
		},

		-- tier 6:
		{
			250,
			{"ruby", 2},
			{"diamond", 3},
		},

		-- tier 7:
		{
			500,
			{"painite", 1},
			{"ruby", 3},
			{"diamond", 3},
		},

		-- tier 8:	(unused for actual enhancement, only used for critical desynth)
		{
			1500,
			{"painite", 2},
			{"ruby", 4},
			{"diamond", 4},
		},
})


-- since there's only one type of item lab, we can handle text data here as well.
local textdata = {

		welcome = {		-- On main shop page
			{"Alt", "Equipment isn't really my specialty, but I'll see what I can do.", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Under normal circumstances, someone *else* would be handling that...", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "We turn scrap into gold, here! ...So long as you have the materials and Macca.", "H_ALT01", SKINCOLOR_BLUE},
		},

		bye = {
			{"Alt", "See ya later!", "H_ALT01", SKINCOLOR_BLUE},
		},

		-- FUSION

		fusion_nopersona = {
			{"Alt", "You don't have any Sub-Persona...", "H_ALT05", SKINCOLOR_BLUE},
		},

		fusion_noframe = {
			{"Alt", "You don't have any "..ICO_ITEM.."Nihil Frame...", "H_ALT05", SKINCOLOR_BLUE},
		},

		choose_persona = {
			{"Alt", "What Sub-Persona should we try fusing into a weapon?", "H_ALT01", SKINCOLOR_BLUE},
		},

		confirm_fusion = {
			{"Alt", "Just to be clear, \x82this will destroy the selected Sub-Persona.\x80\nAre we still good to go?", "H_ALT01", SKINCOLOR_BLUE},
		},

		fusion_success = {
			{"Alt", "Job well done!", "H_ALT03", SKINCOLOR_BLUE},
			{"Alt", "And that's that...", "H_ALT03", SKINCOLOR_BLUE},
		},

		fusion_broke = {
			{"Alt", "You don't have the materials for that...", "H_ALT05", SKINCOLOR_BLUE},
		},

		fusion_unequip = {
			{"Alt", "This Sub-Persona is already in use. Should I unequip it and \x82".."destroy it regardless?", "H_ALT01", SKINCOLOR_BLUE},
		},

		fusion_notyours = {
			{"Alt", "This Sub-Persona is in use by someone else. You're gonna have to ask them to unequip it themselves...", "H_ALT05", SKINCOLOR_BLUE},
		},

		-- DESYNTHESIS
		choose_desynth = {
			{"Alt", "Breaking things is something I'm actually not bad at!", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Alright, what should I "..ICO_SKILLCARD.."Megidolaon out of existence?", "H_ALT02", SKINCOLOR_BLUE},
		},

		confirm_desynth = {
			{"Alt", "You sure?\n\x82".."Once I get my hands on this toy of yours, it's gone forever.", "H_ALT01", SKINCOLOR_BLUE},
		},

		desynth_gone = {
			{"Alt", "Huh? Looks like your item vanished while you were deciding... Where did it even go??", "H_ALT05", SKINCOLOR_BLUE},
		},


		-- ENHANCING
		choose_enhance = {
			{"Alt", "Alright, what should we buff up?", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Y'know, don't come crying if I mess it up...", "H_ALT03", SKINCOLOR_BLUE},
		},

		enhance_confirm = {
			{"Alt", "Set on this one?", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Let's give this one a go...!", "H_ALT01", SKINCOLOR_BLUE},
		},

		enhance_done = {
			{"Alt", "That turned out alright...", "H_ALT03", SKINCOLOR_BLUE},
			{"Alt", "Well, that worked out.", "H_ALT03", SKINCOLOR_BLUE},
		},

		enhance_great = {
			{"Alt", "You better praise me for that...", "H_ALT02", SKINCOLOR_BLUE},
			{"Alt", "That went better than expected... \nI mean, of course it did!", "H_ALT03", SKINCOLOR_BLUE},
		},

		enhance_broke = {
			{"Alt", "You don't have the materials for that...", "H_ALT05", SKINCOLOR_BLUE},
		},

		enhance_maxlevel = {
			{"Alt", "I can't make this one any better.", "H_ALT05", SKINCOLOR_BLUE},
			{"Alt", "This one's reached its maximum potential, I think.", "H_ALT05", SKINCOLOR_BLUE},
		},
}

local state_2_textdata = {
	[ELS_MAIN] = "welcome",
	[ELS_LEAVE] = "bye",

	[ELS_FUSION_NOPERSONA] = "fusion_nopersona",
	[ELS_FUSION_NOFRAME] = "fusion_noframe",
	[ELS_FUSION_SELECTPERSONA] = "choose_persona",
	[ELS_FUSION_ASKUNEQUIP] = "fusion_unequip",
	[ELS_FUSION_NOTYOURS] = "fusion_notyours",
	[ELS_FUSION_CONFIRM] = "confirm_fusion",
	[ELS_FUSION_FAIL] = "fusion_broke",
	[ELS_FUSION_SUCCESS] = "fusion_success",

	[ELS_GRIND_SELECTWEP] = "choose_enhance",
	[ELS_GRIND_CONFIRM] = "enhance_confirm",
	[ELS_GRIND_BROKE] = "enhance_broke",
	[ELS_GRIND_SUCCESS] = "enhance_done",
	[ELS_GRIND_MAXLEVEL] = "enhance_maxlevel",

	[ELS_DESYNTH_SELECTWEP] = "choose_desynth",
	[ELS_DESYNTH_CONFIRM] = "confirm_desynth",
	[ELS_DESYNTH_FAIL] = "desynth_gone",
}

local state_2_textchoices = {
	[ELS_MAIN] = 4,

	[ELS_GRIND_CONFIRM] = 2,	-- yes, no
	[ELS_DESYNTH_CONFIRM] = 2,	-- yes, no

	[ELS_FUSION_CONFIRM] = 2,	-- yes, no
	[ELS_FUSION_ASKUNEQUIP] = 2,	-- yes, no
}

local function handleTextChoices(mo)

	local inpt = mo.P_inputs
	--print(inpt)
	--print(inpt["up"])
	if inpt["up"] == 1
		mo.equiplab.textchoice = $-1
		if not mo.equiplab.textchoice
			mo.equiplab.textchoice = mo.equiplab.maxtextchoice
		end
		S_StartSound(nil, sfx_hover, mo.player)

	elseif inpt["down"] == 1
		mo.equiplab.textchoice = $+1
		if mo.equiplab.textchoice > mo.equiplab.maxtextchoice
			mo.equiplab.textchoice = 1
		end
		S_StartSound(nil, sfx_hover, mo.player)
	elseif inpt[BT_JUMP] == 1
		S_StartSound(nil, sfx_confir, mo.player)
		return mo.equiplab.textchoice
	end
end

local function DNG_changeEQLState(mo, state)

	if not mo.equiplab return end
	if not mo.equiplab.using return end
	if not state return end

	mo.equiplab.state = state

	local tdata = textdata[state_2_textdata[state]]
	if tdata
		mo.equiplab.currtextdata = tdata[P_RandomRange(1, #tdata)]
		mo.equiplab.texttimer = 1
	end

	mo.equiplab.hudtimers.newstate = TICRATE/3
	mo.equiplab.textchoice = 1	-- reset
end

local function DNG_EQLCheckNeeds(mo)

	local e = mo.equiplab
	if not e or not e.using or not e.equipneed return end	-- lol?

	-- check if we have everything!
	local btl = server.P_BattleStatus[mo.player.P_party]

	for i = 1, #e.equipneed
		if i == 1	-- check macca
			if btl.macca < e.equipneed[i]
				return	-- broke ass bitch
			end
		else
			-- check for material
			local it = BTL_findItem(btl, e.equipneed[i][1])
			if it
				it = btl.items[it]
				if it[2] < e.equipneed[i][2]	-- not enough items
					return	-- nope
				end
			else	-- item not found
				return	-- nope
			end

		end

	end

	-- if we made it this far then we have everything
	return true
end

local function DNG_EQLUseMaterials(mo)

	local e = mo.equiplab
	if not e or not e.using or not e.equipneed return end	-- lol?

	-- check if we have everything!
	local btl = server.P_BattleStatus[mo.player.P_party]

	for i = 1, #e.equipneed
		if i == 1	-- check macca
			btl.macca = $- e.equipneed[i]
		else
			-- check for material
			local it = BTL_findItem(btl, e.equipneed[i][1])
			for j = 1, e.equipneed[i][2]
				if it
					BTL_useItem(btl, it, false)
				end
			end
		end
	end
end

rawset(_G, "DNG_handleEquipLab", function(mo)

	if not mo.equiplab return end
	if not mo.equiplab.using return end
	local btl = server.P_BattleStatus[mo.player.P_party]
	local inputs = mo.P_inputs
	local p = mo.player

	PLAY_nomove(mo.player)

	local e = mo.equiplab

	-- iterate hud timers
	for k,v in pairs(e.hudtimers)
		if e.hudtimers[k]
			e.hudtimers[k] = $-1
		end
	end

	e.texttimer = $+1

	if state_2_textchoices[e.state]
		e.maxtextchoice = state_2_textchoices[e.state]
	end

	-- state handling:
	if e.state == ELS_MAIN
		local choice = handleTextChoices(mo)

		local choice_2_state = {
			ELS_GRIND_SELECTWEP,
			ELS_DESYNTH_SELECTWEP,
			ELS_FUSION_SELECTPERSONA,
			ELS_LEAVE,
		}

		local newchoice = choice_2_state[choice]

		if newchoice == ELS_GRIND_SELECTWEP
			local myindex = 1
			for i = 1, server.P_netstat.teamlen
				if server.plentities[mo.player.P_party][i].control == mo.player
					myindex = i
					break
				end
			end

			e.selectparty = myindex	-- 1- netstat.teamlen
			e.selectequip = 1		-- 1 = wep, 2 = wardring
			e.hudtimers.grindstart = 8
			DNG_changeEQLState(mo, ELS_GRIND_SELECTWEP)

		elseif newchoice == ELS_DESYNTH_SELECTWEP
			e.selectequiptype = 1
			e.selectequip = 1
			e.selectscroll = 0
			e.hudtimers.dismantle = 8
			DNG_changeEQLState(mo, ELS_DESYNTH_SELECTWEP)

		elseif newchoice == ELS_FUSION_SELECTPERSONA

			-- check if we can do that?
			if #btl.subpersonas < 2	-- unequipped count as a subpersona
				S_StartSound(nil, sfx_not, mo.player)
				e.hudtimers.nofusion = TICRATE*2
				DNG_changeEQLState(mo, ELS_FUSION_NOPERSONA)
				return
			elseif not BTL_findItem(btl, "nihil frame")
				S_StartSound(nil, sfx_not, mo.player)
				e.hudtimers.nofusion = TICRATE*2
				DNG_changeEQLState(mo, ELS_FUSION_NOFRAME)
				return
			end

			local typelookups = {
				WPT_SHOES,
				WPT_MONITOR,
				WPT_KNUCKLES,
				WPT_REMOTE,
				WPT_LIMITERS,
				WPT_HAMMER,
				WPT_CLAWS,
				WPT_HEELS,
				WPT_PSYGLOVES,
				WPT_HANDSONIC,
				WPT_GENERICMELEE,
				WPT_GENERICRANGED,
			}

			for i = 1, #typelookups do
				if getEquipWeaponType(mo.player.maincontrol) & typelookups[i]
					e.selectequiptype = i
					break
				end
			end

			e.selectequip = 2
			e.hudtimers.weaponfusion = 8
			e.selectscroll = 0
			e.weaponpreview = nil
			DNG_changeEQLState(mo, ELS_FUSION_SELECTPERSONA)

		elseif newchoice == ELS_LEAVE
			--print("bye")
			DNG_changeEQLState(mo, ELS_LEAVE)
			e.hudtimers.leave = TICRATE*2
		end

	elseif e.state == ELS_LEAVE
		if (not e.hudtimers.leave)
		or inputs[BT_BTNA] == 1
			DNG_stopEquipLab(mo)
			return
		end

	/**
	------------------------------------------
	-- WEAPON FUSION
	------------------------------------------
	**/

	elseif e.state == ELS_FUSION_NOPERSONA
	or e.state == ELS_FUSION_NOFRAME

		if (not e.hudtimers.nofusion)
		or inputs[BT_BTNA] == 1
			DNG_changeEQLState(mo, ELS_MAIN)
		end

	elseif e.state == ELS_FUSION_FAIL
	or e.state == ELS_FUSION_NOTYOURS
	or e.state == ELS_FUSION_SUCCESS

		if (not e.hudtimers.fusionbroke)
		or inputs[BT_BTNA] == 1
			local nextstate = ELS_FUSION_SELECTPERSONA

			-- don't allow going back to the fusion state if we lack the items / personas
			if #btl.subpersonas < 2 or not BTL_findItem(btl, "nihil frame")
				nextstate = ELS_MAIN
			end
			DNG_changeEQLState(mo, ELS_FUSION_SELECTPERSONA)
		end

	elseif e.state == ELS_FUSION_CONFIRM
	or e.state == ELS_FUSION_ASKUNEQUIP

		local choice = handleTextChoices(mo)
		local subp = btl.subpersonas[e.selectequip]

		if choice == 1
			-- double check on materials and the persona again
			if not DNG_EQLCheckNeeds(mo) or e.backupsubp ~= subp
				DNG_changeEQLState(mo, ELS_FUSION_FAIL)
				e.hudtimers.fusionbroke = TICRATE*2
				S_StartSound(nil, sfx_not, mo.player)
			end

			-- otheriwise, go to town;
			-- unequip the persona first if necessary
			if subp.equipped
				local plyr = server.plentities[mo.player.P_party][subp.equipped]
				plyr.subpersona = nil
			end
			-- remove the sub persona
			for i = 1, #btl.subpersonas do
				if btl.subpersonas[i] == subp
					table.remove(btl.subpersonas, i)
					break
				end
			end

			subp = nil	-- dereference subp
			-- get the weapon we previewed!
			addWeapon(mo, e.weaponpreview)

			-- and go to the success thing
			e.hudtimers.fusionbroke = TICRATE
			DNG_EQLUseMaterials(mo)
			DNG_changeEQLState(mo, ELS_FUSION_SUCCESS)
		elseif choice == 2
			DNG_changeEQLState(mo, ELS_FUSION_SELECTPERSONA)
			S_StartSound(nil, sfx_cancel, mo.player)
		end


	elseif e.state == ELS_FUSION_SELECTPERSONA
		local t = btl.subpersonas
		local maxitems = 8
		local maxc = #t
		local minc = 2

		local maxscroll = max(0, maxc-maxitems)

		local wpntypes = {
			"nihil shoes",
			"nihil monitor",
			"nihil knuckles",
			"nihil device",
			"nihil limiters",
			"nihil hammer",
			"nihil claws",
			"nihil heels",
			"nihil gloves",
			"nihil blades",
			"nihil rapier",
			"nihil gun",
		}

		local typelookups = {
			WPT_SHOES,
			WPT_MONITOR,
			WPT_KNUCKLES,
			WPT_REMOTE,
			WPT_LIMITERS,
			WPT_HAMMER,
			WPT_CLAWS,
			WPT_HEELS,
			WPT_PSYGLOVES,
			WPT_HANDSONIC,
			WPT_GENERICMELEE,
			WPT_GENERICRANGED,
		}

		if inputs["down"] == 1
		and maxc > 1
			e.selectequip = $+1

			if e.selectequip - e.selectscroll > maxitems/2
			and e.selectequip < maxc - maxitems/3
			and maxc > maxitems
				e.selectscroll = $+1
			end

			if e.selectequip > maxc
				e.selectscroll = 0
				e.selectequip = 2
			end
			e.weaponpreview = nil	-- reset preview weapon

			S_StartSound(nil, sfx_hover, p)

		elseif inputs["up"] == 1
		and maxc > 1
			e.selectequip = $-1

			if e.selectequip < maxc - (maxitems/2)
			and e.selectscroll
				e.selectscroll = $-1
			end

			if e.selectequip < 2
				e.selectequip = maxc
				if maxc > maxitems
					e.selectscroll = maxscroll
				end
			end
			e.weaponpreview = nil	-- reset preview weapon

			S_StartSound(nil, sfx_hover, p)

		elseif inputs["right"] == 1
		and maxc > 1
			e.selectequiptype = $+1
			-- skip over weapon types we can't use...
			local canequip

			while (not canequip) and e.selectequiptype <= #wpntypes
				for i = 1, #server.plentities[mo.player.P_party] do
					--print(i..": "..getEquipWeaponType(server.plentities[mo.player.P_party][i]).." | "..typelookups[e.selectequiptype])
					if getEquipWeaponType(server.plentities[mo.player.P_party][i]) & typelookups[e.selectequiptype]
						canequip = true
						break
					end
				end

				if not canequip
					e.selectequiptype = $+1
				end
			end

			if e.selectequiptype > #wpntypes
				e.selectequiptype = 1

				-- do it again:
				canequip = nil
				while not canequip
					for i = 1, #server.plentities[mo.player.P_party] do
						if getEquipWeaponType(server.plentities[mo.player.P_party][i]) & typelookups[e.selectequiptype]
							canequip = true
							break
						end
					end

					if not canequip
						e.selectequiptype = $+1
					end
				end
			end

			e.weaponpreview = nil	-- reset preview weapon

			S_StartSound(nil, sfx_hover, p)

		elseif inputs["left"] == 1
		and maxc > 1

			e.selectequiptype = $-1

			-- skip over weapon types we can't use...
			local canequip

			while not canequip and e.selectequiptype > 0
				for i = 1, #server.plentities[mo.player.P_party] do
					if getEquipWeaponType(server.plentities[mo.player.P_party][i]) & typelookups[e.selectequiptype]
						canequip = true
						break
					end
				end

				if not canequip
					e.selectequiptype = $-1
				end
			end

			if e.selectequiptype < 1
				e.selectequiptype = #wpntypes
				-- do it again...
				canequip = nil

				while not canequip
					for i = 1, #server.plentities[mo.player.P_party] do
						if getEquipWeaponType(server.plentities[mo.player.P_party][i]) & typelookups[e.selectequiptype]
							canequip = true
							break
						end
					end

					if not canequip
						e.selectequiptype = $-1
					end
				end
			end

			e.weaponpreview = nil	-- reset preview weapon

			S_StartSound(nil, sfx_hover, p)

		elseif inputs[BT_BTNB] == 1
			S_StartSound(nil, sfx_cancel, p)
			DNG_changeEQLState(mo, ELS_MAIN)

		elseif inputs[BT_BTNA] == 1
		and e.weaponpreview
			-- We must check if the currently selected sub-persona isn't equipped and that we have the materials, first!
			local subp = t[e.selectequip]
			local wpn = e.weaponpreview
			if not wpn return end	-- wtf
			e.backupsubp = subp		-- keep a pointer of that

			-- check for all the items we need first:
			-- material factors:
			local fact = 10 + wpn.rarity
			e.equipneed = equipGrindTiers[getEquipGrindTier(wpn)]
			local tmp = {}
			for i = 1, #e.equipneed +1 do
				if i == 1
					tmp[1] = e.equipneed[1]*fact
				elseif i == #e.equipneed + 1	-- Add nihil frame
					tmp[i] = {"nihil frame", 1}
				else
					tmp[i] = {e.equipneed[i][1], e.equipneed[i][2]*fact}
				end
			end

			e.equipneed = tmp	-- now we're good.
			-- we couldn't just write to e.equipneed itself or we'd fuck up the internal tables responsible for keeping track of material needs, so we need that copy

			-- check if we have what we need before deciding the state
			if DNG_EQLCheckNeeds(mo)

				if subp.equipped
					local plyr = server.plentities[mo.player.P_party][subp.equipped]
					if plyr.control == mo.player
						-- this is your char, ask to unequip
						DNG_changeEQLState(mo, ELS_FUSION_ASKUNEQUIP)
						return
					else
						-- this isn't yours
						DNG_changeEQLState(mo, ELS_FUSION_NOTYOURS)
						e.hudtimers.fusionbroke = TICRATE*2
						S_StartSound(nil, sfx_not, mo.player)
						return
					end
				end
				-- nothing special
				DNG_changeEQLState(mo, ELS_FUSION_CONFIRM)
			else
				-- you don't have the materials.
				DNG_changeEQLState(mo, ELS_FUSION_FAIL)
				e.hudtimers.fusionbroke = TICRATE*2
				S_StartSound(nil, sfx_not, mo.player)
			end

		end

		local persona = btl.subpersonas[e.selectequip]

		-- Generate the preview weapon:
		if persona
		and e.weaponpreview == nil
			e.weaponpreview = makeWeapon(wpntypes[e.selectequiptype])
			local w = e.weaponpreview

			-- {level upper limit, attack power, rarity}
			local personaleveltiers = {
				{11, 350, 1},
				{23, 650, 2},
				{35, 900, 3},
				{47, 1280, 4},
				{65, 1500, 5},
				{90, 1900, 6},
				{256, 2400, 7},
			}

			local tier = 1
			for i = 1, #personaleveltiers do
				if persona.level < personaleveltiers[i][1]
					tier = i
					break
				end
			end

			if tier >= 1 and tier <= #personaleveltiers
				-- now that we have our tier, apply everything to the weapon:
				w.rarity = personaleveltiers[tier][3]
				w.atk = personaleveltiers[tier][2]
			end
			-- Pass down Persona stats.
			-- The stat cannot be higher than the weapon's rarity.
			local stats = {"st", "ma", "en", "ag", "lu"}
			for i = 1, #stats do
				local pstat = persona[stats[i]] or 0
				if pstat < 0
					pstat = min(0, $+(w.rarity/2))
				end	-- Negative stats get 1 point off per 2 rarity stars

				w[stats[i]] = min(w.rarity, pstat)
			end

			w.element = persona.ref.weapontype or ATK_ALMIGHTY
			-- slot:
			w.slot = "void boost "..w.rarity
		end
	/**
	------------------------------------------
	-- WEAPON DESYNTHESIS
	------------------------------------------
	**/

	elseif e.state == ELS_DESYNTH_SELECTWEP

		-- select a piece of equipment
		local t = btl.weapons
		if e.selectequiptype == 2
			t = btl.armours
		end

		local maxc = #t
		local maxitems = 10
		local maxscroll = max(0, maxc-maxitems)

		if inputs["down"] == 1
		and maxc

			if e.selectequip - e.selectscroll > maxitems/2
			and e.selectequip < maxc - maxitems/3
			and maxc > maxitems
				e.selectscroll = $+1
			end

			e.selectequip = $+1
			if e.selectequip > #t
				e.selectequip = 1
				e.selectscroll = 0
			end

			S_StartSound(nil, sfx_hover, p)

		elseif inputs["up"] == 1
		and maxc

			if e.selectequip < maxc - (maxitems/2)
			and e.selectscroll
				e.selectscroll = $-1
			end

			e.selectequip = $-1
			if not e.selectequip
				e.selectequip = #t
				if maxc > maxitems
					e.selectscroll = maxscroll
				end
			end

			S_StartSound(nil, sfx_hover, p)

		-- swap category
		elseif inputs["left"] == 1
		or inputs["right"] == 1
			e.selectequiptype = (e.selectequiptype == 1) and 2 or 1
			e.selectscroll = 0
			e.selectequip = 1
			S_StartSound(nil, sfx_turn, p)

		elseif inputs[BT_BTNB] == 1
			S_StartSound(nil, sfx_cancel, p)
			DNG_changeEQLState(mo, ELS_MAIN)

		elseif inputs[BT_BTNA] == 1
		and #t
			S_StartSound(nil, sfx_confir, p)
			e.lastsource = t[e.selectequip]
			DNG_changeEQLState(mo, ELS_DESYNTH_CONFIRM)
		end

	-- confirm desynthesis
	elseif e.state == ELS_DESYNTH_CONFIRM

		local choice = handleTextChoices(mo)

		if choice == 1
			-- check if the weapon we wanted to desynthetize still exists
			local t = e.selectequiptype == 1 and btl.weapons or btl.armours
			local found
			for i = 1, #t do
				if t[i] == e.lastsource
					found = true
					break
				end
			end

			-- item was sold / equipped / whatever while we were confirming
			if not found
				S_StartSound(nil, sfx_not, p)
				e.hudtimers.desynthfail = TICRATE
				DNG_changeEQLState(mo, ELS_DESYNTH_FAIL)
			else
				-- we succesfully desynthetized the weapon
				local mats = equipGrindTiers[getEquipGrindTier(e.lastsource)]
				-- Get the materials (starting from index 2 as index 1 will always be macca)
				local fact = e.lastsource.level + 2
				for i = 2, #mats
					BTL_addItem(btl, mats[i][1], mats[i][2]*fact)
				end

				-- destroy the equipment and its references
				if e.selectequiptype == 1
					removeWeapon(mo, e.lastsource)
				else
					removeRing(mo, e.lastsource)
				end
				e.lastsource = nil

				e.hudtimers.desynthsuccess = TICRATE
				DNG_changeEQLState(mo, ELS_DESYNTH_SUCCESS)
			end


		elseif choice == 2
		or inputs[BT_BTNB] == 1

			DNG_changeEQLState(mo, ELS_DESYNTH_SELECTWEP)
			S_StartSound(nil, sfx_cancel, p)
		end

	elseif e.state == ELS_DESYNTH_FAIL
	or e.state == ELS_DESYNTH_SUCCESS

		if (not e.hudtimers.desynthfail and not e.hudtimers.desynthsuccess)
		or inputs[BT_BTNA] == 1
			DNG_changeEQLState(mo, ELS_DESYNTH_SELECTWEP)
		end

	/**
	------------------------------------------
	-- WEAPON ENHANCEMENT
	------------------------------------------
	**/
	elseif e.state == ELS_GRIND_SELECTWEP
		-- Select a piece of equipment:
		if inputs["left"] == 1
			e.selectparty = $-1
			if not e.selectparty
				e.selectparty = server.P_netstat.teamlen
			end
			S_StartSound(nil, sfx_turn, mo.player)
		elseif inputs["right"] == 1
			e.selectparty = $+1
			if e.selectparty > server.P_netstat.teamlen
				e.selectparty = 1
			end
			S_StartSound(nil, sfx_turn, mo.player)

		-- up/down. There's only 2 choices so whatever.
		elseif inputs["up"] == 1
		or inputs["down"] == 1
			e.selectequip = e.selectequip == 1 and 2 or 1
			S_StartSound(nil, sfx_hover, mo.player)

		elseif inputs[BT_BTNA] == 1
		and e.lastsource	-- make sure we have that available

			-- can we select this?
			if server.plentities[mo.player.P_party][e.selectparty].control ~= mo.player
				S_StartSound(nil, sfx_not, mo.player)
				return

			end

			e.equipneed = equipGrindTiers[getEquipGrindTier(e.lastsource)]

			-- check if we have what we need before deciding the state
			if DNG_EQLCheckNeeds(mo) and e.lastsource.level < 10
				DNG_changeEQLState(mo, ELS_GRIND_CONFIRM)
			else
				DNG_changeEQLState(mo, e.lastsource.level < 10 and ELS_GRIND_BROKE or ELS_GRIND_MAXLEVEL)
				e.hudtimers.grindbroke = TICRATE*2
				S_StartSound(nil, sfx_not, mo.player)
			end

		elseif inputs[BT_BTNB] == 1

			S_StartSound(nil, sfx_cancel, p)
			DNG_changeEQLState(mo, ELS_MAIN)
		end

		-- check what weapon / ring we have selected, prepare a copy that has +1 enhancement level if possible.
		-- this is used to display what the weapon will be like post enhancement

		local who = server.plentities[mo.player.P_party][e.selectparty]
		local what = e.selectequip == 1 and "weapon" or "wardring"
		local source = who[what]
		local copy

		if e.lastsource ~= source	-- update our pointers
			--print("Update copy equip...")

			if e.selectequip == 1	-- weapon
				copy = makeWeapon(source.ref)
			else					-- ring
				copy = makeRing(source.ref)
			end

			-- copy attributes
			for k,v in pairs(source)
				copy[k] = v
			end

			if e.selectequip == 1
				enhanceWeapon(copy)
			else
				enhanceRing(copy)
			end

			e.lastsource = source
			e.sourcecopy = copy
		end

	elseif e.state == ELS_GRIND_CONFIRM

		local choice = handleTextChoices(mo)

		if choice == 1
			-- check materials AGAIN just in case
			if DNG_EQLCheckNeeds(mo)

				-- enhance our weapon slash ring
				if e.selectequip == 1
					enhanceWeapon(e.lastsource)
					enhanceWeapon(e.sourcecopy)	-- yup.
					server.P_BattleStatus[mo.player.P_party].netstats.weaponsenhanced = $+1
				else
					enhanceRing(e.lastsource)
					enhanceRing(e.sourcecopy)	-- yup.
					server.P_BattleStatus[mo.player.P_party].netstats.ringsenhanced = $+1
				end

				e.hudtimers.enhancesuccess = TICRATE
				DNG_EQLUseMaterials(mo)
				DNG_changeEQLState(mo, ELS_GRIND_SUCCESS)
			else
				e.hudtimers.grindbroke = TICRATE*2
				S_StartSound(nil, sfx_not, mo.player)
				DNG_changeEQLState(mo, ELS_GRIND_BROKE)
			end

		elseif choice == 2
			DNG_changeEQLState(mo, ELS_GRIND_SELECTWEP)
		end

	-- grind success, reset by pressing a button
	elseif e.state == ELS_GRIND_SUCCESS
		if not e.hudtimers.enhancesuccess
		or inputs[BT_BTNA] == 1
			DNG_changeEQLState(mo, ELS_GRIND_SELECTWEP)
		end


	elseif e.state == ELS_GRIND_BROKE
	or e.state == ELS_GRIND_MAXLEVEL
		if not e.hudtimers.grindbroke
		or inputs[BT_BTNA] == 1
			DNG_changeEQLState(mo, ELS_GRIND_SELECTWEP)
		end
	end

	-- don't allow base menu to be opened
	return true
end)
