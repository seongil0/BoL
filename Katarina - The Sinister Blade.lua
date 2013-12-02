--[[
	AutoCarry Script - Katarina 1.7 by Skeem
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
   1.5   - No longer AutoCarry Script
         - Requires iSAC library for orbwalking
		 - Revamped code a little
		 - Deleted ult usage from auto KS for now
   1.5.2 - Fixed Skills not casting ult
         - Fixed enemy chasing bug
		 - Added delay W to both harass & full combo with toggle in menu
   1.6   - Fixed Jungle Clear
		 - Added Toggle to Stop ult if enemies can die from other spells
		 - Fixed Ward Jump
		 - Improved Farm a bit
   1.6.1 - Added Blackfire Tourch in combo
         - Fixed ult stop when enemies can die
   1.6.2 - Fixed Blackfire torch error
   1.7   - Updated ward jump, won't use more than 1 item
         - Beta KS with wards if E not ready
		 - Beta ward save when in danger
		 - Doesn't require iSAC anymore
  	]] --		

-- Hero Name Check
if myHero.charName ~= "Katarina" then return end

-- Loading Function --
function OnLoad()
	Variables()
	KatarinaMenu()
	PrintChat("<font color='#FF0000'> >> Katarina - The Sinister Blade 1.7 Loaded!! <<</font>")
end
--[/Plugin OnLoad]--

--[Plugin OnTick]--
function OnTick()
	Checks()
	KillSteal()
	tick = GetTickCount()
	if Target ~= nil then
		if KatarinaMenu.harrass.wHarrass and GetDistance(Target) <= wRange then CastSpell(_W) end
		if KatarinaMenu.killsteal.Ignite then AutoIgnite() end
	end
	
	if KatarinaMenu.autocarry.FullCombo then FullCombo() end
	if KatarinaMenu.harrass.hHK then Harrass() end
	if not KatarinaMenu.farming.mFarm and not KatarinaMenu.autocarry.FullCombo then Farm() end
	if KatarinaMenu.jungle.ClearKey and not KatarinaMenu.autocarry.Fullcombo then
		MoveToMouse()
		LaneClear()
		JungleClear() 
	end
	
	if KatarinaMenu.misc.WardJump then
		MoveToMouse()
		local WardPos = GetDistance(mousePos) <= 600 and mousePos or getMousePos()
		wardJump(WardPos.x, WardPos.z)
	end
	if KatarinaMenu.misc.ZWItems and IsMyHealthLow() and Target and (ZNAREADY or WGTREADY) then CastSpell((wgtSlot or znaSlot)) end
	if KatarinaMenu.misc.aHP and NeedHP() and not (UsingHPot or UsingFlask) and (HPREADY or FSKREADY) then CastSpell((hpSlot or fskSlot)) end
	if KatarinaMenu.misc.AutoLevelSkills then autoLevelSetSequence(levelSequence) end
	
end
--[/Plugin OnTick]--

--[Farm Function]--
function Farm()
	for _, minion in pairs(enemyMinions.objects) do
		local qDmg = getDmg("Q",minion,myHero)
        local wDmg = getDmg("W",minion,myHero)
		local eDmg = getDmg("E",minion,myHero)
		if ValidTarget(minion) then
			if KatarinaMenu.farming.qFarm and QREADY and GetDistance(minion) <= qRange and GetDistance(minion) >= wRange then
				if qDmg >= minion.health then CastSpell(_Q, minion) end
			end
			if KatarinaMenu.farming.wFarm and WREADY and GetDistance(minion) <= wRange then
				if wDmg >= minion.health then CastSpell(_W) end
			end
			if KatarinaMenu.farming.eFarm and EREADY and GetDistance(minion) <= eRange then
				if eDmg >= minion.health then CastSpell(_E, minion) end
			end
		end									
		break			
	end
end
--[/Farm Function]--

-- Jungle Farming --
function JungleClear()
	JungleMob = GetJungleMob()
	if JungleMob ~= nil then
		if KatarinaMenu.jungle.JungleQ and GetDistance(JungleMob) <= qRange then CastSpell(_Q, JungleMob) end
		if KatarinaMenu.jungle.JungleW and GetDistance(JungleMob) <= wRange then CastSpell(_W) end
		if KatarinaMenu.jungle.JungleE and GetDistance(JungleMob) <= eRange then CastSpell(_E, JungleMob) end
		if GetDistance(JungleMob) <= AARange then myHero:Attack(JungleMob) end
	end
end

function LaneClear()
	for _, minion in pairs(enemyMinions.objects) do
		if  ValidTarget(minion) then
			if QREADY and GetDistance(minion) <= qRange then CastSpell(_Q, minion) end
			if WREADY and GetDistance(minion) <= wRange then CastSpell(_W) end
			if EREADY and GetDistance(minion) <= eRange then CastSpell(_E, minion) end
		end
	end
end

-- Harrass Function --
function Harrass()
	if KatarinaMenu.harrass.mTmH then MoveToMouse() end
	if Target ~= nil then
		if KatarinaMenu.harrass.hMode == 1 then
			if GetDistance(Target) <= qRange then CastQ(Target) end
			if GetDistance(Target) <= eRange then CastE(Target) end
			if KatarinaMenu.harrass.DelayW then
				if GetDistance(Target) <= wRange and not QREADY then CastSpell(_W) end
			else
				if GetDistance(Target) <= wRange then CastSpell(_W) end
			end
		end
		if KatarinaMenu.harrass.hMode == 2 then
			if GetDistance(Target) <= qRange then CastQ(Target) end
			if GetDistance(Target) <= wRange then CastSpell(_W) end
		end
	end
end
----------- END OF HARRASS FUNCTION ------------

--[Burst Combo Function]--
function FullCombo()
	if timeult == 0 then ultActive = false end
	if not isChanneling("Spell4") and not ultActive then
		if Target ~= nil then
			OrbWalking(Target)
		else
			moveToCursor()
		end
	end
	if Target ~= nil then
		if KatarinaMenu.autocarry.bItems then
			if DFGREADY then CastSpell(dfgSlot, Target) end
			if BFTREADY then CastSpell(bftSlot, Target) end
			if HXGREADY then CastSpell(hxgSlot, Target) end
			if BWCREADY then CastSpell(bwcSlot, Target) end
			if BRKREADY then CastSpell(brkSlot, Target) end
		end
		if GetDistance(Target) <= qRange and QREADY then CastQ(Target) end
		if GetDistance(Target) <= eRange and EREADY then CastE(Target) end
		if KatarinaMenu.autocarry.DelayW then
			if GetDistance(Target) <= wRange and not QREADY then CastSpell(_W) end
		else
			if GetDistance(Target) <= wRange then CastSpell(_W) end
		end
		if not isChanneling("Spell4") and not QREADY and not EREADY and RREADY and GetDistance(Target) <= rRange then
			CastSpell(_R) 
			timeult = GetTickCount()+250
		end
	end
end
--[/Burst Combo Function]--

-- Casting our Q into enemies --
function CastQ(enemy)
	if not enemy then
		enemy = Target
	end
	if ValidTarget(enemy) then 
		if VIP_USER then
			Packet("S_CAST", {spellId = _Q, targetNetworkId = enemy.networkID}):send()
		else
			CastSpell(_Q, enemy)
		end
	end
end

-- Casting our E into enemies --
function CastE(enemy)
	if not enemy then
		enemy = Target
	end
	if ValidTarget(enemy) then 
		if VIP_USER then
			Packet("S_CAST", {spellId = _E, targetNetworkId = enemy.networkID}):send()
		else
			CastSpell(_E, enemy)
		end
	end
end

-- by Klokje --
function getMousePos(range)
    local temprange = range or 600
    local MyPos = Vector(myHero.x, myHero.y, myHero.z)
    local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)

    return MyPos - (MyPos - MousePos):normalized() * 600
end

-- Ward Jumping for bosses --
function wardJump(x, y)
	if EREADY then
		if next(Wards) ~= nil then
			for i, obj in pairs(Wards) do 
				if obj.valid then
					if GetDistance(obj) <= eRange then
						CastSpell(_E, obj)
					else
						if GetTickCount()-lastwardused >= 2000 then
							if RSTREADY then
								CastSpell(rstSlot, x, y)
								lastwardused = GetTickCount()
							elseif SSREADY then 
								CastSpell(ssSlot, x, y)
								lastwardused = GetTickCount()
							elseif SWREADY then 
								CastSpell(swSlot, x, y)
								lastwardused = GetTickCount()
							elseif VWREADY then
								CastSpell(vwSlot, x, y)
								lastwardused = GetTickCount()
							end
						end
					end
				end
			end
		else
			if GetTickCount()-lastwardused >= 2000 then
				if RSTREADY then
					CastSpell(rstSlot, x, y)
					lastwardused = GetTickCount()
				elseif SSREADY then 
					CastSpell(ssSlot, x, y)
					lastwardused = GetTickCount()
				elseif SWREADY then 
					CastSpell(swSlot, x, y)
					lastwardused = GetTickCount()
				elseif VWREADY then
					CastSpell(vwSlot, x, y)
					lastwardused = GetTickCount()
				end
			end
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
			dfgDmg, hxgDmg, bwcDmg, iDmg,bftDmg  = 0, 0, 0, 0, 0
			qDmg, wDmg, eDmg, rDmg = 0, 0, 0, 0
			if QREADY then qDmg = getDmg("Q",enemy,myHero) end
            if WREADY then wDmg = getDmg("W",enemy,myHero) end
			if EREADY then eDmg = getDmg("E",enemy,myHero) end
            if RREADY then rDmg = getDmg("R",enemy,myHero)*8 end
			if DFGREADY then dfgDmg = (dfgSlot and getDmg("DFG",enemy,myHero) or 0)	end
			if BFTREADY then bftdmg = (bftSlot and getDmg("BFT",enemy,myHero) or 0) end
            if HXGREADY then hxgDmg = (hxgSlot and getDmg("HXG",enemy,myHero) or 0) end
            if BWCREADY then bwcDmg = (bwcSlot and getDmg("BWC",enemy,myHero) or 0) end
            if IREADY then iDmg = (ignite and getDmg("IGNITE",enemy,myHero) or 0) end
            onspellDmg = (liandrysSlot and getDmg("LIANDRYS",enemy,myHero) or 0)+(blackfireSlot and getDmg("BLACKFIRE",enemy,myHero) or 0)
            itemsDmg = dfgDmg + bftDmg + hxgDmg + bwcDmg + iDmg + onspellDmg
			------- DEBUG --------
			--if KatarinaMenu.debug then PrintChat("Total Items Dmg: "..itemsDmg.." Target: "..enemy.name) end
			--if KatarinaMenu.debug then PrintChat("rDmg"..rDmg) end	
			------- DEBUG --------
			if KatarinaMenu.misc.wardSave then
				if enemy.health > (qDmg + wDmg + eDmg + rDmg) then
					if GetDistance(enemy) < 400 and NeedHP() then
						local fountain = GetFountain()
						local mPos = Vector(myHero.x, myHero.y, myHero.z)
						local fPos = Vector(fountain.x, fountain.y, fountain.z)
						local mfPos =  mPos - (mPos - fPos):normalized() * 600
						wardJump(mfPos.x, mfPos.z)
					end
				end
			end
			if KatarinaMenu.killsteal.KillSteal then
				if not KatarinaMenu.killsteal.KSItems then
					DFGREADY = false
					HXGREADY = false
					BWCREADY = false
					BRKREADY = false
					BFTREADY = false
				end
				if enemy.health <= qDmg and GetDistance(enemy) <= qRange and QREADY then
					if QREADY then CastQ(enemy) end
				end
				if enemy.health <= (wDmg) and GetDistance(enemy) <= wRange and WREADY then
					if WREADY then CastSpell(_W) end
				end
				if enemy.health <= (eDmg) and GetDistance(enemy) <= eRange and EREADY then
					if EREADY then CastE(enemy) end
				end
				if enemy.health <= (qDmg + wDmg) and GetDistance(enemy) <= wRange and WREADY and QREADY then
					if QREADY then CastQ(enemy) end
					if WREADY then CastSpell(_W) end
				end
				if enemy.health <= (qDmg + eDmg) and GetDistance(enemy) <= eRange and QREADY and EREADY then
					if QREADY then CastQ(enemy) end
					if EREADY then CastE(enemy) end
				end
				if enemy.health <= (wDmg + eDmg) and GetDistance(enemy) <= wRange and WREADY and EREADY then
					if EREADY then CastE(enemy) end
					if WREADY then CastSpell(_W) end
				end
				if enemy.health <= (qDmg + eDmg + wDmg) and GetDistance(enemy) <= eRange and EREADY and QREADY and WREADY then
					if QREADY then CastQ(enemy) end
					if EREADY then CastE(enemy) end
					if WREADY then CastSpell(_W) end
				end
				if enemy.health <= (qDmg + itemsDmg) and GetDistance(enemy) <= qRange and QREADY then
					if DFGREADY then CastSpell(dfgSlot, enemy) end
					if HXGREADY then CastSpell(hxgSlot, enemy) end
					if BWCREADY then CastSpell(bwcSlot, enemy) end
					if BRKREADY then CastSpell(brkSlot, enemy) end
					if QREADY then CastQ(enemy) end
				end
				if enemy.health <= (wDmg + itemsDmg) and GetDistance(enemy) <= wRange and WREADY then
					if DFGREADY then CastSpell(dfgSlot, enemy) end
					if HXGREADY then CastSpell(hxgSlot, enemy) end
					if BWCREADY then CastSpell(bwcSlot, enemy) end
					if BRKREADY then CastSpell(brkSlot, enemy) end
					if WREADY then CastSpell(_W) end
				end
				if enemy.health <= (eDmg + itemsDmg) and GetDistance(enemy) <= eRange and EREADY then
					if DFGREADY then CastSpell(dfgSlot, enemy) end
					if HXGREADY then CastSpell(hxgSlot, enemy) end
					if BWCREADY then CastSpell(bwcSlot, enemy) end
					if BRKREADY then CastSpell(brkSlot, enemy) end
					if EREADY then CastE(enemy) end
				end
				if enemy.health <= (qDmg + wDmg + itemsDmg) and GetDistance(enemy) <= wRange
					and WREADY and QREADY then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if WREADY and GetDistance(enemy) <= wRange then CastSpell(_W) end
						if QREADY then CastQ(enemy) end
				end
				if enemy.health <= (qDmg + eDmg + itemsDmg) and GetDistance(enemy) <= qRange
					and EREADY and QREADY then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if QREADY then CastQ(enemy) end
						if EREADY then CastE(enemy) end
				end
				if enemy.health <= (wDmg + eDmg + itemsDmg) and GetDistance(enemy) <= eRange
					and EREADY and WREADY then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if ROREADY and GetDistance(enemy) <= 500 then CastSpell(roSlot) end
						if WREADY and GetDistance(enemy) <= wRange then CastSpell(_W) end
						if EREADY then CastE(enemy) end
				end
				if enemy.health <= (qDmg + eDmg + wDmg + itemsDmg) and GetDistance(enemy) <= eRange
					and QREADY and EREADY and WREADY then
						if DFGREADY then CastSpell(dfgSlot, enemy) end
						if HXGREADY then CastSpell(hxgSlot, enemy) end
						if BWCREADY then CastSpell(bwcSlot, enemy) end
						if BRKREADY then CastSpell(brkSlot, enemy) end
						if QREADY then CastQ(enemy) end
						if EREADY then CastE(enemy) end
						if WREADY and GetDistance(enemy) <= wRange then CastSpell(_W) end
				end
				if KatarinaMenu.killsteal.wardKS then 
					if enemy.health <= (qDmg) and GetDistance(enemy) >= eRange and GetDistance(enemy) <= (qRange + eRange) then
						local mPos = Vector(myHero.x, myHero.y, myHero.z)
						local ePos = Vector(enemy.x, enemy.y, Target.z)
						local wPos =  mPos - (mPos - ePos):normalized() * eRange
						wardJump(wPos.x, wPos.z)
						if QREADY then CastQ(enemy) end
					end
					if enemy.health <= (qDmg + wDmg + itemsDmg) and GetDistance(enemy) >= eRange and GetDistance(enemy) <= (wRange + eRange) then
						local mPos = Vector(myHero.x, myHero.y, myHero.z)
						local ePos = Vector(enemy.x, enemy.y, Target.z)
						local wPos =  mPos - (mPos - ePos):normalized() * eRange
						wardJump(wPos.x, wPos.z)
						if QREADY then CastQ(enemy) end
						if WREADY and GetDistance(enemy) <= wRange then CastSpell(_W) end
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
function OnAnimation(unit, animationName)
    if unit.isMe and lastAnimation ~= animationName then lastAnimation = animationName end
end

function isChanneling(animationName)
    if lastAnimation == animationName then
        return true
    else
        return false
    end
end
------------- END OF ANIMATION & CHANELING ------------------

-- Packet Send thanks for the idea pqmailer <3 --
function OnSendPacket(p)
	if KatarinaMenu.autocarry.StopUlt then
		if isChanneling("Spell4") or ultActive then
			if Target ~= nil and GetDistance(Target) <= rRange then
				if not (QREADY and WREADY and EREADY) and Target.health > (qDmg + wDmg + eDmg) then
					local packet = Packet(p)
					if packet:get('name') == 'S_MOVE' then
						if packet:get('sourceNetworkId') == myHero.networkID then
							packet:block()
						end
					end
				end
			end
		end
	end
	if not KatarinaMenu.autocarry.StopUlt then
		if isChanneling("Spell4") or ultActive then
			if Target ~= nil and GetDistance(Target) <= rRange then
				local packet = Packet(p)
				if packet:get('name') == 'S_MOVE' or packet:get('name') == 'S_CAST' then
					if packet:get('sourceNetworkId') == myHero.networkID then
						packet:block()
					end
				end
			end
		end
	end
end
--------- END OF PACKET SEND ---------------------

-- Low Health for Auto Pots & Zhonyas --
function IsMyHealthLow()
	if myHero.health < (myHero.maxHealth * ( KatarinaMenu.misc.ZWHealth / 100)) then
		return true
	else
		return false
	end
end

function NeedHP()
	if myHero.health < (myHero.maxHealth * ( KatarinaMenu.misc.HPHealth / 100)) then
		return true
	else
		return false
	end
end
------------ END OF LOW HEATH FOR AUTOPOTS & ZHONYAS ----------------

-- Object Handling Functions --
function OnCreateObj(obj)
	if obj ~= nil then
		if (obj.name:find("katarina_deathLotus_mis.troy") or obj.name:find("katarina_deathLotus_tar.troy")) then
			if GetDistance(obj, myHero) <= 70 then
				timeult = GetTickCount()+250
			end
		end
		if (obj.name:find("katarina_deathlotus_success.troy") or obj.name:find("Katarina_deathLotus_empty.troy")) then
			if GetDistance(obj, myHero) <= 70 then
				timeult = 0
				ultActive = false
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
		if obj.name:find("SightWard") then
			if GetDistance(obj, myHero) <= eRange then
				table.insert(Wards, obj)
			end
		end
		if obj.name:find("VisionWard") then
			if GetDistance(obj, myHero) <= eRange then
				table.insert(Wards, obj)
			end
		end
		if FocusJungleNames[obj.name] then
                table.insert(JungleFocusMobs, obj)
        elseif JungleMobNames[obj.name] then
                table.insert(JungleMobs, obj)
        end
	end
end

function OnDeleteObj(obj)
	if (obj.name:find("katarina_deathlotus_success.troy") or obj.name:find("Katarina_deathLotus_empty.troy")) then
		ultActive = false
	end
	if (obj.name:find("katarina_deathLotus_mis.troy") or obj.name:find("katarina_deathLotus_tar.troy")) then
		ultActive = false
	end
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
	for i, Mob in pairs(JungleMobs) do
		if obj.name == Mob.name then
			table.remove(JungleMobs, i)
        end
    end
    for i, Mob in pairs(JungleFocusMobs) do
        if obj.name == Mob.name then
            table.remove(JungleFocusMobs, i)
        end
    end
end
------------ END OF OBJECT HANDLING FUNCTIONS -----------------

-- by Apple --
function GetJungleMob()
        for _, Mob in pairs(JungleFocusMobs) do
                if ValidTarget(Mob, eRange) then return Mob end
        end
        for _, Mob in pairs(JungleMobs) do
                if ValidTarget(Mob, eRange) then return Mob end
        end
end

function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name == "KatarinaR" then
		ultActive = true
	end
end

function MoveToMouse()
	local MousePos = Vector(mousePos.x, mousePos.y, mousePos.z)
	local Position = myHero + (Vector(MousePos) - myHero):normalized()*300
	myHero:MoveTo(Position.x, Position.z)
end

--[Plugin OnDraw]--
function OnDraw()
	--> Ranges
	if not KatarinaMenu.drawing.mDraw and not myHero.dead then
		if QREADY and KatarinaMenu.drawing.qDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0xB20000)
		end
		if WREADY and KatarinaMenu.drawing.wDraw then
			DrawCircle(myHero.x, myHero.y, myHero.z, wRange, 0x20B2AA)
		end
		if EREADY and KatarinaMenu.drawing.eDraw then
			DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x800080)
		end
	end
	if KatarinaMenu.drawing.cDraw then
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
	AARange = 125
	QREADY, WREADY, EREADY, RREADY = false, false, false, false
	HPREADY, MPREADY, FSKREADY = false, false, false
	RSTREADY, SSREADY, SWREADY, VWREADY = false, false, false
	lastAnimation = nil
	tick = nil
	levelSequence = { 1,3,2,2,2,4,2,1,2,1,4,1,1,3,3,4,3,3 }
	TextList = {"Harass him!!", "Q+W+E KILL!!", "FULL COMBO KILL!"}
	KillText = {}
	Wards = {}
	lastwardused = 0
	waittxt = {} -- prevents UI lags, all credits to Dekaron
	UsingHPot = false
	timeult, ultActive = 0, false
	lastAnimation = nil
	lastAttack = 0
	lastAttackCD = 0
	lastWindUpTime = 0
	for i=1, heroManager.iCount do waittxt[i] = i*3 end
	enemyMinions = minionManager(MINION_ENEMY, eRange, player, MINION_SORT_HEALTH_ASC)
	allyHeroes = GetAllyHeroes()
	JungleMobs = {}
	JungleFocusMobs = {}

	-- Stolen from Apple who Stole it from Sida --
	JungleMobNames = { -- List stolen from SAC Revamped. Sorry, Sida!
        ["wolf8.1.1"] = true,
        ["wolf8.1.2"] = true,
        ["YoungLizard7.1.2"] = true,
        ["YoungLizard7.1.3"] = true,
        ["LesserWraith9.1.1"] = true,
        ["LesserWraith9.1.2"] = true,
        ["LesserWraith9.1.4"] = true,
        ["YoungLizard10.1.2"] = true,
        ["YoungLizard10.1.3"] = true,
        ["SmallGolem11.1.1"] = true,
        ["wolf2.1.1"] = true,
        ["wolf2.1.2"] = true,
        ["YoungLizard1.1.2"] = true,
        ["YoungLizard1.1.3"] = true,
        ["LesserWraith3.1.1"] = true,
        ["LesserWraith3.1.2"] = true,
        ["LesserWraith3.1.4"] = true,
        ["YoungLizard4.1.2"] = true,
        ["YoungLizard4.1.3"] = true,
        ["SmallGolem5.1.1"] = true,
}

	FocusJungleNames = {
        ["Dragon6.1.1"] = true,
        ["Worm12.1.1"] = true,
        ["GiantWolf8.1.3"] = true,
        ["AncientGolem7.1.1"] = true,
        ["Wraith9.1.3"] = true,
        ["LizardElder10.1.1"] = true,
        ["Golem11.1.2"] = true,
        ["GiantWolf2.1.3"] = true,
        ["AncientGolem1.1.1"] = true,
        ["Wraith3.1.3"] = true,
        ["LizardElder4.1.1"] = true,
        ["Golem5.1.2"] = true,
}

	for i = 0, objManager.maxObjects do
		local object = objManager:getObject(i)
		if object ~= nil then
			if FocusJungleNames[object.name] then
				table.insert(JungleFocusMobs, object)
			elseif JungleMobNames[object.name] then
				table.insert(JungleMobs, object)
			end
		end
	end
end
------------------ END OF VARIABLES --------------------

--Based on Manciuzz Orbwalker http://pastebin.com/jufCeE0e

function OrbWalking(Target)
	if TimeToAttack() and GetDistance(Target) <= myHero.range + GetDistance(myHero.minBBox) then
		myHero:Attack(Target)
    elseif heroCanMove() then
        moveToCursor()
    end
end

function TimeToAttack()
    return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end

function heroCanMove()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
end

function moveToCursor()
	if GetDistance(mousePos) then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()*300
		myHero:MoveTo(moveToPos.x, moveToPos.z)
    end        
end

function OnProcessSpell(object,spell)
	if object == myHero then
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency()/2
			lastWindUpTime = spell.windUpTime*1000
			lastAttackCD = spell.animationTime*1000
        end
    end
end

-- Katarina Main Menu --
function KatarinaMenu()
	KatarinaMenu = scriptConfig("Katarina - The Sinister Blade", "Katarina")
	
	KatarinaMenu:addSubMenu("["..myHero.charName.." - Combo Settings]", "autocarry")
		KatarinaMenu.autocarry:addParam("FullCombo", "Full Combo Key (X)", SCRIPT_PARAM_ONKEYDOWN, false, 88)
		KatarinaMenu.autocarry:addParam("StopUlt", "Stop Ult if enemy can Die", SCRIPT_PARAM_ONOFF, false)
		KatarinaMenu.autocarry:addParam("DelayW", "DelayW", SCRIPT_PARAM_ONOFF, false)
		KatarinaMenu.autocarry:addParam("bItems", "Use Items with Burst", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.autocarry:permaShow("FullCombo") 
	
	KatarinaMenu:addSubMenu("["..myHero.charName.." - Harass Settings]", "harrass")
		KatarinaMenu.harrass:addParam("DelayW", "Delay W", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.harrass:addParam("hMode", "Harass Mode",SCRIPT_PARAM_SLICE, 1, 1, 2, 0)
		KatarinaMenu.harrass:addParam("hHK", "Harass Hotkey (T)", SCRIPT_PARAM_ONKEYDOWN, false, 84)
		KatarinaMenu.harrass:addParam("wHarrass", "Always Sinister Steel (W)", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.harrass:addParam("mTmH", "Move To Mouse", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.harrass:permaShow("hHK") 
		
	
	KatarinaMenu:addSubMenu("["..myHero.charName.." - Farming Settings]", "farming")
		KatarinaMenu.farming:addParam("mFarm", "Disable Farming (Z)", SCRIPT_PARAM_ONKEYTOGGLE, false, 67)
		KatarinaMenu.farming:addParam("qFarm", "Farm with Bouncing Blades (Q)", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.farming:addParam("wFarm", "Sinister Steel (W)", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.farming:addParam("eFarm", "Farm with Shunpo (E)", SCRIPT_PARAM_ONOFF, false)
		KatarinaMenu.farming:permaShow("mFarm") 
		
		
	KatarinaMenu:addSubMenu("["..myHero.charName.." - Clear Settings]", "jungle")
		KatarinaMenu.jungle:addParam("ClearKey", "Jungle/Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, 86)
		KatarinaMenu.jungle:addParam("JungleFarm", "Use Skills to Farm Jungle", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.jungle:addParam("ClearLane", "Use Skills to Clear Lane", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.jungle:addParam("JungleQ", "Farm with Bouncing Blades (Q)", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.jungle:addParam("JungleW", "Sinister Steel (W)", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.jungle:addParam("JungleE", "Use Shunpo (E)", SCRIPT_PARAM_ONOFF, true)
		
		
	KatarinaMenu:addSubMenu("["..myHero.charName.." - KillSteal Settings]", "killsteal")
		KatarinaMenu.killsteal:addParam("KillSteal", "Use Smart Kill Steal", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.killsteal:addParam("wardKS", "Use Wards to KS", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.killsteal:addParam("Ignite", "Auto Ignite", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.killsteal:addParam("KSItems", "Use Items with Auto KS", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.killsteal:permaShow("KillSteal") 
			
	KatarinaMenu:addSubMenu("["..myHero.charName.." - Drawing Settings]", "drawing")	
		KatarinaMenu.drawing:addParam("mDraw", "Disable All Ranges Drawing", SCRIPT_PARAM_ONOFF, false)
		KatarinaMenu.drawing:addParam("cDraw", "Draw Enemy Text", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.drawing:addParam("qDraw", "Draw Bouncing Blades (Q) Range", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.drawing:addParam("wDraw", "Draw Sinister Steel (W) Range", SCRIPT_PARAM_ONOFF, false)
		KatarinaMenu.drawing:addParam("eDraw", "Draw Shunpo (E) Range", SCRIPT_PARAM_ONOFF, false)
	
	KatarinaMenu:addSubMenu("["..myHero.charName.." - Misc Settings]", "misc")
		KatarinaMenu.misc:addParam("WardJump", "Ward Jump Hotkey (G)", SCRIPT_PARAM_ONKEYDOWN, false, 71)
		KatarinaMenu.misc:addParam("wardSave", "Beta Ward Save", SCRIPT_PARAM_ONKEYDOWN, false, 71)
		KatarinaMenu.misc:addParam("ZWItems", "Auto Zhonyas/Wooglets", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.misc:addParam("ZWHealth", "Min Health % for Zhonyas/Wooglets", SCRIPT_PARAM_SLICE, 15, 0, 100, -1)
		KatarinaMenu.misc:addParam("aHP", "Auto Health Pots", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.misc:addParam("HPHealth", "Min % for Health Pots", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
		KatarinaMenu.misc:addParam("AutoLevelSkills", "Auto Level Skills (Requires Reload)", SCRIPT_PARAM_ONOFF, true)
		KatarinaMenu.misc:permaShow("WardJump") 
		
	TargetSelector = TargetSelector(TARGET_LOW_HP, (qRange + eRange),DAMAGE_MAGIC)
	TargetSelector.name = "Katarina"
	KatarinaMenu:addTS(TargetSelector)
end
------------- END OF KATARINA MENU ------------------------

--[Cooldown Checks]--
function Checks()
	-- Updates Targets --
	TargetSelector:update()
	Target = TargetSelector.target
	
	-- Finds Ignite --
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		ignite = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		ignite = SUMMONER_2
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
	znaSlot, wgtSlot, bftSlot =          GetInventorySlotItem(3157),
	                                     GetInventorySlotItem(3090),
										 GetInventorySlotItem(3188)
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
	BFTREADY = (bftSlot ~= nil and myHero:CanUseSpell(bftSlot) == READY)
	
	-- Pots --
	HPREADY = (hpSlot ~= nil and myHero:CanUseSpell(hpSlot) == READY)
	MPREADY =(mpSlot ~= nil and myHero:CanUseSpell(mpSlot) == READY)
	FSKREADY = (fskSlot ~= nil and myHero:CanUseSpell(fskSlot) == READY)
	
	-- Wards --
	RSTREADY = (rstSlot ~= nil and myHero:CanUseSpell(rstSlot) == READY)
	SSREADY = (ssSlot ~= nil and myHero:CanUseSpell(ssSlot) == READY)
	SWREADY = (swSlot ~= nil and myHero:CanUseSpell(swSlot) == READY)
	VWREADY = (vwSlot ~= nil and myHero:CanUseSpell(vwSlot) == READY)
	
	-- Updates Wards that die --
	if next(Wards)~=nil then
		for i, obj in pairs(Wards) do
			if not obj.valid then
				table.remove(Wards, i)
			end
		end
	end
	
	-- Updates Minions --
	enemyMinions:update()
	
	-- Checks if Ult is Active: by eXtragoZ --
	if GetTickCount() <= timeult then ultActive = true end
	if QREADY and WREADY and EREADY and not Target then ultActive = false end
end
--[/Cooldown Checks]--