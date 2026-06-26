# Episode 20 Client Quest Window Sync

Copy the EP20 quest entries from your client `OngoingQuests.lub` into the game client:

**Source (official PRO Asia client):**
`SystemEN/OngoingQuests.lub`

**Quest ID ranges used by the server (must match client NAVI):**

| Range | Chapter |
|-------|---------|
| `17690` | EP20 start |
| `16691`–`16704` | Gorge, espionage, canyon, infiltration prep |
| `17691`–`17709` | Infiltration, sanct, maze, white cat report |
| `23100`–`23118` | Deep ancient sea, nest, maze rumors |
| `18220`–`18233` | Finale (Lehrar marks, Nyar, Undying One) |
| `20000`–`20008` | Chapter log titles |

Side / daily content (optional, not required for main story):
- `17710`–`17711` — maze cleaning daily
- `17712`–`17721` — Garden of Time (`icas_in2`)
- `17725`–`17728` — Lasagna event

The server `db/re/quest_db.yml` titles are aligned to the client EN lub for all main-story IDs above.
