-- Script Name: Just Riven
-- Script Ver.: 1.7
-- Author     : Skeem

--[[ Changelog:
	1.0   - Initial Release
	1.1   - Smoothen up combo
	      - Fixed Error Spamming
	1.2   - Smoothen up Orbwalking
	      - Added some packet checks
	1.3   - Remade orbwalker completely packet based now
	      - Combo should be a lot faster
	      - Added Menu Options for max stacks to use in combo
	1.4   - Whole new combo system
		  - Added Selector make sure to have latest (http://iuser99.com/scripts/Selector.lua)
		  - Removed Max Stacks in combo from menu (let me know if you want this back, i don't think its need anymore)
	      - Added menu to cancel anims with laugh/movement
	      - Added tiamat cancel AA anim -> W cancel tiamat anim -> Q cancel w Anim
	      - Added option to disable orbwalk in combo
	      - Fixed 'chasing target' when using combo
	      - Changed R Menu (Now in Combo Options) & Fixed Path Lib error with R
	      - Added R Damage logic based on skills available and option to use in combo
	      - Fixed Auto Ignite & Nil error spamming when not having it
	1.4.5 - Fixed Ult Kill Usage
	      - Fixed W error spamming
	      - Tried to improve AA in between spells
	      - Fixed boolean error
	      - Fixed Qing backwards when trying to run
	1.5   - Update Riven's orbwalker a bit
	1.6   - Now Uses SxOrbwalker remade a lot of the script!
	1.7   - Updated the script! Combo should be as smooth as baby's butt now
	      - Added Semi Harrass
	      - Added Lane Clear
	      - Updated Orbwalker
	      - Updated Damage Calculations
	      - Fixed All Path Lib Errors
]]--

if myHero.charName ~= 'Riven' then return end

require "SxOrbWalk"

	Spells = {
		Q = {key = _Q, string = 'Q', name = 'Broken Wings',   range = 300, ready = false, data = nil, color = 0x663300},
		W = {key = _W, string = 'W', name = 'Ki Burst',       range = 260, ready = false, data = nil, color = 0x333300},
		E = {key = _E, string = 'E', name = 'Valor',          range = 390, ready = false, data = nil, color = 0x666600},
		R = {key = _R, string = 'R', name = 'Blade of Exile', range = 900, ready = false, data = nil, color = 0x993300}
	}

	Ignite = (myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") and SUMMONER_1) or (myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") and SUMMONER_2) or nil
	EnemyMinions  = minionManager(MINION_ENEMY,  400, player, MINION_SORT_HEALTH_ASC)
	JungleMinions = minionManager(MINION_JUNGLE, 400, player, MINION_SORT_MAXHEALTH_DEC)

	Items = {
		YGB	   = {id = 3142, range = 350, ready = false},
		BRK    = {id = 3153, range = 500, ready = false},
		HYDRA  = {id = 3074, range = 350, ready = false},
		TIAMAT = {id = 3077, range = 350, ready = false}
	}

	BuffInfo = {
		P = {stacks = 0},
		Q = {stage  = 0}
	}

	Orbwalking = {
		lastAA     = 0,
		windUp     = 3.75,
		animation  = 0.625,
	}

	TS = TargetSelector(TARGET_LESS_CAST_PRIORITY, 500, DAMAGE_PHYSICAL)
	TS.name = 'Riven'
	
	RivenMenu = scriptConfig('~[Just Riven]~', 'Riven')
		RivenMenu:addSubMenu('~[Skill Settings]~', 'skills')
			RivenMenu.skills:addParam('', '--[ W Options ]--', SCRIPT_PARAM_INFO, '')
			RivenMenu.skills:addParam('autoW', 'Auto W Close Enemies', SCRIPT_PARAM_ONOFF, false)
		
		RivenMenu:addSubMenu('~[Combo Settings]~', 'combo')
			RivenMenu.combo:addParam('ulti',     'Use R for Potential Kills', SCRIPT_PARAM_ONOFF, true)
			RivenMenu.combo:addParam('forceAAs', 'Force AAs with Passive', SCRIPT_PARAM_ONOFF,    true)
			RivenMenu.combo:addParam('maxStacks', 'Max Passive Stacks',   SCRIPT_PARAM_SLICE, 2,  0, 3)
			RivenMenu.combo:addParam('anim',     'Cancel Animation With:',    SCRIPT_PARAM_LIST, 2, {"Laugh", "Movement"})

		RivenMenu:addSubMenu('~[Harass Settings]~', 'harass')
			RivenMenu.harass:addParam('q',     'Use Q Harass', SCRIPT_PARAM_ONOFF, true)

		RivenMenu:addSubMenu('~[Clear Settings]~', 'clear')
			RivenMenu.clear:addParam('q',     'Use Q Clear', SCRIPT_PARAM_ONOFF, true)
			RivenMenu.clear:addParam('w',     'Use W Clear', SCRIPT_PARAM_ONOFF, true)
			RivenMenu.clear:addParam('e',     'Use E Clear', SCRIPT_PARAM_ONOFF, true)

		RivenMenu:addSubMenu('~[SxOrb Settings]~', 'sxorb')
			SxOrb:LoadToMenu(RivenMenu.sxorb, true)
			SxOrb:RegisterHotKey("harass",    RivenMenu, "harassKey")
			SxOrb:RegisterHotKey("laneclear", RivenMenu, "clearKey" )

		RivenMenu:addSubMenu('~[Kill Settings]~', 'kill')
			RivenMenu.kill:addParam('enabled', 'Enable KillSteal',    SCRIPT_PARAM_ONOFF, true)
			RivenMenu.kill:addParam('killQ',   'GapClose Q to KS',    SCRIPT_PARAM_ONOFF, true)
			RivenMenu.kill:addParam('killR',   'KillSteal with R',    SCRIPT_PARAM_LIST, 1, {"When Already Used", "Always", "Never"})
			RivenMenu.kill:addParam('killW',   'KillSteal with W',    SCRIPT_PARAM_ONOFF, true)
			RivenMenu.kill:addParam('Ignite',  'Auto Ignite Enemies', SCRIPT_PARAM_ONOFF, true)

		RivenMenu:addSubMenu('~[Draw Ranges]~', 'draw')
			for _, spell in pairs(Spells) do
				RivenMenu.draw:addParam(spell.string, 'Draw '..spell.name..' ('..spell.string..')', SCRIPT_PARAM_ONOFF, true)
			end		
		RivenMenu:addParam('comboKey',  'Combo Key  [X]',  SCRIPT_PARAM_ONKEYDOWN, false, GetKey('X'))
		RivenMenu:addParam('harassKey', 'Harass Key [C]',  SCRIPT_PARAM_ONKEYDOWN, false, GetKey('C'))
		RivenMenu:addParam('clearKey',  'Clear Key  [V]',  SCRIPT_PARAM_ONKEYDOWN, false, GetKey('V'))
		RivenMenu:addTS(TS)

PrintChat("<font color='#663300'>Just Riven 1.2 Loaded</font>")

function OnTick()
	Target = GetTarget()

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
	if RivenMenu.clearKey then
		Clear()
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
	if Target then
		DrawCircle(myHero.x, myHero.y, myHero.z, AARange(Target), Spells.Q.color)
	end
end

function OnGainBuff(unit, buff)
	if unit.isMe then
		if buff.name == 'rivenpassiveaaboost' then
			BuffInfo.P.stacks = 1
		end
		if buff.name == 'riventricleavesoundone' then
			BuffInfo.Q.stage  = 1
		end
		if buff.name == 'riventricleavesoundtwo' then
			BuffInfo.Q.stage  = 2
		end
	end
end

function OnLoseBuff(unit, buff)
	if unit.isMe then
		if buff.name == 'rivenpassiveaaboost' then
			BuffInfo.P.stacks = 0
		end
		if buff.name == 'RivenTriCleave' then
			BuffInfo.Q.stage  = 0
		end
	end
end

function OnUpdateBuff(unit, buff)
	if unit.isMe then
		if buff.name == 'rivenpassiveaaboost' then
			BuffInfo.P.stacks = buff.stack
		end
	end
end

function OnSendPacket(packet)
	local p = Packet(packet)
	if p:get('name') == 'S_CAST' and p:get('sourceNetworkId') == myHero.networkID then
		DelayAction(function() CancelAnimation() end, Latency())
		if Target and RivenMenu.comboKey then
			if p:get('spellId') == 0 then
				DelayAction(function() ResetAA() end, Latency())
			elseif p:get('spellId') == 1 and Spells.Q.ready then
				DelayAction(function() Cast(_Q, Target, Spells.Q.range) end, Latency())
			elseif p:get('spellId') == 2 and Spells.Q.ready then
				DelayAction(function() Cast(_Q, Target, Spells.Q.range) end, Latency())
			elseif p:get('spellId') > 3 then
				DelayAction(function() ResetAA() end, Latency())
				DelayAction(function() Cast(_W, Target, Spells.W.range) end, Latency())
			end
		end
	end
end

function OnRecvPacket(packet)
	if packet.header == 0xFE then
		packet.pos = 1
 		if packet:DecodeF() == myHero.networkID then
 			Orbwalking.lastAA = Clock() - Latency()
 			if ValidTarget(Target, 350) then
 				if Items.HYDRA.ready then
					DelayAction(function() CastItem(Items.HYDRA.id)  end, Latency())
				elseif Items.TIAMAT.ready then
					DelayAction(function() CastItem(Items.TIAMAT.id) end, Latency())
				end
			end
 		end
 	end
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
  			if ValidTarget(Target) and Spells.Q.ready then
  				if RivenMenu.comboKey or (RivenMenu.harass.q and RivenMenu.harassKey) then
  					Cast(_Q, Target, Spells.Q.range)
  				end
			end
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
	if ValidTarget(target) then
		local distance  = GetDistanceSqr(target)
		local EQRange   = Spells.E.ready and Spells.Q.ready and Spells.E.range + Spells.Q.range
		local EWRange   = Spells.E.ready and Spells.Q.ready and Spells.E.range + Spells.W.range
		if RivenMenu.combo.ulti and Ult(target) and Spells.R.ready and InRange(target) then
			CastSpell(_R)
		end
		if EQ then
			Cast(_E, target, EQRange)
		elseif EW then
			Cast(_E, target, EWRange)
		else
			Cast(_E, target, Spells.E.range)
		end		
		if RivenMenu.combo.forceAAs then
			if BuffInfo.P.stacks < 1 then
				if not InRange(target) or not CanAttack() then
					Cast(_Q, target, Spells.Q.range)
				end
			end
		else
			Cast(_Q, target, Spells.Q.range)
		end
		if not Items.TIAMAT.ready or Items.HYDRA.ready then 
			Cast(_W, target, Spells.W.range)
		end
	end
end

function Ult(target)
	local R1  = Spells.R.ready and myHero:CalcDamage(target, (myHero.totalDamage *.20)) or 0
	local Dmg = {P  = getDmg('P',  target, myHero) + R1,
				 A  = getDmg('AD', target, myHero) + R1,
				 Q  = Spells.Q.ready and getDmg('Q', target, myHero) + R1 or 0,
				 W  = Spells.W.ready and getDmg('W', target, myHero) + R1 or 0,
				 R2 = Spells.R.ready and getDmg('R', target, myHero) + R1 or 0}

	return ((Dmg.P*4) + (Dmg.A*4) + (Dmg.Q*3) + Dmg.W + Dmg.R2) > target.health
end

function UltOn()
	return Spells.R.data.level > 0 and Spells.R.ready and Spells.R.data.name ~= 'RivenFengShuiEngine'
end

function KillSteal()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy, Spells.R.range) then
			local RDmg = getDmg('R', enemy, myHero) or 0
			if Spells.R.ready and enemy.health <= RDmg then
				if RivenMenu.kill.killR == 1 then
					if UltOn() then
						Cast(_R, enemy, Spells.R.range, true)
					end
				elseif RivenMenu.kill.killR == 2 then
					if UltOn() then
						Cast(_R, enemy, Spells.R.range, true)						
					else
						CastSpell(_R)	
					end
				end
			end
			if Ignite ~= nil and RivenMenu.kill.Ignite and ValidTarget(enemy, 600) then
				IgniteCheck(enemy)
			end
		end
	end
end

function IgniteCheck(target)
	return  target.health < getDmg("IGNITE", target, myHero) and CastSpell(Ignite, target)
end

function Cast(spell, target, range, packet)
	return GetDistanceSqr(target.visionPos) < range * range and (not packet and CastSpell(spell, target.visionPos.x, target.visionPos.z) or Packet("S_CAST", { spellId = spell, toX = target.x, toY = target.z, fromX = target.x, fromY = target.z }):send())
end

function CancelAnimation()
	return RivenMenu.combo.anim == 1 and SendChat('/l') or Packet('S_MOVE', { x = mousePos.x, y = mousePos.z }):send()
end

function Clear()
	local QOn = Spells.Q.ready and RivenMenu.clear.q
	local WOn = Spells.Q.ready and RivenMenu.clear.w
	local EOn = Spells.Q.ready and RivenMenu.clear.e
	EnemyMinions:update()
	for _, minion in pairs(EnemyMinions.objects) do
		if minion and not minion.dead and minion.visible then
			if GetDistanceSqr(minion) < Spells.Q.range * Spells.Q.range and QOn then
				CastSpell(_Q, minion.x, minion.z)
			end
			if GetDistanceSqr(minion) < Spells.W.range * Spells.W.range and WOn then
				CastSpell(_W)
			end
		end
	end
	JungleMinions:update()
	for _, jungleminion in pairs(JungleMinions.objects) do
		if jungleminion and not jungleminion.dead and jungleminion.visible then
			if GetDistanceSqr(jungleminion) < Spells.Q.range * Spells.Q.range and QOn then
				CastSpell(_Q, jungleminion.x, jungleminion.z)
			end
			if GetDistanceSqr(jungleminion) < Spells.W.range * Spells.W.range and WOn then
				CastSpell(_W)
			end
			if GetDistanceSqr(jungleminion) < Spells.Q.range * Spells.Q.range and EOn then
				CastSpell(_E, jungleminion.x, jungleminion.z)
			end
		end
	end
end

function Orb(target)
    if target and CanAttack() and ValidTarget(target, AARange(target)) then
      	Attack(target)
    elseif CanMove() then
    	local MovePos = Vector(myHero) + 400 * (Vector(mousePos) - Vector(myHero)):normalized()
    	local AARange = target and AARange(target)
        if not target then
            Packet('S_MOVE', { x = MovePos.x, y = MovePos.z }):send()
        elseif target and not InRange(target) then
        	Packet('S_MOVE', { x = MovePos.x, y = MovePos.z }):send()
		end
    end
end

function CanAttack()
	return Clock() + Latency()  > Orbwalking.lastAA
end

function AARange(target)
	return myHero.range + myHero.boundingRadius + target.boundingRadius
end

function InRange(target)
	return GetDistanceSqr(target.visionPos, myHero.visionPos) < AARange(target) * AARange(target)
end

function Attack(target)
	Orbwalking.lastAA = Clock() + Latency()
	Packet('S_MOVE', {type = 3, targetNetworkId = target.networkID}):send()
end

function CanMove()
	return Clock() + Latency() > (Orbwalking.lastAA + WindUpTime())
end

function WindUpTime()
	return (1 / (myHero.attackSpeed * Orbwalking.windUp))
end

function Latency()
	return GetLatency() / 2000
end

function Clock()
	return os.clock()
end

function ResetAA()
	Orbwalking.lastAA = 0
end