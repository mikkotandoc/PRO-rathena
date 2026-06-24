# Items & Equipment

[← Back to Home](Home.md)

Gear progression, currencies, and notable items on **PRO-Ragnarok**. Use [Divine Pride](https://www.divine-pride.net/database/item) for base stats, drops, and descriptions.

---

## Progression Overview

```
Starter (iz_int) → Eden/Paradise → Booster Weapons (Centro)
    → Illusion Instance Gear → Episode Grace/Automatic
    → Laphine Upgrades & Enchants → Endgame MVPs / Depth / Corridor
```

---

## Currencies & Tokens

| Currency | Item / Variable | How to Get | Spent At |
|----------|-----------------|------------|----------|
| Zeny | — | Drops, vend | NPCs, resets, rooms |
| Booster Coin | `Booster_Coin` | Events, boxes | Centro |
| PRO-Asia Coin | `Play_RO_Gold_Coin_` | Field map drops | Earl → Coin Shop |
| Silvervine Fruit | ID **6417** | Silvervine Quester | Balheele tickets |
| Playtime Points | `#PlayPoints` | 60 min online | Earl → Points Shop |
| Instance tokens | Per instance | Instance runs | Instance Merchant |

---

## Starting Equipment

New characters receive (from `char_athena.conf`):

| ID | Typical Item |
|----|--------------|
| 1201 | Knife |
| 2301 | Cotton Shirt |
| 23484 | *(look up on Divine Pride)* |
| 100029 | *(look up on Divine Pride)* |

---

## Eden / Paradise Gear

**Source:** Eden Group HQ (`moc_para01`)

- **Paradise weapons & armor** — mission rewards for beginners
- **MVP Exchange** — trade duplicate MVP gear for Safe Refine Certificate
- **EAT Gear Mimic** — cosmetic copy of Eden equipment appearance

Best for levels **1–99** before switching to Booster or illusion gear.

---

## Booster Equipment

**Source:** Centro — `prontera 166,300` (`mega_booster.yml`)

| Category | Examples |
|----------|----------|
| Booster weapons | Job-group swords, spears, katars, books, etc. |
| Booster shadows | Shadow armor set pieces |
| Upgrade items | +3 weapon tickets, metal refine boxes |
| Enchant scrolls | `Boost_C_Enchant_1`, `Boost_C_Enchant_2` |
| Boxes | Booster Hat/Back box, Memento boxes |
| Tickets | EP17.1 ticket, Illusion Upgrade |

Good **shortcut** into mid-game; not required if you prefer pure instance progression.

---

## Illusion Investigation Gear

**Source:** Instance & EP Merchant — `prontera 164,172`

| Instance Set | Theme |
|--------------|-------|
| Vampire | Undead / blood |
| Underwater | Aquatic |
| Twins | Mirror bosses |
| Moonlight | Payon theme |
| Frozen | Ice |
| Turtle | Turtle island |
| Luanda | Africa-style |
| Teddy Bear | Toy factory |

Farm materials in each illusion dungeon, then barter at the merchant. Check [Divine Pride](https://www.divine-pride.net/) for set bonuses.

---

## Episode Equipment

| Episode | Gear Type | Hub |
|---------|-----------|-----|
| 16.x | Grace equipment | Instance Merchant |
| 17.1 | Grace + illusion hybrids | `sp_cor`, barters |
| 17.2 | Automatic / admin gear | Baggot Lab (`ba_in01`) |
| 18–20 | Episode token gear | Wolf Village, Ice Castle, Jor Nest |

**Episode Clear tickets** unlock NPCs without farming full story — no gear is given free.

---

## Laphine Synthesis & Upgrade

**Database:** `db/re/laphine_upgrade.yml`

- Use special boxes on equipped gear to reform stats, refine, random options
- Includes Ein weapon boxes, metal refine tickets, hundreds of episode reform items
- Read each box description in-game; confirm targets on Divine Pride

---

## PRO-Asia Coin Purchases

### Supplies (`barter_pro_coins`)

| Item | Cost (coins) |
|------|--------------|
| Blacksmith Blessing | 4 |
| Enriched Oridecon Box (5) | 3 |
| Enriched Elunium Box | 6 |
| Shadowdecon Ore Box | 3 |
| Amethyst Fragment Box | *(see yml)* |

### Costumes (`barter_pro_costumes`) — **vanity only**

Popular picks: Scarlet Band, Vesper Headgear, Neko Mimi Kafra, Deviling Hat, Angeling Hat, Reginleif Hairband, Mistress Crown, Freyja Crown — **6–12 coins** each.

---

## Playtime Shop Rewards (sample)

Spend `#PlayPoints` at Earl → Points Shop:

| Item ID | Cost | Look up |
|---------|------|---------|
| 12534 | 20 pts | Divine Pride |
| 607 | 5 pts | Yggdrasil Berry |
| 12250–12255 | 9 pts | Buff foods |
| 25223 | 1 pt | — |
| 102803 | 1 pt | — |

Full list in `npc/custom/hourly.txt`.

---

## Refining & Enchants

| System | Where |
|--------|-------|
| Safe Refine Certificate | Eden MVP exchange |
| Blacksmith Blessing | PVP prizes, coin shop, drops |
| Malangdo costume enchant | `malangdo` / `mal_in01` |
| Booster costume enchant | Centro → Yves |
| Episode 17.2 orbs | Baggot Lab |
| Laphine / Perfect Enchant UI | Usable items + client `EnchantList.lub` |

---

## Cards

| Service | Details |
|---------|---------|
| Drop rate | **100×** official |
| King Poring | 4 cards + 2.5M z → random card |
| Card Remover | `prt_in 28,73` — fees apply |
| `@whodrops <item>` | Find which mob drops a card |

---

## Quest Reward Items

| Quest | Reward type |
|-------|-------------|
| Valhallen | High-end weapon |
| Kaho Horn | Kaho horn headgear |
| Elven Ears / Sunglasses / Bandit Beard | Classic headgear |
| King's Items / May Hats | Custom hats |

---

## MVP & Endgame Loot

| Content | Notable drops |
|---------|---------------|
| Private MVP Room | Standard MVP tables, solo |
| Corridor of Phantoms | Shared MVP maps — high competition |
| Biosphere Depth | Daily hunt EXP + Barmund materials |
| Standard MVPs | Use `@whodrops` + Divine Pride |

---

## Item Lookup Tips

```
@iteminfo <name or id>   — in-game summary
@whodrops <item>         — drop sources
```

Website: [https://www.divine-pride.net/database/item](https://www.divine-pride.net/database/item)

---

## See Also

- [Custom Systems](Custom-Systems.md)
- [Dungeons & Instances](Dungeons.md)
- [NPCs & Merchants](NPCs-and-Merchants.md)
- [Home](Home.md)
