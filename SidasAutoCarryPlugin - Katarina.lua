--[[
	AutoCarry Script - Katarina 1.3.1 by Skeem
		With Code from Kain <3

	Changelog :
   1.0 - Initial Release
   1.1 - Fixed Damage Calculation
	   - Fixed Auto Ignite
	   - Hopefully Fixed BugSplat
   1.2 - Really fixed BugSplat Now
	   - More Damage Calculation Adjustments
	   - More checks for when to ult
	   - More checks to not use W when enemy not in range
   1.2.1 - Fixed the problem with channelling ultimate
   1.3 - Fixed the problem with ult AGAIN
       - Added Auto Pots
	   - Added Auto Zhonyas
	   - Added Draw Circles of targets that can die
   1.3.1 - Lul another Ult fix wtfux
         - Added move to mouse to harass mode
   1.4 - Recoded most of the script
       - Added toggle to use items with KS
	   - Jungle Clearing
	   - New method to stop ult from not channeling
	   - New Menu
	   - Lane Clear
   1.4.1 - Added packet block ult movement
   1.4.2 - Some draw text fixes
		 - ult range fixes so it doesn't keep spinning if no enemies are around
		 - Added some permashows
   1.4.4 - Added Ward Jump default hotkey is G
  	]] --		

-- Hero Name Check
if myHero.charName ~= "Katarina" then return end


--[Plugin OnLoad]--
function PluginOnLoad()
	Variables()
	KatarinaMenu()
	if IsSACReborn then
        AutoCarry.Crosshair:SetSkillCrosshairRange(675)
    else
        AutoCarry.SkillsCrosshair.range = 675
    end
end
--[/Plugin OnLoad]--

--[Plugin OnTick]--
function PluginOnTick()
	Checks()
	KatarinaChanneling()
	KillSteal()
	tick = GetTickCount()
	
	if Target ~= nil then
		if Menu.autocarry.bCombo and Carry.AutoCarry then bCombo() end
		if Menu.harrass.wHarrass and GetDistance(Target) <= wRange then CastSpell(_W) end
		if Menu.killsteal.Ignite then AutoIgnite() end
	end
	if Menu.harrass.hHK then Harrass() end
	if not Menu.farming.mFarm and not Carry.AutoCarry then Farm() end
	if Menu.jungle.JungleFarm and Carry.LaneClear then JungleClear() end
	if Menu.jungle.ClearLane and Carry.LaneClear then LaneClear() end
	
	if Menu.misc.WardJump then WardJump() end
	if Menu.misc.ZWItems and IsMyHealthLow() and Target and (ZNAREADY or WGTREADY) then CastSpell((wgtSlot or znaSlot)) end
	if Menu.misc.aHP and NeedHP() and not (UsingHPot or UsingFlask) and (HPREADY or FSKREADY) then CastSpell((hpSlot or fskSlot)) end
	if Menu.misc.AutoLevelSkills then autoLevelSetSequence(levelSequence) end
end
--[/Plugin OnTick]--

--[Farm Function]--
function Farm()
	for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
		local qDmg = getDmg("Q",minion,myHero)
        local wDmg = getDmg("W",minion,myHero)
		local eDmg = getDmg("E",minion,myHero)
		if ValidTarget(minion) then
			if Menu.farming.qFarm and QREADY and GetDistance(minion) <= qRange then
				if qDmg >= minion.health then CastSpell(_Q, minion) end
			end
			if Menu.farming.wFarm and WREADY and GetDistance(minion) <= wRange then
				if wDmg >= minion.health then CastSpell(_W) end
			end
			if Menu.farming.eFarm and EREADY and GetDistance(minion) <= eRange then
				if eDmg >= minion.health then CastSpell(_E, minion) end
			end
		end									
		break			
	end
end
--[/Farm Function]--

-- Jungle Farming --
function JungleClear()
	if IsSACReborn then
		JungleMob = AutoCarry.Jungle:GetAttackableMonster()
	else
		JungleMob = AutoCarry.GetMinionTarget()
	end
	if JungleMob ~= nil then
		if Menu.jungle.JungleQ and GetDistance(JungleMob) <= qRange then CastSpell(_Q, JungleMob) end
		if Menu.jungle.JungleW and GetDistance(JungleMob) <= wRange then CastSpell(_W) end
		if Menu.jungle.JungleE and GetDistance(JungleMob) <= eRange then CastSpell(_E, JungleMob) end
	end
end

function LaneClear()
	for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
		if Carry.LaneClear and ValidTarget(minion) then
			if QREADY and GetDistance(minion) <= qRange then CastSpell(_Q, minion) end
			if WREADY and GetDistance(minion) <= wRange then CastSpell(_W) end
			if EREADY and GetDistance(minion) <= eRange then CastSpell(_E, minion) end
		end
	end
end

-- Harrass Function --
function Harrass()
	if Menu.harrass.mTmH then myHero:MoveTo(mousePos.x, mousePos.z) end
	if Target ~= nil then
		if Menu.harrass.hMode == 1 then
			if GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
			if GetDistance(Target) <= eRange then CastSpell(_E, Target) end
			if GetDistance(Target) <= wRange then CastSpell(_W, Target) end
		end
		if Menu.harrass.hMode == 2 then
			if GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
			if GetDistance(Target) <= wRange then CastSpell(_W, Target) end
		end
	end
end
----------- END OF HARRASS FUNCTION ------------

--[Burst Combo Function]--
function bCombo()
	if Menu.autocarry.bItems then
		if DFGREADY then CastSpell(dfgSlot, Target) end
		if HXGREADY then CastSpell(hxgSlot, Target) end
		if BWCREADY then CastSpell(bwcSlot, Target) end
		if BRKREADY then CastSpell(brkSlot, Target) end
	end
	if GetDistance(Target) <= qRange and QREADY then CastSpell(_Q, Target) end
	if GetDistance(Target) <= eRange and EREADY then CastSpell(_E, Target) end
	if GetDistance(Target) <= wRange and WREADY then CastSpell(_W) end
	if not ultActive and not QREADY and not EREADY and RREADY and GetDistance(Target) <= rRange then
		CastSpell(_R) 
		timeult = GetTickCount()+250
	end
end
--[/Burst Combo Function]--

-- Ward Jumping for bosses --
function WardJump()
	myHero:MoveTo(mousePos.x, mousePos.z)
	if EREADY then
		if next(Wards) ~= nil then
			for i, obj in pairs(Wards) do 
				if obj.valid then
					if GetDistance(obj) <= eRange then
						CastSpell(_E, obj)
					else
						if RSTREADY then CastSpell(rstSlot, mousePos.x, mousePos.z) end
						if SSREADY then CastSpell(ssSlot, mousePos.x, mousePos.z) end
						if SWREADY and not SSREADY then CastSpell(swSlot, mousePos.x, mousePos.z) end
						if VWREADY and not SWREADY then CastSpell(vwSlot, mousePos.x, mousePos.z) end
					end
				end
			end
		else
			if RSTREADY then CastSpell(rstSlot, mousePos.x, mousePos.z) end
			if SSREADY then CastSpell(ssSlot, mousePos.x, mousePos.z) end
			if SWREADY and not SSREADY then CastSpell(swSlot, mousePos.x, mousePos.z) end
			if VWREADY and not SWREADY then CastSpell(vwSlot, mousePos.x, mousePos.z) end
		end
	end
end
--- END OF WARD JUMPING FUR BOSSES --

-- Auto Ignite Function --
function AutoIgnite()
	if not enemy then enemy = Target end
	if enemy.health <= iDmg and GetDistance(enemy) <= 600 then
		if IREADY then CastSpell(ignite, enemy) end
	end
end

-- KillSteal Function --
function KillSteal()
	 for i=1, heroManager.iCount do
	 local enemy = heroManager:GetHero(i)
		if ValidTarget(enemy) then
			dfgDmg, hxgDmg, bwcDmg, iDmg  = 0, 0, 0, 0
			qDmg = getDmg("Q",enemy,myHero)
            wDmg = getDmg("W",enemy,myHero)
			eDmg = getDmg("E",enemy,myHero)
            rDmg = getDmg("R",enemy,myHero)*9
			if DFGREADY then dfgDmg = (dfgSlot and getDmg("DFG",enemy,myHero) or 0)	end
            if HXGREADY then hxgDmg = (hxgSlot and getDmg("HXG",enemy,myHero) or 0) end
            if BWCREADY then bwcDmg = (bwcSlot and getDmg("BWC",enemy,myHero) or 0) end
            if IREADY then iDmg = (ignite and getDmg("IGNITE",enemy,myHero) or 0) end
            onspellDmg = (liandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(blackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
            itemsDmg = dfgDmg + hxgDmg + bwcDmg + iDmg + onspellDmg
			------- DEBUG --------
			--if Menu.debug then PrintChat("Total Items Dmg: "..itemsDmg.." Target: "..enemy.name) end
			--if Menu.debug then PrintChat("rDmg"..rDmg) end	
			------- DEBUG --------
			if Menu.killsteal.KillSteal then
				if not Menu.killsteal.KSItems then
					DFGREADY = false
					HXGREADY = false
					BWCREADY = false
					BRKREADY = false
				end
				if enemy.health <= (qDmg) and GetDistance(enemy) <= qRange and QREADY then
					if QREADY then CastSpell(_Q, enemy) end
				end
				if enemy.health <= (wDmg) and GetDistance(enemy) <= wRange and WREADY then
					if WREADY then CastSpell(_W, enemy) end
				end
				if enemy.health <= (eDmg) and GetDistance(enemy) <= eRange and EREADY then
					if EREADY then CastSpell(_E, enemy) end
				end
				if enemy.health <= (qDmg + wDmg) and GetDistance(enemy) <= wRange and WREADY and QREADY then
					if QREADY then CastSpell(_Q, enemy) end
					if WREADY then CastSpell(_W, enemy) end
				end
				if enemy.health <= (qDmg + eDmg) and GetDistance(enemy) <= eRange and QREADY and EREADY then
					if QREADY then CastSpell(_Q, enemy) end
					if EREADY then CastSpell(_E, enemy) end
				end
				if enemy.health <= (wDmg + eDmg) and GetDistance(enemy) <= wRange and WREADY and EREADY then
					if EREADY then CastSpell(_E, enemy) end
					if WREADY then CastSpell(_W, enemy) end
				end
				if enemy.health <= (qDmg + eDmg + wDmg) and GetDistance(enemy) <= eRange and EREADY and QREADY and WREADY then
					if QREADY then CastSpell(_Q, enemy) end
					if EREADY then CastSpell(_E, enemy) end
					if WREADY then CastSpell(_W, enemy) end
				end
				if enemy.health <= (qDmg + itemsDmg) and GetDistance(enemy) <= qRange and QREADY then
					if DFGREADY then CastSpell(dfgSlot, enemy) end
					if HXGREADY then CastSpell(hxgSlot, enemy) end
					if BWCREADY then CastSpell(bwcSlot, enemy) end
					if BRKREADY then CastSpell(brkSlot, enemy) end
					if QREADY then CastSpell(_Q, enemy) end
				end
				if enemy.health <= (wDmg + itemsDmg) and GetDistance(enemy) <= wRange and WREADY then
					if DFGREADY then CastSpell(dfgSlot, enemy) end
					if HXGREADY then CastSpell(hxgSlot, enemy) end
					if BWCREADY then CastSpell(bwcSlot, enemy) end
					if BRKREADY then CastSpell(brkSlot, enemy) end
					if WREADY then CastSpell(_W, enemy) end
				end
				if enemy.health <= (eDmg + itemsDmg) and GetDistance(enemy) <= eRange and EREADY then
					if DFGREADY then CastSpell(dfgSlot, enemy) end
					if HXGREADY then CastSpell(hxgSlot, enemy) end
					if BWCREADY then CastSpell(bwcSlot, enemy) end
					if BRKREADY then CastSpell(brkSlot, enemy) end
					if EREADY then CastSpell(_E, enemy) end
				end
				if enemy.health <= (qDmg + wDmg + itemsDmg) and GetDistance(enemy) <= wRange
					and WREADY and QREADY then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if WREADY and GetDistance(enemy) <= wRange then CastSpell(_W, enemy) end
						if QREADY then CastSpell(_Q, enemy) end
				end
				if enemy.health <= (qDmg + eDmg + itemsDmg) and GetDistance(enemy) <= qRange
					and EREADY and QREADY then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if QREADY then CastSpell(_Q, enemy) end
						if EREADY then CastSpell(_E, enemy) end
				end
				if enemy.health <= (wDmg + eDmg + itemsDmg) and GetDistance(enemy) <= eRange
					and EREADY and WREADY then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if ROREADY and GetDistance(enemy) <= 500 then CastSpell(roSlot) end
						if WREADY and GetDistance(enemy) <= wRange then CastSpell(_W, enemy) end
						if EREADY then CastSpell(_E, enemy) end
				end
				if enemy.health <= (qDmg + eDmg + wDmg + itemsDmg) and GetDistance(enemy) <= eRange
					and QREADY and EREADY and WREADY then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if QREADY then CastSpell(_Q, enemy) end
						if EREADY then CastSpell(_E, enemy) end
						if WREADY and GetDistance(enemy) <= wRange then CastSpell(_W, enemy) end
				end
				if enemy.health <= (qDmg + eDmg + wDmg + rDmg + itemsDmg) and GetDistance(enemy) <= qRange
					and QREADY and EREADY and WREADY and not ultActive and RREADY and enemy.health > (qDmg + eDmg + wDmg) then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if QREADY then CastSpell(_Q, enemy) end
						if EREADY then CastSpell(_E, enemy) end
						if WREADY and GetDistance(enemy) <= wRange then CastSpell(_W, enemy) end
						if RREADY and not QREADY and not EREADY then 
							CastSpell(_R)
							timeult = GetTickCount()+250 
						end
				end
				if enemy.health <= (rDmg + itemsDmg) and GetDistance(enemy) <= rRange
					and not QREADY and not EREADY and RREADY and not ultActive then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if RREADY then 
							CastSpell(_R)
							timeult = GetTickCount()+250
						end
				end
				if enemy.health <= iDmg and GetDistance(enemy) <= 600 then
					if IREADY then CastSpell(ignite, enemy) end
				end
			end
			KillText[i] = 1 
			if enemy.health <= (qDmg + eDmg + wDmg + itemsDmg) then
			KillText[i] = 2
			end
			if enemy.health <= (qDmg + eDmg + wDmg + rDmg + itemsDmg) and enemy.health >= (qDmg + eDmg + wDmg + itemsDmg) then
			KillText[i] = 3
			end
		end
	end
end
------------- END OF KILLSTEAL FUNCTION -------------------

-- Animation & Channeling Functions --
function PluginOnAnimation(unit, animationName)
    if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
end

function isChanneling(animationName)
    if lastAnimation == animationName then
        return true
    else
        return false
    end
end

function KatarinaChanneling()
	ultActive = false
	if GetTickCount() <= timeult then ultActive = true end
	if isChanneling("Spell4") then
		if IsSACReborn then
			AutoCarry.MyHero:MovementEnabled(false)
			AutoCarry.MyHero:AttacksEnabled(false)
			RREADY = false
        else
			AutoCarry.CanAttack = false
			AutoCarry.CanMove = false
			RREADY = false
		end
	else
		if IsSACReborn then
			AutoCarry.MyHero:MovementEnabled(true)
			AutoCarry.MyHero:AttacksEnabled(true)
        else
			AutoCarry.CanAttack = true
			AutoCarry.CanMove = true
		end
	end
end

------------- END OF ANIMATION & CHANELING ------------------

-- Packet Send thanks for the idea pqmailer <3 --
function PluginOnSendPacket(p)
	if isChanneling("Spell4") then
		if Target ~= nil and GetDistance(Target) <= rRange then
			local packet = Packet(p)
			if packet:get('name') == 'S_MOVE' then
				if packet:get('sourceNetworkId') == myHero.networkID then
					packet:block()
				end
			end
		end
	end
end
--------- END OF PACKET SEND ---------------------

-- Low Health for Auto Pots & Zhonyas --
function IsMyHealthLow()
	if myHero.health < (myHero.maxHealth * ( Menu.misc.ZWHealth / 100)) then
		return true
	else
		return false
	end
end

function NeedHP()
	if myHero.health < (myHero.maxHealth * ( Menu.misc.HPHealth / 100)) then
		return true
	else
		return false
	end
end
------------ END OF LOW HEATH FOR AUTOPOTS & ZHONYAS ----------------

-- Object Handling Functions --
function PluginOnCreateObj(obj)
	if obj ~= nil then
		if (obj.name:find("katarina_deathLotus_mis.troy") or obj.name:find("katarina_deathLotus_tar.troy")) then
			if GetDistance(obj, myHero) <= 70 then
				timeult = GetTickCount()+250
			end
		end
		if (obj.name:find("katarina_deathlotus_success.troy") or obj.name:find("Katarina_deathLotus_empty.troy")) then
			if GetDistance(obj, myHero) <= 70 then
				timeult = 0
			end
		end
		if obj.name:find("Global_Item_HealthPotion.troy") then
			if GetDistance(obj, myHero) <= 70 then
				UsingHPot = true
				UsingFlask = true
			end
		end
		if obj.name:find("Global_Item_ManaPotion.troy") then
			if GetDistance(obj, myHero) <= 70 then
				UsingFlask = true
				UsingMPot = true
			end
		end
		if obj.name:find("SightWard") or obj.name:find("VisionWard") then
			if GetDistance(obj, myHero) <= eRange then
				table.insert(Wards, obj)
			end
		end
	end
end

function PluginOnDeleteObj(obj)
	if obj.name:find("TeleportHome.troy") then
		Recall = false
	end
	if obj.name:find("Global_Item_HealthPotion.troy") then
		UsingHPot = false
		UsingFlask = false
	end
	if obj.name:find("Global_Item_ManaPotion.troy") then
		UsingMPot = false
		UsingFlask = false
	end
end
------------ END OF OBJECT HANDLING FUNCTIONS -----------------

-- FPS Improvement Function by Kain <3 --
function IsTickReady(tickFrequency)
	-- Improves FPS
	if tick ~= nil and math.fmod(tick, tickFrequency) == 0 then
		return true
	else
		return false
	end
end
----------- END OF FPS IMPROVEMENT FUNCTION ----------


--[Plugin OnDraw]--
function PluginOnDraw()
	--> Ranges
	if not Menu.drawing.mDraw and not myHero.dead then
		if QREADY and Menu.drawing.qDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0xB20000)
		end
		if WREADY and Menu.drawing.wDraw then
			DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x20B2AA)
		end
		if EREADY and Menu.drawing.eDraw then
			DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x800080)
		end
	end
	if Menu.drawing.cDraw then
		for i=1, heroManager.iCount do
			local Unit = heroManager:GetHero(i)
			if ValidTarget(Unit) then
				if waittxt[i] == 1 and (KillText[i] ~= nil or 0 or 1) then
					PrintFloatText(Unit, 0, TextList[KillText[i]])
				end
			end
			if waittxt[i] == 1 then
				waittxt[i] = 30
			else
				waittxt[i] = waittxt[i]-1
			end
		end
	end
end
--[/Plugin OnDraw]--


-- Variables --
function Variables()
	qRange, wRange, eRange, rRange = 675, 375, 700, 550
	QREADY, WREADY, EREADY, RREADY = false, false, false, false
	HPREADY, MPREADY, FSKREADY = false, false, false
	RSTREADY, SSREADY, SWREADY, VWREADY = false, false, false
	Carry = AutoCarry.MainMenu
	lastAnimation = nil
	tick = nil
	levelSequence = { 1,3,2,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3 }
	TextList = {"Harass him!!", "Q+W+E KILL!!", "FULL COMBO KILL!"}
	KillText = {}
	Wards = {}
	waittxt = {} -- prevents UI lags, all credits to Dekaron
	UsingHPot = false
	ultActive = false
	timeult = 0
	for i=1, heroManager.iCount do waittxt[i] = i*3 end
	if AutoCarry.Skills then IsSACReborn = true else IsSACReborn = false end
end
------------------ END OF VARIABLES --------------------

-- Katarina Main Menu --
function KatarinaMenu()
	Menu = AutoCarry.PluginMenu
	
	Menu:addSubMenu("["..myHero.charName.." Auto Carry: Auto Carry]", "autocarry")
		Menu.autocarry:addParam("bCombo", "Burst With AutoCarry", SCRIPT_PARAM_ONOFF, true)
		Menu.autocarry:addParam("bItems", "Use Items with Burst", SCRIPT_PARAM_ONOFF, true)
	
	Menu:addSubMenu("["..myHero.charName.." Auto Carry: Harass]", "harrass")
		Menu.harrass:addParam("hMode", "Harass Mode",SCRIPT_PARAM_SLICE, 1, 1, 2, 0)
		Menu.harrass:addParam("hHK", "Harass Hotkey", SCRIPT_PARAM_ONKEYDOWN, false, 84)
		Menu.harrass:addParam("wHarrass", "Always Sinister Steel (W)", SCRIPT_PARAM_ONOFF, true)
		Menu.harrass:addParam("mTmH", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
		
	
	Menu:addSubMenu("["..myHero.charName.." Auto Carry: Farming]", "farming")
		Menu.farming:addParam("mFarm", "Disable Farming", SCRIPT_PARAM_ONKEYTOGGLE, false, 67)
		Menu.farming:addParam("qFarm", "Farm with Bouncing Blades (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.farming:addParam("wFarm", "Sinister Steel (W)", SCRIPT_PARAM_ONOFF, true)
		Menu.farming:addParam("eFarm", "Farm with Shunpo (E)", SCRIPT_PARAM_ONOFF, false)
		
		
	Menu:addSubMenu("["..myHero.charName.." Auto Carry: Lane Clear]", "jungle")
		Menu.jungle:addParam("JungleFarm", "Use Skills to Farm Jungle", SCRIPT_PARAM_ONOFF, true)
		Menu.jungle:addParam("ClearLane", "Use Skills to Clear Lane", SCRIPT_PARAM_ONOFF, true)
		Menu.jungle:addParam("JungleQ", "Farm with Bouncing Blades (Q)", SCRIPT_PARAM_ONOFF, true)
		Menu.jungle:addParam("JungleW", "Sinister Steel (W)", SCRIPT_PARAM_ONOFF, true)
		
		
	Menu:addSubMenu("["..myHero.charName.." Auto Carry: Kill Steal]", "killsteal")
		Menu.killsteal:addParam("KillSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
		Menu.killsteal:addParam("Ignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
		Menu.killsteal:addParam("KSItems", "Use Items with Auto KS", SCRIPT_PARAM_ONOFF, true)
			
	Menu:addSubMenu("["..myHero.charName.." Auto Carry: Drawing]", "drawing")	
		Menu.drawing:addParam("mDraw", "Disable All Ranges Drawing", SCRIPT_PARAM_ONOFF, false)
		Menu.drawing:addParam("cDraw", "Draw Enemy Text", SCRIPT_PARAM_ONOFF, true)
		Menu.drawing:addParam("qDraw", "Draw Bouncing Blades (Q) Range", SCRIPT_PARAM_ONOFF, true)
		Menu.drawing:addParam("wDraw", "Draw Sinister Steel (W) Range", SCRIPT_PARAM_ONOFF, true)
		Menu.drawing:addParam("eDraw", "Draw Shunpo (E) Range", SCRIPT_PARAM_ONOFF, true)
	
	Menu:addSubMenu("["..myHero.charName.." Auto Carry: Misc]", "misc")
		Menu.misc:addParam("WardJump", "Ward Jump Hotkey", SCRIPT_PARAM_ONKEYDOWN, false, 71)
		Menu.misc:addParam("ZWItems", "Auto Zhonyas/Wooglets", SCRIPT_PARAM_ONOFF, true)
		Menu.misc:addParam("ZWHealth", "Min Health % for Zhonyas/Wooglets", SCRIPT_PARAM_SLICE, 15, 0, 100, -1)
		Menu.misc:addParam("aHP", "Auto Health Pots", SCRIPT_PARAM_ONOFF, true)
		Menu.misc:addParam("HPHealth", "Min % for Health Pots", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
		Menu.misc:addParam("AutoLevelSkills", "Auto Level Skills (Requires Reload)", SCRIPT_PARAM_ONOFF, true)
end
------------- END OF KATARINA MENU ------------------------

--[Cooldown Checks]--
function Checks()
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		ignite = SUMMONER_2
	end
	if IsSACReborn then
		Target = AutoCarry.Crosshair:GetTarget(true)
	else 
		Target = AutoCarry.GetAttackTarget(true) 
	end
	
	-- Slots for Items / Pots / Wards --
	rstSlot, ssSlot, swSlot, vwSlot =    GetInventorySlotItem(2045),
									     GetInventorySlotItem(2049),
									     GetInventorySlotItem(2044),
									     GetInventorySlotItem(2043)
	dfgSlot, hxgSlot, bwcSlot, brkSlot = GetInventorySlotItem(3128),
										 GetInventorySlotItem(3146),
										 GetInventorySlotItem(3144),
										 GetInventorySlotItem(3153)
	hpSlot, mpSlot, fskSlot =            GetInventorySlotItem(2003),
							             GetInventorySlotItem(2004),
							             GetInventorySlotItem(2041)
	znaSlot, wgtSlot =                   GetInventorySlotItem(3157),
	                                     GetInventorySlotItem(3090)
	-- Spells --									 
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	
	-- Items --
	DFGREADY = (dfgSlot ~= nil and myHero:CanUseSpell(dfgSlot) == READY)
	HXGREADY = (hxgSlot ~= nil and myHero:CanUseSpell(hxgSlot) == READY)
	BWCREADY = (bwcSlot ~= nil and myHero:CanUseSpell(bwcSlot) == READY)
	BRKREADY = (brkSlot ~= nil and myHero:CanUseSpell(brkSlot) == READY)
	ZNAREADY = (znaSlot ~= nil and myHero:CanUseSpell(znaSlot) == READY)
	WGTREADY = (wgtSlot ~= nil and myHero:CanUseSpell(wgtSlot) == READY)
	
	-- Pots --
	HPREADY = (hpSlot ~= nil and myHero:CanUseSpell(hpSlot) == READY)
	MPREADY =(mpSlot ~= nil and myHero:CanUseSpell(mpSlot) == READY)
	FSKREADY = (fskSlot ~= nil and myHero:CanUseSpell(fskSlot) == READY)
	
	-- Wards --
	RSTREADY = (rstSlot ~= nil and myHero:CanUseSpell(rstSlot) == READY)
	SSREADY = (ssSlot ~= nil and myHero:CanUseSpell(ssSlot) == READY)
	SWREADY = (swSlot ~= nil and myHero:CanUseSpell(swSlot) == READY)
	VWREADY = (vwSlot ~= nil and myHero:CanUseSpell(vwSlot) == READY)
end
--[/Cooldown Checks]--