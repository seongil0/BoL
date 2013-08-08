--[ AutoCarry Plugin: Annie Hastur, the Dark Child by UglyOldGuy]--

if myHero.charName ~= "Annie" then return end -- Hero Check

require "AoE_Skillshot_Position" -- Library Required in Common Folder

--[ Plugin Loads] --
function PluginOnLoad()
	
	loadMain() -- Loads Global Variables
	menuMain() -- Loads AllClass Menu
end
--[/Loads]

--[Plugin OnTick]--
function PluginOnTick()
		Target = AutoCarry.GetAttackTarget(true)
		
		qReady = (myHero:CanUseSpell(_Q) == READY)
		wReady = (myHero:CanUseSpell(_W) == READY)
		eReady = (myHero:CanUseSpell(_E) == READY)
		rReady = (myHero:CanUseSpell(_R) == READY)
		DamageCalc()
		
		if Menu.dAttack then AutoCarry.CanAttack = false else AutoCarry.CanAttack = true end
		if Menu.qKS and qReady then qKS() end
		if Menu.qHarrass and qReady and Target then CastSpell(_Q, Target) end
		if Menu.qFarm and qReady and Menu.qMana <= MinMana and HaveStun and not Menu.cFarm and not Carry.AutoCarry then qFarm() end
		if Menu.qFarm and qReady and Menu.qMana <= MinMana and not HaveStun and not Carry.AutoCarry then qFarm() end
		if Menu.cStun and eReady and not HaveStun and not Backing then CastSpell(_E) end
		if Menu.bCombo and Carry.AutoCarry then smartCombo() end
		if Menu.cKS then smartKS() end
end
--[/OnTick]--

function qKS()
		for i = 1, heroManager.iCount, 1 do
                        local qTarget = heroManager:getHero(i)
                        if ValidTarget(qTarget, qRange) then
                                if qTarget.health <=  getDmg("Q", qTarget, myHero) then CastSpell(_Q, qTarget) end
                        end
                end
end

function qFarm()
		for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
                        if ValidTarget(minion) and qReady and GetDistance(minion) <= qRange then
                                if minion.health < getDmg("Q", minion, myHero) then 
									CastSpell(_Q, minion) 
								end
                        end
                end
end


function castR(target)
        if Menu.rMEC then
                local ultPos = GetAoESpellPosition(250, target)
                if ultPos and GetDistance(ultPos) <= rRange     then
                        if CountEnemies(ultPos, 600) >= Menu.MinEnem then
                                CastSpell(_R, ultPos.x, ultPos.z)
                        end
                end
        elseif GetDistance(target) <= rRange then
                CastSpell(_R, target.x, target.z)
        end
end

function PluginOnCreateObj(object)
        if object and object.name == "StunReady.troy" then HaveStun = true end
		if object and GetDistance(object) <= 150 and object.name == "TeleportHome.troy" then Backing = true end
		if object and object.name == "BearFire_foot.troy" then HaveTibbers = true end 
end
 
function PluginOnDeleteObj(object)
        if object and object.name == "StunReady.troy" then HaveStun = false end
		if object and GetDistance(object) <= 150 and object.name == "TeleportHome.troy" then Backing = false end
		if object and object.name == "BearFire_foot.troy" then HaveTibbers = false end
end

function DamageCalc()
        for i=1, heroManager.iCount do
        local enemy = heroManager:GetHero(i)
        if ValidTarget(enemy) then
			dfgDmg, hxgDmg, bwcDmg, iDmg, sheenDmg, triDmg, lichDmg  = 0, 0, 0, 0, 0, 0, 0
			pDmg = getDmg("P",enemy,myHero)
			qDmg = getDmg("Q",enemy,myHero)
            wDmg = getDmg("W",enemy,myHero)
            rDmg = getDmg("R",enemy,myHero)
			hitDmg = getDmg("AD",enemy,myHero)
			myMana = (myHero.mana)
			qMana = myHero:GetSpellData(_Q).mana
			wMana = myHero:GetSpellData(_W).mana
			rMana = myHero:GetSpellData(_R).mana
			dfgDmg = (dfgSlot and getDmg("DFG",Target,myHero) or 0)
            hxgDmg = (hxgSlot and getDmg("HXG",Target,myHero) or 0)
            bwcDmg = (bwcSlot and getDmg("BWC",Target,myHero) or 0)
            iDmg = (ignite and getDmg("IGNITE",Target,myHero) or 0)
            onhitDmg = (sheenSlot and getDmg("SHEEN",Target,myHero) or 0)+(triSlot and getDmg("TRINITY",Target,myHero) or 0)+(lichSlot and getDmg("LICHBANE",Target,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)                                                 
            onspellDmg = (liandrysSlot and getDmg("LIANDRYS",Target,myHero) or 0)+(blackfireSlot and getDmg("BLACKFIRE",Target,myHero) or 0)
            dpsDmg = onspellDmg
            itemsDmg = onhitDmg + qDmg + wDmg + rDmg + dfgDmg + hxgDmg + bwcDmg + iDmg + onspellDmg
			combo1 = onspellDmg + pDmg + onhitDmg + hitDmg --0 cd
            combo2 = onspellDmg + pDmg + onhitDmg + hitDmg
            combo3 = 0
            combo4 = 0
            if qReady then
                combo1 = combo1 + qDmg
                combo2 = combo2 + qDmg
                combo3 = combo3 + qDmg
                combo4 = combo4 + qDmg
            end
            if wReady then
                combo1 = combo1 + wDmg
                combo2 = combo2 + wDmg
                combo3 = combo3 + wDmg
                combo4 = combo4 + wDmg
            end
            if rReady then
                combo1 = combo1 + rDmg
                combo2 = combo2 + rDmg
                combo3 = combo3 + rDmg
                combo4 = combo4 + rDmg
            end
            if hxgReady then              
                combo1 = combo1 + hxgDmg    
                combo2 = combo2 + hxgDmg
                combo3 = combo3 + hxgDmg
                combo4 = combo4 + hxgDmg
            end
            if bwcReady then
                combo1 = combo1 + bwcDmg
                combo2 = combo2 + bwcDmg
                combo3 = combo3 + bwcDmg
                combo4 = combo4 + bwcDmg
            end
            if dfgReady then        
				combo1 = combo1 + dfgDmg            
				combo2 = combo2 + dfgDmg
				combo3 = combo3 + dfgDmg
				combo4 = combo4 + dfgDmg
            end                                                
            if iReady then
				combo1 = combo1 + iDmg
				combo2 = combo2 + iDmg
				combo3 = combo3 + iDmg
				combo4 = combo4 + iDmg
            end
            if combo4 >= enemy.health then
				killable[i] = 4
            elseif combo3 >= enemy.health then
                killable[i] = 3
            elseif combo2 >= enemy.health then
                killable[i] = 2
            elseif combo1 >= enemy.health then
                killable[i] = 1
            else
                killable[i] = 0
            end
        end
		end
end
function smartCombo()
			if Target and Target.health <= dpsDmg + qDmg and qReady then
					if qReady and qMana <= myMana and GetDistance(Target) <= qRange then
					if qReady then CastSpell(_Q, Target) end
					end
			end
			if Target and Target.health <= dpsDmg + itemsDmg + qDmg and qReady then
					if qReady and qMana <= myMana and GetDistance(Target) <= qRange then
						if dfgReady then CastSpell(dfgSlot, Target) end
						if hxgReady then CastSpell(hxgSlot, Target) end
						if bwcReady then CastSpell(bwcSlot, Target) end		
						if qReady then CastSpell(_Q, Target) end
					end
			end
			if Target and Target.health <= dpsDmg + wDmg and wReady and not qDie then
					if wReady and wMana <= myMana and GetDistance(Target) <= wRange then
						if wReady then CastSpell(_W, Target)  end
					end
			end
				if Target and Target.health <= dpsDmg + itemsDmg + wDmg and wReady and not qDie then
					if wReady and qMana <= myMana and GetDistance(Target) <= wRange then
						if dfgReady then CastSpell(dfgSlot, Target) end
						if hxgReady then CastSpell(hxgSlot, Target) end
						if bwcReady then CastSpell(bwcSlot, Target) end
						if wReady then CastSpell(_W, Target) end
					end
			end
			if Target and Target.health <= dpsDmg + qDmg + wDmg and qReady and wReady then
				ComboMana = qMana + wMana
					if ComboMana <= myMana and GetDistance(Target) <= qRange then
						if qReady then CastSpell(_Q, Target) end
						if wReady then CastSpell(_W, Target) end
					end
			end
			if Target and Target.health <= dpsDmg + itemsDmg + qDmg + wDmg and qReady and wReady then
				ComboMana = qMana + wMana
					if ComboMana <= myMana and GetDistance(Target) <= qRange then
						if dfgReady then CastSpell(dfgSlot, Target) end
						if hxgReady then CastSpell(hxgSlot, Target) end
						if bwcReady then CastSpell(bwcSlot, Target) end
						if qReady then CastSpell(_Q, Target) end
						if wReady then CastSpell(_W, Target) end
					end
			end
			if Target and Target.health <= rDmg and rReady and not qDie and not wDie then
					if rMana <= myMana and GetDistance(Target) <= rRange then
						if rReady then castR(Target) end
					end
			end
			if Target and Target.health <= rDmg + qDmg and rReady and qReady then
				ComboMana = rMana + qMana
					if ComboMana <= myMana and GetDistance(Target) <= rRange then
						if rReady then castR(Target) end
						if qReady then CastSpell(_Q, Target) end
					end
			end
			if Target and Target.health <= rDmg + wDmg and rReady and wReady then
				ComboMana = rMana + wMana
					if ComboMana <= myMana and GetDistance(Target) <= rRange then
						if rReady then castR(Target) end
						if wReady then CastSpell(_W, Target) end
					end
			end
			if Target and Target.health <= rDmg + qDmg + wDmg and rReady and qReady and wReady then
				ComboMana = rMana + qMana + wMana
					if ComboMana <= myMana and GetDistance(Target) <= rRange then
						if rReady then castR(Target) end
						if qReadt then CastSpell(_Q, Target) end
						if wReady then CastSpell(_W, Target) end
					end
			end
			if Target and Target.health <= dpsDmg + itemsDmg + rDmg + qDmg + wDmg and rReady and qReady and wReady then
				ComboMana = rMana + qMana + wMana
				if ComboMana <= myMana and GetDistance(Target) <= rRange then
						if dfgReady then CastSpell(dfgSlot, Target) end
						if hxgReady then CastSpell(hxgSlot, Target) end
						if bwcReady then CastSpell(bwcSlot, Target) end
						if rReady and not HaveTibbers then castR(Target) end
						if qReady and GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
						if wReady and GetDistance(Target) <= wRange then CastSpell(_W, Target) end
				end
			end
			if Target and Target.health > dpsDmg + itemsDmg + rDmg + qDmg + wDmg then
					if dfgReady then CastSpell(dfgSlot, Target) end
					if hxgReady then CastSpell(hxgSlot, Target) end
					if bwcReady then CastSpell(bwcSlot, Target) end
					if rReady and not HaveTibbers and HaveStun and not qDie and not wDie and GetDistance(Target) <= rRange then castR(Target) end
					if qReady and GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
					if wReady and GetDistance(Target) <= wRange then CastSpell(_W, Target) end
			end
end
function smartKS()
			for i = 1, heroManager.iCount, 1 do
            local ksTarget = heroManager:getHero(i)
				if ValidTarget(ksTarget) then
					if ksTarge and ksTarge.health <= dpsDmg + qDmg and qReady then
						if qReady and qMana <= myMana and GetDistance(ksTarge) <= qRange then
							if qReady then CastSpell(_Q, ksTarge) end
						end
					end
					if ksTarge and ksTarge.health <= dpsDmg + itemsDmg + qDmg and qReady then
						if qReady and qMana <= myMana and GetDistance(ksTarge) <= qRange then
							if dfgReady then CastSpell(dfgSlot, ksTarge) end
							if hxgReady then CastSpell(hxgSlot, ksTarge) end
							if bwcReady then CastSpell(bwcSlot, ksTarge) end		
							if qReady then CastSpell(_Q, ksTarge) end
						end
					end
					if ksTarge and ksTarge.health <= dpsDmg + wDmg and wReady then
						if wReady and wMana <= myMana and GetDistance(ksTarge) <= wRange then
							if wReady then CastSpell(_W, ksTarge)  end
						end
					end
					if ksTarge and ksTarge.health <= dpsDmg + itemsDmg + wDmg and wReady then
						if wReady and qMana <= myMana and GetDistance(ksTarge) <= wRange then
							if dfgReady then CastSpell(dfgSlot, ksTarge) end
							if hxgReady then CastSpell(hxgSlot, ksTarge) end
							if bwcReady then CastSpell(bwcSlot, ksTarge) end
							if wReady then CastSpell(_W, ksTarge) end
						end
					end
					if ksTarge and ksTarge.health <= dpsDmg + qDmg + wDmg and qReady and wReady then
						ComboMana = qMana + wMana
						if ComboMana <= myMana and GetDistance(ksTarge) <= qRange then
							if qReady then CastSpell(_Q, ksTarge) end
							if wReady then CastSpell(_W, ksTarge) end
						end
					end
					if ksTarge and ksTarge.health <= dpsDmg + itemsDmg + qDmg + wDmg and qReady and wReady then
						ComboMana = qMana + wMana
						if ComboMana <= myMana and GetDistance(ksTarge) <= qRange then
							if dfgReady then CastSpell(dfgSlot, ksTarge) end
							if hxgReady then CastSpell(hxgSlot, ksTarge) end
							if bwcReady then CastSpell(bwcSlot, ksTarge) end
							if qReady then CastSpell(_Q, ksTarge) end
							if wReady then CastSpell(_W, ksTarge) end
						end
					end
					if ksTarge and ksTarge.health <= rDmg and rReady then
						if rMana <= myMana and GetDistance(ksTarge) <= rRange then
							if rReady then castR(ksTarge) end
						end
					end
					if ksTarge and ksTarge.health <= rDmg + qDmg and rReady and qReady then
						ComboMana = rMana + qMana
						if ComboMana <= myMana and GetDistance(ksTarge) <= rRange then
							if rReady then castR(ksTarge) end
							if qReady then CastSpell(_Q, ksTarge) end
						end
					end
					if ksTarge and ksTarge.health <= rDmg + wDmg and rReady and wReady then
						ComboMana = rMana + wMana
						if ComboMana <= myMana and GetDistance(ksTarge) <= rRange then
							if rReady then castR(ksTarge) end
							if wReady then CastSpell(_W, ksTarge) end
						end
					end
					if ksTarge and ksTarge.health <= rDmg + qDmg + wDmg and rReady and qReady and wReady then
						ComboMana = rMana + qMana + wMana
						if ComboMana <= myMana and GetDistance(ksTarge) <= rRange then
							if rReady then castR(ksTarge) end
							if qReadt then CastSpell(_Q, ksTarge) end
							if wReady then CastSpell(_W, ksTarge) end
						end
					end
					if ksTarge and ksTarge.health <= dpsDmg + itemsDmg + rDmg + qDmg + wDmg and rReady and qReady and wReady then
						ComboMana = rMana + qMana + wMana
						if ComboMana <= myMana and GetDistance(ksTarge) <= rRange then
							if dfgReady then CastSpell(dfgSlot, ksTarge) end
							if hxgReady then CastSpell(hxgSlot, ksTarge) end
							if bwcReady then CastSpell(bwcSlot, ksTarge) end
							if rReady and not HaveTibbers then CastSpell(_R, ksTarge) end
							if qReady and GetDistance(ksTarge) <= qRange then CastSpell(_Q, ksTarge) end
							if wReady and GetDistance(ksTarge) <= wRange then CastSpell(_W, ksTarge) end
						end
					end
			end
		end
end

function PluginOnDraw()
	if not myHero.dead then
				if Menu.drawQ then
					DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FF00)
				end
				if Target then
                    DrawText("Targetting: " .. Target.charName, 15, 100, 100, 0xFFFF0000)
                    DrawCircle(Target.x, Target.y, Target.z, 100, 0x00FF00)
                end
        for i=1, heroManager.iCount do
        local enemydraw = heroManager:GetHero(i)
                if ValidTarget(enemydraw) then
				        if killable[i] == 1 then
                                        DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 100, 0xFFFFFF00)
                                end
                        if killable[i] == 2 then
                               
                                DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 100, 0xFFFFFF00)
                               
                        end
                        if killable[i] ==3  then
                                for j=0, 10 do
                                        DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 100+j*0.8, 0x099B2299)
                                end
                        end
                        if killable[i] ==4  then
                                for j=0, 10 do
                                        DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 100+j*0.8, 0x099B2299)
                                       
                                end
                        end
						if killable[i] ==5  then
                                for j=0, 10 do
                                        DrawCircle(enemydraw.x, enemydraw.y, enemydraw.z, 100+j*0.8, 0xFFFFFF00)
                                       
                                end
                        end
                        if waittxt[i] == 1 and killable[i] ~= 0 then
                                PrintFloatText(enemydraw,0,floattext[killable[i]])
                        end
                end
                if waittxt[i] == 1 then waittxt[i] = 30
                else waittxt[i] = waittxt[i]-1 end
        end		
	end
end

function loadMain()
		Menu = AutoCarry.PluginMenu
		Carry = AutoCarry.MainMenu
        AutoCarry.SkillsCrosshair.range = 625
		MinMana = ((myHero.mana/myHero.maxMana)*100)
		HaveStun = false
		HaveTibbers = false
		KillableTarget = false
		ComboDisplay = 12
		HK1, HK2, HK3 = string.byte("Z"), string.byte("K"), string.byte("T")
        qRange, wRange, eRange, rRange = 625, 625, 600, 630
        qReady, wReady, eReady, rReady, dfgReady, hxgReadt, bwcReady, iReady = false, false, false, false, false, false, false, false
		dfgSlot, hxgSlot, bcSlot, sheenSlot, triSlot, lichSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
        iceSlot, liandrysSlot, blackfireSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)  
		qReady = (myHero:CanUseSpell(_Q) == READY)
		wReady = (myHero:CanUseSpell(_W) == READY)
		eReady = (myHero:CanUseSpell(_E) == READY)
		rReady = (myHero:CanUseSpell(_R) == READY)
		dfgReady = (dfgSlot ~= nil and myHero:CanUseSpell(dfgSlot) == READY)
        hxgReady = (hxgSlot ~= nil and myHero:CanUseSpell(hxgSlot) == READY)
        bwcReady = (bwcSlot ~= nil and myHero:CanUseSpell(bwcSlot) == READY)
		iReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
		waittxt = {}
		killable = {}
		floattext = {"Skills are not available","Able to fight","Killable","Murder him!",}
		for i=1, heroManager.iCount do
		waittxt[i] = i*3
		enemies = heroManager:getHero(i) end
		qDie,wDie,rDie = false, false, false
		qCheck = getDmg("Q",enemies,myHero)
        wCheck = getDmg("W",enemies,myHero)
		if qReady and enemies.health <= qCheck then qDie = true end
		if wReady and enemies.health <= wCheck then wDie = true end
		PrintList = {"Kill with Q!", "Kill With Items+Q!", "Kill with W!", "Kill with Items+W!",
					 "Kill with Q+W!", "Kill With Items+Q+W", "Kill with R", "Kill with R+Q!", 
					 "Kill with R+W!", "Kill with R+Q+W!",  "Kill with Full Combo!", "Harrass!!", 
					 "Need Mana for Q!", "Need Mana for Q!", "Need Mana for W!", "Need Mana for W!", 
					 "Need Mana for Q+W!", "Need Mana for Q+W!", "Need Mana for R", "Need Mana for R+Q!",
					 "Need Mana for R+W", "Need Mana for R+Q+W!", "Need Mana for Full Combo!"}

end

 
function menuMain()
        Menu:addParam("sep", "-- Farm Options --", SCRIPT_PARAM_INFO, "")
       	Menu:addParam("qFarm", "Disintegrate(Q) - Farm ", SCRIPT_PARAM_ONKEYTOGGLE, false, HK1)
		Menu:addParam("cFarm", "Don't Q Farm if Stun Ready", SCRIPT_PARAM_ONKEYTOGGLE, false, HK2)
		Menu:addParam("qMana", "Minimum % of Mana to farm",  SCRIPT_PARAM_SLICE, 25, 0, 100, 2)
		Menu:addParam("sep1", "-- Combo Options --", SCRIPT_PARAM_INFO, "")
		Menu:addParam("qHarrass", "Disintegrate(Q) - Harrass", SCRIPT_PARAM_ONKEYTOGGLE, true, HK3)
		Menu:addParam("dAttack", "Disable Auto Attacks", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("I"))
		Menu:addParam("cStun", "Charge Stun with E", SCRIPT_PARAM_ONOFF, true)
		Menu:addParam("bCombo", "Burst Combo while AutoCarry", SCRIPT_PARAM_ONOFF, true)
		Menu:addParam("rMec", "Tibbers Use MEC", SCRIPT_PARAM_ONOFF, true)
		Menu:addParam("MinEnem", "Tibbers - Min Enemies",SCRIPT_PARAM_SLICE, 1, 1, 5, 0)
		Menu:addParam("sep2", "-- KS Options --", SCRIPT_PARAM_INFO, "")
		Menu:addParam("qKS", "Disintegrate(Q) - Kill Steal", SCRIPT_PARAM_ONOFF, true)
		Menu:addParam("cKS", "Use Smart Combo KS", SCRIPT_PARAM_ONOFF, true)
		Menu:addParam("sep3", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
		Menu:addParam("drawQ", "Draw Disintegrate (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu:addParam("drawC", "Draw Enemy Circles", SCRIPT_PARAM_ONOFF, false)
		AutoCarry.PluginMenu:permaShow("qFarm")
		AutoCarry.PluginMenu:permaShow("qHarrass")
		AutoCarry.PluginMenu:permaShow("dAttack")
		AutoCarry.PluginMenu:permaShow("cFarm")
		
end