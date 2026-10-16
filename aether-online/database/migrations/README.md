# Database migrations

PostgreSQL is the planned database for AETHER Online. It is not provisioned in this repository.

This directory will hold forward-only SQL migrations in a later slice. Do not add connection strings, passwords, roles, or certificates here. The dedicated server will read a connection string from the `AETHER_DB_CONNECTION_STRING` environment variable when a database slice exists. Until then, leave that variable unset.

See `docs/DATABASE_SCHEMA.md`.
