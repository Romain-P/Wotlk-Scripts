Priest Scripts!
===================


Enable this script to get special macros and auras/event analizing.  
The patch **patch-4.mpq** modifies the range of Smite (rank 2) as Melee Range (needed for fake cast).  
Place it in *wow/data/*  
Heal is an auto-rotation function for healing.
before casting.

    #showtooltip Penance
    /script Heal("Unit")
    
> **Note:**

> - Units can be enemy units such as **player, party1, party2 etc..**
> - You can add everything you want before the script *(e.g /stopcasting)*
    
You also have 2 other functions for dots and dps a given unit. See @macro-list  
Configuration
-------------

You can configurate a few this script by modifying the following lines in the script
	
    ahk_rate = 0.10             -- Time between each analize (faster if reduced, but it takes fps)
	show_frame = true           -- Show the red/green square
	show_errors = true          -- Show errors (related to SafeCasts)
    
    -- Depends on ur localization, change names if you're not under ENGLISH client
    Totems = {
        TYPE = "Totem",
        TREMOR = "Tremor Totem"
    }  
Macros list
-------------

    #showtooltip null
    /script Dot("target")

    #showtooltip Holy Fire
    /script Dps("target")