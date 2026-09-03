default:
    @just --list

update:
    nix flake update

# Create and provision the OrbStack NixOS builder VM. Register it on the host
# afterwards by applying the downstream darwin config.
deploy-orbstack-builder:
    #!/bin/sh
    set -e
    if ! orb list | grep -q nixos-builder; then
        echo "Creating OrbStack VM: nixos-builder"
        orb create nixos:25.11 nixos-builder
    fi
    ./modules/hosts/_satsuki/setup-orbstack-builder.sh

fmt:
    find . -name "*.nix" -exec nixpkgs-fmt {} \;

lint:
    statix check .
    deadnix .

check-py:
    ruff check .

check:
    nix flake check "path:$PWD"

check-all-systems:
    nix flake check "path:$PWD" --all-systems --no-build --keep-going

# Build the CI coverage target (modules/home/targets/ci.nix). Not deployable --
# it exists to prove the exported homeModules still build.
check-hm:
    nix build "path:$PWD#homeConfigurations.ci-linux.activationPackage"

test-workflow:
    act -j build --container-architecture linux/amd64

test-pr:
    act pull_request --container-architecture linux/amd64

clean-atuin:
    home/bin/k-atuin-clean interactive
