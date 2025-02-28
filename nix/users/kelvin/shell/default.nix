{ ... }:

let
  readFile = builtins.readFile;
in
{
  vscode-remote = readFile ./vscode-remote.sh;
  dt = readFile ./dt.sh;
  try-echo = readFile ./try-echo.sh;
}
