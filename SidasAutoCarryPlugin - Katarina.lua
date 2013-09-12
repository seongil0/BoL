--[AutoCarry Script - Katarina by Skeem]--
-- Hero Name Check
if myHero.charName ~= "Katarina" then return end

--[Plugin OnLoad]--
function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = 675
	--> Main Load	
	mainLoad()
	--> Main Menu
	mainMenu()
end
--[/Plugin OnLoad]--

--[Plugin OnTick]--
function PluginOnTick()
	if isChanneling() then
		AutoCarry.CanAttack = false
		AutoCarry.CanMove = false
	else
		AutoCarry.CanAttack = true
		AutoCarry.CanMove = true
	end
	Checks()
	smartKS()
	if Menu.hHK then Harrass() end
	if Menu.bCombo and Carry.AutoCarry then bCombo() end
	if not Menu.mFarm and not Carry.AutoCarry then Farm() end
	if Menu.wHarrass and Target and GetDistance(Target) <= wRange then
		CastSpell(_W)
	end
end
--[/Plugin OnTick]--

--[Farm Function]--
function Farm()
	for _, minion in pairs(AutoCarry.EnemyMinions().objects) do
		if ValidTarget(minion) then
			if Menu.qFarm and QREADY and GetDistance(minion) <= qRange then
				if minion.health <= getDmg("Q", minion, myHero) then CastSpell(_Q, minion) end
			end
			if Menu.wFarm and WREADY and GetDistance(minion) <= wRange then
				if minion.health < getDmg("W", minion, myHero) then CastSpell(_W, minion) end
			end
			if Menu.eFarm and EREADY and GetDistance(minion) <= eRange then
				if minion.health <= getDmg("E", minion, myHero) then CastSpell(_E, minion) end
			end
		end
	end
end
--[/Farm Function]--

--[Harrass Function]--
function Harrass()
	if Target and Menu.hHK then
		if Menu.hMode == 1 then
			if GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
			if GetDistance(Target) <= eRange then CastSpell(_E, Target) end
			if GetDistance(Target) <= wRange then CastSpell(_W, Target) end
		end
		if Menu.hMode == 2 then
			if GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
			if GetDistance(Target) <= wRange then CastSpell(_W, Target) end
		end
	end
end
--[/Harrass Function]--

--[Burst Combo Function]--
function bCombo()
	if Target then
		if DFGREADY then CastSpell(dfgSlot, enemy) end
		if HXGREADY then CastSpell(hxgSlot, enemy) end
		if BWCREADY then CastSpell(bwcSlot, enemy) end
		if BRKREADY then CastSpell(brkSlot, enemy) end
		if ROREADY and GetDistance(enemy) <= 500 then CastSpell(roSlot) end
		if GetDistance(Target) <= qRange then CastSpell(_Q, Target) end
		if GetDistance(Target) <= eRange then CastSpell(_E, Target) end
		if GetDistance(Target) <= wRange then CastSpell(_W, Target) end
		if GetDistance(Target) <= rRange then CastSpell(_R, Target) end
	end
end
--[/Burst Combo Function]--

--[Smart KS Function]--
function smartKS()
	 for i=1, heroManager.iCount do
	 local enemy = heroManager:GetHero(i)
		if ValidTarget(enemy) then
			dfgDmg, hxgDmg, bwcDmg, iDmg, sheenDmg, triDmg, lichDmg  = 0, 0, 0, 0, 0, 0, 0
			qDmg = getDmg("Q",enemy,myHero)
            wDmg = getDmg("W",enemy,myHero)
			eDmg = getDmg("E",enemy,myHero)
            rDmg = getDmg("R",enemy,myHero)
			dfgDmg = (dfgSlot and getDmg("DFG",enemy,myHero) or 0)
            hxgDmg = (hxgSlot and getDmg("HXG",enemy,myHero) or 0)
            bwcDmg = (bwcSlot and getDmg("BWC",enemy,myHero) or 0)
            iDmg = (ignite and getDmg("IGNITE",enemy,myHero) or 0)
            onhitDmg = (sheenSlot and getDmg("SHEEN",enemy,myHero) or 0)+(triSlot and getDmg("TRINITY",enemy,myHero) or 0)+(lichSlot and getDmg("LICHBANE",enemy,myHero) or 0)+(IcebornSlot and getDmg("ICEBORN",enemy,myHero) or 0)                                                 
            onspellDmg = (liandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(blackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
            itemsDmg = onhitDmg + qDmg + wDmg + rDmg + dfgDmg + hxgDmg + bwcDmg + iDmg + onspellDmg
			if Menu.sKS then
				if enemy.health <= (qDmg + itemsDmg) and GetDistance(enemy) <= qRange and QREADY then
					if DFGREADY then CastSpell(dfgSlot, enemy) end
					if HXGREADY then CastSpell(hxgSlot, enemy) end
					if BWCREADY then CastSpell(bwcSlot, enemy) end
					if BRKREADY then CastSpell(brkSlot, enemy) end
					if ROREADY and GetDistance(enemy) <= 500 then CastSpell(roSlot) end
					if QREADY then CastSpell(_Q, enemy) end
				end
				if enemy.health <= (wDmg + itemsDmg) and GetDistance(enemy) <= wRange and WREADY then
					if DFGREADY then CastSpell(dfgSlot, enemy) end
					if HXGREADY then CastSpell(hxgSlot, enemy) end
					if BWCREADY then CastSpell(bwcSlot, enemy) end
					if BRKREADY then CastSpell(brkSlot, enemy) end
					if ROREADY and GetDistance(enemy) <= 500 then CastSpell(roSlot) end
					if WREADY then CastSpell(_W, enemy) end
				end
				if enemy.health <= (eDmg + itemsDmg) and GetDistance(enemy) <= eRange and EREADY then
					if DFGREADY then CastSpell(dfgSlot, enemy) end
					if HXGREADY then CastSpell(hxgSlot, enemy) end
					if BWCREADY then CastSpell(bwcSlot, enemy) end
					if BRKREADY then CastSpell(brkSlot, enemy) end
					if ROREADY and GetDistance(enemy) <= 500 then CastSpell(roSlot) end
					if EREADY then CastSpell(_E, enemy) end
				end
				if enemy.health <= (qDmg + wDmg + itemsDmg) and GetDistance(enemy) <= wRange
					and WREADY and QREADY then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if ROREADY and GetDistance(enemy) <= 500 then CastSpell(roSlot) end
						if WREADY then CastSpell(_W, enemy) end
						if QREADY then CastSpell(_Q, enemy) end
				end
				if enemy.health <= (qDmg + eDmg + itemsDmg) and GetDistance(enemy) <= qRange
					and EREADY and QREADY then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if ROREADY and GetDistance(enemy) <= 500 then CastSpell(roSlot) end
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
						if WREADY then CastSpell(_W, enemy) end
						if EREADY then CastSpell(_E, enemy) end
				end
				if enemy.health <= (qDmg + eDmg + wDmg + itemsDmg) and GetDistance(enemy) <= eRange
					and QREADY and EREADY and WREADY then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if ROREADY and GetDistance(enemy) <= 500 then CastSpell(roSlot) end
						if QREADY then CastSpell(_Q, enemy) end
						if EREADY then CastSpell(_E, enemy) end
						if WREADY then CastSpell(_W, enemy) end
				end
				if enemy.health <= (qDmg + eDmg + wDmg + rDmg + itemsDmg) and GetDistance(enemy) <= qRange
					and QREADY and EREADY and WREADY and RREADY and enemy.health > (qDmg + eDmg + wDmg) then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if ROREADY and GetDistance(enemy) <= 500 then CastSpell(roSlot) end
						if QREADY then CastSpell(_Q, enemy) end
						if EREADY then CastSpell(_E, enemy) end
						if WREADY then CastSpell(_W, enemy) end
						if RREADY then CastSpell(_R, enemy) end
				end
				if enemy.health <= (rDmg + itemsDmg) and GetDistance(enemy) <= rRange
					and RREADY then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if ROREADY and GetDistance(enemy) <= 500 then CastSpell(roSlot) end
						if RREADY then CastSpell(_R) end
				end
			end
		end
	end
end
--[/Smart KS Function]--

--[Plugin OnAnimation - Credits: Λnonymous]--
function PluginOnAnimation(unit, animationName)
	if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
end
--[/Plugin OnAnimation - Credits: Λnonymous]--

--[Channeling Function - Credits: Λnonymous]--
function isChanneling()
	if lastAnimation == "Spell4" then
		return true
	else
		return false
	end
end
--[/Channeling Function]--

--[Plugin OnDraw]--
function PluginOnDraw()
	--> Ranges
	if not Menu.mDraw and not myHero.dead then
		if QREADY and Menu.qDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x191970)
		end
		if WREADY and Menu.wDraw then
			DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x20B2AA)
		end
		if EREADY and Menu.eDraw then
			DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x800080)
		end
	end
end
--[/Plugin OnDraw]--

--[Function mainLoad]--
function mainLoad()
	qRange, wRange, eRange, rRange = 675, 355, 700, 530
	QREADY, WREADY, EREADY, RREADY = false, false, false, false
	lastAnimation = "Run"
	Menu = AutoCarry.PluginMenu
	Carry = AutoCarry.MainMenu
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
end
--[/Function mainLoad]--

--[Main Menu Function]--
function mainMenu()
	Menu:addParam("sep", "-- Combo Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("bCombo", "Burst With AutoCarry", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sKS", "Use Smart KS Combos", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep1", "-- Harrass Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("hMode", "Harrass Mode",SCRIPT_PARAM_SLICE, 1, 1, 2, 0)
	Menu:addParam("hHK", "Harrass Hotkey", SCRIPT_PARAM_ONKEYDOWN, false, 84)
	Menu:addParam("wHarrass", "Always Sinister Steel (W)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep2", "-- Farm Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("mFarm", "Disable Farming", SCRIPT_PARAM_ONKEYTOGGLE, false, 671)
	Menu:addParam("qFarm", "Farm with Bouncing Blades (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("wFarm", "Sinister Steel (W)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("eFarm", "Farm with Shunpo (E)", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("sep3", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("mDraw", "Disable All Ranges Drawing", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("qDraw", "Draw Bouncing Blades (Q) Range", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("wDraw", "Draw Sinister Steel (W) Range", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("eDraw", "Draw Shunpo (E) Range", SCRIPT_PARAM_ONOFF, true)
end
--[/Main Menu Function]--

--[Cooldown Checks]--
function Checks()
	Target = AutoCarry.GetAttackTarget(true)
	dfgSlot, hxgSlot, bwcSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
	sheenSlot, trinitySlot, LBSlot = GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)
	iSlot, ltSlot, btSlot = GetInventorySlotItem(3025), GetInventorySlotItem(3151), GetInventorySlotItem(3188)
	stiSlot, roSlot, brkSlot = GetInventorySlotItem(3092),GetInventorySlotItem(3143),GetInventorySlotItem(3153)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGREADY = (dfgSlot ~= nil and myHero:CanUseSpell(dfgSlot) == READY)
	HXGREADY = (hxgSlot ~= nil and myHero:CanUseSpell(hxgSlot) == READY)
	BWCREADY = (bwcSlot ~= nil and myHero:CanUseSpell(bwcSlot) == READY)
	STIREADY = (stiSlot ~= nil and myHero:CanUseSpell(stiSlot) == READY)
	BRKREADY = (brkSlot ~= nil and myHero:CanUseSpell(brkSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end
--[/Cooldown Checks]--