# Configuration samples

These files document the configuration shape. They are not loaded automatically.

- `client.example.json` is client-only. It has no database section.
- `server.example.json` names the environment variable that will hold a PostgreSQL connection string later. It does not contain a connection string.
- `../.env.example` lists the same variables with comments.

Logging levels are `Trace`, `Debug`, `Information`, `Warning`, `Error`, and `Critical`. The active level comes from `AETHER_LOG_LEVEL`. The sample default is `Information`.

Do not log connection strings or account credentials. The full convention is in `docs/TECHNICAL_ARCHITECTURE.md`.
