Warrior Scripts!
===================


Enable this script one time and an auto-rotation gonna attack itself your target.
If you wanna cast manually a spel, simply create a macro with the following content: 

    #showtooltip Spell Name
    /script CustomCast("Spell Name", "Unit")

> **Note:**

> - Showtooltip is gonna put the spell icon with its gcd on your macro
> - Units can be **target, focus, party1, party2, mouseover etc..**
> - Don't put any unit if you wanna cast a spell on yourself.
> - You can add everything you want before the script *(e.g /cancelaura Bladestorm)*

Some spells are listened by this function. That is to say it gonna do required actions to cast some spells.
For example, if you use **CustomCast("Shield Bash", "target")**, it gonna check for rage if you don't have anough rage, and change your weapon to one hand and a shield, then it gonna cast Shield Bash in the next GCD.

----------
Configuration
-------------

You can configurate a few this script by modifying the following lines in the script

    rage_for_heroic = 75  -- Min rage for cast heroic strike
    rage_for_execute = 30 -- Min rage for cast execute
    ahk_rate = 0.01       -- AutoHotKeys delay, between each 'tried-cast'
    show_frame = true     -- Show or not the green/red square
    show_errors = true    -- Show errors in chat (related to your custom casts)
    protected_interrupt = true -- Interrupts can't be fake if set on true
   
    -- Just replace values between "" by your weapons
    Weapons = {
	    TWO_HANDS = "Shadowmourne",
	    LEFT = "Wrathful Gladiator's Handaxe",
	    RIGHT = "Wrathful Gladiator's Shield Wall"
    }
    
----------
Macros list
-------------
    #showtooltip Bladestorm
    /script CustomCast("Bladestorm")

    #showtooltip Shield Block
    /script CustomCast("Shield Block")

    #showtooltip Recklessness
    /script CustomCast("Recklessness")

    #showtooltip Shield Wall
	/script CustomCast("Shield Wall")

	#showtooltip Spell Reflection
	/script CustomCast("Spell Reflection")

    #showtooltip Retaliation
	/script CustomCast("Retaliation")

    #showtooltip Piercing Howl
	/script CustomCast("Piercing Howl")

	#showtooltip Berserker Rage
	/script CustomCast("Berserker Rage")

	#showtooltip Enraged Regeneration
	/script CustomCast("Enraged Regeneration")

	#showtooltip Commanding Shout
	/script CustomCast("Commanding Shout")

	#showtooltip Battle Shout
	/script CustomCast("Battle Shout")

	#showtooltip Demoralizing Shout
	/script CustomCast("Demoralizing Shout")

    #showtooltip Intervene
	/script CustomCast("Intervene", "party1")

	#showtooltip Heroic Throw
	/script CustomCast("Heroic Throw", "target")

	#showtooltip Charge
	/script CustomCast("Charge", "target")

	#showtooltip Intercept
	/script CustomCast("Intercept", "target")

	#showtooltip Intercept
	/script CustomCast("Intercept", "focus")

	#showtooltip Disarm
	/script CustomCast("Disarm", "target")

	#showtooltip Shield Bash
	/script CustomCast("Shield Bash", "target")

	#showtooltip Pummel
	/script CustomCast("Pummel", "target")

	#showtooltip Hamstring
	/script CustomCast("Hamstring", "target")

	#showtooltip Shattering Throw
	/cancelaura bladestorm
	/script CustomCast("Shattering Throw", "target")

	#showtooltip Intimidating Shout
	/script CustomCast("Intimidating Shout", "focus")