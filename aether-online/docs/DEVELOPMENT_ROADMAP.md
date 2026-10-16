# Development roadmap

The client now opens Verdant Test Field, an offline isometric map with local click-to-move. The dedicated server still only boots. Combat resolution, progression, and gameplay networking are not implemented. See `docs/PLAYABLE_WORLD.md`.

## Explicitly not next

The next slice is not combat, not gameplay networking, and not character progression. Those depend on a content boundary and a configuration boundary that do not exist yet. Building them now would hard-code behavior the server cannot describe with data.

Also not next: accounts, PostgreSQL migrations, ENet peers, inventories, and quests.

## Next slice

Boot configuration and a read-only content catalog.

- Add a small diagnostics interface so client and server share the log-level read without sharing server settings.
- Load `data/` through a read-only catalog. `Aether.GameData` stays models. Put the loader in a new plain C# project if it needs file IO, so the model assembly stays free of disk access.
- Both processes log how many descriptors loaded, then exit the smoke path the way they do today.
- Fail closed on a missing file, a duplicate id, or a document that contains combat or progression fields.
- Tests cover malformed JSON, a client path that cannot see `AETHER_DB_CONNECTION_STRING`, and a catalog that returns Placeholder Haven and Placeholder Traveler.
- Still no socket, no peer, no experience, and no damage.

`tools/` can host a validator for the same catalog once the loader exists. `infrastructure/` stays empty of host definitions until the server process has something to supervise beyond boot.

## Later slices

After the catalog slice, in order:

1. Presentation contract: lock the isometric camera and a placeholder environment as data, still with no actors and no combat.
2. Session transport: construct the planned ENet peer and exchange the existing hello messages. Still no gameplay messages.
3. Account and PostgreSQL boundary: migrations and a verifier design, still without combat or job tables.
4. Only then, simulation: movement, targeting, and progression as server-owned rules behind `IGameRuleModule`.

Each of those is a separate slice. This roadmap does not schedule them.

## Watch item

.NET 8 and the 8.0.32 runtime reach end of support on 2026-11-10. Godot 4.5.2's desktop projects target `net8.0`, so this repository stays on that framework. Revisit the SDK pin together with the Godot pin. Do not move the target framework in the catalog slice.
