# Passage: age-based password store. FiloSottile/passage, drop-in-ish for `pass`.
#
# Why: GPG-pass on macOS needs pinentry juggling and lacks first-class biometrics.
# age supports multi-recipient encryption out of the box -- the same store can be
# decrypted by macOS Secure Enclave (Touch ID), a YubiKey, an SSH key, or a plain
# offline backup key. Each device decrypts with whatever identity it holds.
#
# Recipient list lives in `~/.passage/store/.age-recipients` (committed alongside
# the store). Keep public keys checked in; never commit identity files for SE /
# YubiKey / file-based keys (those go in ~/.config/passage/identities/, gitignored).
#
# Plugins (separate features, only present where applicable):
#   - age-plugin-se        : macOS Secure Enclave / Touch ID (Darwin)
#   - age-plugin-yubikey   : YubiKey hardware identity (any platform with PCSC)
_: {
  flake.homeModules.passage = { pkgs, ... }: {
    home.packages = [
      pkgs.passage
    ];
  };
}
