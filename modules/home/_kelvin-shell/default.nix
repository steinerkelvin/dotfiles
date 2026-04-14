{ ... }:

let
  readFile = builtins.readFile;
in
{
  dt = readFile ./dt.sh;
}
