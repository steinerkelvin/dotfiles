#!/bin/sh
# Provision the OrbStack NixOS builder VM.
#
# Reads the host's /etc/nix/builder_ed25519.pub, templates it into
# orbstack-builder-guest.nix, copies the result into the VM, patches
# configuration.nix to import it, and rebuilds.
#
# Idempotent - safe to re-run after updating the guest module.
#
# Prerequisites:
#   - VM already created: orb create nixos:25.11 nixos-builder
#   - /etc/nix/builder_ed25519 keypair exists on the host
#     (the public key is read and injected into the guest module)
#
# After running, you still need to (on the host):
#   1. Run: nix run nix-darwin -- switch --flake .
#   2. Reload daemon: sudo launchctl kickstart -k system/systems.determinate.nix-daemon
set -e

VM_NAME="nixos-builder"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GUEST_TEMPLATE="$SCRIPT_DIR/orbstack-builder-guest.nix"
HOST_PUBKEY="/etc/nix/builder_ed25519.pub"

# Read the host's builder public key.
if [ ! -f "$HOST_PUBKEY" ]; then
  echo "Error: $HOST_PUBKEY not found. Generate with:" >&2
  echo "  sudo ssh-keygen -t ed25519 -f /etc/nix/builder_ed25519 -N '' -C builder@localhost" >&2
  exit 1
fi
PUBKEY=$(cat "$HOST_PUBKEY")

# Template the public key into the guest module.
STAGED=$(mktemp)
trap 'rm -f "$STAGED"' EXIT
sed "s|@BUILDER_PUBKEY@|$PUBKEY|" "$GUEST_TEMPLATE" > "$STAGED"

# Clear stale host keys from previous VM instances.
sudo ssh-keygen -R "${VM_NAME}.orb.local" 2>/dev/null || true

echo "Setting up builder in OrbStack VM: $VM_NAME"

# Stage the guest NixOS module into the VM.
# Two-step (push to /tmp, then cp) because orb push runs as the default user.
orb push -m "$VM_NAME" "$STAGED" /tmp/builder.nix
orb shell -m "$VM_NAME" -u root cp /tmp/builder.nix /etc/nixos/builder.nix

# Patch configuration.nix to import builder.nix.
# Inserts the import line right after ./orbstack.nix in the imports list.
orb shell -m "$VM_NAME" -u root sh -c '
  if grep -q "builder.nix" /etc/nixos/configuration.nix; then
    echo "builder.nix import already present"
  elif ! grep -q "./orbstack.nix" /etc/nixos/configuration.nix; then
    echo "Error: ./orbstack.nix not found in configuration.nix, cannot insert import" >&2
    exit 1
  else
    sed -i "/\.\/orbstack\.nix/a\\      ./builder.nix" /etc/nixos/configuration.nix
    if grep -q "builder.nix" /etc/nixos/configuration.nix; then
      echo "Added builder.nix import to configuration.nix"
    else
      echo "Error: sed failed to insert builder.nix import" >&2
      exit 1
    fi
  fi
'

# Apply the configuration.
echo "Running nixos-rebuild switch..."
orb shell -m "$VM_NAME" -u root nixos-rebuild switch

echo "Done. Test with:"
echo "  sudo ssh -i /etc/nix/builder_ed25519 builder@${VM_NAME}.orb.local 'echo ok'"
