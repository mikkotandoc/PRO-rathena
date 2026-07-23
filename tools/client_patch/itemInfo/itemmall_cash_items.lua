-- Item Mall + Legendary Hunting Mission gear (insert into SystemEN/itemInfo_C.lua tbl_override).
-- Deploy: powershell -File tools/deploy_itemmall_iteminfo_patch.ps1 -ClientRoot "path\to\client"

-- Valkyrie Drop
[28564] = {
	unidentifiedDisplayName = "Unidentified Accessory",
	unidentifiedResourceName = "Valkyrie_Drop",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Valkyrie Drop [1]",
	identifiedResourceName = "Valkyrie_Drop",
	identifiedDescriptionName = {
		"Crystallized tears of a battle maiden.",
		"------------------------",
		"SP Recovery + 50%, Variable Cast Time - 10%, After Cast Delay - 5%.",
		"Oratio variable cast - 50%, fixed cast - 100%.",
		"Magnus Exorcismus damage increases with Base Level and Impositio Manus.",
		"------------------------",
		"^0000CCType:^000000 Accessory",
		"^0000CCWeight:^000000 30",
		"^0000CCRequired Level:^000000 100"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Gothic Heart Hairband-LT
[400433] = {
	unidentifiedDisplayName = "Unidentified Hat",
	unidentifiedResourceName = "Gothic_HW_TW_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Gothic Heart Hairband-LT [1]",
	identifiedResourceName = "Gothic_HW_TW_LT",
	identifiedDescriptionName = {
		"A gothic heart-themed hairband with lingering power.",
		"------------------------",
		"Max HP + 10%, After Cast Delay + 8% (reduced by refine).",
		"Max HP + 3000 per 3 refine levels.",
		"------------------------",
		"^0000CCType:^000000 Headgear",
		"^0000CCWeight:^000000 30"
	},
	slotCount = 1,
	ClassNum = 2372,
	costume = false
},
-- Apollo Armor-LT
[450295] = {
	unidentifiedDisplayName = "Unidentified Armor",
	unidentifiedResourceName = "Apollo_Armor_TW_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Apollo Armor-LT [1]",
	identifiedResourceName = "Apollo_Armor_TW_LT",
	identifiedDescriptionName = {
		"Light armor imbued with the sun god's radiance.",
		"------------------------",
		"Max HP + 20%, Max HP + 500 per 2 refine levels, VIT + 8 per 2 refine levels.",
		"Dragon Breath, Earth Drive, and Shield Press skill damage bonus by refine.",
		"------------------------",
		"^0000CCType:^000000 Armor",
		"^0000CCDefense:^000000 30",
		"^0000CCRequired Level:^000000 150"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Asteria's Armor-LT
[450385] = {
	unidentifiedDisplayName = "Unidentified Armor",
	unidentifiedResourceName = "Astraea_Armor_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Asteria's Armor-LT [1]",
	identifiedResourceName = "Astraea_Armor_LT",
	identifiedDescriptionName = {
		"Sacred armor of the Asteria series.",
		"------------------------",
		"Damage from all sizes - 5%, Max HP + 20%.",
		"VIT/ATK/MATK bonus and Max HP bonus scale with refine.",
		"------------------------",
		"^0000CCType:^000000 Armor",
		"^0000CCDefense:^000000 100",
		"^0000CCRequired Level:^000000 150"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Mercury Suit-LT
[450389] = {
	unidentifiedDisplayName = "Unidentified Armor",
	unidentifiedResourceName = "Mercury_Suits_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Mercury Suit-LT [1]",
	identifiedResourceName = "Mercury_Suits_LT",
	identifiedDescriptionName = {
		"A swift suit blessed by mercury's flow.",
		"------------------------",
		"ATK/MATK + 120 (+ 10 per 2 refine levels).",
		"Huuuma Shuriken and Cross Slash damage bonus by refine.",
		"Fire/Water/Wind magic damage bonus by refine.",
		"------------------------",
		"^0000CCType:^000000 Armor",
		"^0000CCDefense:^000000 30",
		"^0000CCRequired Level:^000000 150"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Asteria's Boots-LT
[470205] = {
	unidentifiedDisplayName = "Unidentified Shoes",
	unidentifiedResourceName = "Astraea_Shoes_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Asteria's Boots-LT [1]",
	identifiedResourceName = "Astraea_Shoes_LT",
	identifiedDescriptionName = {
		"Boots of the Asteria equipment line.",
		"------------------------",
		"All Basic Status + 3, MDEF + 10.",
		"Refine bonuses based on STR/AGI/VIT/INT/DEX/LUK thresholds.",
		"------------------------",
		"^0000CCType:^000000 Shoes",
		"^0000CCDefense:^000000 25",
		"^0000CCRequired Level:^000000 190"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Twinhead Dragon Boots
[470274] = {
	unidentifiedDisplayName = "Unidentified Shoes",
	unidentifiedResourceName = "Twinhead_dragon_Boots",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Twinhead Dragon Boots [1]",
	identifiedResourceName = "Twinhead_dragon_Boots",
	identifiedDescriptionName = {
		"Boots crafted from twin-headed dragon materials.",
		"------------------------",
		"Player damage reduction, Boss/Normal damage reduction.",
		"Bonuses to Dragon Breath Water and Dragonic Breath by skill level.",
		"------------------------",
		"^0000CCType:^000000 Shoes",
		"^0000CCDefense:^000000 12",
		"^0000CCRequired Level:^000000 100"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Tristan Imperial Cape-LT
[480453] = {
	unidentifiedDisplayName = "Unidentified Garment",
	unidentifiedResourceName = "Tristan_Cape_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Tristan Imperial Cape-LT [1]",
	identifiedResourceName = "Tristan_Cape_LT",
	identifiedDescriptionName = {
		"An imperial cape worn by Tristan's elite.",
		"------------------------",
		"Immune to Knockback.",
		"ATK, CON, CRT, long-range damage, and critical damage bonus by refine.",
		"------------------------",
		"^0000CCType:^000000 Garment",
		"^0000CCDefense:^000000 20",
		"^0000CCRequired Level:^000000 190"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Dimension Linkage Stone
[490336] = {
	unidentifiedDisplayName = "Unidentified Accessory",
	unidentifiedResourceName = "Dimension_L_Stone",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Dimension Linkage Stone [1]",
	identifiedResourceName = "Dimension_L_Stone",
	identifiedDescriptionName = {
		"A stone that links dimensional weapon systems.",
		"------------------------",
		"STR + 20, Max HP + 15%, Long-range physical damage + 10%.",
		"Perfect Hit + 15%, Neutral Barrier cooldown reduction.",
		"Arm Cannon, Cold Slower, and Flame Launcher damage by Base Level.",
		"------------------------",
		"^0000CCType:^000000 Accessory (Left)",
		"^0000CCRequired Level:^000000 100",
		"^0000CCClass:^000000 Blacksmith / 3rd / 4th"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Asteria's Ring-LT
[490595] = {
	unidentifiedDisplayName = "Unidentified Accessory",
	unidentifiedResourceName = "Astraea_Ring_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Asteria's Ring-LT [1]",
	identifiedResourceName = "Astraea_Ring_LT",
	identifiedDescriptionName = {
		"A ring from the Asteria equipment series.",
		"------------------------",
		"MDEF + 10, All Trait Stats + 1, Sacrament Lv.5.",
		"Physical/Magic class damage + 8%, Ignore DEF/MDEF + 10%.",
		"------------------------",
		"^0000CCType:^000000 Accessory (Left)",
		"^0000CCRequired Level:^000000 150"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Legend Hunt Scrap (crafting material; sprite from item #2181 / Hervor)
[1000700] = {
	unidentifiedDisplayName = "Legend Hunt Scrap",
	unidentifiedResourceName = "\199\236\184\163\186\184\184\163",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Legend Hunt Scrap",
	identifiedResourceName = "\199\236\184\163\186\184\184\163",
	identifiedDescriptionName = {
		"A common crafting fragment earned from hunting",
		"monsters level 220 and above.",
		"------------------------",
		"Used at the Legendary Hunting Missions NPC",
		"to forge cash shop armor and weapons.",
		"------------------------",
		"^0000CCType:^000000 Etc"
	},
	slotCount = 0,
	ClassNum = 0,
	costume = false
},
-- Rest in Peace (LHM armor)
[450439] = {
	unidentifiedDisplayName = "Unidentified Armor",
	unidentifiedResourceName = "kingly_armor",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Rest in Peace [1]",
	identifiedResourceName = "kingly_armor",
	identifiedDescriptionName = {
		"Armor emanating a quiet aura of eternal rest.",
		"------------------------",
		"Damage from Normal and Boss enemies - 15%.",
		"POW/SPL + 2 per refine, ATK/MATK + 30 per 2 refine levels.",
		"Max HP/SP, stats, and race damage bonuses at high refine.",
		"Grade bonuses include Hallucination Walk Lv. 5.",
		"------------------------",
		"^0000CCType:^000000 Armor",
		"^0000CCDefense:^000000 150",
		"^0000CCRequired Level:^000000 100"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Dragonic Shield (LHM shield)
[460117] = {
	unidentifiedDisplayName = "Unidentified Shield",
	unidentifiedResourceName = "C_Defense_Shield",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Dragonic Shield [1]",
	identifiedResourceName = "C_Defense_Shield",
	identifiedDescriptionName = {
		"A shield forged from hardened dragon scales.",
		"------------------------",
		"POW + 5, CON + 5, ATK + 50.",
		"Swordman classes: Max HP + 25,000, Exp + 25%.",
		"POW/CON/ATK per refine; STR/DEX and Max HP/SP per 2 refine.",
		"Dragon Breath damage and class resistance bonuses at +10 or higher.",
		"------------------------",
		"^0000CCType:^000000 Shield",
		"^0000CCDefense:^000000 200",
		"^0000CCRequired Level:^000000 100"
	},
	slotCount = 1,
	ClassNum = 4,
	costume = false
},
-- Kiel Successor Doll (LHM headgear)
[401043] = {
	unidentifiedDisplayName = "Unidentified Hat",
	unidentifiedResourceName = "Kiel_Egg",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Kiel Successor Doll [1]",
	identifiedResourceName = "Kiel_Egg",
	identifiedDescriptionName = {
		"A doll made in the image of Kiel's successor.",
		"------------------------",
		"ASPD + 10%, Max HP/SP + 15%, long-range physical damage + 20%.",
		"POW, long-range damage, and stat bonuses scale with refine.",
		"High refine can trigger Acid Bomb, Sharp Shooting, and Arrow Storm.",
		"------------------------",
		"^0000CCType:^000000 Headgear (Upper)",
		"^0000CCDefense:^000000 50",
		"^0000CCRequired Level:^000000 100"
	},
	slotCount = 1,
	ClassNum = 910,
	costume = false
},
-- [S2] Authority of Issgard-VG (LHM mid headgear)
[410496] = {
	unidentifiedDisplayName = "Unidentified Accessory",
	unidentifiedResourceName = "dimmension_jewelry",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "[S2] Authority of Issgard-VG [1]",
	identifiedResourceName = "dimmension_jewelry",
	identifiedDescriptionName = {
		"Proof of authority earned during the Issgard season.",
		"------------------------",
		"All Stats + 15, All Trait Stats + 15.",
		"Exp and item drop rate from all races + 15%.",
		"After Cast Delay - 15%.",
		"------------------------",
		"^0000CCType:^000000 Headgear (Middle)",
		"^FF0000This item cannot be traded, dropped, or stored in guild storage.^000000"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Dragon Thorns Plant Hero (LHM accessory)
[490787] = {
	unidentifiedDisplayName = "Unidentified Accessory",
	unidentifiedResourceName = "Wicked_Plant",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Dragon Thorns Plant Hero [1]",
	identifiedResourceName = "Wicked_Plant",
	identifiedDescriptionName = {
		"A heroic dragon thorn plant cherished by alchemists.",
		"------------------------",
		"ATK + 100, After Cast Delay - 10%, CRIT + 20.",
		"Physical damage to all classes + 15%.",
		"Alchemist classes only.",
		"------------------------",
		"^0000CCType:^000000 Accessory (Right)",
		"^0000CCRequired Level:^000000 190"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Faceworm Queen's Scale (LHM accessory)
[490791] = {
	unidentifiedDisplayName = "Unidentified Accessory",
	unidentifiedResourceName = "Fafnir_Scale",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Faceworm Queen's Scale [1]",
	identifiedResourceName = "Fafnir_Scale",
	identifiedDescriptionName = {
		"A glittering scale shed by the Faceworm Queen.",
		"------------------------",
		"MDEF + 30, Perfect Dodge + 30, POW + 15, CON + 15.",
		"ASPD + 15%, melee and ranged physical damage + 15%.",
		"Critical damage and class damage scale with Base Level.",
		"------------------------",
		"^0000CCType:^000000 Accessory",
		"^0000CCDefense:^000000 300"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Bacchus Armor-LT (Episode 20)
[450386] = {
	unidentifiedDisplayName = "Unidentified Armor",
	unidentifiedResourceName = "Bacchus_Armor_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Bacchus Armor-LT [1]",
	identifiedResourceName = "Bacchus_Armor_LT",
	identifiedDescriptionName = {
		"Armor blessed by the god of revelry, favored by gunslingers.",
		"------------------------",
		"ATK + 150 (+ 15 per 2 refine levels).",
		"Round Trip, Dragon Tail, Slug Shot, and Hammer of God damage bonus by refine.",
		"Long-range damage, all-race damage, and After Cast Delay bonuses at high refine.",
		"------------------------",
		"^0000CCType:^000000 Armor",
		"^0000CCDefense:^000000 30",
		"^0000CCRequired Level:^000000 150"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Neptune Uniform-LT (Episode 20)
[450387] = {
	unidentifiedDisplayName = "Unidentified Armor",
	unidentifiedResourceName = "Neptune_Uniform_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Neptune Uniform-LT [1]",
	identifiedResourceName = "Neptune_Uniform_LT",
	identifiedDescriptionName = {
		"A uniform carrying the deep power of the sea god.",
		"------------------------",
		"ATK/MATK + 120 (+ 10 per 2 refine levels).",
		"Solar Burst, Full Moon Kick, Esma, and Curse Explosion damage bonus by refine.",
		"ATK/MATK %, all-race damage, and After Cast Delay bonuses at high refine.",
		"------------------------",
		"^0000CCType:^000000 Armor",
		"^0000CCDefense:^000000 30",
		"^0000CCRequired Level:^000000 150"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Diana Suit-LT (Episode 20)
[450388] = {
	unidentifiedDisplayName = "Unidentified Armor",
	unidentifiedResourceName = "Diana_Suits_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Diana Suit-LT [1]",
	identifiedResourceName = "Diana_Suits_LT",
	identifiedDescriptionName = {
		"A moonlit suit tailored for Doram adventurers.",
		"------------------------",
		"ATK/MATK + 120 (+ 10 per 2 refine levels).",
		"Picky Peck, Lunatic Carrot Beat, Stem Spear, and Catnip Meteor damage bonus by refine.",
		"ATK/MATK %, all-race damage, and After Cast Delay bonuses at high refine.",
		"------------------------",
		"^0000CCType:^000000 Armor",
		"^0000CCDefense:^000000 30",
		"^0000CCRequired Level:^000000 150"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Janus Armor-LT (Episode 20)
[450391] = {
	unidentifiedDisplayName = "Unidentified Armor",
	unidentifiedResourceName = "Janus_Armor_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Janus Armor-LT [1]",
	identifiedResourceName = "Janus_Armor_LT",
	identifiedDescriptionName = {
		"Two-faced armor holding both old and new power.",
		"------------------------",
		"ATK/MATK + 120 (+ 10 per 2 refine levels).",
		"Storm Gust, Meteor Storm, Lord of Vermilion, Holy Cross, and Shield Boomerang damage bonus by refine.",
		"Super Novice: grants Soul Expansion, Wind Cutter, Cart Tornado, Varetyr Spear.",
		"------------------------",
		"^0000CCType:^000000 Armor",
		"^0000CCDefense:^000000 30",
		"^0000CCRequired Level:^000000 150"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Asteria's Helm-LT (Episode 20)
[400699] = {
	unidentifiedDisplayName = "Unidentified Hat",
	unidentifiedResourceName = "Astraea_Helm_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Asteria's Helm-LT [1]",
	identifiedResourceName = "Astraea_Helm_LT",
	identifiedDescriptionName = {
		"Sacred helm of the Asteria series.",
		"------------------------",
		"MaxHP + 5%, ATK/MATK + 15 per 2 refine levels.",
		"Damage taken from all classes, races, properties, and sizes reduced by refine.",
		"Variable/fixed cast reduction and all-size damage bonus at high refine.",
		"------------------------",
		"^0000CCType:^000000 Headgear",
		"^0000CCDefense:^000000 20",
		"^0000CCRequired Level:^000000 150"
	},
	slotCount = 1,
	ClassNum = 2565,
	costume = false
},
-- Asteria's Cloak-LT (Episode 20)
[480338] = {
	unidentifiedDisplayName = "Unidentified Garment",
	unidentifiedResourceName = "Astraea_Cape_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Asteria's Cloak-LT [1]",
	identifiedResourceName = "Astraea_Cape_LT",
	identifiedDescriptionName = {
		"Sacred cloak of the Asteria series.",
		"------------------------",
		"All Basic Stats + 2, MaxHP/MaxSP + 10%.",
		"ATK/MATK and Neutral resistance bonus by refine.",
		"All-size damage, melee/ranged/magic damage, and delay bonuses at high refine.",
		"------------------------",
		"^0000CCType:^000000 Garment",
		"^0000CCDefense:^000000 150",
		"^0000CCRequired Level:^000000 150"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Battle Aura Manteau-LT (Episode 20)
[480454] = {
	unidentifiedDisplayName = "Unidentified Manteau",
	unidentifiedResourceName = "Battle_Aura_Manteau_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Battle Aura Manteau-LT [1]",
	identifiedResourceName = "Battle_Aura_Manteau_LT",
	identifiedDescriptionName = {
		"A manteau overflowing with fighting spirit.",
		"------------------------",
		"Immune to Knockback. Enables Call Spirits Lv. 5.",
		"ATK, POW, CON, and melee/ranged damage bonus by refine.",
		"ATK + 15%, ASPD + 10% at +7; all-property damage and Perfect Hit at high refine.",
		"------------------------",
		"^0000CCType:^000000 Garment",
		"^0000CCDefense:^000000 20",
		"^0000CCRequired Level:^000000 190"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Twin Shadow Mirror Cloak-LT (Episode 20)
[480522] = {
	unidentifiedDisplayName = "Unidentified Garment",
	unidentifiedResourceName = "Dual_SW_Cape_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Twin Shadow Mirror Cloak-LT [1]",
	identifiedResourceName = "Dual_SW_Cape_LT",
	identifiedDescriptionName = {
		"A cloak reflecting twin shadows of its wearer.",
		"------------------------",
		"All Basic Stats + 5 (+ 1 per 2 refine levels).",
		"ATK/MATK, all-class and all-property damage bonus by refine.",
		"After Cast Delay, variable cast, and ASPD bonuses at high refine.",
		"------------------------",
		"^0000CCType:^000000 Garment",
		"^0000CCRequired Level:^000000 130"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Graceful Force of Nature Cloak-LT (Episode 20)
[480526] = {
	unidentifiedDisplayName = "Unidentified Garment",
	unidentifiedResourceName = "Occult_Nature_Cape_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Graceful Force of Nature Cloak-LT [1]",
	identifiedResourceName = "Occult_Nature_Cape_LT",
	identifiedDescriptionName = {
		"A cloak woven with the graceful force of nature.",
		"------------------------",
		"MATK + 15 per 2 refine levels, SPL bonus by refine.",
		"Earth/Water magic damage + 10% per 3 refine levels.",
		"MATK + 15% at +7; Elemental Master/Meister skill bonuses at high refine.",
		"------------------------",
		"^0000CCType:^000000 Garment",
		"^0000CCRequired Level:^000000 150"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Thought Ring-LT (Episode 20)
[490596] = {
	unidentifiedDisplayName = "Unidentified Accessory",
	unidentifiedResourceName = "RingOfThought_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Thought Ring-LT [1]",
	identifiedResourceName = "RingOfThought_LT",
	identifiedDescriptionName = {
		"A ring that sharpens the wearer's thoughts.",
		"------------------------",
		"After Cast Delay - 7%, ASPD + 10%. Enables Teleport Lv. 1.",
		"Physical damage to all classes + 10%, MATK + 10%.",
		"Doubled at Base Level 200 or higher.",
		"------------------------",
		"^0000CCType:^000000 Accessory (Right)",
		"^0000CCRequired Level:^000000 150"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Emerald Ring-LT (Episode 20)
[490526] = {
	unidentifiedDisplayName = "Unidentified Accessory",
	unidentifiedResourceName = "Emerald_Ring_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Emerald Ring-LT [1]",
	identifiedResourceName = "Emerald_Ring_LT",
	identifiedDescriptionName = {
		"A deep green ring loved by archers.",
		"------------------------",
		"All Basic Stats + 5 (more with Double Strafe mastery).",
		"Arrow Shower, Double Strafe, Severe Rainstorm, Reverberation,",
		"and Metallic Fury damage increase with Base Level.",
		"------------------------",
		"^0000CCType:^000000 Accessory (Right)",
		"^0000CCRequired Level:^000000 100"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Emerald Earring-LT (Episode 20)
[490527] = {
	unidentifiedDisplayName = "Unidentified Accessory",
	unidentifiedResourceName = "Emerald_Earring_LT_TW",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Emerald Earring-LT [1]",
	identifiedResourceName = "Emerald_Earring_LT_TW",
	identifiedDescriptionName = {
		"A deep green earring loved by performers.",
		"------------------------",
		"All Basic Stats + 5 (more with Music Lessons mastery).",
		"Arrow Vulcan, Melody Strike, Musical Strike, Metallic Sound,",
		"and Rose Blossom damage increase with Base Level.",
		"------------------------",
		"^0000CCType:^000000 Accessory (Left)",
		"^0000CCRequired Level:^000000 100"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Lunar Eclipse Guardian Heart-LT (Episode 20)
[490440] = {
	unidentifiedDisplayName = "Unidentified Accessory",
	unidentifiedResourceName = "Eclipsedefmind_LT",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Lunar Eclipse Guardian Heart-LT [1]",
	identifiedResourceName = "Eclipsedefmind_LT",
	identifiedDescriptionName = {
		"A guardian heart infused with lunar eclipse energy.",
		"------------------------",
		"Enables Sight Lv. 1. MaxHP + 15.",
		"Melee and ranged physical damage + 10%.",
		"Magical damage of all properties + 10%.",
		"------------------------",
		"^0000CCType:^000000 Accessory",
		"^0000CCRequired Level:^000000 190"
	},
	slotCount = 1,
	ClassNum = 0,
	costume = false
},
-- Legend Hunt Core (crafting material; sprite from item #2182 / Hervor Alvitr)
[1000701] = {
	unidentifiedDisplayName = "Legend Hunt Core",
	unidentifiedResourceName = "\199\236\184\163\186\184\184\163\190\198\184\163\186\241\198\174",
	unidentifiedDescriptionName = { "" },
	identifiedDisplayName = "Legend Hunt Core",
	identifiedResourceName = "\199\236\184\163\186\184\184\163\190\198\184\163\186\241\198\174",
	identifiedDescriptionName = {
		"A rare crafting fragment earned from hunting",
		"monsters level 220 and above.",
		"MVP monsters drop this at higher rates.",
		"------------------------",
		"Used at the Legendary Hunting Missions NPC",
		"to forge cash shop armor and weapons.",
		"------------------------",
		"^0000CCType:^000000 Etc"
	},
	slotCount = 0,
	ClassNum = 0,
	costume = false
},
