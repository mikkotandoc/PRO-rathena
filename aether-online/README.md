# AETHER Online

AETHER Online is an original 2.5D fantasy MMORPG. This repository is the initialization slice: a Godot 4 .NET client, a headless Godot dedicated server, and pure C# libraries for rules, message contracts, and content models. Combat, character progression, and gameplay networking are not implemented.

The client is the Windows player build. The dedicated server is a Linux-capable process. Both are C# Godot projects. Shared code does not reference Godot.

## Pinned versions

| Tool | Version |
| --- | --- |
| Godot .NET | 4.5.2 stable (`4.5.2.stable.mono.official.6ce3de25a`) |
| Godot.NET.Sdk | 4.5.2 |
| .NET SDK | 8.0.426 (`global.json` sets `rollForward` to `disable`) |
| .NET runtime / target framework | 8.0.32 / `net8.0` |
| C# | 12 |
| PowerShell | 7.6.7 |
| xUnit | 2.9.3 |
| xunit.runner.visualstudio | 2.8.2 |
| Microsoft.NET.Test.Sdk | 17.14.1 |

Godot's download name still says `mono`. That archive is the .NET build. The same pins are in `VERSIONS` and `docs/DECISIONS.md`.

## Windows client

1. Install the [.NET SDK 8.0.426](https://dotnet.microsoft.com/download/dotnet/8.0) x64 build.
2. Install [PowerShell 7.6.7](https://github.com/PowerShell/PowerShell/releases/tag/v7.6.7).
3. Install the official Godot **.NET** editor from `Godot_v4.5.2-stable_mono_win64.zip` (GitHub release `4.5.2-stable`). Use `Godot_v4.5.2-stable_mono_win64.exe` to edit. Use `Godot_v4.5.2-stable_mono_win64_console.exe` when you need a console.
4. Confirm `dotnet --version` prints `8.0.426` and the Godot executable prints a version that starts with `4.5.2`.
5. From the repository root:

```powershell
pwsh -File .\scripts\bootstrap.ps1
pwsh -File .\scripts\build.ps1
pwsh -File .\scripts\test.ps1
```

6. Open `client/AetherClient/project.godot` in the Godot 4.5.2 .NET editor, or press Play. The main scene is Verdant Test Field, an offline isometric map with one local character. Bindings are listed below and in `docs/INPUT_BINDINGS.md`.
7. Run the dedicated server from a terminal (it stays up until you stop the process):

```powershell
.\Godot_v4.5.2-stable_mono_win64_console.exe --headless --path server\AetherServer
```

Smoke-check that the project loads and then exits:

```powershell
.\Godot_v4.5.2-stable_mono_win64_console.exe --headless --path server\AetherServer --quit-after 30
```

Check that the client project opens:

```powershell
.\Godot_v4.5.2-stable_mono_win64_console.exe --headless --editor --path client\AetherClient --quit-after 1
```

## Linux server

The dedicated server runs headless. A desktop session is not required.

1. Install .NET SDK 8.0.426. A user-local install is enough:

```bash
curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
bash /tmp/dotnet-install.sh --version 8.0.426 --install-dir "$HOME/.dotnet"
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$DOTNET_ROOT:$PATH"
```

2. Install PowerShell 7.6.7 and put `pwsh` on `PATH`.
3. Download `Godot_v4.5.2-stable_mono_linux_x86_64.zip` from the Godot `4.5.2-stable` release. The executable is `Godot_v4.5.2-stable_mono_linux.x86_64`, next to the `GodotSharp` directory. Keep those files together. Put the executable on `PATH` as `godot`, or call it by path. The official binary expects the usual Godot shared libraries (X11, GL, fontconfig).
4. Confirm `dotnet --version` prints `8.0.426` and `godot --version` starts with `4.5.2`.
5. From the repository root, the bash wrapper adds a user-local `dotnet` and `pwsh` to `PATH` when they exist, then runs the PowerShell script:

```bash
./scripts/run.sh bootstrap
./scripts/run.sh build
./scripts/run.sh test
```

`pwsh -File ./scripts/bootstrap.ps1` (and the build and test scripts) is the same thing when `pwsh` and `dotnet` are already on `PATH`.

6. Open the client, when a desktop Godot session is available:

```bash
godot --editor --path client/AetherClient
```

Headless launch of the field:

```bash
godot --headless --path client/AetherClient --quit-after 40
```

7. Start the dedicated server. The process stays running until it is stopped:

```bash
godot --headless --path server/AetherServer
```

Load checks:

```bash
godot --headless --editor --path client/AetherClient --quit-after 1
godot --headless --path server/AetherServer --quit-after 30
```

## Build output

`scripts/build.ps1` and `scripts/test.ps1` use the Debug configuration. Godot's .NET SDK does not define a standard Release configuration, so the solution maps the client and server Release entries to Debug. Their assemblies land in `.godot/mono/temp/bin/Debug`, which is gitignored along with `bin/` and `obj/`.

## Configuration

Samples live in `config/` and `.env.example`. They contain no credentials. The only database setting is the name of an environment variable, `AETHER_DB_CONNECTION_STRING`, and it is server-only. Leave it unset. Logging uses `AETHER_LOG_LEVEL` (`Trace`, `Debug`, `Information`, `Warning`, `Error`, `Critical`). See `docs/TECHNICAL_ARCHITECTURE.md`.

## Layout

`client/AetherClient` and `server/AetherServer` are separate Godot projects. `shared/` holds `Aether.GameRules`, `Aether.Contracts`, and `Aether.GameData`. The client does not reference the server. Shared projects do not reference Godot. `docs/` describes the game, the architecture, the planned ENet session, the planned PostgreSQL schema, the roadmap, and the version decisions. `database/migrations/` has no SQL yet.

## Playable field

Verdant Test Field is the client's main scene. It is offline. The dedicated server is unchanged and still does not simulate this map.

| Input | Action |
| --- | --- |
| Left click | Move along a navigation path. Blocked ground and misses do not move the character. |
| W A S D | Camera-relative move. Holding a key cancels the click path. |
| Mouse wheel | Zoom the orthographic camera. |
| Q / E | Rotate the camera by 90 degrees. |
| F | Local attack animation. No damage. |
| G | Local death animation. Movement stops. |
| T | Leave the death animation. |

Details and the headless navigation harness are in `docs/INPUT_BINDINGS.md` and `docs/PLAYABLE_WORLD.md`.

## Scope

There is still no combat resolution, inventory, character progression, account, or network session. Attack and death on the field are animation states only. The dedicated server remains a boot process. See `docs/DEVELOPMENT_ROADMAP.md`.
