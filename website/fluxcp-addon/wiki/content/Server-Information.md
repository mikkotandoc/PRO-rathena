# Server Information

[← Back to Home](Home.md)

Mechanics and rates for **PRO-Ragnarok (Cathode)** from `conf/` and `src/config/`.

---

## General

| Setting | Value |
|---------|-------|
| Display / brand | PRO-Ragnarok |
| Char server name | **Cathode** |
| Game mode | Renewal |
| Client date | **2021-11-03** |
| Max base level | **275** |
| Max job level | **10–70** (varies by class) |
| PK mode | Off |
| Multi-level up | **Yes** — multiple level-ups per kill possible |
| Pincode | **Forced** on login |
| Character slots | Up to **9** per account (default rAthena) |
| Char delete delay | **1 second** (birthdate required) |

---

## Experience Rates

| Type | Rate | Notes |
|------|------|-------|
| Base EXP | **150x** | `base_exp_rate: 15000` |
| Job EXP | **150x** | `job_exp_rate: 15000` |
| MVP EXP modifier | 1x | `mvp_exp_rate: 100` |
| Quest EXP | 1x | `quest_exp_rate: 100` |

### Death Penalty

| Setting | Value |
|---------|-------|
| Type | Lose % of current level EXP |
| Base EXP lost | **1%** per death |
| Job EXP lost | **1%** per death |
| Zeny lost (PvP) | **0%** |

---

## Drop Rates

rAthena uses **100 = 1×** official. Config value **10000 = 100×**.

| Drop Type | Rate |
|-----------|------|
| Common / etc | **100x** |
| Healing items | **100x** |
| Usable items | **100x** |
| Equipment | **100x** |
| Cards (normal mobs) | **100x** |
| MVP inventory rewards | **10x** (`item_rate_mvp: 1000`) |
| Add-drop / treasure | 1x |

**Floating rates** (`floating_rates.txt`) exist in the repo but are **disabled**.

Use `@rates` in-game to see the live values your client displays.

---

## Combat & Stats

| Setting | Value |
|---------|-------|
| Max walk speed | **300** |
| Max ASPD (base / 2nd) | **190** |
| Max ASPD (3rd / 4th / expanded) | **193** |
| Max stats (3rd+) | **130** |
| Monster HP rate | **1x** (no inflation) |
| MVP HP rate | **1x** |

---

## VIP Bonuses

VIP is group **5** (`vip_group` in login config). When VIP is active:

| Bonus | Value |
|-------|-------|
| Base EXP | **+50%** |
| Job EXP | **+50%** |
| Drop rate | **+50%** |
| Extra storage | **+300** slots |
| Account storages | **6** slots (`@storage`–`@storage6`) vs 3 for normal |
| Gemstone requirement | Reduced (mode 2) |

*(staff: document how players obtain VIP.)*

---

## War of Emperium

**Controller:** default `agit_controller.txt` (custom `woe_controller.txt` is **disabled**).

| Day | Start | End |
|-----|-------|-----|
| **Tuesday** | 21:00 | 23:00 |
| **Thursday** | 21:00 | 23:00 |
| **Saturday** | 16:00 | 18:00 |

**Castles:** all 20 first-edition castles (Prontera, Payon, Geffen, Aldebaran × 5 each).

### GvG Damage ( Renewal )

| Type | Damage dealt in WoE |
|------|---------------------|
| Melee / ranged | **80%** |
| Weapon / magic / misc skills | **60%** |
| Flee penalty | **20%** |

Guilds can hold unlimited castles (`guild_max_castles: 0`).

---

## Party & Social

| Setting | Value |
|---------|-------|
| Party EXP share level gap | **15** |
| Same-account party block | **On** |
| Party item share | Random |
| Chat channels | `#global`, `#support`, `#trade`, `#ally`, `#map` |

---

## Mail & Trading

| Setting | Value |
|---------|-------|
| Mail zeny fee | **2%** |
| Mail attachment fee | **2,500z** per item |
| Mail weight cap | **2,000** |
| Autotrade timeout | **None** (0) |
| Auction house | **Off** |

---

## New Character Setup

| Setting | Value |
|---------|-------|
| Start maps | `iz_int` intro maps |
| Default save point | **prontera 156, 191** |
| Starting zeny | **0** |
| Starting items | Knife, Cotton Shirt, + custom items (IDs 23484, 100029) |

Look up item names on [Divine Pride](https://www.divine-pride.net/database/item).

---

## Enabled Features

From `conf/battle/feature.conf` (highlights):

- Buying store, search stores, banking, autotrade
- Roulette, achievements, stylist UI, refine UI, enchant UI
- Pet evolution, private airship system
- BG queue (custom BG scripts are off)

---

## Episode Coverage

| Episode | Status |
|---------|--------|
| 16.x | Quest + barter content |
| 17.1–17.2 | Instances, enchants, merchants |
| 18–20 | Active hubs |
| 21 | Not available yet |

Use **Episode Guide** (`prontera 165,175`) or **Balheele** episode tickets for access.

---

## See Also

- [Home](Home.md) · [Custom Systems](Custom-Systems.md) · [Rules](Rules.md)
