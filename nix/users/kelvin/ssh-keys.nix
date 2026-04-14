# Kelvin's SSH public keys for authorized_keys.
# Kept outside the nixia archive because the keys are user-scoped and
# likely to be referenced by any future Linux or remote host config.

rec {
  users.kelvin = {
    satsuki = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/p/ZbOkA/Wv4dTYbT/CJ+vndMS7xN/8J8SAnVroK0T kelvin@satsuki.local";
  };

  # All kelvin's keys -- convenient for authorized_keys lists.
  kelvinAll = builtins.attrValues users.kelvin;
}
