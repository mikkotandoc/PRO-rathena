# Custom Systems

[← Back to Home](Home.md)

PRO-Ragnarok-specific mechanics beyond standard Renewal content.

---

## Booster Coin System

**NPC:** Centro — `prontera 166,300`  
**Data:** `npc/custom/barters/mega_booster.yml`, `npc/custom/official/booster_coin_exchange.txt`

### Promotional Exchange (mega00)

| Item | Cost (Booster Coins) |
|------|---------------------|
| Booster Hat Box | 50 |
| Booster Back Box | 50 |
| Metal Weapon Box | 5 |
| Booster Weapon Ticket | 5 |
| Booster Weapon Upgrade +3 | 15 |
| Costume Enchant Scroll 1 | 10 |
| Costume Enchant Scroll 2 | 20 |
| Memento Box | 150 |
| Premium Memento Box | 300 |
| EP17.1 Ticket | 10 |
| Illusion Upgrade | 5 |
| Random Option boxes (P/M) | 10 each |

### Weapon Vouchers (mega04–mega12)

Job-group weapon exchanges using **Booster Weapon Tickets**. Covers Swordsman, Merchant, Thief, Wizard, Acolyte, Archer, Star Emperor/Soul Linker, Summoner/Ninja, and Novice/Gunslinger groups.

### Related NPCs

| NPC | Location | Role |
|-----|----------|------|
| Booster Operator | prt_in | Illusion equipment vouchers |
| Yves | malangdo | Booster costume enchantment |
| RS26-1 | sp_cor | Bound illusion equipment enchant |

---

## Episode Clear (Balheele)

**NPC:** Balheele — `prt_cas 373,77`  
**Scripts:** `npc/custom/episode_clear.txt`, `npc/custom/episode_instance_access.txt`

Skips episode quest progression **without granting rewards, EXP, or achievements**.

### Silvervine Purchase Costs

| Ticket | Silvervine Cost |
|--------|-----------------|
| Episode 13 Clear | 20 |
| Episode 14 Clear | 20 |
| Episode 15 Clear | 20 |
| Episode 16 Clear | 42 |
| Episode 17 Clear | 28 |
| Episode 18 Clear | 80 |
| Episode 19 Clear | 100 |
| Episode 20 Clear | 120 |

### Level Requirements

- Episode 17.1: Base Lv **110+**
- Episode 17.2: Base Lv **130+**

---

## Enchantment Systems

### Malangdo Costumes

**File:** `npc/re/merchants/malangdo_costume.txt`

- Full official costume exchange roster
- **Gregio Grumani** — 4th slot visual effect enchanter (99,800z removal fee)
- Enchant Stone Box 4–21 support

### Laphine Upgrade

**File:** `db/re/laphine_upgrade.yml`

Usable items that upgrade target equipment with optional random options, refine levels, and card rules. Includes Ein weapon boxes, Metal refine tickets, and hundreds of episode gear reforms.

### Perfect Enchant UI (Client)

**Tool:** `tools/deploy_enchantlist_client.py`  
**Client file:** `data/luafiles514/lua files/Enchant/EnchantList.lub`

Deploys English AegisName enchant tables for the Perfect Enchant UI. Includes fixes for garbled kRO enchant names.

---

## Playtime Point System

**Script:** `npc/custom/hourly.txt`  
**Command:** `@playtime`

- Earn 1 **Play Point** per 60 minutes online
- Vending disqualifies you from earning points
- Re-log to re-enroll after vending
- Spend points at **Playtime Points Shop** (`prontera 144,178`)

---

## Silvervine Quester

**NPC:** `prontera 153,191`

Daily mini-boss hunt contracts with rewards. Includes GM debug menu and automatic repair for stuck/expired hunt records.

---

## King Poring Card Recycler

**NPC:** `prontera 174,176`

- Recycle exactly **N** cards (configurable) for a random card reward
- Cost: **2,500,000 Zeny** per attempt
- Separate rates for Normal (99%), Mini Boss (3%), MVP (1%) cards
- Forbidden card list prevents recycling valuable cards

---

## Plagiarism NPC

**NPC:** `prontera 142,172`

Allows Rogues with Plagiarism to copy select skills from a configured skill list. Optional zeny fee.

---

## Corridor of Phantoms

**Maps:** `vis_h01`, `vis_h02`, `vis_h03`  
**Script:** `npc/custom/quests/corridor_of_phantoms.txt`

Public MVP hunting area (iRO/kRO style).

---

## kRO Q1 2026 Skill Rebalance

**Tracking file:** `kro-q1-2026-skill-rebalance.csv`

Server implements kRO Q1 2026 class changes for 4th jobs including Dragon Knight, Imperial Guard, Arch Mage, Meister, Biolo, Cardinal, and others. Status per skill: Done, Partial, or pending.

→ [Classes & Skills](Classes.md)

---

## PRO-Asia Costume Shop

**File:** `npc/custom/barters/cash_coin_costumes.yml`  
**Currency:** `Play_RO_Gold_Coin_` (PRO-Asia Coins)

Vanity-only costumes (no zeny sales). Examples: Skarlet Band, Vesper Headgear, Neko Mimi Kafra, Deviling Hat, Angeling Hat.

---

## See Also

- [NPCs & Merchants](NPCs-and-Merchants.md)
- [Items & Equipment](Items-and-Equipment.md)
- [Home](Home.md)
