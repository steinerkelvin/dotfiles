# age-plugin-se: Apple Secure Enclave plugin for age.
#
# Provides Touch-ID-gated identities backed by the SE. The private key never
# leaves the enclave; the identity file in ~/.config/passage/identities/ only
# references it.
#
# Provisioning (run once per Mac, by hand, after this module is active):
#
#     mkdir -p ~/.config/passage/identities
#     age-plugin-se keygen \
#       --access-control=any-biometry-or-passcode \
#       -o ~/.config/passage/identities/$(hostname -s)-se.txt
#
# Capture the printed `age1se1...` recipient line and add it to the store's
# .age-recipients file (and to passage-recipients.nix for reproducibility).
#
# Darwin-only: SE is Apple silicon hardware. Module is a no-op on Linux.
_: {
  flake.homeModules.age-plugin-se = { pkgs, lib, ... }: {
    home.packages = lib.optionals pkgs.stdenv.isDarwin [
      pkgs.age-plugin-se
    ];
  };
}
