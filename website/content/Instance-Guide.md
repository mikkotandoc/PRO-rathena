# Instance & Episode Progression Guide

[← Back to Home](Home.md)

Step-by-step guide for **memorial dungeons and episode instances** on PRO-Ragnarok. Flow matches **kRO / iRO Renewal** episode scripts in this repository (`npc/re/quests/`, `npc/re/instances/`).

> **Verified source:** NPC dialogue, quest IDs, and `ep*_main` variables from live scripts — not third-party wiki copy.

---

## Before You Start

### How memorial dungeons work

| Rule | Detail |
|------|--------|
| Party | Almost all episode MDs require a **party** (often solo party `/organize Name` is enough) |
| Leader | **Party leader** selects **Create / Prepare**, then **Enter** |
| Cooldowns | Many dailies use `PLAYTIME` quests (once per day or multi-day) — read the NPC warning |
| Taming | Official scripts warn: **taming or abnormal monster handling can break instance progress** |
| Navigation | Yellow `!` quest icons and `<NAVI>` links in dialogue point to the next NPC |

### Server shortcuts

| NPC | Location | Purpose |
|-----|----------|---------|
| **Episode Guide** | `prontera 165,175` | Warp to episode hubs & story starts |
| **Balheele** | `prt_cas 373,77` | **Episode Clear tickets** — skip story *(no EXP/rewards)* but unlock instance NPCs |
| **Instance & EP Merchant** | `prontera 164,172` | Illusion gear barters *(after you clear instances)* |
| **Warper** | `prontera 159,192` | Classic dungeons, Illusion fields, guild dungeons |

### Recommended episode order

```
Ep 13–15 → Ep 16 (Terra Gloria) → Ep 17.1 → Ep 17.2 → Ep 18 → Ep 19 → Ep 20
```

**Balheele prerequisites** (organic story *or* prior episode clear ticket):

| Episode | Requires | Min BL (ticket) |
|---------|----------|-----------------|
| 17.1 | Episode 16 complete | 110 |
| 17.2 | Episode 17.1 complete | 130 |
| 18 | Episode 17.2 complete | 170 |
| 19 | Episode 18 complete (`ep18_main` 57) | 200 |
| 20 | Episode 19 complete (`ep19_main` 100) | 215 |

---

## Episode 16 — Terra Gloria

**Hub:** `prt_cas_q` (Prontera Castle quest map)

| Step | Action |
|------|--------|
| 1 | Complete **Room of Consciousness** arc (`ep16_royal` ≥ 17) |
| 2 | Enter `prt_cas_q` — talk to **Nihil M. Heine** & **Skia Nerius** (`21,39` area) |
| 3 | Follow **Terra Gloria** chapter quests until `terra_gloria_main` reaches **25** |
| 4 | This unlocks **Episode 17.1** (Nihil reappears at `prt_cas_q` for the Illusion arc) |

**Instances in arc:** Heart Hunter War Base, Werner Laboratory, and other Ep 16 MDs unlock through the Terra Gloria / royal quest chain — follow quest icons in `prt_cas_q`, `prt_cas`, and related maps.

**Skip:** Balheele → Episode 16 Clear Ticket → sets `terra_gloria_main` 25 and uncloaks Ep 16 NPCs.

---

## Episode 17.1 — Dawn, Illusion

**Start requirement:** `terra_gloria_main == 25`  
**Story start:** `prt_cas_q` — **Nihil M. Heine** (`21,39`) after touching `#EP_171_START`  
**Hub warps:** Episode Guide → Cor / Rudus / OS / Lighthalzen

### Main story instances (in order)

#### 1. Sealed OS

| | |
|---|---|
| **Map** | `ein_fild03` |
| **NPC** | **Rebellion Crew** (field scout — follow quests from `einbech`) |
| **Quest chain** | `11599` → `11600` (ready to enter) |
| **MD name** | `Sealed OS` |
| **Party** | Required — leader **Open the gate** then **Go inside** |

#### 2. Regenschirm

| | |
|---|---|
| **Map** | `lighthalzen` |
| **NPC** | **Rekenber Guard Oscar** (`55,278`) |
| **Quest** | `7862` active (after Lighthalzen briefing chain) |
| **MD name** | `Regenschirm` |
| **Party** | Required — Create → Enter |

#### 3. Cor Memorial (Elyumina capture)

| | |
|---|---|
| **Map** | `sp_cor` |
| **NPC** | **Elena Volkova** (`110,130` — Innocent Menace arc) |
| **MD name** | `Cor Memorial` |
| **Party** | **Solo party only** — leader must `/organize` party of 1 |
| **Flow** | Select **Ready** (creates MD) → **Enter** |

#### 4. OS Occupation (story + daily)

| | |
|---|---|
| **Map** | `sp_cor` (`163,56` area) |
| **NPC** | **Est** (`Est#171_ocp`) — story mode after quest `11603` complete |
| **MD name** | `OS Occupation` |
| **Party** | Required |
| **Daily** | **Operation Officer** (`160,55`) — quest `12454`/`12455`, 24h cooldown |

**Merchants / enchants:** `sp_cor` — Grace Operator, RS26 enchanters, Elyumina exchanges.

**Skip 17.1:** Balheele → Ep 17 → **Dawn, Illusion** (BL 110+) — uncloaks OS Occupation entrance.

---

## Episode 17.2 — Sage's Legacy

**Start requirement:** Episode 17.1 complete (`isbegin_quest(16360) == 2`), **Base Level 130+**  
**Entry NPC:** **Rookie** — `sp_cor 255,285` (`Rookie#rm171_2`)

| Step | Action |
|------|--------|
| 1 | Talk to Rookie → sets `ep17_2_main` 1, quest `18000` |
| 2 | Select **Let's Go!** → warps to `ba_pw02` (mansion sewer entrance) |
| 3 | Clear mansion quests through **ba_maison**, **ba_in01**, **ba_pw01** |
| 4 | Meet mansion manager NPCs in the garden wing per Rookie's directions |

### Memorial dungeons

#### Water Garden

| | |
|---|---|
| **NPC** | **Harad** — `ba_maison 238,44` |
| **Requirement** | `ep172_watergarden` ≥ 3 (story) |
| **MD names** | `Water Garden` / `Water Garden Hard` (BL 180+ for Hard) |
| **Cooldown** | Quest `16439` — **once per day** (normal + hard share timer) |
| **Note** | Party leader who accepted the Water Garden quest must enter |

#### Hidden Flower Garden

| | |
|---|---|
| **NPC** | **Flower Garden Manager** — `ba_maison 120,321` (`#he_admin1` story / `#he_admin2` daily) |
| **MD name** | `Hidden Flower Garden` |
| **Party** | Leader **Authenticate Identity** → **Enter** |
| **Daily cooldown** | Quest `12498` (after story quest `12497` complete) |

**Merchants:** `ba_in01` — Lisa, Spiera, Yeoncheong, Baggot Lab row (automatic orbs, reforms).

**Skip 17.2:** Balheele → Ep 17 → **Sage's Legacy** (BL 130+) — sets `ep17_2_main` 36, uncloaks garden NPCs.

---

## Episode 18 — Wolf Village (Direction of Prayer)

**Start:** Continues from 17.2 — `ep18_main` becomes active; story opens in **Rachel**  
**Hub:** `wolfvill` — Episode Guide warp  
**Final flag:** `ep18_main == 57` (unlocks Episode 19)

### Key story steps (Rachel arc)

| Step | Location | What to do |
|------|----------|------------|
| 1 | `rachel 182,176` | **Masked Girl** — equip **Mini Elly** costume headgear (`400127`) for Elly dialogue |
| 2 | Same area | Complete crowd / speech quests (`8681` → `8682`…) |
| 3 | `ra_temin` | Temple guards **Dent** & **Neil** — immigration riot storyline |
| 4 | Follow quest icons | Through Wolf Village (`wolfvill`), Oz maze maps, Rachel HQ |

### Memorial dungeons

| Instance | Unlock (script) | Entrance |
|----------|-----------------|----------|
| **Wolves** | `ep18_main` 50–51 | Wolf Village quest chain |
| **Maze of Oz** | Mid-episode (`ep18_main` ~28+) | Entrance NPC inside Oz dungeon maps |
| **High Priest's Villa** | `ep18_main` 54+ | **Ira** — `oz_dun01` (talk when ready → MD enter) |
| **Villa of Deception** | Later chapter | Related Oz / wolf storyline |

After villa arc (`ep18_main` 55+), return to **Wolf Village** leadership quests until `ep18_main` 57.

**Skip:** Balheele → Episode 18 Clear (BL 170+) — sets `ep18_main` 57, uncloaks instance NPCs on `wolfvill`, `rachel`, `oz_dun01`.

---

## Episode 19 — Ice Castle (Issgard)

**Start requirement:** `ep18_main == 57`, **Base Level 200+**  
**Start NPC:** **Maram** — `wolfvill 220,85` (with Miriam & Suad)  
**Hub:** `icas_in`, `icecastle`, `jor_nest`

### Main instances (story order)

| Instance | Unlock | Notes |
|----------|--------|-------|
| **Iwin Patrol** | Mid-story | Entrance NPC embedded in instance scripts |
| **Airship Destruction** | `ep19_main` 33 | Quest `17637` — destroy Rgan airship operation |
| **Confused Snake's Nest** | Story chapter | `1@jorchs` — multi-area MD |
| **Bagot Laboratory** | `ep19_main` 50+ | **Juncea** opens passage — leader **Prepare** → **Enter** `Bagot Laboratory` |
| **Airship Crash** | Post-story daily | `dali02` — **Dr. Dulaisakstrom** (BL 215+, 3-day cooldown quest `15092`) |

**Final flag:** `ep19_main == 100` — unlocks Episode 20 and remaining dailies.

**Skip:** Balheele → Episode 19 Clear (BL 200+) — sets `ep19_main` 100.

---

## Episode 20 — The Immortal (Yggdrasil)

**Start requirement:** `ep19_main == 100`, **Base Level 215+**, quest `17650` complete  
**Start NPC:** **Horuru** — Ice Castle / Issgard quest hub (follow `17690` quest chain)  
**Hub:** `jor_nest` — Episode Guide warp; conference room in `icas_in`

### Main instances (story order)

| # | Instance | NPC / trigger | `ep20_main` |
|---|----------|---------------|-------------|
| 1 | **Canyon Exploration** | **Lehar** — `icecastle 201,171` | 13 (solo party required) |
| 2 | **Drift Ice Zone** | Story gate in `jor_maze` | ~21+ |
| 3 | **Nest of Twigs** | Aurelie storyline — `jor_twice` | ~25+ |
| 4 | **The Immortal** | Final chapter NPC | ~29+ → 100 |

**Flow pattern:** Each chapter NPC offers **Enter &lt;Instance&gt;** → `F_ep20_instance_enter` creates party MD and warps you in. After `ep20_main` 100, Lehar and other NPCs allow **repeat entry** for dailies.

**Skip:** Balheele → Episode 20 Clear (BL 215+) — sets `ep20_main` 100.

---

## Illusion Investigation (standalone)

Not part of the episode ticket chain — run these anytime via **Warper → Illusion Dungeon** (fields) or memorial NPCs. Exchange loot at **Instance & EP Merchant** (`prontera 164,172`).

| Instance | Warper entry |
|----------|--------------|
| Illusion of Vampire | Illusion Dungeon menu |
| Illusion of Underwater | Illusion Dungeon menu |
| Illusion of Twins | Illusion Dungeon menu |
| Illusion of Moonlight | Illusion Dungeon menu |
| Illusion of Frozen | Illusion Dungeon menu |
| Illusion of Turtle | Illusion Dungeon menu |
| Illusion of Luanda | Illusion Dungeon menu |
| Illusion of Teddy Bear | Illusion Dungeon menu |
| Illusion of Labyrinth / Abyss | Illusion Dungeon menu |

**Suggested level:** 100+ for most Illusion MDs; use Eden boards 100–140 while gearing.

---

## Skip vs. Legitimate Progression

| Method | Pros | Cons |
|--------|------|------|
| **Story quests** | Full EXP, rewards, achievements, learn mechanics | Takes longer |
| **Balheele tickets** | Instant episode flag & uncloaked instance NPCs | **No** quest EXP, drops, or story rewards |
| **Episode Guide warps** | Fast travel to hubs | Does not replace quest progress |

If instance NPCs are invisible after a ticket, talk to Balheele → **[Debug] Repair hidden episode NPCs**.

---

## Custom Server Instances

| Content | Access |
|---------|--------|
| **Biosphere Depth** | `ba_in01` — BL 250+ daily |
| **Corridor of Phantoms** | Comodo → `vis_h01`–`vis_h03` public MVP maps |
| **Private MVP Room** | `prontera 148,174` |
| **Clock Tower Unknown Basement** | Episode 18 extension — quest-gated |

---

## Quick reference — party rules

| Instance | Party rule |
|----------|------------|
| Cor Memorial | Solo party (1 member) only |
| Sealed OS, Regenschirm, OS Occupation | Any party, leader creates |
| Water Garden | Party; quest holder must be leader |
| Hidden Flower Garden | Leader authenticates |
| Ep 20 MDs | `F_ep20_instance_enter` — party required, leader creates |
| Airship Crash | Party, BL 215+, 3-day cooldown |

---

## See Also

- [Dungeons & Instances](Dungeons.md) — hub list & Illusion barters
- [Custom Systems](Custom-Systems.md) — Episode Clear (Balheele) ticket costs
- [Getting Started](Getting-Started.md) — Eden leveling before episodes
- [Home](Home.md)

*Last verified against `npc/re/quests/quests_17_1.txt`, `quests_18.txt`, `quests_19.txt`, `quests_20.txt`, and `npc/re/instances/`.*
