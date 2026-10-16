# Input bindings

These bindings are local to the Verdant Test Field. They are read in `ClickToMoveInput` and do not start combat, progression, or a network session.

| Input | Action |
| --- | --- |
| Left click | Raycast into the field. A walkable hit becomes a path. A blocked hit or a miss does not move the character. |
| W A S D | Optional camera-relative move. Cancels the current click path while held. |
| Mouse wheel | Zoom the orthographic camera in and out. |
| Q / E | Rotate the camera yaw by 90 degrees. |
| F | Play the local attack animation. It does not apply damage. |
| G | Play the local death animation and stop movement. |
| T | Return from the death animation to idle. |

The camera starts at yaw 45 degrees and pitch -35.264 degrees, orthographic, and follows the character. World coordinates are X and Z on the ground, with Y up. The field size comes from `content/maps/verdant-test-field.json`.
