# AGENTS.md

## Cursor Cloud specific instructions

rAthena is a Ragnarok Online MMORPG server emulator written in C++. It is a split
multi-server stack backed by a MariaDB/MySQL database. There is no game client in
this repo; clients connect over rAthena's TCP protocol.

### Services / ports
| Service | Binary | Port | Required | Notes |
|---|---|---|---|---|
| Login | `login-server` | 6900 | yes | account auth, hands client to char server |
| Char | `char-server` | 6121 | yes | characters; connects to login |
| Map | `map-server` | 5121 | yes | game world + NPC scripts; connects to char |
| Web | `web-server` | 8888 | optional | emblems/configs for modern clients |

### Build
- `./configure` then `make server tools` (renewal mode is the default; add `--enable-prere=yes` for pre-renewal).
- Binaries are written to the repo root (where `athena-start` expects them).
- The bundled 3rd-party libs in `3rdparty/` are built automatically; system build deps
  are `build-essential zlib1g-dev libpcre3-dev libmariadb-dev` (installed by the update script).

### Database setup (one-time per fresh DB; not in the update script)
MariaDB must be running first. On this VM the socket dir is not created automatically:
```
sudo mkdir -p /run/mysqld && sudo chown mysql:mysql /run/mysqld
sudo mariadbd --user=mysql &
```
Create the schema and import (renewal data is loaded from YAML in `db/`, so only the
core SQL is needed because `use_sql_db: no`):
```
sudo mariadb -e "CREATE DATABASE IF NOT EXISTS ragnarok;"
sudo mariadb ragnarok < sql-files/main.sql
sudo mariadb ragnarok < sql-files/logs.sql
sudo mariadb ragnarok < sql-files/web.sql
sudo mariadb ragnarok < sql-files/roulette_default_data.sql
```
Create a password-authenticated DB user (the default `root` is `unix_socket`-only and
cannot be used over TCP; note `127.0.0.1` resolves to `localhost` here):
```
sudo mariadb -e "CREATE USER IF NOT EXISTS 'ragnarok'@'localhost' IDENTIFIED BY 'ragnarok';
GRANT ALL PRIVILEGES ON ragnarok.* TO 'ragnarok'@'localhost'; FLUSH PRIVILEGES;"
```
DB credentials are supplied to the servers via the local override
`conf/import/inter_conf.txt` (this path is gitignored). Set `*_id`/`*_pw` to
`ragnarok`/`ragnarok` for all of login/ipban/char/map/web/log.

### Inter-server auth gotcha (important)
The committed `conf/char_athena.conf` and `conf/map_athena.conf` use inter-server
credentials `tier1` / `proserverpassword`. The `login` table's server account
(`account_id=1`, `sex='S'`) must match. Because `conf/login_athena.conf` has
`use_MD5_passwords: yes`, the stored `user_pass` must be the **MD5 hash** of the
plaintext, e.g.:
```
sudo mariadb ragnarok -e "UPDATE login SET userid='tier1', user_pass=MD5('proserverpassword') WHERE account_id=1;"
```
The same MD5 rule applies to player accounts (insert with `user_pass=MD5('<password>')`).

### Run
Start MariaDB (above), then either `./athena-start start` or run each binary in its own
shell (`./login-server`, `./char-server`, `./map-server`, optionally `./web-server`).
Start order does not strictly matter — char and map retry their connections every ~10s.

### Test / validate
- `./map-server --run-once` is the canonical CI validation: it loads all NPC scripts +
  YAML databases, then exits 0. Expect ~50 pre-existing **non-fatal** content errors in
  this fork (e.g. "Unknown mob ID" spawn references); these do not fail the run.
- `./tools/ci/npc.sh` enables all custom/test NPCs before a stricter validation run.
- There are no unit tests; correctness is validated by the run-once load and by logging
  in over the protocol.

### Note on a committed build fix
`src/char/int_quest.cpp` calls `mapif_quest_delete()` before its definition. A forward
declaration was added so the code compiles with modern GCC; this is required to build.
