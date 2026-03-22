# Raycast Script Commands

Standalone shell scripts with Raycast metadata comments. These run directly as script commands — no build step or dependencies required.

## Setup

1. Open Raycast Preferences > Extensions > Script Commands
2. Add this directory as a script command source

## Commands

| Script | Description | Mode |
|--------|-------------|------|
| `iso-week-date.sh` | Displays current ISO week date (e.g., `2026-W12`) | compact |

## Adding New Script Commands

Create a shell script with Raycast metadata comments:

```sh
#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title My Command
# @raycast.mode compact

# Optional parameters:
# @raycast.icon 🔧
# @raycast.packageName my-package

# Documentation:
# @raycast.author kelvin_steiner

echo "output shown in Raycast"
```

Make it executable: `chmod +x my-command.sh`

### Modes

- `compact` — single-line output shown inline
- `fullOutput` — multi-line output in a detail view
- `silent` — no output shown
- `inline` — shown in menu bar (with `refreshTime`)

## Reference

- [raycast/script-commands](https://github.com/raycast/script-commands) — community script commands and documentation

## See Also

For more complex commands using the Raycast API (TypeScript, UI components, AI):
see `packages/raycast-kelvin/`.
