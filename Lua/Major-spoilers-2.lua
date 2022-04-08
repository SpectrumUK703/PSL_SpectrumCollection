if CV_FindVar("mnemesisrogue") then return end
local mnemesisrogue = CV_RegisterVar({
	name = "mnemesisrogue",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	possiblevalue = CV_OnOff
})

enemyList["mnemesis_arm2"].shufflename = "Arm - A" //For the edited RogueGen code to give the arms identical shuffles

-- Event to shift to phase 3
eventList["ev_mpeak_phase3"] = {
		
	[1] = {"function", 	function(evt, btl)
							
							local cam = btl.cam
							local ps = server.plentities[btl.n]
							local en = ps[1].enemies[2] or ps[1].enemies[1]	-- yep, crude assumption!	

							evt.camtimer = $ and $+1 or 1
							
							if evt.camtimer == TICRATE*14
								evt.camtimer = nil
								return true
							end		
							
							if evt.camtimer < TICRATE*5
							
								if evt.camtimer & 1
									S_StartSound(en, sfx_pop)
								end	
								
								local x = en.x + P_RandomRange(-128, 128)*FRACUNIT
								local y = en.y + P_RandomRange(-128, 128)*FRACUNIT
								local z = en.z + P_RandomRange(0, 192)*FRACUNIT
								
								local e = P_SpawnMobj(x, y, z, MT_DUMMY)
								e.state = S_QUICKBOOM1
								e.scale = FRACUNIT*3
							end
							
							
							if evt.camtimer == TICRATE*4
								
								for i = 1, #server.plentities[btl.n]
									local mo = server.plentities[btl.n][i]
									if mo and mo.valid and mo.control and mo.control.valid
										P_FlashPal(mo.control, 1, 5)
									end	
								end
								
								if mnemesisrogue.value
									BTL_spawnEnemy(en, ROGUE_initEnemyStats("mnemesis_arm1"), true)
									BTL_spawnEnemy(en, ROGUE_initEnemyStats("mnemesis_arm2"))
								else
									BTL_spawnEnemy(en, "mnemesis_arm1", true)
									BTL_spawnEnemy(en, "mnemesis_arm2")
								end

								BTL_changeEnemy(en, "mnemesis_3")
								en.guaranteedevasion = true
								
											
							elseif evt.camtimer == TICRATE*6
								return true
							end	
						end	
		},
}
