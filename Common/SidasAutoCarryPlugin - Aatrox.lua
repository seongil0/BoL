--[[
	AutoCarry Plugin - Aatrox the Darkin Blade
		With Code From Kain <3

	Changelog :
   1.0 - Initial Release
 ]] --

if myHero.charName ~= "Aatrox" then return end

--[Function When Plugin Loads]--
function PluginOnLoad()
	mainLoad() -- Loads our Variable Function
	mainMenu() -- Loads our Menu function
end

--[OnTick]--
function PluginOnTick()
	if Recall then return end
	if IsSACReborn then
		AutoCarry.Crosshair:SetSkillCrosshairRange(1000)
	else
		AutoCarry.SkillsCrosshair.range = 1000
	end
	Checks()
	SmartKS()
	wCheck()
	
	if Carry.AutoCarry and Target ~= nil then FullCombo() end
	if Carry.MixedMode and Target ~= nil then 
		if Menu.eHarass and GetDistance(Target) <= eRange then CastE(Target) end
	end
	if Menu.qRun then QToMouse() end
	if Carry.LaneClear then JungleClear() end
	
	if Extras.aHP and NeedHP() and not (UsingHPot or UsingFlask) and (HPREADY or FSKREADY) then CastSpell((hpSlot or fskSlot)) end
end

--[Drawing our Range/Killable Enemies]--
function PluginOnDraw()
	if not myHero.dead then
		if QREADY and Menu.qDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x191970)
		end
		if Menu.cDraw then
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
end

--[Casting our Q into Enemies]--
function CastQ(enemy)
	if not enemy and Target ~= nil then enemy = Target end
    if QREADY then 
        if IsSACReborn then
            SkillQ:ForceCast(Target)
        else
			AutoCarry.CastSkillshot(SkillQ, Target)
        end
    end
end

--[Casting our E into Enemies]--
function CastE(enemy)
	if not enemy and Target ~= nil then enemy = Target end
    if EREADY then 
        if IsSACReborn then
            SkillE:ForceCast(enemy)
        else
			AutoCarry.CastSkillshot(SkillE, enemy)
        end
    end
end


function QToMouse()
	if QREADY then
	MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)
	CastSpell(_Q, MousePos.x, MousePos.z)
	end
end

--[Object Detection]--
function PluginOnCreateObj(obj)
	if obj.name:find("TeleportHome.troy") then
		if GetDistance(obj, myHero) <= 70 then
			Recall = true
		end
	end
	if obj.name:find("Global_Item_HealthPotion.troy") then
		if GetDistance(obj, myHero) <= 70 then
			UsingHPot = true
			UsingFlask = true
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
end

--[Health Pots Function]--
function NeedHP()
	if myHero.health < (myHero.maxHealth * ( Extras.HPHealth / 100)) then
		return true
	else
		return false
	end
end

--[Smart KS Function]--
function SmartKS()
	 for i=1, heroManager.iCount do
	 local enemy = heroManager:GetHero(i)
		if ValidTarget(enemy) then
			dfgDmg, hxgDmg, bwcDmg, iDmg  = 0, 0, 0, 0
			qDmg = getDmg("Q",enemy,myHero)
            eDmg = getDmg("E",enemy,myHero)
			rDmg = getDmg("R",enemy,myHero)
			if DFGREADY then dfgDmg = (dfgSlot and getDmg("DFG",enemy,myHero) or 0)	end
            if HXGREADY then hxgDmg = (hxgSlot and getDmg("HXG",enemy,myHero) or 0) end
            if BWCREADY then bwcDmg = (bwcSlot and getDmg("BWC",enemy,myHero) or 0) end
            if IREADY then iDmg = (ignite and getDmg("IGNITE",enemy,myHero) or 0) end
            onspellDmg = (liandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(blackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
            itemsDmg = dfgDmg + hxgDmg + bwcDmg + iDmg + onspellDmg
			if Menu.sKS then
				if enemy.health <= (qDmg) and GetDistance(enemy) <= qRange and QREADY then
					if QREADY then CastQ(enemy) end
				
				elseif enemy.health <= (eDmg) and GetDistance(enemy) <= eRange and EREADY then
					if EREADY then CastE(enemy) end
				
				elseif enemy.health <= (qDmg + eDmg) and GetDistance(enemy) <= qRange and EREADY and QREADY then
					if EREADY then CastE(enemy) end
					if QREADY then CastQ(enemy) end
									
				elseif enemy.health <= (qDmg + itemsDmg) and GetDistance(enemy) <= qRange and QREADY then
					if DFGREADY then CastSpell(dfgSlot, enemy) end
					if HXGREADY then CastSpell(hxgSlot, enemy) end
					if BWCREADY then CastSpell(bwcSlot, enemy) end
					if BRKREADY then CastSpell(brkSlot, enemy) end
					if QREADY then CastQ(enemy) end
				
				elseif enemy.health <= (eDmg + itemsDmg) and GetDistance(enemy) <= eRange and EREADY then
					if DFGREADY then CastSpell(dfgSlot, enemy) end
					if HXGREADY then CastSpell(hxgSlot, enemy) end
					if BWCREADY then CastSpell(bwcSlot, enemy) end
					if BRKREADY then CastSpell(brkSlot, enemy) end
					if EREADY then CastE(enemy) end
				
				elseif enemy.health <= (qDmg + eDmg + itemsDmg) and GetDistance(enemy) <= qRange
					and EREADY and QREADY then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if EREADY then CastE(enemy) end
						if QREADY then CastQ(enemy) end
				
				end
								
				if enemy.health <= iDmg and GetDistance(enemy) <= 600 then
					if IREADY then CastSpell(ignite, enemy) end
				end
			end
			KillText[i] = 1 
			if enemy.health <= (qDmg + eDmg + itemsDmg) and QREADY and EREADY then
			KillText[i] = 2
			end
		end
	end
end

function wActive()
	if myHero:GetSpellData(_W).name == "aatroxw2" then
		return true
	else
		return fase
	end
end

function wCheck()
	if wActive() and WREADY and myHero.health < (myHero.maxHealth * ( Menu.wMinHealth / 100)) then
		CastSpell(_W)
	end
end

--[Full Combo with Items]--
function FullCombo()
	if Target ~= nil then
		if AutoCarry.MainMenu.AutoCarry then
			if Menu.useW then
				if not wActive() and WREADY and myHero.health > (myHero.maxHealth * ( Menu.wMinHealth / 100)) then
					CastSpell(_W)
				end
				if wActive() and WREADY and myHero.health < (myHero.maxHealth * ( Menu.wMinHealth / 100)) then
					CastSpell(_W)
				end
			end
			if Menu.useR then
				if RREADY and GetDistance(Target) <= rRange and Target.health  < (myHero.maxHealth * ( Menu.rMinHealth / 100)) then
					CastSpell(_R)
				end
			end
			if Menu.useE and GetDistance(Target) <= eRange then CastE() end
			if Menu.useQ and GetDistance(Target) <= qRange then CastQ() end
		end
	end
end

function JungleClear()
	if IsSACReborn then
		JungleMob = AutoCarry.Jungle:GetAttackableMonster()
	else
		JungleMob = AutoCarry.GetMinionTarget()
	end
	if JungleMob then
		if Extras.JungleE and GetDistance(JungleMob) <= eRange then CastE(JungleMob) end
		if Extras.JungleQ and GetDistance(JungleMob) <= qRange then CastQ(JungleMob) end
	end
end

--[Variables Load]--
function mainLoad()
	if AutoCarry.Skills then IsSACReborn = true else IsSACReborn = false end
	if IsSACReborn then AutoCarry.Skills:DisableAll() end
	Carry = AutoCarry.MainMenu
	qRange,eRange, rRange = 650, 1000, 300
	qDelay, eDelay = 270, 270
	qName, wName, eName, rName = "Dark Flight", "Blood Thirst", "Blades of Torment", "Massacre"
	qSpeed, eSpeed = 1.8, 1.2
	qWidth, eWidth = 280, 80
	QREADY, WREADY, EREADY, RREADY = false, false, false, false
	HK1, HK2, HK3 = string.byte("Z"), string.byte("K"), string.byte("G")
	Menu = AutoCarry.PluginMenu
	UsingHPot, UsingFlask = false, false
	Recall = false
	TextList = {"Harass him!!", "Q+E KILL!!"}
	KillText = {}
	waittxt = {} -- prevents UI lags, all credits to Dekaron
	for i=1, heroManager.iCount do waittxt[i] = i*3 end -- All credits to Dekaron
	if IsSACReborn then
		SkillQ = AutoCarry.Skills:NewSkill(false, _Q, qRange, qName, AutoCarry.SPELL_CIRCLE, 0, false, false, qSpeed, qDelay, qWidth, false)
		SkillE = AutoCarry.Skills:NewSkill(false, _E, eRange, eName, AutoCarry.SPELL_LINEAR, 0, false, false, eSpeed, eDelay, eWidth, false)
	else
		SkillQ = {spellKey = _Q, range = qRange, speed = qSpeed, delay = qDelay, width = qWidth, configName = qName, displayName = "Q "..qName.."", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = false }
		SkillE = {spellKey = _E, range = rRange, speed = eSpeed, delay = eDelay, width = eWidth, configName = eName, displayName = "E "..eName.."", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = false }
	end
end

--[Main Menu & Extras Menu]--
function mainMenu()
	Menu:addParam("sep1", "-- Full Combo Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useQ", "Use "..qName.." (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useW", "Use "..wName.." (W)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("wMinHealth", "Minimum Health Heal W", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
	Menu:addParam("useE", "Use "..eName.." (E)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useR", "Use "..rName.." (R)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("rMinHealth", "Minimum Enemy Health to R", SCRIPT_PARAM_SLICE, 60, 0, 100, -1)
	Menu:addParam("qRun", "Q To Mouse", SCRIPT_PARAM_ONKEYDOWN, false, HK3)
	Menu:addParam("sep2", "-- Mixed Mode Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("eHarass", "Use "..eName.." (E)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep3", "-- KS Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("sKS", "Use Smart Combo KS", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep5", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("qDraw", "Draw "..qName.." (Q)", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("cDraw", "Draw Enemy Text", SCRIPT_PARAM_ONOFF, true)
	Extras = scriptConfig("Sida's Auto Carry Plugin: "..myHero.charName..": Extras", myHero.charName)
	Extras:addParam("sep6", "-- Misc --", SCRIPT_PARAM_INFO, "")
	Extras:addParam("JungleQ", "Jungle with "..qName.." (Q)", SCRIPT_PARAM_ONOFF, true)
	Extras:addParam("JungleE", "Jungle with "..eName.." (E)", SCRIPT_PARAM_ONOFF, true)
	Extras:addParam("aHP", "Auto Health Pots", SCRIPT_PARAM_ONOFF, true)
	Extras:addParam("HPHealth", "Min % for Health Pots", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
end

--[Certain Checks]--
function Checks()
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then ignite = SUMMONER_2 end
	if IsSACReborn then Target = AutoCarry.Crosshair:GetTarget() else Target = AutoCarry.GetAttackTarget() end
	dfgSlot, hxgSlot, bwcSlot = GetInventorySlotItem(3128), GetInventorySlotItem(3146), GetInventorySlotItem(3144)
	brkSlot = GetInventorySlotItem(3092),GetInventorySlotItem(3143),GetInventorySlotItem(3153)
	hpSlot, mpSlot, fskSlot = GetInventorySlotItem(2003),GetInventorySlotItem(2004),GetInventorySlotItem(2041)
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
	DFGREADY = (dfgSlot ~= nil and myHero:CanUseSpell(dfgSlot) == READY)
	HXGREADY = (hxgSlot ~= nil and myHero:CanUseSpell(hxgSlot) == READY)
	BWCREADY = (bwcSlot ~= nil and myHero:CanUseSpell(bwcSlot) == READY)
	BRKREADY = (brkSlot ~= nil and myHero:CanUseSpell(brkSlot) == READY)
	IREADY = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
	HPREADY = (hpSlot ~= nil and myHero:CanUseSpell(hpSlot) == READY)
	FSKREADY = (fskSlot ~= nil and myHero:CanUseSpell(fskSlot) == READY)
end