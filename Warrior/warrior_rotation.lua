-- Hold
if not cache then cache = true
	-- Configuration [srt]
	rage_for_heroic = 50
	-- Configuration [end]
	
	target = "target"
	player = "player"
	
	SpellNames = {}
	Spells = {
		MORTAL_STRIKE = 47486,
		EXECUTE = 47471,
		OVERPOWER = 7384,
		HEROIC_STRIKE = 47450
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
end

-- Script
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