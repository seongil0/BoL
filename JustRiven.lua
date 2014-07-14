-- Script Name: Just Riven
-- Script Ver.: 1.2
-- Author     : Skeem

--[[ Changelog:
	1.0 -Initial Release
	1.1 - Smoothen up combo
	    - Fixed Error Spamming
	1.2 - Smoothen up Orbwalking
	    - Added some packet checks
]]--

if myHero.charName ~= 'Riven' then return end

require 'VPrediction'

	Spells = {
		Q = {key = _Q, string = 'Q', name = 'Broken Wings',   range = 300, ready = false, data = nil, color = 0x663300},
		W = {key = _W, string = 'W', name = 'Ki Burst',       range = 260, ready = false, data = nil, color = 0x333300},
		E = {key = _E, string = 'E', name = 'Valor',          range = 390, ready = false, data = nil, color = 0x666600},
		R = {key = _R, string = 'R', name = 'Blade of Exile', range = 900, ready = false, data = nil, color = 0x993300}
	}

	Ignite = (myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") and SUMMONER_2) or nil

	Items = {
		YGB	   = {id = 3142, range = 350, ready = false},
		BRK    = {id = 3153, range = 500, ready = false},
		HYDRA  = {id = 3074, range = 350, ready = false},
		TIAMAT = {id = 3077, range = 350, ready = false}
	}

	SpellNames = {'RivenTriCleave', 'RivenMartyr', 'RivenFeint', 'RivenFengShuiEngine', 'rivenizunablade'}

	BuffInfo = {
		P = false,
		Q = {stage  = 0}
	}

	vPred = VPrediction()

	Orbwalking = {
		projectile = math.huge,
		lastAA     = 0,
		windUp     = 3,
		animation  = 0.6,
		updated    = false,
		range      = 0
	}

	TS = TargetSelector(TARGET_LESS_CAST_PRIORITY, 500, DAMAGE_PHYSICAL)
	TS.name = 'Riven'
	
	RivenMenu = scriptConfig('~[Just Riven]~', 'Riven')
		RivenMenu:addSubMenu('~[Skill Settings]~', 'skills')
			RivenMenu.skills:addParam('', '--[ W Options ]--', SCRIPT_PARAM_INFO, '')
			RivenMenu.skills:addParam('autoW', 'Auto W Close Enemies', SCRIPT_PARAM_ONOFF, true)
			RivenMenu.skills:addParam('', '--[ R Options ]--',    SCRIPT_PARAM_INFO, '')
			RivenMenu.skills:addParam('comboR', 'Use in Combo',   SCRIPT_PARAM_LIST, 1, {"When other skills are not on CD", "Always", "Never"})	
			RivenMenu.skills:addParam('healthR', 'Min Health %',  SCRIPT_PARAM_SLICE, 50, 0, 100, -1)
		RivenMenu:addSubMenu('~[Kill Settings]~', 'kill')
			RivenMenu.kill:addParam('enabled', 'Enable KillSteal',    SCRIPT_PARAM_ONOFF, true)
			RivenMenu.kill:addParam('killQ',   'GapClose Q to KS',    SCRIPT_PARAM_ONOFF, true)
			RivenMenu.kill:addParam('killR',   'KillSteal with R',    SCRIPT_PARAM_LIST, 1, {"When other skills are not on CD", "Always", "Never"})
			RivenMenu.kill:addParam('killW',   'KillSteal with W',    SCRIPT_PARAM_ONOFF, true)
			RivenMenu.kill:addParam('Ignite',  'Auto Ignite Enemies', SCRIPT_PARAM_ONOFF, true)

		RivenMenu:addSubMenu('~[Draw Ranges]~', 'draw')
			for _, spell in pairs(Spells) do
				RivenMenu.draw:addParam(spell.string, 'Draw '..spell.name..' ('..spell.string..')', SCRIPT_PARAM_ONOFF, true)
			end
		RivenMenu:addParam('forceAAs', 'Force AAs with Passive', SCRIPT_PARAM_ONOFF,         true)
		RivenMenu:addParam('comboKey', 'Combo Key X'           , SCRIPT_PARAM_ONKEYDOWN, false, 88)

PrintChat("<font color='#663300'>Just Riven 1.2 Loaded</font>")

function OnTick()
	Target = GetTarget()

	Orbwalking.range = myHero.range + vPred:GetHitBox(myHero)

	for _, spell in pairs(Spells) do
		spell.ready = myHero:CanUseSpell(spell.key) == READY
		spell.data  = myHero:GetSpellData(spell.key)
	end

	for _, item in pairs(Items) do
		item.ready = GetInventoryItemIsCastable(item.id)
	end

	if RivenMenu.comboKey then
		Orb(Target)
		CastCombo(Target)
	end
	if RivenMenu.skills.autoW and Spells.W.ready and Target then
		Cast(_W, Target, Spells.W.range)
	end
	if RivenMenu.kill.enabled then
		KillSteal()
	end
end 

function OnDraw()
	for _, spell in pairs(Spells) do
		if spell.ready and RivenMenu.draw[spell.string] then
			DrawCircle(myHero.x, myHero.y, myHero.z, spell.range, spell.color)
		end
	end
end

function OnGainBuff(unit, buff)
	if unit.isMe then
		if buff.name == 'rivenpassiveaaboost' then
			BuffInfo.P = true
		end
		if buff.name == 'riventricleavesoundone' then
			BuffInfo.Q.stage = 1
		end
		if buff.name == 'riventricleavesoundtwo' then
			BuffInfo.Q.stage = 2
		end
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe then
		if buff.name == 'rivenpassiveaaboost' then
			BuffInfo.P = false
		end
		if buff.name == 'RivenTriCleave' then
			BuffInfo.Q.stage = 0
		end
	end
end

function OnProcessSpell(unit, spell)
	if unit.isMe then
		if spell.name:lower():find("attack") then
			if Orbwalking.updated then
				Orbwalking.animation = 1 / (spell.animationTime * myHero.attackSpeed)
				Orbwalking.windUp    = 1 / (spell.windUpTime    * myHero.attackSpeed)
				Orbwalking.updated   = true
			end
			if RivenMenu.comboKey then
				if Items.HYDRA.ready or Items.TIAMAT.ready then
					UseItems(spell.target)
					Orbwalking.lastAA = 0
				end
			else
				Orbwalking.lastAA = os.clock() - GetLatency() / 2000
			end
		end
	end
end

function OnSendPacket(packet)
	local p = Packet(packet)
	if p:get('name') == 'S_CAST' and p:get('sourceNetworkId') == myHero.networkID then
		if p:get('spellId') == 2 then
			if RivenMenu.comboKey and Target then
				Cast(_Q, Target, Spells.Q.range)
			end
		end
		Packet('S_MOVE', { x = mousePos.x, y = mousePos.z }):send()
		Orbwalking.lastAA = 0
	end
end

function OnRecvPacket(packet)
	if packet.header == 0x34 then
		packet.pos = 1
		if packet:DecodeF() == myHero.networkID then
			packet.pos = 9
			if packet:Decode1() == 0x11 then
				Orbwalking.lastAA = 0
			end
		end
	end
	-- Thanks to Bilbao :3 --
	if packet.header == 0x65 then
  		packet.pos = 5
  		local dmgType  = packet:Decode1()
  		local targetId = packet:DecodeF()
  		local souceId  = packet:DecodeF()
  		if souceId == myHero.networkID and dmgType == (12 or 3) then
  			Orbwalking.lastAA = 0
  		end
 	end
end

function GetTarget()
	TS:update()
	if TS.target ~= nil and not TS.target.dead and TS.target.type  == myHero.type and TS.target.visible then
		return TS.target
	end
end


function CastCombo(target)
	if target then
		local truerange = Orbwalking.range + vPred:GetHitBox(target) + 50
		local distance  = GetDistanceSqr(target)
		local EQRange   = Spells.E.ready and Spells.Q.ready and Spells.E.range + Spells.Q.range
		local EWRange   = Spells.E.ready and Spells.Q.ready and Spells.E.range + Spells.W.range
		if RivenMenu.skills.comboR ~= 3 and Spells.R.ready and Spells.R.data.name == 'RivenFengShuiEngine' then
			if RivenMenu.skills.comboR == 1 then
				if target.health < (target.maxHealth * (RivenMenu.skills.healthR / 100)) and ((Spells.E.ready and Spells.Q.ready) or (Spells.W.ready and Spells.Q.ready)) then
					CastSpell(_R)
				end
			elseif RivenMenu.skills.comboR == 2 then
				if target.health < (target.maxHealth * (RivenMenu.skills.healthR / 100)) then
					CastSpell(_R)
				end
			end
		end

		if RivenMenu.forceAAs then
			if not BuffInfo.P then
				Cast(_Q, target, Spells.Q.range)
				if EQ then
					Cast(_E, target, EQRange)
				elseif EW then
					Cast(_E, target, EWRange)
				else
					Cast(_E, target, Spells.E.range)
				end
				Cast(_W, target, Spells.W.range)
			end
		else
			Cast(_Q, target, Spells.Q.range)
			if EQ then
				Cast(_E, target, EQRange)
			elseif EW then
				Cast(_E, target, EWRange)
			else
				Cast(_E, target, Spells.E.range)
			end
			Cast(_W, target, Spells.W.range)
		end
	end
end

function KillSteal()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy) then
			if Spells.R.ready then
				if RivenMenu.kill.killR == 1 then
					if enemy.health < getDmg("R", enemy, myHero) and Spells.R.data.name ~= 'RivenFengShuiEngine' then
						Cast(_R, enemy, Spells.R.range)
					end
				elseif RivenMenu.kill.killR == 2 then
					if ValidTarget(enemy, Spells.R.range) and enemy.health < getDmg("R", enemy, myHero) then
						Cast(_R, enemy, Spells.R.range)
					end	
				end
			end
			if RivenMenu.kill.Ignite and GetDistanceSqr(enemy) < 600 * 600 then
				IgniteCheck(enemy)
			end
			if RivenMenu.kill.killW and enemy.health < getDmg("W", enemy, myHero) then
				Cast(_W, enemy, Spells.W.range)
			end
		end
	end
end

function IgniteCheck(target)
	return  target.health < getDmg("IGNITE", target, myHero) and CastSpell(Ignite, target)
end

function Cast(spell, target, range)
	return GetDistanceSqr(target) < range * range and Packet("S_CAST", { spellId = spell, toX = target.x, toY = target.z, fromX = target.x, fromY = target.z }):send()
end

function UseItems(enemy)
	if enemy and enemy.type == myHero.type then
		for _, item in pairs(Items) do
			if item.ready and GetDistanceSqr(enemy) <= item.range*item.range then
      			CastItem(item.id, enemy)
    		end
		end
	end
end

function Orb(target)
	local truerange  = target ~= nil and Orbwalking.range + vPred:GetHitBox(target)
	if CanAttack() and ValidTarget(target, truerange) then
		Attack(target)
	elseif CanMove() then
		if not target then
			local MovePos = Vector(myHero) + 400 * (Vector(mousePos) - Vector(myHero)):normalized()
			Packet('S_MOVE', { x = MovePos.x, y = MovePos.z }):send()
		elseif GetDistanceSqr(target) > 200*200 + math.pow(vPred:GetHitBox(target), 2) then
			local point = vPred:GetPredictedPos(target, 0, 2*myHero.ms, myHero, false)
			if GetDistanceSqr(point) < 200*200 + math.pow(vPred:GetHitBox(target), 2) then
				point = Vector(Vector(myHero) - point):normalized() * 50
			end
			Packet('S_MOVE', { x = point.x, y = point.z }):send()
		end
	end
end

function CanAttack()
	if Orbwalking.lastAA <= os.clock() then
		return (os.clock() + GetLatency() / 2000  > Orbwalking.lastAA + AnimationTime())
	end
	return false
end

function Attack(target)
	Packet('S_MOVE', {type = 3, targetNetworkId = target.networkID}):send()
end

function CanMove()
	if Orbwalking.lastAA <= os.clock() then
		return (os.clock() + GetLatency() / 2000 > Orbwalking.lastAA + WindUpTime())
	end
end
function AnimationTime()
	return (1 / (myHero.attackSpeed * Orbwalking.animation))
end

function WindUpTime()
	return (1 / (myHero.attackSpeed * Orbwalking.windUp))
end