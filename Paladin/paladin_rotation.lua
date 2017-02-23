-- Hold
if not cache then cache = true
	-- Configuration [srt]
	ahk_rate = 0.10
	show_frame = true
	show_errors = true
    
    Totems = {
        TYPE = "Totem",
        TREMOR = "Tremor Totem",
        GROUNDING = "Grounding Totem",
        EARTHBIND = "Earthbind Totem",
        MANA = "Mana Tide Totem"
    }
    -- Configuration [end]
	
    target = "target"
    player = "player"
	player_name = UnitName(player)
	enemy = "enemy"
	ally = "ally"
    gcd_value = 1.5
    enabled = false
    
    SpellNames = {}
	SpellIds = {}
    Spells = {
        HOLY_SHOCK = 48825,
        FLASH_HEAL = 48785,
        HOJ = 10308,
        SACRIFICE = 64205,
        HAND_SACRIFICE = 6940,
        TAUNT = 62124,
        JUDGEMENT = 20271,
        JUDGEMENT_OF_JUSTICE = 53407,
        HOLY_WRATH = 48817,
        FEAR = 10326,
        SEDUCTION = 6358
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
		ENRAGE = 57522,
        GROUNDING_TOTEM = 8178,
        BEAST = 34471,
        LICHBORN = 49039,
        MAGIC_SHIELD = 48707
	}
    
    ArenaEnemies = {
		"arenapet1",
		"arenapet2",
		"arena1",
		"arena2",
		"arena1pet",
		"arena2pet",
        "target",
        "mouseover"
        "focus",
	}

	Enemies = {
		"target",
		"targettarget",
		"focustarget",
		"focus",
		"mouseover"
	}
    
    -- Return true if the player is playing in Arena
	function IsArena()
		return select(1, IsActiveBattlefieldArena()) == 1
	end

	-- Return an enemy array depending on the current area of the player
	function GetEnemies()
		if IsArena() then
			return ArenaEnemies
		else
			return Enemies
		end
	end
	
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
            return gcd_value - duration >= 0
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

	-- Return true if a given unit isn't dmg protected
	function IsDamageProtected(unit)
		return HasAura(Auras.DIVINE_SHIELD, unit)
            or HasAura(Auras.HAND_PROTECTION, unit)
            or HasAura(Auras.CYCLONE, unit)
            or HasAura(Auras.ICEBLOCK, unit)
            or HasAura(Auras.DETERRENCE, unit)
            or HasAura(Auras.GROUNDING_TOTEM, unit)
            or HasAura(Auras.BEAST, unit)
            or HasAura(Auras.MAGIC_SHIELD, unit)
	end
    
    -- Return true if a given unit is under 10 yards range
    function In10yards(unit)
        return IsSpellInRange(SpellNames[Spells.JUDGEMENT_OF_JUSTICE], unit) == 1
    end
    
    -- Cast healing spells on a given unit
    function Heal(unit)
        if not Cast(Spells.HOLY_SHOCK, unit) then
            Cast(Spells.FLASH_HEAL, unit)
        end
    end
    
    -- Cast sacrifices
    function Sacrifice(unit)
        if not Cast(Spells.SACRIFICE)
        and not Cast(Spells.HAND_SACRIFICE, unit) then
            if show_errors then
                print("ERROR: no cd remains")
            end
        end
    end
    
    -- Safe cast
    function SafeCast(spell, unit)
        if not IsDamageProtected(unit) then
            CastSpellByName(spell, unit)
        elseif show_errors then
            print("ERROR: can't cast '"..spell.."' on protected target")
        end
    end
    
    -- Analizing totems
    function AnalizeTotem(totem, unit)
        if strmatch(totem, Totems.TYPE) == nil then return false end
        local melee = false
        
        if totem == Totems.GROUNDING
        or totem == Totems.TREMOR
        or totem == Totems.EARTHBIND
        or totem == Totems.MANA then
            melee = true
            
            if totem ~= Totems.MANA
            and not Cast(Spells.TAUNT, unit)
            and not Cast(Spells.JUDGEMENT, unit) then
               melee = true 
            elseif not Cast(Spells.TAUNT, unit)
            and not Cast(Spells.HOLY_SHOCK, unit)
            and not Cast(Spells.JUDGEMENT, unit) then
               melee = true
            end
            
            if melee and unit ~= target then
                TargetUnit(unit)
            end
            if melee then
                RunMacroText("/startattack")
            end
        else
            RunMacroText("/startattack")
        end
        return true
    end
    
    -- Analizing Auras
    function AnalizeAuras(unit)
        if HasAura(Auras.LICHBORN, unit) then
            if In10yards(unit)
            and not IsDamageProtected(unit)
            and not Cast(Spells.HOLY_WRATH) then
                SpellStopCasting()
                Cast(Spells.FEAR, unit)
            end
        elseif (HasAura(Auras.VANISH, unit)
         or HasAura(Auras.SHADOWMELD, unit))
         and not Cast(Spells.JUDGEMENT, unit)
         and Cast(Spells.HOLY_SHOCK, unit) then
            SpellStopCasting()
        else
            return false
        end
        return true
    end
    
    -- Analizing units :D
    function ListeningUnits()
        for _, unit in ipairs(GetEnemies()) do
            if ValidUnit(unit, enemy) then
                local unit_name = UnitName(unit)
                
                if not AnalizeTotem(unit_name, unit) 
                and not AnalizeAuras(unit) then
                    local cast, _, _, _, _, _, _, _, _ = UnitCastingInfo(unit)
                    local chan, _, _, _, _, _, _, _, _ = UnitChannelInfo(unit)
                    
                    if cast == SpellNames[Spells.SEDUCTION]
                    or chan == SpellNames[Spells.SEDUCTION] then
                        if In10yards(unit)
                        and not IsDamageProtected(unit)
                        and not Cast(Spells.HOLY_WRATH)
                        and Cast(Spells.FEAR, unit) then
                            SpellStopCasting()
                        end
                    end
                end
            end
        end
    end
	
	local combatFrame = CreateFrame("FRAME", nil, UIParent)
	combatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	combatFrame:SetScript("OnEvent", 
		function(self, event, _, type,  _, caster, _, _, target, _, spell)
			if type == "SPELL_CAST_SUCCESS" then
                
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
            ListeningUnits();
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
	
	print("[PaladinScripts] Created by Romain. /reload to disable the frame.")
	print("See updates on https://github.com/romain-p/wotlk-scripts")
end

-- Script
if enabled then
	Disable()
else
	Enable()
end
