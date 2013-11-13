--[[ Consumables Helper by Skeem

	 a friend requested it so I made a simple one
	 might turn into a more complicated script later
	 I've been using this in most of my plugins
	
	 Features
	 - Uses Health Pots (1 at the time with % in menu)
	 - Uses Mana Pots (1 at the time with % in menu)
	
	 Changelog:
	 0.1 : Beta Release
	 
	 TODO:
	 - Add flask
	 - Add Items such as Zhonyas
	 - Add Red Pot
	 
	 ]]--

local HealthPotSlot
local ManaPotSlot
local FlaskSlot	 
	 

function OnLoad()

	ConsumablesHelper = scriptConfig("Consumables Helper", "consumableshelper")
		ConsumablesHelper:addParam("AutoHealthPots", "Auto Health Pots", SCRIPT_PARAM_ONOFF, true)
		ConsumablesHelper:addParam("PercentofHealth", "Minimum Health %", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
		ConsumablesHelper:addParam("AutoManaPots", "Auto Mana Pots", SCRIPT_PARAM_ONOFF, true)
		ConsumablesHelper:addParam("PercentofMana", "Minimum Mana %", SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
		PrintChat("Consumables Helper by Skeem Loaded!")
		
	UsingHealthPot, UsingManaPot, UsingFlask = false, false, false
	
	
end

function OnTick()

	HealthPotSlot = GetInventorySlotItem(2003)
	ManaPotSlot = GetInventorySlotItem(2004)
	FlaskSlot = GetInventorySlotItem(2041)
	
	if ConsumablesHelper.AutoHealthPots and MyHealthIsLow() then
		if FlaskSlot ~= nil and not (UsingHealthPot or UsingFlask) then CastSpell(FlaskSlot) end
		if HealthPotSlot ~= nil and not (UsingHealthPot or UsingFlask) then CastSpell(HealthPotSlot) end
	end
	if ConsumablesHelper.AutoManaPots and MyManaIsLow() then
		if FlaskSlot ~= nil and not (UsingManaPot or UsingFlask) then CastSpell(FlaskSlot) end
		if ManaPotSlot ~= nil and not (UsingManaPot or UsingFlask) then CastSpell(ManaPotSlot) end
	end
end

function OnCreateObj(obj)
	if obj ~= nil then
		if obj.name:find("Global_Item_HealthPotion.troy") then
			if GetDistance(obj, myHero) <= 70 then
				UsingHealthPot = true
				UsingFlask = true
			end
		end
		if obj.name:find("Global_Item_ManaPotion.troy") then
			if GetDistance(obj, myHero) <= 70 then
				UsingFlask = true
				UsingManaPot = true
			end
		end
	end
end

function OnDeleteObj(obj)
	if obj ~= nil then
		if obj.name:find("TeleportHome.troy") then
			Recall = false
		end
		if obj.name:find("Global_Item_HealthPotion.troy") then
			UsingHealthPot = false
			UsingFlask = false
		end
		if obj.name:find("Global_Item_ManaPotion.troy") then
			UsingManaPot = false
			UsingFlask = false
		end
	end
end

function MyHealthIsLow()
	if myHero.health < (myHero.maxHealth * ( ConsumablesHelper.PercentofHealth / 100)) then
		return true
	else
		return false
	end
end

function MyManaIsLow()
	if myHero.mana < (myHero.maxMana * ( ConsumablesHelper.PercentofMana / 100)) then
		return true
	else
		return false
	end
end