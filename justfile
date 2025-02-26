default:
    @just --list

update:
    nix flake update

check:
    nix flake check

fmt:
    find . -name "*.nix" -exec nixpkgs-fmt {} \;

test-workflow:
    act -j build --container-architecture linux/amd64

test-pr:
    act pull_request --container-architecture linux/amd64
