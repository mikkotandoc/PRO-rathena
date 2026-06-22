# Items & Equipment

[← Back to Home](Home.md)

Equipment progression and notable items on PRO-Ragnarok.

---

## Item Database References

| Resource | URL |
|----------|-----|
| Divine Pride (multi-server) | https://www.divine-pride.net/database/item |
| rAthena item bonuses | `/doc/item_bonus.txt` in repo |
| Server item DB | `db/re/item_db.yml`, `db/re/item_db_usable.yml` |

---

## Progression Overview

```
Eden/Paradise Gear → Booster Weapons → Illusion Instance Gear
        → Episode Grace/Automatic Gear → Laphine Upgrades → Endgame Enchants
```

---

## Booster Equipment

**Source:** Centro (`prontera 166,300`) — `mega_booster.yml`

| Category | Examples |
|----------|----------|
| Booster weapons | IW_B_T_Sword, HB_B_T_Spear, job-group voucher weapons |
| Booster shadows | Shadow equipment exchanges |
| Upgrade items | Booster_W_Up_3, Metal refine tickets |
| Enchant scrolls | Boost_C_Enchant_1, Boost_C_Enchant_2 |
| Memento boxes | Memento_Box, P_Memento_Box |

---

## Episode Equipment

| Episode | Gear Type | How to Obtain |
|---------|-----------|---------------|
| 16.1–16.2 | Grace equipment | Instance & EP Merchant barters |
| 17.1 | Grace + Illusion tickets | sp_cor merchants, barters |
| 17.2 | Automatic / Admin accessories | Baggot Lab barters |
| 18–20 | Episode token gear | Episode hub merchants |

---

## Laphine Items

**Database:** `db/re/laphine_upgrade.yml`

Notable entry categories:

- **Ein weapon boxes** (`Ein_Ddbox`, `Ein_Ddbox2`) — Ein series weapons
- **Metal Refine Ticket** — refines Metal series to +7
- Hundreds of episode reform boxes for armor, garments, footgear, accessories

Use the item in inventory with a valid target equipped.

---

## Costumes

| Source | Currency |
|--------|----------|
| PRO-Asia costume barter | `Play_RO_Gold_Coin_` |
| Malangdo exchange | Zeny / exchange items |
| Booster boxes | Booster Coins |
| Gacha / events | *(placeholder)* |

Sample PRO-Asia costumes: C_Skarlet_Band_EXE, C_VesperHeadGear_J, C_Neko_Mimi_Kafra, C_Deviling_Hat

---

## Quest Reward Items

Enabled custom quests:

| Quest | Item |
|-------|------|
| Valhallen | Godly equipment |
| Kaho Horn | Kaho horn item |
| Elven Ears, Sunglasses, Bandit Beard | Classic headgear quests |
| King's Items, May Hats, Event 6 Hats | Custom headgear |

---

## Usable Items (Recent Changes)

`db/re/item_db_usable.yml` includes server-specific usable definitions. Check git history for latest additions (enchant stones, tickets, boxes).

---

## Card System

- **King Poring** (`prontera 174,176`) — recycle cards for random rewards
- **Card Remover** — remove cards from equipment
- Card drop rate: **100x** official

---

## See Also

- [Custom Systems](Custom-Systems.md)
- [Dungeons & Instances](Dungeons.md)
- [Home](Home.md)
