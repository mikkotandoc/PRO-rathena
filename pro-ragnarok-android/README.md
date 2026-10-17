# PRO-Ragnarok Android — Phase 1

Native **Android-first** Godot 4.x (GDScript) MMORPG client prototype. Runs **fully offline** with original placeholder assets. No commercial Ragnarok Online client data, and no speculative RO packet / WebSocket implementation.

Target engine: **Godot 4.7.x** (project features declare `4.7`).

## Layout

```
pro-ragnarok-android/
  project.godot
  export_presets.cfg          # Android APK export preset
  assets/placeholders/        # Original placeholder art only
  scenes/                     # main, demo map, player, mobile HUD
  scripts/
    rendering/                # Camera, billboard sprites, graphics quality
    input/                    # Virtual joystick, touch-to-move, pinch-zoom
    gameplay/                 # Player movement + offline demo session
    networking/               # Interface-only TCP/rAthena stubs (offline)
    assets/                   # Sprite + map provider interfaces
    ui/                       # Mobile HUD + safe-area helpers
    world/                    # Demo map builder
    core/                     # Bootstrap + main entry
  tests/run_tests.gd          # Headless movement / navigation / scene tests
```

Strict layering: rendering, input, gameplay, networking, and asset loading do not cross-call implementation details.

## Desktop debug

1. Install [Godot 4.7.x](https://godotengine.org/download) (standard build, not Mono required).
2. Open `pro-ragnarok-android/` in the Godot editor (or import `project.godot`).
3. Press **F5** / Run Project.

Headless / CLI:

```bash
godot --path pro-ragnarok-android
# or
godot --path pro-ragnarok-android --resolution 1920x1080
```

Desktop mouse emulates touch (`pointing/emulate_touch_from_mouse=true`):

- Drag the lower-left joystick to walk
- Click the ground to pathfind
- Mouse-wheel is not pinch; use two-finger trackpad pinch on touch devices, or adjust camera distance in code / future hotkeys
- Four skill buttons log placeholder offline casts
- **GFX** cycles Low / Medium / High; FPS is shown top-left

## Android APK export

Export preset: **Android** → `export/PRO-Ragnarok-Phase1.apk`

Package id: `com.proragnarok.client`  
Orientation: landscape / sensor landscape  
Architecture: **arm64-v8a**  
Export mode: Godot Android template APK (`gradle_build/use_gradle_build=false`)  
**Internet permission disabled** (offline Phase 1)

### One-time Godot Android setup

1. Install Android SDK + NDK via Android Studio, or command-line tools.
2. In Godot: **Editor → Editor Settings → Export → Android** — set SDK path, and configure a debug keystore (Godot can generate one).
3. Install Android export templates matching your Godot version (**Editor → Manage Export Templates**).
4. Open **Project → Export → Android → Export Project**.

CLI (after editor Android settings are configured on the machine):

```bash
godot --headless --path pro-ragnarok-android --export-debug "Android" export/PRO-Ragnarok-Phase1.apk
```

Install on a device:

```bash
adb install -r export/PRO-Ragnarok-Phase1.apk
adb shell am start -n com.proragnarok.client/com.godot.game.GodotApp
```

## Tests

```bash
godot --headless --path pro-ragnarok-android -s res://tests/run_tests.gd
```

Covers direction indexing, safe-area aspect helpers, offline network interface, asset providers, scene loading, navigation mesh presence, steer/path movement, and camera zoom clamps.

## Networking (Phase 1)

`NetworkClientBase` / `OfflineNetworkClient` define a future **native TCP** seam toward rAthena. Phase 1 always stays disconnected: `connect_to_server` / `send_raw` return `ERR_UNAVAILABLE`. **PACKETVER** and packet structs will be taken from real rAthena source later — nothing is invented here. No WebSocket or browser networking.

## License / assets

Placeholder PNGs and UI icons are original for this prototype. Do not redistribute Gravity / official RO client assets into this tree.
