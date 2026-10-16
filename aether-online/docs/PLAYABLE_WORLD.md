# Playable world

Verdant Test Field is the client's main scene. It is an offline 2.5D map: one local character, click-to-move through Godot navigation, an orthographic isometric camera, and placeholder art generated in this repository. The dedicated server was not changed. There is no multiplayer, no combat resolution, and no progression. Attack and death are local animation states.

## Files

| Path | Role |
| --- | --- |
| `client/Aether.ClientSim/` | Plain C# map layout, walk grid, path request, step limiter, animation state, and camera rig. No Godot types. |
| `client/AetherClient/content/maps/verdant-test-field.json` | Map size, blocked rects, paths, and props. The client reads this file. |
| `data/maps/verdant-test-field.json` | Identical catalog copy. |
| `client/AetherClient/scenes/maps/VerdantTestField.tscn` | Main scene. Player, navigation agent, camera, and debug overlay. |
| `client/AetherClient/scripts/maps/FieldMap.cs` | Builds ground, paths, blockers, and props from the JSON. |
| `client/AetherClient/scripts/maps/NavigationMeshFactory.cs` | Turns the walk grid into a `NavigationMesh`. |
| `client/AetherClient/scripts/maps/PropFactory.cs` | Placeholder tree, rock, and building meshes. |
| `client/AetherClient/scripts/player/PlayerController.cs` | Applies click movement and optional WASD. |
| `client/AetherClient/scripts/player/PlayerVisual.cs` | `AnimatedSprite3D`, feet on the ground, depth sort from X+Z. |
| `client/AetherClient/scripts/player/CharacterAnimationController.cs` | Drives idle, walk, attack, and death frames. |
| `client/AetherClient/scripts/camera/IsometricCameraController.cs` | Follow, zoom, and 90-degree yaw. |
| `client/AetherClient/scripts/input/ClickToMoveInput.cs` | Mouse and key input. It does not move the body. |
| `client/AetherClient/scripts/navigation/LocalNavigationController.cs` | `NavigationAgent3D` path follow, capped by speed × delta. |
| `client/AetherClient/scripts/debug/DebugOverlay.cs` | Position, destination, path status, FPS, animation. |
| `client/AetherClient/scripts/session/VerdantFieldSession.cs` | Wires the components and runs the headless harness. |
| `client/AetherClient/assets/sprites/placeholder-traveler.png` | 8 directions × idle, walk, attack, and death frames. |
| `tools/generate_placeholder_sprites.py` | Regenerates that sheet. |
| `tests/Aether.ClientSim.Tests/` | Path, step, animation, and camera tests. |
| `docs/INPUT_BINDINGS.md` | Key and mouse table. |

World axes are X and Z on the ground, Y up. Cell size is `min(sizeX, sizeZ) / cellsAlongShortSide` from the map document. Movement speed is a character property, not a world size.

## Launch

From the repository root, with Godot 4.5.2 .NET and .NET SDK 8.0.426 on `PATH` (`DOTNET_ROOT` set if the SDK is user-local):

```bash
dotnet build AetherOnline.sln -c Debug
dotnet test AetherOnline.sln -c Debug
godot --headless --path client/AetherClient --quit-after 40
godot --headless --path client/AetherClient --quit-after 300 -- --nav-harness
```

Desktop:

```bash
godot --path client/AetherClient
```

The main scene is `res://scenes/maps/VerdantTestField.tscn`. Left click moves. WASD is camera-relative. The wheel zooms. Q and E rotate 90 degrees. F, G, and T are attack, death, and revive animations. See `docs/INPUT_BINDINGS.md`.

## Test results

`dotnet build AetherOnline.sln -c Debug` — **pass**, 0 warnings, 0 errors.

`dotnet test AetherOnline.sln -c Debug` — **pass**.

- `Aether.Architecture.Tests`: 13 passed, 0 failed.
- `Aether.ClientSim.Tests`: 10 passed, 0 failed.

Those 10 tests cover a path around a wall, a rejected out-of-bounds and blocked point that does not move the follower, the Verdant document's detour, map size read from JSON, animation facing, attack and death states, zoom, quarter turns, follow smoothing, and camera-relative WASD math. They also assert the project main scene is the field and that the scene contains one player plus the seven components.

`godot --headless --path client/AetherClient --quit-after 40` — **pass**, exit 0.

```text
[Information] AetherClient ready role=client protocol=0.1 map=map.verdant-test-field player=1 rules=0 main_scene=res://scenes/maps/VerdantTestField.tscn
```

`godot --headless --path client/AetherClient --quit-after 300 -- --nav-harness` — **pass**, exit 0.

```text
HARNESS map=map.verdant-test-field player=1
HARNESS plain_points=22 agent_points=26 moved=0.300 cap=0.300
HARNESS ground_ray=True blocker_ray=True
HARNESS zoom 12.00->10.80 yaw 45.00->135.00
HARNESS animation=walk_east
HARNESS_RESULT=pass
```

The harness ran inside the field after navigation had synced. It did all of the following:

- Asked `GridPathfinder` for a walkable goal whose straight line crosses a blocker, and got 22 waypoints that stay outside the blocked interior.
- Set that goal on `NavigationAgent3D` and read 26 path points. The path does not enter a blocked rect (border contact within 0.2 units is allowed).
- Called `PlayerController.SimulateStep(0.05)`. The body moved 0.300, equal to speed × delta, and did not reach the goal.
- Cast a physics ray onto open ground (`ground_ray=True`) and onto the central blocker (`blocker_ray=True`). An outside pick and a blocked pick left the position unchanged.
- Called `IsometricCameraController.ZoomBy(1)` and `RotateQuarter(1)`. Orthographic size went from 12 to 10.80 and yaw from 45 to 135, and the `Camera3D` size matched.
- After the step, `CharacterAnimationController` reported `walk_east`.

## Known limitations

- No windowed mouse or keyboard was injected. Headless code called the same controller methods the input node calls. WASD key events were not pressed; `IsometricCameraRig.CameraRelativeMove` was unit-tested instead.
- Sprites were not screenshotted. Frame choice is covered by `CharacterAnimationLogic` and by the harness animation name.
- `NavigationAgent3D.AvoidanceEnabled` is false. Static obstacles are cut out of the navigation mesh, which is what makes the path go around them. `NavigationObstacle3D` agents are not used.
- Attack does not hit anything. Death does not remove the character. T returns to idle.
- The server process does not load this map.
- Godot's funnel can skim a blocker border. The harness treats 0.2 units of border contact as outside the blocked interior.
- Closing the headless process can report dummy-renderer RID leaks in some runs. The successful launch and harness logs above did not.
