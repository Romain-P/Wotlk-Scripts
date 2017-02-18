-- Hold
if not cache then cache = true
    -- Configuration [srt]
    rage_for_heroic = 75
	rage_for_execute = 30
    ahk_rate = 0.01
	show_frame = true
	show_errors = true
	protected_interrupt = true
	
	Weapons = {
		TWO_HANDS = "Shadowmourne",
		LEFT = "Wrathful Gladiator's Handaxe",
		RIGHT = "Wrathful Gladiator's Shield Wall"
	}
    -- Configuration [end]
	
    target = "target"
    player = "player"
	player_name = UnitName(player)
	enemy = "enemy"
	ally = "ally"
	gdc_value = 1.5
	enabled = false
	
	Customcast = {
		ID = 0,
		DELAY = 0,
		UNIT = nil
	}
    
    SpellNames = {}
	SpellIds = {}
    Spells = {
        MORTAL_STRIKE = 47486,
        EXECUTE = 47471,
        OVERPOWER = 7384,
        HEROIC_STRIKE = 47450,
		REND = 47465,
		REVENGE = 57823,
		HAMSTRING = 1715,
		SHATTERING_THROW = 64382,
		RETALIATION = 20230,
		BLADESTORM = 46924,
		HEROIC_THROW = 57755,
		THUNDER_CLAP = 47502,
		SWEEPING_STRIKES = 12328,
		ENRAGED_REGENERATION = 55694,
		PIERCING_HOWL = 12323,
		DEMORALIZING_SHOUT = 47437,
		COMMANDING_SHOUT = 47440,
		BATTLE_SHOUT = 47436,
		WHIRLWIND = 1680,
		DISARM = 676,
		REFLECT = 23920,
		WALL = 871,
		BLOCK = 2565,
		BASH = 72,
		PUMMEL = 6552,
		RECKLESSNESS = 1719,
		FEAR = 5246,
		CHARGE = 11578,
		INTERCEPT = 20252,
		SUNDER_ARMOR = 7386,
		INTERVENE = 3411,
		RAGE = 2687,
		BERSERKER_RAGE = 18499
    }
	
	local var = nil
	for _,v in pairs(Spells) do
		var = select(1, GetSpellInfo(v))
		if var ~= nil then
			SpellNames[v] = var
			SpellIds[strlower(var)] = v
		end
    end
	
	-- Returns the spell id of a given spell name
	function GetSpellId(spellname)
		return SpellIds[strlower(spellname)]
	end
	
	Stances = {
		BATTLE = 1,
		DEFENSIVE = 2,
		BERSERKER = 3
	}
	
	Auras = {
		DIVINE_SHIELD = 642,
		AURA_MASTERY = 31821,
		HAND_PROTECTION = 10278,
		BURNING_DETERMINATION = 54748,
		OVERPOWER_PROC = 60503,
		FAKE_DEATH = 5384,
		SCATTER = 19503,
		REPENTANCE = 20066,
		BLIND = 2094,
		HOJ = 10308,
		SEDUCTION = 6358,
		SEDUCTION2 = 6359,
		STEALTH = 1784,
		VANISH = 26889,
		SHADOWMELD = 58984,
		PROWL = 5215,
		BLADESTORM = 46924,
		SHADOW_DANCE = 51713,
		AVENGING_WRATH = 31884,
		HUNT_DISARM = 53359,
		WAR_DISARM = 676,
		ROGUE_DISARM = 51722,
		SP_DISARM = 64058,
		FEAR = 6215,
		PSYCHIC_SCREAM = 10890,
		HOWL_OF_TERROR = 17928,
		GOUGE = 1776,
		ENRAGED_REGENERATION = 55694,
		SHAMAN_NATURE_SWIFTNESS = 16188,
		DRUID_NATURE_SWIFTNESS = 17116,
		ELEMENTAL_MASTERY = 16166,
		PRESENCE_OF_MIND = 12043,
		CYCLONE = 33786,
		DETERRENCE = 19263,
		PIERCING_HOWL = 12323,
		HAND_FREEDOM = 1044,
		MASTER_CALL = 54216,
		DEEP = 44572,
		ICEBLOCK = 45438,
		HOT_STREAK = 48108,
		COILE = 47860,
		BLOODRAGE = 29131,
		BERSERKER_RAGE = 18499,
		ENRAGE = 57522
	}
	
	-- Reload functions
	function Reload()
		cache = false
		print("Applied: next click gonna reload the script.")
	end
	
    -- Return true if the Cooldown of a given spell is reset (with gcd or not) 
    function CdRemains(spellId, gcd)
        if gcd == nil then gcd = true end
        local duration = select(2, GetSpellCooldown(spellId))
        
        if gcd then
            return not (duration
                + (select(1, GetSpellCooldown(spellId)) - GetTime()) >= 0)
        else
            return gdc_value - duration >= 0
        end
    end
    
    -- Return true if a given spell can be casted
    function Cast(id, unit)
        unit = unit or player
        if CdRemains(id, false) 
		and (unit == player or IsSpellInRange(SpellNames[id], unit) == 1) then
            CastSpellByID(id, unit)
            return true
        end
        return false
    end
	
	-- Return the current player stance
	function GetStance()
		return GetShapeshiftForm()
	end
    
    -- Return the current player rage
    function GetRage()
        return UnitPower(player, 1)
    end
    
    -- Return true if a given unit is under <id> dot for more than 3 seconds
    function HasDot(id, unit)
        local dot = select(7, UnitDebuff("target", GetSpellInfo(id)))
        return dot ~= nil and dot - GetTime() >= 3
    end
	
	-- Return true if a given aura is present on a given unit
	function HasAura(id, unit)
		unit = unit or player
		return UnitDebuff(unit, GetSpellInfo(id)) ~= nil 
			or select(11, UnitAura(unit, GetSpellInfo(id))) == id
	end
	
	-- Return true if a given type is checked
	function ValidUnitType(unitType, unit)
		local isEnemyUnit = UnitCanAttack(player, unit) == 1
		return (isEnemyUnit and unitType == enemy)
			or (not isEnemyUnit and unitType == friend)
	end
	
	-- Return if a given unit exists, isn't dead
	function ValidUnit(unit, unitType) 
		return UnitExists(unit)==1 and ValidUnitType(unitType, unit)
	end
	
	-- Return true if a given unit health is under a given percent
	function HealthIsUnder(unit, percent)
		return (((100 * UnitHealth(unit) / UnitHealthMax(unit))) < percent)
	end
	
	-- Return true if the whole party has health > x
	function HealthTeamNotUnder(percent) 	
		for _, unit in ipairs(Friends) do
			if UnitExists(unit) and HealthIsUnder(unit, percent) then
				return false	
			end
		end
		return true
	end
	
	-- Return true if a given unit isn't overpower protected
	function IsOverpowerProtected(unit)
		return HasAura(Auras.DIVINE_SHIELD, unit)
			or HasAura(Auras.HAND_PROTECTION, unit)
			or HasAura(Auras.CYCLONE, unit)
			or HasAura(Auras.ICEBLOCK, unit)
	end
	
	-- Return true if a given unit isn't dmg protected
	function IsDamageProtected(unit)
		return IsOverpowerProtected(unit) or HasAura(Auras.DETERRENCE, unit)
	end
	
	-- Return true if a given unit isn't cast-cancelable
	function IsProtectedUnit(unit)
		return IsDamageProtected(unit)
			or HasAura(Auras.AURA_MASTERY, unit) 
			or HasAura(Auras.BURNING_DETERMINATION, unit)
	end
	
	-- Return true if the player has a two_hands weapon equipped (defined in config part)
	function TwoHandsEquipped()
		return IsEquippedItem(Weapons.TWO_HANDS) == 1
	end
	
	-- Gonna cast the given spell before the global rotation
	function CustomCast(name, unit)
		unit = unit or player
		local id = GetSpellId(name)
		if id == nil then
			if show_errors then
				print("ERROR: '"..name.."' is undefined spell")
			end
			return
		elseif not CdRemains(id, false) then
			if show_errors then
				print("GCD: "..name.." not ready yet")
			end
			return
		elseif not UnitExists(unit) then
			if show_errors then
				print("ERROR: '"..unit.."' is undefined unit")
			end
			return
		elseif (id == Spells.BASH or id == Spells.PUMMEL) then
			local cast, _, _, _, _, _, _, _, _ = UnitCastingInfo(unit)
			local chan, _, _, _, _, _, _, _, _ = UnitChannelInfo(unit)
			if (cast ~= nil and IsProtectedUnit(unit))
			or (chan ~= nil and IsProtectedUnit(unit)) then
				if show_errors then
					print("BLOCKED: can't interrupt protected '"..unit.."'")
				end
				return
			elseif cast == nil and chan == nil and protected_interrupt then
				if show_errors then
					print("BLOCKED: nothing to interrupt")
				end
				return
			end
			
			SpellStopCasting()
			if GetRage() < 10 and not CdRemains(Spells.RAGE) then
				if show_errors then
					print("ERROR: not enough rage for interrupt '"..unit.."'")
				end
				return
			end
		elseif id == Spells.REFLECT or id == Spells.DISARM or id == Spells.INTERVENE then
			SpellStopCasting()
			
			local required_rage = 15
			if id == Spells.INTERVENE then
				required_rage = 10
			end
			if GetRage() < required_rage and not CdRemains(Spells.RAGE) then
				if show_errors then
					print("ERROR: not enough rage for '"..name.."'")
				end
				return
			end
		elseif IsProtectedUnit(unit) and id ~= Spells.SHATTERING_THROW then
			if show_errors then
				print("BLOCKED: can't '"..name.."' protected '"..unit.."'")
			end
			return
		elseif id == Spells.ENRAGED_REGENERATION 
		and not HasAura(Auras.BLOODRAGE) and not HasAura(Auras.BERSERKER_RAGE)
		and not HasAura(Auras.ENRAGE) and not CdRemains(Spells.RAGE) then
			if show_errors then
				print("ERROR: rage effect required for regen.")
			end
			return
		elseif id == Spells.INTERCEPT then
			SpellStopCasting()
			if GetRage() < 10 and not CdRemains(Spells.RAGE) then
				if show_errors then
					print("ERROR: not enough rage for intercept")
				end
				return
			end
		elseif id == Spells.FEAR or id == Spells.SHATTERING_THROW
			or id == Spells.BLADESTORM then
			SpellStopCasting()
			
			if GetRage() < 5 and GetRage() < 25 and not CdRemains(Spells.RAGE) then
				if show_errors then
					print("ERROR: not enough rage for '"..name.."'")
				end
				return
			end
		end
		
		Customcast.UNIT = unit
		Customcast.ID = id;
		Customcast.DELAY = GetTime()
	end
	
	-- Auto rage and swap stances/weapons for some spells
	function OnSpecialCases(id)
		if id == Spells.REFLECT or id == Spells.BASH 
		or id == Spells.WALL or id == Spells.INTERVENE
		or id == Spells.DISARM or id == Spells.BLOCK then
			if id ~= Spells.INTERVENE then
				if TwoHandsEquipped() and id ~= Spells.DISARM then
					EquipItemByName(Weapons.LEFT, 16)
					EquipItemByName(Weapons.RIGHT, 17)
				end
				if id ~= Spells.WALL and id ~= Spells.BLOCK and GetRage() < 15 then
					Cast(Spells.RAGE)
				end
			elseif GetRage() < 10 then
				Cast(Spells.RAGE)
			end
			
			if GetStance() == Stances.BERSERKER 
			or (GetStance() == Stances.BATTLE and
				id ~= Spells.BASH and id ~= Spells.REFLECT) then
				
				local future = Stances.DEFENSIVE
				
				if GetStance() == Stances.BERSERKER and
				(id == Spells.BASH or id == Spells.REFLECT) then
					future = Stances.BATTLE
				end
				
				CastShapeshiftForm(future)
			end
		
		elseif (id == Spells.PUMMEL or id == Spells.RECKLESSNESS
			or id == Spells.INTERCEPT) and GetStance() ~= Stances.BERSERKER then
			if id ~= Spells.RECKLESSNESS and GetRage() < 10 then
				Cast(Spells.RAGE)
			end
			CastShapeshiftForm(Stances.BERSERKER)
		
		elseif (id == Spells.FEAR or id == Spells.SHATTERING_THROW
			 or id == Spells.BLADESTORM)
		and GetRage() >= 5 and GetRage() < 25 then
			Cast(Spells.RAGE)
		
		elseif id == Spells.ENRAGED_REGENERATION 
		and ((not HasAura(Auras.BLOODRAGE) and not HasAura(Auras.BERSERKER_RAGE)
		and not HasAura(Auras.ENRAGE)) or GetRage() < 15) then
			Cast(Spells.RAGE)
		
		elseif id == Spells.BERSERKER_RAGE and HasAura(Spells.ENRAGED_REGENERATION) then
			RunMacroText("/cancelaura "..SpellNames[Spells.ENRAGED_REGENERATION])
		
		elseif id == Spells.CHARGE and GetStance() ~= Stances.BATTLE then
			CastShapeshiftForm(Stances.BATTLE)
		
		elseif id == Spells.INTERCEPT then
			if GetRage() < 10 then
				Cast(Spells.RAGE)
			end
			if GetStance() ~= Stances.BERSERKER then
				CastShapeshiftForm(Stances.BERSERKER)
			end	
		end
	end

	-- Cast the increasing-dmg rotation
    function Rotation()
		if Customcast.ID ~= 0 then
			if GetTime() - Customcast.DELAY <= gdc_value then
				if Cast(Customcast.ID, Customcast.UNIT) then
					OnSpecialCases(Customcast.ID)
				end
				return
			else
				Customcast.ID = 0
			end
		end
		if not ValidUnit(target, enemy) then return
		elseif IsDamageProtected(target) then
			if not IsOverpowerProtected(target) and GetStance() == Stances.BATTLE then
				Cast(Spells.OVERPOWER, target)
			end
			return
		end
		RunMacroText("/startattack")
        if UnitCastingInfo(target) or UnitChannelInfo(target)
        or HasDot(Spells.MORTAL_STRIKE, target) or not CdRemains(Spells.MORTAL_STRIKE, false) then
            if IsUsableSpell(SpellNames[Spells.OVERPOWER]) and GetStance() == Stances.BATTLE then
                Cast(Spells.OVERPOWER, target)
            end
            if IsUsableSpell(SpellNames[Spells.EXECUTE]) and GetRage() >= rage_for_execute
			and GetStance() ~= Stances.DEFENSIVE then
                Cast(Spells.EXECUTE, target)
            end
			if IsUsableSpell(SpellNames[Spells.REVENGE])
			and GetStance() == Stances.DEFENSIVE then
				Cast(Spells.REVENGE, target)
			end
        end
        if not Cast(Spells.MORTAL_STRIKE, target) and GetRage() > rage_for_heroic then
            Cast(Spells.HEROIC_STRIKE, target)
        end
		if GetStance() ~= Stances.BERSERKER
		and not HasDot(Spells.REND, target)
		and (HasDot(Spells.MORTAL_STRIKE, target)
			or not CdRemains(Spells.MORTAL_STRIKE, false)
			or not HealthIsUnder(target, 80)) then
			Cast(Spells.REND, target)
		end
    end
	
	local combatFrame = CreateFrame("FRAME", nil, UIParent)
	combatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	combatFrame:SetScript("OnEvent", 
		function(self, event, _, type,  _, caster, _, _, target, _, spell)
			if type == "SPELL_CAST_SUCCESS" 
			and caster == player_name
			and spell == Customcast.ID then
				Customcast.ID = 0
				Customcast.DELAY = 0
			end
		end
	)
	
	-- Square frame (red/green)
    rate_counter = 0
    frame = CreateFrame("Frame", nil, UIParent)
	if show_frame then
		frame:SetMovable(true)
		frame:EnableMouse(true)
		frame:RegisterForDrag("LeftButton")
		frame:SetScript("OnDragStart", frame.StartMoving)
		frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
		frame:SetPoint("CENTER")
		frame:SetWidth(24)
		frame:SetHeight(24)
		texture = frame:CreateTexture("ARTWORK")
		texture:SetAllPoints()
		texture:SetTexture(1.0, 0, 0)
	else
		frame:Show()
	end
    frame:SetScript("OnUpdate", function(self, elapsed)
        rate_counter = rate_counter + elapsed
        if enabled and rate_counter > ahk_rate then
            Rotation()
            rate_counter = 0
        end
    end)
	
	-- Enable the rotation
	function Disable()
		enabled = false
		if show_frame then
			texture:SetTexture(1.0, 0, 0)
		end
	end
	
	-- Disable the rotation
	function Enable()
		enabled = true
		if show_frame then
			texture:SetTexture(0, 1.0, 0)
		end
	end
	
	print("[WarrScripts] Created by Romain. /reload to disable the frame.")
	print("See updates on https://github.com/romain-p/wotlk-scripts")
end

-- Script
if enabled then
	Disable()
else
	Enable()
end