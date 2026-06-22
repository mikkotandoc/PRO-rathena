# Classes & Skills

[← Back to Home](Home.md)

---

## Job Master

**Location:** `prontera 153,193`

Supports full Renewal job tree:

- Novice → 1st → 2nd → Transcendent → 3rd → **4th class**
- Baby classes (if enabled in Job Master config)
- Expanded classes: Super Novice, Taekwon, Star Gladiator, Soul Linker, Gunslinger, Rebellion, Ninja, Kagerou/Oboro, Summoner

**Platinum skills:** `prontera 128,200` — grants all quest skills for your class.

---

## Level Caps by Tier

From `db/re/job_exp.yml`:

| Tier | Max Base Level | Max Job Level |
|------|----------------|---------------|
| Novice / 1st | 99–200 | 10–50 |
| 2nd / Trans | 99–200 | 50–70 |
| 3rd | 200 | 60–70 |
| 4th / Expanded endgame | **275** | **70** |

Exact values vary per job — 4th jobs (Dragon Knight, Arch Mage, etc.) cap at **Base 275 / Job 70**.

---

## kRO Q1 2026 Skill Rebalance

PRO-rathena tracks and implements kRO's Q1 2026 class rebalance.

**Tracking file:** `kro-q1-2026-skill-rebalance.csv`

### Classes with Changes

| Class | Notable Skills | Status |
|-------|----------------|--------|
| Dragon Knight | Dragonic Breath, Hack and Slasher, Madness Crusher, Dragonic Pierce | Mostly Done |
| Imperial Guard | Shield Shooting, Overslash, Cross Rain | Done |
| Arch Mage | Destructive Hurricane, Astral Strike, Mystical Amplification | Mostly Done |
| Meister | Mighty Smash, Attack Machine, ABR summons | Partial |
| Biolo | Mayhemic Thorns, Explosive Powder, summons | Partial |
| Cardinal | Arbitrium, Effligo, Petitio | Partial |
| *(see CSV for full list)* | | |

### Custom battle.cpp Tweaks

- Episode 20 monsters: 10% physical/magic damage taken from players
- 2H sword/spear range rules for Dragon Knight skills
- ABR summon damage reduction (÷10)

---

## Expanded & Custom Jobs

The job exp table includes entries for:

- Hyper Novice, Spirit Handler, Sky Emperor, Shinkiro, Shiranui, Night Watch
- Baby_Karnos, **Alitea** (upcoming kRO job — data present)

*(Placeholder — confirm which jobs are playable in-game.)*

---

## Skill Reset

| Service | Cost | Location |
|---------|------|----------|
| Reset Skills | 5,000 zeny | Reset Girl `prontera 150,193` |
| Reset Stats | 5,000 zeny | Reset Girl |
| Reset Both | 9,000 zeny | Reset Girl |

---

## Plagiarism

Rogues can copy select skills via **Plagiarism NPC** at `prontera 142,172`. Requires Plagiarism skill learned.

---

## See Also

- [Getting Started](Getting-Started.md)
- [Custom Systems](Custom-Systems.md)
- [Home](Home.md)
