default:
    @just --list

update:
    nix flake update

check:
    nix flake check "path:$PWD"

check-all-systems:
    nix flake check "path:$PWD" --all-systems --no-build --keep-going

check-hm-mac:
    nix build "path:$PWD#homeConfigurations.satsuki.activationPackage"

check-hm-linux:
    nix build "path:$PWD#homeConfigurations.linux.activationPackage"

deploy-hm *args:
    ./bootstrap-home-manager.sh {{args}}

deploy-darwin *args:
    ./bootstrap-darwin.sh {{args}}

# Create and provision the OrbStack NixOS builder VM.
# Run deploy-darwin afterwards to register the builder on the host.
deploy-orbstack-builder:
    #!/bin/sh
    set -e
    if ! orb list | grep -q nixos-builder; then
        echo "Creating OrbStack VM: nixos-builder"
        orb create nixos:25.11 nixos-builder
    fi
    ./modules/hosts/_satsuki/setup-orbstack-builder.sh

lint:
    statix check .
    deadnix .

fmt:
    find . -name "*.nix" -exec nixpkgs-fmt {} \;

check-py:
    ruff check .

test-workflow:
    act -j build --container-architecture linux/amd64

test-pr:
    act pull_request --container-architecture linux/amd64

clean-atuin:
    home/bin/k-atuin-clean interactive
