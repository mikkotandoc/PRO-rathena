# Decisions

## ADR-001 — Split client, server, and shared code

The player build and the authoritative process are different programs. They share rules, message shapes, and content models, and they do not share host code.

- `client/AetherClient` is the Godot project a player opens. It does not reference the server project and does not read database settings.
- `server/AetherServer` is the dedicated server. It may reference the shared libraries. It does not reference the client.
- `shared/Aether.GameData`, `Aether.Contracts`, and `Aether.GameRules` are plain `net8.0` libraries. They do not reference Godot, so unit tests and future tools run without the engine.
- `Aether.Contracts` does not reference `Aether.GameData`. Message records stay on primitives so a later codec does not have to take a dependency on content types.
- `Aether.GameRules` may reference Contracts and GameData. Those projects do not reference GameRules. The graph is one-way.
- The server is one process. Modules, when they exist, will sit behind `IGameRuleModule` inside that process. The catalog is empty on purpose.

## ADR-002 — Pin Godot 4.5.2 and .NET SDK 8.0.426

| Pin | Value | Why |
| --- | --- | --- |
| Godot | 4.5.2 stable, build `4.5.2.stable.mono.official.6ce3de25a` | Newest stable release on the 4.5 line. The 4.4 line is end of life. Newer major lines exist; this initialization asked for 4.4 or 4.5. |
| Godot.NET.Sdk | 4.5.2 | Matches the editor. The SDK attribute is the C# binding version. |
| .NET SDK | 8.0.426 | Current 8.0 SDK when this repository was initialized. `global.json` sets `rollForward` to `disable`, so a different patch will not build until the pin is changed on purpose. |
| Runtime | 8.0.32 | Shipped with SDK 8.0.426. |
| Target framework | `net8.0` | Godot 4.5 desktop projects require .NET 8 or later. One framework keeps the client, server, and libraries on the SDK that `global.json` allows. Android export would need .NET 9 and is out of scope, so the Android target-framework conditional from the Godot template is omitted. |
| C# | 12 | Language version that ships with `net8.0`. |
| PowerShell | 7.6.7 | Scripts require PowerShell 7. `scripts/run.sh` is only a Linux PATH wrapper around those scripts. |
| xUnit | 2.9.3, runner 2.8.2, Microsoft.NET.Test.Sdk 17.14.1 | Explicit test stack. Versions are attributes on the test project, not floating restores. |

The official Godot .NET archives are still named `mono`. That is the .NET build.

.NET 8 support ends on 2026-11-10. Stay on this pin until a Godot upgrade and a framework upgrade can land together. See `docs/DEVELOPMENT_ROADMAP.md`.

## ADR-003 — Compatibility renderer

Both projects set `renderer/rendering_method="gl_compatibility"`. Headless validation and machines without Vulkan can open them. Stylized 3D and an orthographic isometric camera do not require Forward+ in the boot shell. A presentation slice can revisit the renderer.

## ADR-004 — No gameplay networking in this slice

ENet via Godot multiplayer is the planned transport and is documented in `docs/NETWORK_PROTOCOL.md`. The code defines `HelloMessage`, `HelloAckMessage`, and `DisconnectNotice` only. Nothing constructs a peer. Tests fail if `ENetMultiplayerPeer`, `MultiplayerPeer`, or `PacketPeer` appears under `client/`, `server/`, or `shared/`.

## ADR-005 — Secrets stay out of the tree

Samples name `AETHER_DB_CONNECTION_STRING` and never assign it a real value. Commented examples use placeholders such as `<from-secret-store>`. `.gitignore` ignores `.env` and private key material. The architecture tests scan tracked text, outside the test project itself, for assigned secrets and private-key blocks.

The server boot log reports `database=set` or `database=unset`. It does not write the connection string.

## ADR-006 — Placeholder content only

`data/` and `PlaceholderContent` agree on two ids: `map.placeholder.haven` and `appearance.placeholder.traveler`. Descriptors are marked `placeholder: true`. They have no combat or progression fields. No third-party art is vendored. The icons are original vector marks. The ground is a `BoxMesh` created in the client boot script.
