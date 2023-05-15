{ ... }:

let
  readFile = builtins.readFile;
in
{
  copilot-cli = readFile ./copilot-cli.sh;
  aliases = readFile ./aliases.sh;
  nix = readFile ./nix.sh;
}
