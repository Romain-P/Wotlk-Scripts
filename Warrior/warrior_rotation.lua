-- Hold
if not cache then cache = true
    -- Configuration [srt]
    rage_for_heroic = 50
    ahk_rate = 0.05
    -- Configuration [end]
    
    target = "target"
    player = "player"
	enemy = "enemy"
	ally = "ally"
	ahk_mode = false
    
    SpellNames = {}
    Spells = {
        MORTAL_STRIKE = 47486,
        EXECUTE = 47471,
        OVERPOWER = 7384,
        HEROIC_STRIKE = 47450
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
		COILE = 47860
	}
    
    for u,v in pairs(Spells) do
        SpellNames[v] = select(1, GetSpellInfo(v))
    end
    
    -- Return true if the Cooldown of a given spell is reset (with gcd or not) 
    function CdRemains(spellId, gcd)
        if gcd == nil then gcd = true end
        local duration = select(2, GetSpellCooldown(spellId))
        
        if gcd then
            return not (duration
                + (select(1, GetSpellCooldown(spellId)) - GetTime()) >= 0)
        else
            return 1.5 - duration >= 0
        end
    end
    
    -- Return true if a given spell can be casted
    function Cast(id, unit)
        unit = unit or player
        if CdRemains(id, false) then
            CastSpellByID(id, target)
            return true
        end
        return false
    end
    
    -- Return the current player rage
    function GetRage()
        return UnitPower(player, 1)
    end
    
    -- Return true if a given unit is under mortal_strike dot for more than 3 seconds
    function HasMs(unit)
        local mortal = select(7, UnitDebuff("target", GetSpellInfo(Spells.MORTAL_STRIKE)))
        return mortal ~= nil and GetTime() - mortal > 3
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

	-- Cast the increasing-dmg rotation
    function Rotation()
		if not ValidUnit(target, enemy) then return
		elseif IsDamageProtected(target) then
			if not IsOverpowerProtected(target) then
				Cast(Spells.OVERPOWER, target)
			end
			return
		end
        if UnitCastingInfo(target) or UnitChannelInfo(target)
        or HasMs(target) or not CdRemains(Spells.MORTAL_STRIKE, false) then
            if IsUsableSpell(SpellNames[Spells.OVERPOWER]) then
                Cast(Spells.OVERPOWER, target)
            end
            if IsUsableSpell(SpellNames[Spells.EXECUTE]) and GetRage() >= 30 then
                Cast(Spells.EXECUTE, target)
            end
        end
        if not Cast(Spells.MORTAL_STRIKE, target) and GetRage() > rage_for_heroic then
            Cast(Spells.HEROIC_STRIKE, target)
        end
    end

	-- Square frame (red/green)
    rate_counter = 0
    frame = CreateFrame("Frame",nil,UIParent)
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
    frame:SetScript("OnUpdate", function(self, elapsed)
        rate_counter = rate_counter + elapsed
        if ahk_mode and rate_counter > ahk_rate then
            Rotation()
            rate_counter = 0
        end
    end)
	
	function DisableAhk()
		ahk_mode = false
		texture:SetTexture(1.0, 0, 0)
	end
end

-- Script
if ahk_mode then
	DisableAhk()
else
	ahk_mode = true
	texture:SetTexture(0, 1.0, 0)
end