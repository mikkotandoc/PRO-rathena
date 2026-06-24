# Custom Systems

[← Back to Home](Home.md)

PRO-Ragnarok custom mechanics beyond standard Renewal. All locations are in-game coordinates.

---

## Booster Coin System

**NPC:** Centro — `prontera 166,300`  
**Data:** `npc/custom/official/booster_coin_exchange.txt`, `mega_booster.yml`

Trade **Booster Coins** for promotional gear:

- Booster hat / back boxes, metal weapon boxes, weapon tickets
- Costume enchant scrolls (slots 1–2)
- Memento boxes, illusion upgrade tickets, episode tickets
- Job-group **Booster Weapons** (Swordsman, Merchant, Thief, Mage, Acolyte, Archer, expanded classes)
- Booster shadow equipment, level-up tickets

**Related NPCs:** Booster Operator (`prt_in`), Yves (Malangdo costume enchant).

---

## PRO-Asia Coin Shop (Earl)

**NPC:** Cash Coin Point Shop — `prontera 144,178` (Earl)

| Menu | Status |
|------|--------|
| **Points Shop** | **Open** — spends `#PlayPoints` from playtime |
| **Coin Shop → General Supplies** | **Open** — `barter_pro_coins` |
| **Coin Shop → Costume Shop** | **Open** — `barter_pro_costumes` (vanity only) |
| Cash Shop | *Not implemented* |
| Vote Shop | *Not implemented* |

**Currency:** `Play_RO_Gold_Coin_` (PRO-Asia Coins) — drops on select farming maps. Macro patrol may run on those maps.

### General Supplies (sample)

| Item | Coins | Divine Pride |
|------|-------|--------------|
| Blacksmith Blessing | 4 | [6635](https://www.divine-pride.net/database/item/6635) |
| Enriched Oridecon Box (5) | 3 | Search DB |
| Enriched Elunium Box | 6 | Search DB |
| Shadowdecon Ore Box | 3 | Search DB |

### Costume Shop (sample — vanity only)

| Costume | Coins |
|---------|-------|
| Scarlet Band | 12 |
| Vesper Headgear | 7 |
| Neko Mimi Kafra | 6 |
| Deviling Hat | 7 |
| Angeling Hat | 6 |
| Freyja Crown | 10 |

Full list: `npc/custom/barters/cash_coin_costumes.yml`. Look up stats on [Divine Pride](https://www.divine-pride.net/database/item).

---

## Playtime Point System

**Script:** `npc/custom/hourly.txt`  
**Command:** `@playtime`

- Tracks online time in **10-minute** steps; **60 minutes** = **1 Play Point** (`#PlayPoints`)
- **Vending disqualifies** you — re-log to re-enroll
- Spend points at Earl → **Points Shop**

**Sample rewards:** Battle manuals, foods, buff items, costume boxes *(see script for full list)*.

---

## Silvervine Quester

**NPC:** `prontera 153,191`

- **10 mini-boss hunts per day**
- Reward: **5× Silvervine Fruit** per completion
- Silvervine is used at **Balheele** to buy Episode Clear tickets

---

## Episode Clear (Balheele)

**NPC:** Balheele — `prt_cas 373,77`

Skip episode storyline **without rewards or EXP** — unlocks instance NPCs only.

| Ticket | Silvervine Cost |
|--------|-----------------|
| Episode 13–15 Clear | 20 each |
| Episode 16 Clear | 42 |
| Episode 17 Clear | 28 |
| Episode 18 Clear | 80 |
| Episode 19 Clear | 100 |
| Episode 20 Clear | 120 |

**Level gates:** Ep 17.1 requires BL **110+**; Ep 17.2 requires BL **130+**.

---

## King Poring Card Recycler

**NPC:** `prontera 174,176`

- Sacrifice exactly **4 different cards** + **2,500,000 zeny**
- Receive one random card:
  - Normal pool: **~98%**
  - Mini-boss pool: **~1.99%**
  - MVP pool: **~0.01%**
- Some cards are on a **forbidden list** and cannot be recycled

---

## Plagiarism Master

**NPC:** `prontera 142,172`  
**Cost:** **25,000 zeny**  
**Classes:** Rogue / Stalker with Plagiarism learned — copy a skill from the configured list.

---

## Corridor of Phantoms

**NPC:** Phantom's Spirit — `comodo 214,186` / `208,187`  
**Maps:** `vis_h01`, `vis_h02`, `vis_h03`

Public MVP hunting area (iRO-style). MVP HP is scaled (**100×** base). Entry passes and time limits apply — talk to the NPC in Comodo.

---

## Biosphere Depth Daily

**NPC:** Depth Researcher — `ba_in01 286,104`  
**Requirement:** Base level **250+**, registered with Deep Research Manager

| Hunt | Kills | Map |
|------|-------|-----|
| Depth Level 1 | 300 | `bl_depth1` |
| Depth Level 2 | 450 | `bl_depth2` |

**Cooldown:** once per day per hunt (4-hour playtime quest lock). Large EXP rewards on turn-in.

*(Standard Biosphere daily script is present in repo but not enabled — only Depth is loaded.)*

---

## PVP Ladder

**NPC:** PVP Ladder Registrar — `lighthalzen 154,106`  
**Schedule:** Sign-up at **18:00** and **21:00** server time (5-minute window)  
**Arena:** `pvp_y_8-1`

| Setting | Value |
|---------|-------|
| Min entrants | 4 (bracket padded to power of 2) |
| Max entrants | 32 |
| Min base level | **70** |
| Entry fee | **50,000 zeny** |
| Match timeout | 180 seconds |

**Prizes (top 3):**

| Place | Blacksmith Blessing | Sacred Cat Whiskers |
|-------|---------------------|---------------------|
| 1st | 5 | 50 |
| 2nd | 3 | 30 |
| 3rd | 1 | 15 |

**Bonus:** 1st place earns title **Apex Predator** (7 days) + aura; 2nd/3rd get shorter aura duration.

---

## Private MVP Room

**NPC:** `prontera 148,174`  
**Cost:** **100,000 zeny** for **60 minutes**  
**Maps:** `06guild_01`–`06guild_08` — solo MVP hunting instances.

---

## Account Storage

**Script:** `npc/custom/etc/account_storage.txt`

| Account type | Storages |
|--------------|----------|
| Normal | `@storage`, `@storage2`, `@storage3` |
| VIP | `@storage` through `@storage6` |

Use `@storage` alone for a menu, or `@storage2` etc. directly.

---

## Extended Autoloot (`@alootid2`)

**Script:** `npc/custom/alootid2.txt`

- **10 autoloot groups**, **10 item IDs** per group
- Configure with `@alootid2` — useful for targeted farming

---

## Macro Patrol

**Script:** `npc/custom/macro_patrol.txt`

- Runs `@macrodetect` on players farming maps that drop **PRO-Asia Coins**
- Staff command: `@macropatrol`
- **Policy:** see [Server Rules](Rules.md) — do not use macros/bots

---

## Title & Aura System

**Script:** `npc/custom/etc/title_system.txt`

- PVP Ladder awards title ID **1047** (Apex Predator) and aura ID **2000**
- Other titles may be added by staff

---

## Eden Group Services

**Map:** `moc_para01`  
**Scripts:** `eden_hq_services.txt`, `eden_events.txt`, `MVP_exchange.txt`, `eat_gear_mimic.txt`

| Service | Notes |
|---------|-------|
| Registration & training | Secretary Lime Evenor, instructors |
| MVP exchange | 2× MVP gear → Safe Refine Certificate (`53,33`) |
| Eden daily events | Rotating hunts |
| EAT gear mimic | Copy appearance of Eden gear |

Warp via Warper or Eden Teleport Officer.

---

## Disabled Systems (in repo, not loaded)

These exist but are **commented out** in `npc/scripts_custom.conf`:

- Custom WoE controller & WoE info NPC
- Costume recycler, floating rates, stock market, hunting missions
- Most holiday events, battleground recruiters, MVP arena
- `web_commands`, quest shop/board

---

## See Also

- [NPCs & Merchants](NPCs-and-Merchants.md)
- [Items & Equipment](Items-and-Equipment.md)
- [Dungeons & Instances](Dungeons.md)
- [Home](Home.md)
