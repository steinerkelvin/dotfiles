{ config, lib, ... }:

{
  config = lib.mkIf (config.k.host.tags.server) { };
}
