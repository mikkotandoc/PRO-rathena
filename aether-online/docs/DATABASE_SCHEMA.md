# Database schema

Status: planned. PostgreSQL is the intended database. No server is running, no migration SQL exists, and no credentials are stored in this repository.

## Connection

The dedicated server will read a connection string from `AETHER_DB_CONNECTION_STRING` when a database slice exists. `config/server.example.json` records that variable name and sets `database.enabled` to false. It does not contain a connection string. The client sample has no database section and the client code does not read the variable.

Leave the variable unset. Supply a real value only through the process environment or a secret store outside git. Do not commit a password, a certificate, or a host that is specific to a private environment.

`database/migrations/` contains a README and no SQL. Future migrations will be forward-only files in that directory, still without credentials.

## Planned tables

These names describe a later account-and-character slice. They are not created.

| Table | Purpose | Notes |
| --- | --- | --- |
| `account` | A login identity. | The verifier column is intentionally unspecified. Credential storage is a later design. No password column is defined here. |
| `character` | A character owned by an account. | Will reference an account and an appearance id. No level column is defined here. |
| `character_appearance` | The appearance a character uses. | Matches a content id such as `appearance.placeholder.traveler`. |

Not planned in the next slices, and not specified here: inventories, items, combat logs, experience, job tables, guilds, mail, or market data.

## Content versus rows

Map and appearance descriptors in `data/` are content files, not rows. A later catalog loads those files in process. PostgreSQL is for player-owned state, not for the placeholder JSON.

## Operational rules

- One database per environment, selected by the connection string.
- Migrations run out of band of the game server until an explicit migration runner exists.
- Application logs must not include the connection string.
- The initialization slice does not add a container, a role, or a local database.
