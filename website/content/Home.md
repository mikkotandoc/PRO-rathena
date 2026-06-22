# PRO-Ragnarok Wiki

> **Unofficial player wiki** for the PRO-rathena private server.  
> Mechanics and data are sourced from the live server repository where possible. Sections marked *(placeholder)* need staff confirmation.

---

## Quick Navigation

| | | |
|---|---|---|
| [Getting Started](Getting-Started.md) | [Server Information](Server-Information.md) | [Custom Systems](Custom-Systems.md) |
| [NPCs & Merchants](NPCs-and-Merchants.md) | [Items & Equipment](Items-and-Equipment.md) | [Dungeons & Instances](Dungeons.md) |
| [Player Commands](Commands.md) | [Server Rules](Rules.md) | [Classes & Skills](Classes.md) |

**External references:** [Divine Pride Database](https://www.divine-pride.net/) · [rAthena Wiki](https://github.com/rathena/rathena/wiki)

---

## Table of Contents

1. [Welcome](#welcome)
2. [Server Info Box](#server-info-box)
3. [Latest News](#latest-news)
4. [Getting Started](#getting-started)
5. [Server Features](#server-features)
6. [Custom Systems](#custom-systems)
7. [Economy](#economy)
8. [NPCs & Merchants](#npcs--merchants)
9. [Items & Equipment](#items--equipment)
10. [Dungeons & Instances](#dungeons--instances)
11. [Player Commands](#player-commands)
12. [Server Rules](#server-rules)

---

## Welcome

Welcome to **PRO-Ragnarok** — a Renewal-based Ragnarok Online private server built on the **PRO-rathena** fork (rAthena + kRO/iRO episode content and custom PRO-Asia features).

New players receive a welcome message on login and are directed to the **Barter Shop** in Prontera. The server tracks **kRO Q1 2026 class rebalance** changes in-repo and implements many of them server-side.

If you are new to Ragnarok Online in general, start with [Getting Started](Getting-Started.md). Returning players should review [Custom Systems](Custom-Systems.md) and the [Prontera Service Hub](#prontera-service-hub) below.

---

## Server Info Box

| | |
|---|---|
| **Server Name** | PRO-Ragnarok *(display name; char `server_name` not set in repo — confirm in-game)* |
| **Emulator** | PRO-rathena (rAthena fork) |
| **Mode** | **Renewal** (`RENEWAL`, `RENEWAL_CAST`, `RENEWAL_EXP`, `RENEWAL_LVDMG`, `RENEWAL_ASPD`, `RENEWAL_STAT`) |
| **Episode Content** | Episodes **14–20** active; **Episode 21** listed but not yet available |
| **Max Base Level** | **275** (4th jobs / expanded classes in `db/re/job_exp.yml`) |
| **Max Job Level** | Up to **70** (4th jobs); varies by class tier |
| **Base EXP Rate** | **450x** (`base_exp_rate: 45000`) |
| **Job EXP Rate** | **450x** (`job_exp_rate: 45000`) |
| **Common Drop Rate** | **300x** (`item_rate_common: 30000`) |
| **Heal Item Drop** | **100x** (`item_rate_heal: 10000`) |
| **Card Drop Rate** | **100x** (`item_rate_card: 10000`) |
| **MVP Drop Rate** | **300x** (`item_rate_mvp: 30000`) |
| **Death Penalty** | **1%** base & job EXP per death (`death_penalty_type: 1`) |
| **Max ASPD** | **190** base / **193** 3rd class (`conf/battle/player.conf`) |
| **PK Mode** | **Off** (`pk_mode: 0`) |
| **Client** | *(placeholder — confirm PACKETVER / patch date with staff)* |
| **Website / Discord** | *(placeholder)* |
| **WOE Schedule** | *(placeholder — `woe_controller` is disabled in `npc/scripts_custom.conf`; confirm which WoE script is active)* |

> **Rate note:** Floating rates (`npc/custom/etc/floating_rates.txt`) exist in the repo but are **commented out** and not active. Advertised rates are the static values above unless staff enable the script.

---

## Latest News

| Date | Headline |
|------|----------|
| *(placeholder)* | Server launch / patch notes |
| *(placeholder)* | Episode 20 content updates |
| In-repo | kRO Q1 2026 skill rebalance tracking (`kro-q1-2026-skill-rebalance.csv`) |

*Staff: replace this table with dated patch notes. Style reference: [Hazy Forest News](https://hazyforest.com/), [Shining Moon Main Page](https://wiki.shining-moon.com/index.php/Main_Page).*

---

## Getting Started

### Create Your Character

1. Register and log in *(registration URL — placeholder)*.
2. Create a character on the main char server.
3. You spawn in **Prontera** with access to core service NPCs (see hub map below).

### First Steps in Prontera

| Step | What to Do |
|------|------------|
| Heal & buff | Visit **Healer** at `prontera 162,193` — free full heal, buffs, and auto-identify |
| Job change | **Job Master** at `prontera 153,193` — supports up to **4th class** |
| Skills | **Platinum Skill NPC** at `prontera 128,200` — grants quest/platinum skills |
| Travel | **Warper** at `prontera 159,192` — towns, fields, dungeons, instances |
| Episodes | **Episode Guide** at `prontera 165,175` — warp to official episode hubs |
| Booster gear | **Centro** at `prontera 166,300` — Booster Coin exchanges |

### Eden Group HQ

Custom Eden HQ guides (`npc/custom/official/eden/eden_hq_services.txt`) provide navigation for:

- Registration with Secretary Lime Evenor
- Mission boards and Paradise equipment
- MVP exchange and Eden events

Warp via Eden Teleport Officer or the in-game warper.

→ Full guide: [Getting Started](Getting-Started.md)

---

## Server Features

### Official-Style Content

| Feature | Status |
|---------|--------|
| Renewal formulas (EXP, ASPD, stats, level damage) | **Enabled** |
| Episode 17.1 / 17.2 (Illusion, Sage's Legacy) | **Active** — merchants, instances, enchants |
| Episode 18 (Wolf Village) | **Active** |
| Episode 19 (Ice Castle) | **Active** |
| Episode 20 (Yggdrasil / Jor) | **Active** — custom damage tuning in `battle.cpp` |
| Episode 21 | **Not yet available** |
| Illusion Investigation instances | **Active** — bartered via Instance & EP Merchant |
| Clock Tower Unknown Basement | **Loaded** (`npc/re/quests/clock_tower_unknown_basement.txt`) |
| Malangdo costume NPCs | **Active** — exchange & enchant (`malangdo_costume.txt`) |
| Laphine Upgrade system | **Active** — `db/re/laphine_upgrade.yml` (5,000+ entries) |
| Perfect Enchant UI | **Client deploy** — `EnchantList.lub` via `tools/deploy_enchantlist_client.py` |
| Banking | **Enabled** (`feature.banking: on`) |
| Battlegrounds queue | **Enabled** (`feature.bgqueue: on`) |
| Roulette | **Enabled** (`feature.roulette: on`) |

### PRO-Asia Custom Features

| Feature | Location / Notes |
|---------|------------------|
| **Booster Coin system** | Centro (`prontera 166,300`) + `mega_booster.yml` barters |
| **Episode Clear (Balheele)** | `prt_cas 373,77` — skip episode progress with tickets or Silvervine |
| **Silvervine Quester** | `prontera 153,191` — daily mini-boss hunt rewards |
| **Playtime Points** | `@playtime` — earn points while online (vending disqualifies) |
| **King Poring Card Recycler** | `prontera 174,176` — merge cards for random reward |
| **Plagiarism NPC** | `prontera 142,172` — copy select skills onto Rogue |
| **Costume shop (PRO-Asia Coins)** | `barter_pro_costumes` — priced in `Play_RO_Gold_Coin_` |
| **Corridor of Phantoms** | Custom MVP public maps (`vis_h01`–`vis_h03`) |
| **Biosphere Depth Daily** | Official-style daily instance script |
| **kRO Q1 2026 rebalances** | Dragon Knight, Imperial Guard, Arch Mage, Meister, Biolo, Cardinal, and more |

### Quality-of-Life NPCs

| NPC | Location | Service |
|-----|----------|---------|
| Reset Girl | `prontera 150,193` | Stats 5,000z / Skills 5,000z / Both 9,000z |
| Stylist | `prontera 170,180` | Appearance change |
| Universal Rental NPC | `prontera 124,201` | Mount/pet rentals |
| Card Remover | *(see NPCs page)* | Remove cards from equipment |
| Bank Clerk (Kafra) | `prontera 131,190` | Account bank |
| MVP Private Room | `prontera 148,174` | Solo MVP hunting room |

→ Details: [Custom Systems](Custom-Systems.md) · [NPCs & Merchants](NPCs-and-Merchants.md)

---

## Custom Systems

### Booster Coin Exchange (Centro)

Located at **Prontera 166,300**. Exchanges **Booster Coins** for:

- Promotional hat/back boxes, metal weapon boxes, weapon tickets
- Booster costume enchant scrolls (slots 1–2)
- Memento boxes, Illusion upgrade tickets
- Job-class **Booster Weapons** (mega04–mega12 shops)
- Booster shadow equipment, level-up tickets, bound illusion enchants

Related NPCs: **Booster Operator** (prt_in), **Yves** (Malangdo costume enchant), **RS26-1** (sp_cor bound enchant).

### Episode Clear System (Balheele)

Located at **`prt_cas 373,77`** (Prontera Castle library).

- Use **Episode Clear Tickets** (Episodes 13–20) to mark storyline progress **without rewards or EXP**
- Purchase tickets with **Silvervine Fruit** (20–120 each, scaling by episode)
- Episode 17.1 requires Base Lv **110+**; 17.2 requires **130+**
- Instance entrance NPCs are uncloaked via `episode_instance_access.txt`

### Enchantment

| System | Where |
|--------|-------|
| Malangdo costumes | `malangdo` / `mal_in01` — Gregio Grumani (4th slot visual effects), full costume exchange roster |
| Booster costume enchants | Centro menu → Malangdo Yves |
| Episode 17.2 Sage's Legacy | Baggot Lab (`ba_in01`) — automatic orb enchants, bound perfect enchants |
| Laphine Synthesis / Upgrade | Usable items defined in `db/re/laphine_upgrade.yml` |
| Perfect Enchant UI | Client `EnchantList.lub` — deploy with `tools/deploy_enchantlist_client.py` |

### Playtime & Hourly Rewards

- **Playtime Point System** — 1 point per 60 minutes online; check with `@playtime`
- **Playtime Points Shop** — `prontera 144,178` (point shop currency `#playtimepts`)
- **Cash Coin Point Shop** — same area (`hourly.txt`)

→ Full breakdown: [Custom Systems](Custom-Systems.md)

---

## Economy

### Currencies

| Currency | Item / Variable | Used For |
|----------|-----------------|----------|
| Zeny | Standard | NPCs, resets, King Poring recycler (2,500,000z) |
| Booster Coin | `Booster_Coin` | Centro promotional exchanges |
| PRO-Asia Gold Coin | `Play_RO_Gold_Coin_` | Cash costume barter (vanity only) |
| Silvervine Fruit | `Silvervine` (6417) | Episode Clear tickets via Balheele |
| Playtime Points | `#PlayPoints` / `#playtimepts` | Hourly shop rewards |
| Episode Points | Various EP tokens | Instance & EP Merchant barters |
| Gacha Coins | *(costume recycler — script present, confirm if loaded)* | Costume recycling |

### Shops & Markets

- **Equipment / Headgear / Supply Dealers** — `prontera 142,238` area (`itemmall.txt`)
- **Instance & EP Merchant** — `prontera 164,172` — illusion & episode barters
- **Stock Market** — script present, **disabled** in `scripts_custom.conf`
- **Player vending** — standard Renewal vending enabled

### Tax & Fees

| Setting | Value |
|---------|-------|
| Mail zeny fee | 2% (`mail_zeny_fee: 2`) |
| Mail attachment fee | 2,500z (`mail_attachment_price: 2500`) |
| Vending tax | *(default — confirm `vending_tax` in battle conf)* |

---

## NPCs & Merchants

### Prontera Service Hub

Approximate layout of enabled custom NPCs in Prontera:

```
                    [Episode Guide 165,175]
    [Instance Merchant 164,172]     [Silvervine 153,191]
[Platinum 128,200]  [Job Master 153,193] [Reset 150,193] [Healer 162,193]
    [Warper 159,192]  [WOE Info 149,193]*  [King Poring 174,176]
         [Stylist 170,180]  [Playtime Shop 144,178]
              [Centro / Booster 166,300]

* WOE Information NPC exists but woe_controller may be disabled — confirm schedule.
```

### Key Merchants by Map

| Map | NPC / System |
|-----|--------------|
| `prontera` | Centro, Episode Guide, Instance Merchant, Job Master, Healer, Warper, Eden warp |
| `prt_cas` | Balheele (Episode Clear) |
| `malangdo` / `mal_in01` | Costume exchange & enchant (Gregio Grumani, Aver De Dosh, etc.) |
| `sp_cor` | Episode 17.1 — Grace Operator, RS26 enchanters |
| `ba_in01` | Episode 17.2 — Baggot Lab merchant row |
| `wolfvill` | Episode 18 merchants |
| `icas_in` | Episode 19 traders |
| `moc_para01` | Eden Group HQ services |

→ Full NPC list: [NPCs & Merchants](NPCs-and-Merchants.md)

---

## Items & Equipment

### Custom & Notable Items

| Category | Source |
|----------|--------|
| Booster weapons & shadows | Centro — `mega_booster.yml` |
| Booster costume enchants | `Boost_C_Enchant_1`, `Boost_C_Enchant_2` |
| Episode Clear tickets | `EpisodClear13`–`EpisodClear20` via Balheele |
| PRO-Asia costumes | `cash_coin_costumes.yml` — Skarlet Band, Vesper Headgear, Neko Mimi Kafra, etc. |
| Laphine upgrade targets | Ein weapons, Metal refine tickets, hundreds of reform boxes |
| Eden / Paradise gear | Eden HQ, official Eden scripts |
| Godly quest items | Valhallen, Kaho Horn quests (enabled) |

### Equipment Progression Path (Suggested)

1. **Eden/Paradise** gear from Eden Group missions
2. **Booster Weapons** from Centro (early-endgame shortcut)
3. **Illusion gear** from instance barters (Instance Merchant)
4. **Episode Grace / Automatic gear** (Ep 16–17.2 barters)
5. **Laphine upgrades & enchants** for min-maxing

Use [Divine Pride](https://www.divine-pride.net/database/item) for base item stats; server may have custom bonuses in `db/re/item_db*.yml`.

→ [Items & Equipment](Items-and-Equipment.md)

---

## Dungeons & Instances

### Episode Instances

Access via **Episode Guide** warps or natural quest progression. Episode Clear tickets unlock memorial dungeon NPCs without requiring full quest completion.

| Episode | Hub / Instance Examples |
|---------|-------------------------|
| 16.x | Terra Gloria, Heart Hunter |
| 17.1 | Rudus, OS Occupation, Cor Operation |
| 17.2 | Water Garden, Baggot Lab, Pax Employment |
| 18 | Wolf Village storyline instances |
| 19 | Ice Castle content |
| 20 | Yggdrasil / Jor Nest |

### Illusion Investigation

Available through **Instance & EP Merchant** (`prontera 164,172`):

- Illusion Vampire, Underwater, Twins, Moonlight, Frozen, Turtle, Luanda, Teddy Bear
- Resonance Stone exchange

### Custom MVP Content

| Content | Notes |
|---------|-------|
| Corridor of Phantoms | Public MVP maps `vis_h01`–`vis_h03` |
| Private MVP Room | `prontera 148,174` |
| Clock Tower Unknown Basement | Episode 18 dungeon extension |

### Standard Dungeons

Use the **Warper** (`prontera 159,192`) for all classic Renewal dungeons, guild dungeons, and instance menus.

→ [Dungeons & Instances](Dungeons.md)

---

## Player Commands

### Known Custom Commands

| Command | Description |
|---------|-------------|
| `@playtime` | Check playtime point progress and last reward time |

### Standard rAthena Commands

Most atcommands depend on group level. Common player commands:

| Command | Description |
|---------|-------------|
| `@autoloot` | Toggle automatic loot pickup |
| `@alootid` | Autoloot specific item IDs |
| `@storage` | Open Kafra storage *(if enabled for group)* |
| `@go` | Warp to town presets |
| `@where` | Show current map and position |
| `@time` | Server time |

*Full command list for your group level: *(placeholder — link to FluxCP or in-game `@commands`)*.*

→ [Player Commands](Commands.md)

---

## Server Rules

*(Placeholder — staff must fill in.)*

| Rule | Description |
|------|-------------|
| 1 | *(placeholder)* |
| 2 | *(placeholder)* |
| 3 | *(placeholder)* |

**Suggested categories:** account sharing, botting/macro policy, harassment, trading scams, WoE conduct, GvG etiquette, real-money trading (RMT).

→ [Server Rules](Rules.md)

---

## See Also

- [Getting Started](Getting-Started.md) — install, login, first-hour checklist
- [Server Information](Server-Information.md) — rates, penalties, VIP, renewal mechanics
- [Custom Systems](Custom-Systems.md) — booster, episode clear, enchants, playtime
- [NPCs & Merchants](NPCs-and-Merchants.md) — full NPC directory
- [Items & Equipment](Items-and-Equipment.md) — gear guides and item DB notes
- [Dungeons & Instances](Dungeons.md) — instance access and loot
- [Classes & Skills](Classes.md) — job changes and rebalance notes
- [Player Commands](Commands.md)
- [Server Rules](Rules.md)

---

*Last generated from PRO-rathena repository audit. Edit this page when configs or NPC scripts change.*
