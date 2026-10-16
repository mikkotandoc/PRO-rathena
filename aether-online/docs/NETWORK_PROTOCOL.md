# Network protocol

Status: planned. This repository does not open a socket, create a multiplayer peer, or serialize packets.

## Transport

The planned transport is ENet through Godot's multiplayer API (`ENetMultiplayerPeer` on a dedicated-server peer and on the client). Godot already integrates ENet, which gives reliable and unreliable channels without a second networking stack. The dedicated server process is the Godot project in `server/AetherServer`. The client project must not host that peer.

No port is reserved and no peer is constructed in this slice. A listen port, if one is chosen later, will come from configuration rather than a credential.

## Authority

The server decides what is true. A future client will send intents. The server will accept or reject them and send the resulting state. The client will not simulate combat, rewards, or persistence on its own.

That authority split is the reason message contracts live in `Aether.Contracts`, separate from both Godot projects.

## What exists now

`Aether.Contracts` defines records only.

| Type | Kind | Fields |
| --- | --- | --- |
| `HelloMessage` | `Hello` (1) | `ClientBuild`, `ProtocolMajor`, `ProtocolMinor` |
| `HelloAckMessage` | `HelloAck` (2) | `ProtocolMajor`, `ProtocolMinor`, `ServerBuild` |
| `DisconnectNotice` | `Disconnect` (3) | `ReasonCode` |

`ProtocolVersion` is major `0`, minor `1`, name `aether.session`. `DisconnectReasons` defines `client_requested` and `protocol_mismatch`.

There is no serializer, no frame header, no channel number, and no Godot type in this assembly. `Aether.Contracts` does not reference `Aether.GameData`, so a later codec can stay on primitives.

`IMessageKindFilter` in `Aether.GameRules` is the seam a future session module can implement. Nothing implements it.

## Planned lifecycle

A later slice can add the peer. The intended order, still unimplemented, is:

1. The server process creates a server peer.
2. The client creates a client peer and sends `HelloMessage`.
3. The server answers with `HelloAckMessage` when the protocol numbers match, or `DisconnectNotice` with `protocol_mismatch` when they do not.
4. Either side can send `DisconnectNotice` with `client_requested` when the session ends.

Reliable delivery is the planned mode for those three messages. Unreliable delivery is reserved for later high-frequency state and is not designed here.

World entry, movement, combat, inventory, and chat are not message types yet. Do not add them as an incidental part of bringing up the peer.

## Security

Messages in this slice carry a build label and protocol numbers, not credentials. Do not put passwords, connection strings, or account verifiers into a message record. Authentication is a later slice and is not specified here.

## Explicit non-goals

- No ENet or `MultiplayerPeer` usage in the client, server, or shared projects.
- No replication of transforms.
- No combat or progression messages.
- No database access from the protocol assembly.
