# NPCs & Merchants

[← Back to Home](Home.md)

Directory of enabled custom NPCs from `npc/scripts_custom.conf`.

---

## Prontera — Core Services

| NPC | Coordinates | Service |
|-----|-------------|---------|
| Episode Guide | 165, 175 | Warp to episode hubs (17.1–20) |
| Instance & EP Merchant | 164, 172 | Illusion & episode barter shops |
| Centro (Booster) | 166, 300 | Booster Coin exchanges |
| Job Master | 153, 193 | Job changes through 4th class |
| Silvervine Quester | 153, 191 | Daily mini-boss hunts |
| Reset Girl | 150, 193 | Stat/skill reset (5k/5k/9k zeny) |
| Healer | 162, 193 | Free heal, buffs, identify all |
| Warper | 159, 192 | Full world warper |
| Platinum Skill NPC | 128, 200 | Quest/platinum skills |
| Stylist | 170, 180 | Appearance change |
| Universal Rental NPC | 124, 201 | Mount rentals |
| Bank Clerk (Kafra) | 131, 190 | Account bank |
| King Poring | 174, 176 | Card recycler (2.5M zeny) |
| Plagiarism NPC | 142, 172 | Skill copy for Rogues |
| Playtime Points Shop | 144, 178 | Hourly reward shop |
| Cash Coin Point Shop | 144, 178 | Cash coin rewards |
| Equipment Merchant | 142, 238 | Basic equipment |
| Headgear & Garment Dealer | 142, 241 | Headgear/garments |
| Supply Dealer | 142, 246 | Consumables |
| Private MVP Room | 148, 174 | Solo MVP room |
| Card Remover | *(confirm coords)* | Remove cards from gear |
| WOE Information | 149, 193 | WoE schedule info *(controller may be off)* |
| Debug Episode#gm | 167, 173 | GM episode debug |

---

## Prontera Castle

| NPC | Coordinates | Service |
|-----|-------------|---------|
| Balheele | 373, 77 | Episode Clear tickets |

---

## Episode Hub Warps (via Episode Guide)

### Episode 17.1 — Dawn, Illusion

| Destination | Key NPCs |
|-------------|----------|
| sp_cor (Cor Operation) | Grace Operator, RS26 Enchanter, Elyumina |
| sp_rudus (Rudus) | Elena Volkova, rebellion crews |
| sp_os (OS Area) | Border NPCs |
| lighthalzen | Main 17.1 story hub |

### Episode 17.2 — Sage's Legacy

| Destination | Key NPCs |
|-------------|----------|
| ba_in01 (Baggot Lab) | Lisa, Spiera, Yeoncheong, Cube Lane |
| ba_pw01 (Pax Employment) | Employment quests |
| sp_cor (epilogue) | 17.2 epilogue area |

### Episodes 18–20

| Episode | Hub | NPCs |
|---------|-----|------|
| 18 | wolfvill | Emmet, Asad merchants |
| 19 | icas_in | Hoyoyo, Maram, Forr traders |
| 20 | jor_nest | Yggdrasil content |

---

## Malangdo

**File:** `npc/re/merchants/malangdo_costume.txt`

| NPC | Role |
|-----|------|
| Gregio Grumani | 4th slot costume visual effects |
| Aver De Dosh | Costume exchange (enchant boxes) |
| Yves | Booster promotional costume enchant |
| *(others)* | Full kRO costume exchange roster |

---

## Eden Group HQ

**Map:** `moc_para01`  
**Script:** `npc/custom/official/eden/eden_hq_services.txt`

| Service | NPC / Location |
|---------|----------------|
| Registration | Secretary Lime Evenor (27,35) |
| Beginner training | Instructor Boya (25,35) |
| Advanced training | Instructor Ur (23,35) |
| MVP exchange | MVP_exchange.txt |
| Eden events | eden_events.txt |
| EAT gear mimic | eat_gear_mimic.txt |

---

## Instance & Episode Barters

Opened via **Instance & EP Merchant** menu:

**Illusion:** Vampire, Underwater, Twins, Resonance Stone, Moonlight, Frozen, Turtle, Luanda, Teddy Bear

**Episodes:** 14–21 menus (21 not yet available); Grace equipment by job; rebellion supply; automatic equipment exchanges; teleport tickets; reinforcement cubes

---

## Disabled NPCs (Present in Repo)

These scripts exist but are **commented out** in `scripts_custom.conf`:

- Card Seller, WOE Controller, MVP Arena, Lottery, Stock Market, Hunting Missions, Quest Shop, most holiday events, Battleground recruiters, Floating Rates, Welcome NPC, Costume Recycler

---

## See Also

- [Custom Systems](Custom-Systems.md)
- [Home](Home.md)
