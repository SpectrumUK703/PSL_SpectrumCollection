//I would replace the VFX_Play function here, but that'd mean either breaking Jenna's QOL mod or stealing from her, so I'll just use this dirty hack instead
addHook("PlayerThink", function(p)
	if p.mo and p.mo.valid
		p.mo.name = p.name or p.mo.skin or "WTF" //No name or skin?!?!?!
	end
end)

//Actually, this should also fix issues
//Copied and edited from Player_Stats.LUA in SRB2P-main.pk3
for k, v in pairs(charStats)
	if k ~= "sonic" 
	and k ~= "tails" 
	and k ~= "knuckles" 
	and k ~= "amy" 
	and k ~= "metalsonic" 
	and k ~= "shadow" 
	and k ~= "eggman" 
	and k ~= "blaze" 
	and k ~= "silver" 
	and k ~= "kanade" 
		VFX_freeslotC(k)
	end
end

for k, v in pairs(attackDefs)
	if v.power ~= nil and tonumber(v.power) == nil
		//print("changed skill "..v.name.."'s power to 1")
		v.power = 1
	end
end