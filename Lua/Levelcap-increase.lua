-- Generate EXP table:
local basexp = 25
local totalxp = basexp
rawset(_G, "needEXP", {})

for i = 1, 1000 //If you're going to increase the levelcap above 999, make sure to increase this too
	needEXP[i] = totalxp
	--print("Lv: "..i..":"..needEXP[i])
	totalxp = ($1 + (basexp*i)*38/100)
end

//I don't like these changes any more, but I'll keep the expanded needEXP table

-- Get a Persona's stats at any given level using growth rates
-- NOTE: These are the base stats and do not take equipment into account

/*rawset(_G, "PLYR_getStatsAtLevel", function(persona, level)
	
	local stats = PLYR_getLv1Stats(persona)
	local lv1bst = stats[1] + stats[2] + stats[3] + stats[4] + stats[5]	-- Intended: 12 (3*lvl + 9)
	
	local rates = PLYR_getGrowthRates(persona)
	
	local lvstats = {}
	local extrapoints = 0
	
	for i = 1, #stats do
		lvstats[i] = ((stats[i]*1000) + (level-1)*rates[i])
		if lvstats[i]%1000 >= 500	-- round UP!
			lvstats[i] = $ + 1000 
		end
		
		lvstats[i] = $/1000
		
		if lvstats[i] > 999	-- Stats can't normally exceed 99 before bonuses //Now they go up to 999
			extrapoints = $ + (lvstats[i] - 999)
			lvstats[i] = 999
		end
	end
	
	-- Award excess points (> 99) to the lowest stat if this happens
	while extrapoints
	
		local loweststat = 999
		local lowestindex = 0	
	
		for i = 1, #stats do
			
			if lvstats[i] < loweststat
				loweststat = lvstats[i]
				lowestindex = i
			end	
			
		end
		
		-- give points to the lowest stat
		if lowestindex
			lvstats[lowestindex] = $+1
			extrapoints = $-1
		else		-- this means all our stats are already at //999, just break out
			extrapoints = 0
			break
		end	
		
	end

	local bst = lvstats[1] + lvstats[2] + lvstats[3] + lvstats[4] + lvstats[5]

	--print(persona.name.." At Lv"..level..": "..lvstats[1]..", "..lvstats[2]..", "..lvstats[3]..", "..lvstats[4]..", "..lvstats[5].." (BST: "..bst..")")
	return lvstats
end)

difficulty_cap[7] = 999 //lol only monad block getting the changed level cap*/