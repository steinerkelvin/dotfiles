---
name: tailscale-serve
description: |
  This skill should be used when the user wants to serve a file, directory,
  or git diff over Tailscale HTTPS. Triggers on "serve on tailscale",
  "share via tailscale", "tailscale-serve", "tailscale serve file",
  "serve diff on tailscale", or /tailscale-serve.
allowed-tools:
  - Read
  - Bash
  - Write
---

# ts-serve

<!-- TODO: scripts and scope allowed-tools better -->

Serve files, directories, or git diffs over Tailscale HTTPS for easy cross-device access.

## Modes

Determine the serving mode from the user's arguments:

| Input                   | Mode    | What happens                                           |
| ----------------------- | ------- | ------------------------------------------------------ |
| No args (in a git repo) | diff    | Generate side-by-side HTML diff of uncommitted changes |
| `--diff`                | diff    | Explicit diff mode                                     |
| Path to a file          | file    | Serve that single file                                 |
| Path to a directory     | dir     | Serve directory listing                                |
| `off` or `stop`         | cleanup | Tear down server and tailscale serve config            |

## Serving workflow

### Step 1: Prepare content

**Diff mode** (default when no args and inside a git repo):

```sh
git diff --no-ext-diff --no-color HEAD | bunx diff2html-cli -s side -i stdin -F /tmp/ts-serve-diff.html
```

Set `SERVE_DIR=/tmp` and `SERVE_FILE=ts-serve-diff.html`.

**File mode**: Set `SERVE_DIR` to the file's parent directory, `SERVE_FILE` to the basename.

**Directory mode**: Set `SERVE_DIR` to the directory path, no `SERVE_FILE`.

### Step 2: Find a free port

```sh
python3 -c "import socket; s=socket.socket(); s.bind(('',0)); print(s.getsockname()[1]); s.close()"
```

Store as `PORT`.

### Step 3: Start local HTTP server

```sh
python3 -m http.server $PORT --directory "$SERVE_DIR" --bind 127.0.0.1 &
echo $! > /tmp/ts-serve.pid
```

### Step 4: Derive semantic slug

Generate a context-appropriate URL path slug:

- **Diff mode**: `/<repo-basename>-diff` — get repo name from `basename $(git rev-parse --show-toplevel)`
- **File mode**: `/<filename-without-extension>`
- **Directory mode**: `/<dirname-basename>`
- **User override**: If `--path <slug>` is provided, use that instead

### Step 5: Expose via Tailscale

```sh
tailscale serve --bg --set-path "/$SLUG" "http://127.0.0.1:$PORT"
```

### Step 6: Construct and return the URL

Get the machine's Tailscale DNS name:

```sh
tailscale status --self --json | python3 -c "import sys,json; print(json.load(sys.stdin)['Self']['DNSName'].rstrip('.'))"
```

Construct the full URL:

- File/diff: `https://<ts-hostname>/<slug>/<filename>`
- Directory: `https://<ts-hostname>/<slug>/`

Print the URL prominently for the user. Mention it is accessible from any device on their tailnet.

## Cleanup workflow

When invoked with `off` or `stop`:

```sh
# Stop tailscale serve
tailscale serve reset

# Kill HTTP server
kill $(cat /tmp/ts-serve.pid 2>/dev/null) 2>/dev/null
rm -f /tmp/ts-serve.pid

# Remove temp diff file
rm -f /tmp/ts-serve-diff.html
```

Confirm cleanup to the user.

## Notes

- Always bind the HTTP server to `127.0.0.1` — Tailscale handles external access
- `tailscale serve --bg` runs in background and persists until reset
- The HTTPS certificate is provisioned automatically by Tailscale
- If `tailscale serve` fails, fall back to printing `http://<ts-ip>:<port>/<filename>` and explain that `tailscale serve` may need to be enabled in the admin console
