# Passage

Multi-recipient secrets store. Replaces GPG-based `pass`.

## Layout

- `~/.passage/identities` -- single file, all identities for *this* machine concatenated. passage reads only this path.
- `~/.passage/store/` -- the store. Can be a symlink (e.g. into `~/data/secrets/passage/` to colocate with other secrets).
- `~/.passage/store/.age-recipients` -- public recipient list, committed alongside the store. Each entry is encrypted to all recipients.
- `~/.config/passage/identities/*.txt` -- per-identity source files; concatenated into `~/.passage/identities` to enable each.

## Recipients

Identities that can decrypt the store. Public keys committed; the source identity files live machine-locally or offline.

| Recipient | Hardware | Source identity file | Recipient string (public) |
|-----------|----------|----------------------|----------------------------|
| satsuki SE | macOS Secure Enclave + Touch ID | `~/.config/passage/identities/satsuki-se.txt` | `age1se1...` |
| YubiKey | YubiKey 5+ slot | `~/.config/passage/identities/yubikey-<serial>.txt` | `age1yubikey1...` |
| Offline backup | plain age key on USB / paper | offline only -- never on disk | `age1...` |

Add more recipients as new hosts come online (e.g., linux box -> SSH ed25519 pubkey accepted directly by age).

## One-time provisioning (per Mac)

After `bootstrap-home-manager.sh` ships the new modules:

```sh
mkdir -p ~/.config/passage/identities

# Secure Enclave identity (Touch ID prompts on every decrypt)
age-plugin-se keygen \
  --access-control=any-biometry-or-passcode \
  -o ~/.config/passage/identities/$(hostname -s)-se.txt

# Capture the printed `age1se1...` line
```

## One-time provisioning (per YubiKey)

```sh
age-plugin-yubikey
# Interactive: pick a slot, set PIN policy (once / always), set touch policy (cached / always).
# Recommendation: PIN once-per-session, touch always.
# Capture the printed `age1yubikey1...` line.
# Identity file is generated under ~/.config/passage/identities/.
```

## One-time provisioning (offline backup)

```sh
# Pick a removable / offline destination:
age-keygen -o /Volumes/<usb>/passage-backup-$(date +%Y-%m-%d).key

# Capture the `# public key:` line. Store the *file* offline -- USB in a safe,
# encrypted disk image, paper printout, or a secondary location for redundancy.
# Never commit it. Never copy it to a synced cloud folder.
```

## Build the local identities file

passage reads exactly one file at `~/.passage/identities`. Concatenate the per-identity sources for this machine. The SE keygen output has no trailing newline, so a plain `cat` glues line 4 of the SE block onto the YK header -- use `printf '\n'` between them:

```sh
{ cat ~/.config/passage/identities/satsuki-se.txt
  printf '\n'
  cat ~/.config/passage/identities/yubikey-*.txt
} > ~/.passage/identities
chmod 600 ~/.passage/identities
```

Verify:

```sh
awk 'NR<=12 {printf "%d:%s\n", NR, $0}' ~/.passage/identities
# Expect: SE 4-line block, blank line, YK header + AGE-PLUGIN-YUBIKEY-1 line.
# If line 4 ends with `#       Serial: ...`, the cat glued blocks together --
# rebuild with the printf separator.
```

## Initialise the store

```sh
mkdir -p ~/.passage/store          # or symlink into ~/data/secrets/passage
cd ~/.passage/store
git init
```

`passage init <recipients>` is referenced in v1.7.4a2's dispatch but `cmd_init` isn't defined in the script -- it errors. Write `.age-recipients` directly:

```sh
printf '%s\n' \
  age1se1...           \
  age1yubikey1...      \
  age1...backup        \
  > ~/.passage/store/.age-recipients

git add .age-recipients && git commit -m "passage: initial recipients"
```

Smoke-test with a throwaway entry:

```sh
echo "test" | passage insert -m -f smoke-test
passage show smoke-test            # Touch ID prompt; expect "test"
passage rm -f smoke-test
```

## Migrate from `pass`

See `scripts/pass-to-passage.py`. Run after the store is initialised.

```sh
just check-hm-mac && ./bootstrap-home-manager.sh   # Phase 0+1 active
# provisioning steps above -- capture three recipient strings
# init store with those recipients
uv run scripts/pass-to-passage.py --source ~/.password-store --verify
```

The script:
1. Walks `~/.password-store` for `*.gpg`
2. `pass show` each entry (uses GPG + pinentry-mac, prompts once thanks to 8h cache)
3. `passage insert -m` the same content (uses passage + age-plugin-se, Touch ID prompt)
4. Re-reads with `passage show` and diffs against the GPG plaintext
5. Reports any mismatches

After a clean run with zero diffs:

```sh
mv ~/.password-store ~/.password-store.archive-$(date +%Y-%m-%d)
```

## Add a recipient later

```sh
cd ~/.passage/store
# Edit .age-recipients, add or remove a line
passage reencrypt          # re-encrypts every entry to the current recipient set
git add -A && git commit -m "passage: <change>"
```

## Lockout recovery

- Lost SE access (Mac wiped, replaced): YubiKey or offline backup decrypts. Re-provision SE on the new Mac, add its pubkey, re-encrypt.
- Lost YubiKey: SE or offline backup decrypts. Provision new YubiKey, add pubkey, re-encrypt, remove old YubiKey recipient.
- Lost SE *and* YubiKey: offline backup decrypts. Provision both fresh, swap recipients.
- Lost all three: store is unrecoverable. **Don't lose all three.** Two physically separate offline copies of the backup is the standard.

## What lives where

- Public recipients: `~/.passage/store/.age-recipients` (committed)
- Identity files: `~/.config/passage/identities/*.txt` (machine-local, gitignored)
- Encrypted store: `~/.passage/store/**/*.age` (committed to private remote)
- nix-managed CLI + plugins: see `modules/features/passage.nix`, `age-plugin-se.nix`, `age-plugin-yubikey.nix`
