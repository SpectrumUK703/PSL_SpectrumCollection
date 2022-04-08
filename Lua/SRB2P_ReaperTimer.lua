if not CV_FindVar("reapertimerall")
local function reapertimerallfunc(arg1)
	if server
		if arg1.value == -2
			COM_BufInsertText(server, "reapertimer1 0")
			COM_BufInsertText(server, "reapertimer2 9")
			COM_BufInsertText(server, "reapertimer3 8")
			COM_BufInsertText(server, "reapertimer4 7")
			COM_BufInsertText(server, "reapertimer5 7")
			COM_BufInsertText(server, "reapertimer6 7")
			COM_BufInsertText(server, "reapertimer7 7")
		else
			COM_BufInsertText(server, "reapertimer1 "..arg1.value)
			COM_BufInsertText(server, "reapertimer2 "..arg1.value)
			COM_BufInsertText(server, "reapertimer3 "..arg1.value)
			COM_BufInsertText(server, "reapertimer4 "..arg1.value)
			COM_BufInsertText(server, "reapertimer5 "..arg1.value)
			COM_BufInsertText(server, "reapertimer6 "..arg1.value)
			COM_BufInsertText(server, "reapertimer7 "..arg1.value)
		end
	end
end

local filejustadded = 1

local reapertimerall = CV_RegisterVar({
  name = "reapertimerall",
  defaultvalue = -2,
  flags = CV_NETVAR|CV_CALL,
  PossibleValue = {MIN = -2, MAX = 60},
  func = reapertimerallfunc
})

local function reapertimer1func(arg1)
	reapertimers[1] = arg1.value
	if server and server.difficulty == 1
	and arg1.value == 0
		local d = server.P_DungeonStatus
		d.reapertimer = nil
	end
end

local reapertimer1 = CV_RegisterVar({
  name = "reapertimer1",
  defaultvalue = 0,
  flags = CV_NETVAR|CV_CALL,
  PossibleValue = {MIN = -1, MAX = 60},
  func = reapertimer1func
})

local function reapertimer2func(arg1)
	reapertimers[2] = arg1.value
	if server and server.difficulty == 2
	and arg1.value == 0
		local d = server.P_DungeonStatus
		d.reapertimer = nil
	end
end

local reapertimer2 = CV_RegisterVar({
  name = "reapertimer2",
  defaultvalue = 9,
  flags = CV_NETVAR|CV_CALL,
  PossibleValue = {MIN = -1, MAX = 60},
  func = reapertimer2func
})

local function reapertimer3func(arg1)
	reapertimers[3] = arg1.value
	if server and server.difficulty == 3
	and arg1.value == 0
		local d = server.P_DungeonStatus
		d.reapertimer = nil
	end
end

local reapertimer3 = CV_RegisterVar({
  name = "reapertimer3",
  defaultvalue = 8,
  flags = CV_NETVAR|CV_CALL,
  PossibleValue = {MIN = -1, MAX = 60},
  func = reapertimer3func
})

local function reapertimer4func(arg1)
	reapertimers[4] = arg1.value
	if server and server.difficulty == 4
	and arg1.value == 0
		local d = server.P_DungeonStatus
		d.reapertimer = nil
	end
end

local reapertimer4 = CV_RegisterVar({
  name = "reapertimer4",
  defaultvalue = 7,
  flags = CV_NETVAR|CV_CALL,
  PossibleValue = {MIN = -1, MAX = 60},
  func = reapertimer4func
})

local function reapertimer5func(arg1)
	reapertimers[5] = arg1.value
	if server and server.difficulty == 5
	and arg1.value == 0
		local d = server.P_DungeonStatus
		d.reapertimer = nil
	end
end

local reapertimer5 = CV_RegisterVar({
  name = "reapertimer5",
  defaultvalue = 7,
  flags = CV_NETVAR|CV_CALL,
  PossibleValue = {MIN = -1, MAX = 60},
  func = reapertimer5func
})

local function reapertimer6func(arg1)
	reapertimers[6] = arg1.value
	if server and server.difficulty == 6
	and arg1.value == 0
		local d = server.P_DungeonStatus
		d.reapertimer = nil
	end
end

local reapertimer6 = CV_RegisterVar({
  name = "reapertimer6",
  defaultvalue = 7,
  flags = CV_NETVAR|CV_CALL,
  PossibleValue = {MIN = -1, MAX = 60},
  func = reapertimer6func
})

local function reapertimer7func(arg1)
	reapertimers[7] = arg1.value
	if server and server.difficulty == 7
	and arg1.value == 0
		local d = server.P_DungeonStatus
		d.reapertimer = nil
	end
end

local reapertimer7 = CV_RegisterVar({
  name = "reapertimer7",
  defaultvalue = 7,
  flags = CV_NETVAR|CV_CALL,
  PossibleValue = {MIN = -1, MAX = 60},
  func = reapertimer7func
})

addHook("NetVars", function(net)
	reapertimers = net($) //Since I'm changing this, it needs to be NetVar'd
end)
end

local function mm_genericOptions(v, anim, choices, curchoice)
	local t = TICRATE/4 - anim
	local scale = max(1, t*FRACUNIT /3)
	if scale/FRACUNIT < 2
		v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch("H_1M_B"), V_40TRANS)
	else
		v.fadeScreen(135, 6)
	end

	local width = max(0, 70 - anim*12)

	v.drawFill(100 - width/2, 0, width, 300, 31|V_SNAPTOTOP)

	SYS_drawGenericMenu(v, anim, choices, curchoice)
end

local netgameplay_opt = {

	{"Turn timer", 100, 32, CT_CVARNUM, {cv_turntimer, 0, 99}, nil, "Time in seconds for players to take their turn. Disabled if 0."},
	{"Reaper timer", 100, 68, CT_CVARNUM, {CV_FindVar("reapertimerall"), -2, 60}, nil, "Reaper spawn timer (in minutes). 0 is no reaper, -1 is instant reaper, -2 is defaults."},
	{"Reaper timer (Thebel)", 100, 80, CT_CVARNUM, {CV_FindVar("reapertimer1"), -1, 60}, nil, "Reaper spawn timer (in minutes) for the Thebel block."},
	{"Reaper timer (Arqa)", 100, 92, CT_CVARNUM, {CV_FindVar("reapertimer2"), -1, 60}, nil, "Reaper spawn timer (in minutes) for the Arqa block."},
	{"Reaper timer (Yabbashah)", 100, 104, CT_CVARNUM, {CV_FindVar("reapertimer3"), -1, 60}, nil, "Reaper spawn timer (in minutes) for the Yabbashah block."},
	{"Reaper timer (Tziah)", 100, 116, CT_CVARNUM, {CV_FindVar("reapertimer4"), -1, 60}, nil, "Reaper spawn timer (in minutes) for the Tziah block."},
	{"Reaper timer (Harabah)", 100, 128, CT_CVARNUM, {CV_FindVar("reapertimer5"), -1, 60}, nil, "Reaper spawn timer (in minutes) for the Harabah block."},
	{"Reaper timer (Adamah)", 100, 140, CT_CVARNUM, {CV_FindVar("reapertimer6"), -1, 60}, nil, "Reaper spawn timer (in minutes) for the Adamah block."},
	--{"Spawn Reaper", 100, 56, CT_CVAR, cv_reaper, nil, "Spawns the Reaper after a while in netgames"},
	--{"Reaper timer", 100, 68, CT_CVARNUM, {cv_reapertimer, 1, 30}, nil, "Reaper spawn timer (in minutes)"},
}

if srb2p.local_conds[UNLOCK_B7]
	table.insert(netgameplay_opt, {"Reaper timer (Monad)", 100, 152, CT_CVARNUM, {CV_FindVar("reapertimer7"), -1, 60}, nil, "Reaper spawn timer (in minutes) for the Monad block."})
end
if CV_FindVar("showreapertimer")
	table.insert(netgameplay_opt, 2, {"Display Reaper timer", 100, 56, CT_CVAR, CV_FindVar("showreapertimer"), nil, "Show how long left until the Reaper appears."})
end
if CV_FindVar("autoallowjoin")
	table.insert(netgameplay_opt, 2, {"AutoAllowjoin", 100, 44, CT_CVAR, CV_FindVar("autoallowjoin"), nil, "Automatically disable joins in dungeons and re-enable joins in the lobby."})
end
if CV_FindVar("monadrematch") and srb2p.local_conds[UNLOCK_B7_FINISHED] //Well, this will only work with the unlock fix lmao
	table.insert(netgameplay_opt, {"Monad Rematch", 100, 164, CT_CVAR, CV_FindVar("monadrematch"), nil, "Enable Re: Alt."})
end
if CV_FindVar("enemyhealchance")
	table.insert(netgameplay_opt, {"Enemy Heal Chance", 100, 176, CT_CVARNUM, {CV_FindVar("enemyhealchance"), 0, 100}, nil, "Modify enemies' chance of using heal skills"})
end
if CV_FindVar("mnemesisrogue") and srb2p.local_conds[UNLOCK_MR_FINISHED] //Spoilers (also only works with the unlock fix though)
	table.insert(netgameplay_opt, {"Metal Nemesis Rogue", 100, 188, CT_CVAR, CV_FindVar("mnemesisrogue"), nil, "Allows Metal Nemesis' arms to be affected by Rogue mode"})
end
if CV_FindVar("reaperrespawns")
	table.insert(netgameplay_opt, {"Reaper respawning", 100, 200, CT_CVAR, CV_FindVar("reaperrespawns"), nil, "The Reaper respawns when defeated"})
end

local changedmenu = {
		opentimer = TICRATE/4,
		drawfunc = mm_genericOptions,
		displayflags = 0,
		prev = MS_NETOPTIONS,

		choices = netgameplay_opt,
	}

SYS_menus[SM_TITLE][MS_NETGAMEPLAYOPTIONS] = changedmenu
SYS_menus[SM_PAUSE][MS_NETGAMEPLAYOPTIONS] = changedmenu
SYS_menus[SM_PAUSE_SP][MS_NETGAMEPLAYOPTIONS] = changedmenu