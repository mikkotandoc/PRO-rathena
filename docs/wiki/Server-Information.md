# Server Information

[← Back to Home](Home.md)

Detailed server mechanics sourced from `conf/battle/` and `src/config/`.

---

## General

| Setting | Value | Config Source |
|---------|-------|---------------|
| Server mode | Renewal | `src/config/renewal.hpp` |
| Max Base Level | 275 | `db/re/job_exp.yml` |
| Max Job Level | 10–70 (varies by class) | `db/re/job_exp.yml` |
| PK Mode | Off | `conf/battle/misc.conf` |
| Multi-level up | Off | `conf/battle/exp.conf` |

---

## Experience Rates

| Type | Rate | Config Key |
|------|------|------------|
| Base EXP | **450x** | `base_exp_rate: 45000` |
| Job EXP | **450x** | `job_exp_rate: 45000` |
| MVP EXP bonus | 100% (1x modifier) | `mvp_exp_rate: 100` |
| Quest EXP | 100% | `quest_exp_rate: 100` |
| Party EXP bonus | +25% per extra attacker (max 12) | `exp_bonus_attacker: 25` |

### Death Penalty

| Setting | Value |
|---------|-------|
| Type | Lose % of **current level** EXP |
| Base EXP loss | 1% per death |
| Job EXP loss | 1% per death |
| Zeny loss on PvP death | 0% |

---

## Drop Rates

All rates use rAthena's `item_rate_*` system where **100 = 1x** official.

| Drop Type | Rate | Config Key |
|-----------|------|------------|
| Common (etc) | **300x** | `item_rate_common: 30000` |
| Healing items | **100x** | `item_rate_heal: 10000` |
| Usable items | **300x** | `item_rate_use: 30000` |
| Equipment | **300x** | `item_rate_equip: 30000` |
| Cards | **100x** | `item_rate_card: 10000` |
| MVP rewards | **300x** | `item_rate_mvp: 30000` |
| Add-drop (equip) | **300x** | `item_rate_adddrop: 30000` |
| Drop rate cap | 90x max | `drop_rate_cap: 9000` |
| Logarithmic drops | Off | `item_logarithmic_drops: no` |
| Renewal drop formula | **Off** | `RENEWAL_DROP` not defined |

### Floating Rates

Script `npc/custom/etc/floating_rates.txt` can randomize rates 1.0x–1.5x every 6 hours. **Currently disabled** in `npc/scripts_custom.conf`.

---

## Combat & Stats

| Setting | Value |
|---------|-------|
| Max ASPD (base) | 190 |
| Max ASPD (3rd class) | 193 |
| Max stat parameter (3rd) | 130 |
| Left-hand card fix | Enabled (official) |
| Natural HP regen interval | 6s |
| Natural SP regen interval | 8s |

---

## VIP System

VIP storage/exp bonuses are defined in `conf/battle/player.conf`:

| Bonus | Value |
|-------|-------|
| Extra storage | +300 slots |
| Base EXP bonus | +50% |
| Job EXP bonus | +50% |

*(Placeholder — confirm if VIP is sold / how to obtain.)*

---

## War of Emperium

| Setting | Status |
|---------|--------|
| Custom WOE controller | Present but **commented out** in `scripts_custom.conf` |
| WOE Information NPC | `prontera 149,193` |
| Castles configured | Prontera, Payon, Geffen, Aldebaran, Arunafeltz, Schwarzwald + TE castles |

*(Placeholder — add WOE day/time schedule once confirmed with staff.)*

---

## Enabled Features

From `conf/battle/feature.conf`:

- Buying store, search stores, banking, autotrade, BG queue, roulette, achievements, stylist, pet evolution, refine UI, enchant UI, private airship system

---

## Episode Coverage

| Episode | Status |
|---------|--------|
| 14–16.2 | Quest + barter content |
| 17.1–17.2 | Full (instances, enchants, merchants) |
| 18–20 | Active hubs and content |
| 21 | Not yet available |

---

## See Also

- [Home](Home.md)
- [Custom Systems](Custom-Systems.md)
- [Rules](Rules.md)
