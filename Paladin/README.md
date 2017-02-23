Paladin Scripts!
===================


Enable this script to get special macros and auras/event analizing.  
The patch **patch-4.mpq** modifies the range of Exorcism (rank 2) as Melee Range (needed for fake cast).  
Place it in *wow/data/*  
SafeCast is a macro allowing you to cast a spell safely. That's to say it will check if the target is protected
before casting.

    #showtooltip Spell Name
    /script SafeCast("Spell Name", "Unit")
    
You also have 2 other functions for sacrifice, and healing a given unit. See @macro-list

----------
Configuration
-------------

You can configurate a few this script by modifying the following lines in the script
	
    ahk_rate = 0.10             -- Time between each analize (faster if reduced, but it takes fps)
	show_frame = true           -- Show the red/green square
	show_errors = true          -- Show errors (related to SafeCasts)
    
    -- Depends on ur localization, change names if you're not under ENGLISH client
    Totems = {
        TYPE = "Totem",
        TREMOR = "Tremor Totem",
        GROUNDING = "Grounding Totem",
        EARTHBIND = "Earthbind Totem",
        MANA = "Mana Tide Totem"
    }

----------
Macros list
-------------

    #showtooltip Holy Shock
    /script Heal(player)

    #showtooltip Holy Shock
    /script Heal("party1")

    #showtooltip Divine Sacrifice
    /script Sacrifice("party1")

    #showtooltip Hammer of Justice
    /script SafeCast("Hammer of Justice", target)

    #showtooltip Judgement of Justice
    /script SafeCast("Judgement of Justice", target)

    #showtooltip Judgement of Light
    /script SafeCast("Judgement of Light", target)

    #showtooltip Judgement of Wisdom
    /script SafeCast("Judgement of Wisdom", target)

    #showtooltip Holy Shock
    /script SafeCast("Holy Shock", target)
