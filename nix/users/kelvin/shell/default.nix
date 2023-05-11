{ ... }:

let
  readFile = builtins.readFile;
in
{
  copilot-cli = readFile ./copilot-cli.sh;
  nix = readFile ./nix.sh;
}
