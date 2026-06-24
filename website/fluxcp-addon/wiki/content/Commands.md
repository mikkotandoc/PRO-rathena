# Player Commands

[← Back to Home](Home.md)

Atcommands and script-bound commands on **PRO-Ragnarok**. Type `@commands` in-game for your full list.

**Default player group** is defined in `conf/groups.yml` (group **Player**, ID 0).

---

## Custom Script Commands

| Command | Description |
|---------|-------------|
| `@playtime` | Playtime progress — minutes toward next `#PlayPoints` reward |
| `@alootid2` | Manage extended autoloot groups (10×10 item slots) |
| `@storage2` | Open account storage slot 2 |
| `@storage3` | Open account storage slot 3 |
| `@storage4` | Open account storage slot 4 *(VIP)* |
| `@storage5` | Open account storage slot 5 *(VIP)* |
| `@storage6` | Open account storage slot 6 *(VIP)* |
| `@ping` | Connection latency check |
| `@macropatrol` | **GM only** — trigger macro detection on coin farm maps |

**Account storage:** `@storage` alone opens a menu (slots 1–3, or 1–6 if VIP).

---

## Information Commands (All Players)

| Command | Description |
|---------|-------------|
| `@commands` | List commands available to you |
| `@help` | Command help |
| `@rates` | Server EXP/drop rates |
| `@uptime` | How long the map server has been online |
| `@exp` | Current base/job EXP progress |
| `@mobinfo <name/id>` | Monster stats |
| `@iteminfo <name/id>` | Item description |
| `@whodrops <item>` | Monsters that drop an item |
| `@whereis <mob id>` | Maps a monster spawns on |
| `@servertime` | Server clock |
| `@showexp` | Toggle EXP gain display |
| `@showzeny` | Toggle zeny gain display |
| `@hominfo` / `@homstats` | Homunculus information |

---

## Loot & Quality of Life

| Command | Description |
|---------|-------------|
| `@autoloot` | Toggle pick up all drops |
| `@alootid +<id>` | Add item ID to autoloot list |
| `@alootid -<id>` | Remove from autoloot list |
| `@autoloottype` / `@aloottype` | Autoloot by item type |
| `@autotrade` | Keep vending offline after logout |
| `@refresh` | Clear active statuses on your character |
| `@noask` | Block trade / party invites |
| `@noks` | Kill-steal protection toggle |
| `@changedress` | Toggle wedding dress view |
| `@resurrect` | Revive without token *(if enabled)* |

---

## Travel & Storage

| Command | Description |
|---------|-------------|
| `@go <city>` | Warp to preset town |
| `@storage` | Kafra storage (slot 1) or storage menu |
| `@breakguild` | Leave guild (leader = disband) |

**Note:** `@mall` is documented in some files but **not granted** to players — use **Warper → Item Mall** instead.

---

## Chat Channels

| Command | Description |
|---------|-------------|
| `@channel` | Join / leave chat channels |
| `#global` | Server-wide chat *(cannot leave)* |
| `#trade` | Trading chat |
| `#support` | Help requests |
| `#ally` | Alliance chat |
| `#map` | Current map chat |

---

## VIP Commands

VIP group (**5**) inherits Player commands plus:

| Command | Extra |
|---------|-------|
| `@who` | List online players |
| `@rates` | *(also on VIP)* |

VIP also unlocks `@storage4`–`@storage6` via account storage script.

---

## Party & Guild

| Command | Description |
|---------|-------------|
| `@breakguild` | Leave or disband guild |
| `@request` | Send request message to GMs |

Charcommands (`#command`) may differ — type `@charcommands` if available.

---

## GM Commands

Not listed here. Staff use `doc/atcommands.txt` in the repo.

---

## Useful Combinations

```
@autoloot
@alootid +4001          // example: add Red Potion ID
@alootid2               // configure grouped autoloot
@rates
@playtime
@whodrops Jellopy
```

---

## See Also

- [Server Information](Server-Information.md)
- [Custom Systems](Custom-Systems.md)
- [Home](Home.md)
