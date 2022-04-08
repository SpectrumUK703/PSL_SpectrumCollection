itemDefs["levelcap up"].checkfunc = function(user, mo)
						if mo.levelcap >= #needEXP //Hey, if you've added to that table too, I'm not gonna stop you from increasing the level cap further
							return true
						end	
					end

/*itemDefs["levelcap up 2"] = {
		name = "Void Unlimiter 2",
		desc = "Some grape juice can.\nRaises party level cap by 10",
		attack = "dummy",
		menuonly = true,
		rarity = 7,
		useall = true,		-- force item to target all in the menu
		checkfunc = function(user, mo)
						if mo.levelcap >= #needEXP
							return true
						end	
					end,
		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)
						
						local lcap = 0
						local pa = server.plentities[user.player.P_party]
						for i = 1, #pa do
							local m = pa[i]
							m.levelcap = min(#needEXP, $+10)
							lcap = m.levelcap
						end
						S_StartSound(nil, sfx_heal4, user.player)
						DNG_logMessage("\x82".."Level cap increased! "..(lcap-10).." -> "..lcap)
					end,
		cost = 0,
	}

table.insert(VR_itemrewards[6], {"levelcap up 2", 1, 100})
table.insert(VR_itemrewards[9], {"levelcap up 2", 1, 100})
table.insert(VR_itemrewards[15], {"levelcap up 2", 1, 100})

itemDefs["levelcap up 3"] = {
		name = "Void Unlimiter 3",
		desc = "Some blackcurrant juice can.\nRaises party level cap by 100",
		attack = "dummy",
		menuonly = true,
		rarity = 7,
		useall = true,		-- force item to target all in the menu
		checkfunc = function(user, mo)
						if mo.levelcap >= #needEXP
							return true
						end	
					end,
		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)
						
						local lcap = 0
						local pa = server.plentities[user.player.P_party]
						for i = 1, #pa do
							local m = pa[i]
							m.levelcap = min(#needEXP, $+100)
							lcap = m.levelcap
						end
						S_StartSound(nil, sfx_heal4, user.player)
						DNG_logMessage("\x82".."Level cap increased! "..(lcap-100).." -> "..lcap)
					end,
		cost = 0,
	}

table.insert(VR_itemrewards[15], {"levelcap up 3", 1, 100})*/
