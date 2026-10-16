# AETHER Online — game design

This document records the game we intend to build. None of the systems below are implemented. The playable shell in this repository is a boot scene and a headless process.

## Pitch

AETHER Online is an original 2.5D fantasy MMORPG set in Vaelund, a coast and highland world stitched by visible currents of aether. Players control original sprite characters in stylized three-dimensional places. The camera looks down an orthographic isometric view. Other players share the same places on a dedicated server that decides what is true.

The world, monsters, characters, and art are original. This project does not reuse another MMORPG's names, maps, items, or assets.

## Presentation

- Characters are sprites.
- Places are stylized 3D environments.
- The camera is orthographic, with a classic isometric pitch (about 35.264 degrees) and a 45 degree yaw.
- The client window starts at 1280 by 720.
- The current client scene draws a title, a solid backdrop, and a primitive ground mesh. That mesh is a placeholder, not a location in Vaelund.

## World

Vaelund is the setting name reserved for later writing. The only authored place in the repository is Placeholder Haven (`map.placeholder.haven`). The only authored appearance is Placeholder Traveler (`appearance.placeholder.traveler`). There is no bestiary, no town list, and no quest line yet.

## Play pattern

The intended game is a modernized classic sprite MMORPG:

- Real-time combat against a selected target. Damage, skills, and monster behavior are undesigned here and unimplemented.
- Two progression tracks: base level and job level. Thresholds, jobs, and rewards are undesigned here and unimplemented.
- A persistent character on a server the player does not host.
- Other players visible in the same place, with the server deciding positions and outcomes.

Those sentences are design intent. There is no combat loop, no experience table, and no account.

## Session shape

A future session is server-authoritative. The client shows the world and sends intents. The server accepts or rejects them. The planned transport is ENet through Godot's multiplayer API, described in `docs/NETWORK_PROTOCOL.md` and not built.

Persistence is planned on PostgreSQL, described in `docs/DATABASE_SCHEMA.md` and not built.

## What a player can do in this build

Launch the client and see the boot shell. Launch the dedicated server and see a boot log line. Nothing else.

## Art

The only original marks in the repository are two vector icons (client and server) and the primitive mesh created in code. There is no sprite sheet, no environment pack, and no third-party asset dependency.
