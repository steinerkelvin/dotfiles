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

deploy-hm:
    ./bootstrap-home-manager.sh

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
