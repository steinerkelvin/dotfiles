# Reusable home-manager module: git commit signing (the how-I-sign half).
#
# The signing KEY is host- and hardware-specific (a TPM-sealed SSH key on one
# box, a Secure Enclave / YubiKey / GPG key on another), so this module owns only
# the wiring and takes the key from the consumer. Pairs with homeModules.identity
# (who I am), which is portable; this one is not.
#
# Layers additively on homeModules.git (which sets no signing). Disabled by
# default -- a host opts in and supplies a key:
#
#   imports = [ inputs.kelvin-dotfiles.homeModules.git-signing ];
#   features.git-signing = {
#     enable = true;
#     format = "ssh";                          # or "openpgp"
#     key = "/home/me/.ssh/id_ecdsa.pub";      # ssh: pubkey PATH; openpgp: key id
#     allowedSignersFile = "/home/me/.ssh/allowed_signers";   # ssh-only, for local verify
#   };
#
# CAVEAT: signByDefault = true means commit.gpgsign is on globally, so a commit
# FAILS CLOSED if the signing backend (ssh agent / gpg-agent / smartcard) is
# unreachable. Repos that pin a repo-local signingkey still win over this.

_:

{
  flake.homeModules.git-signing = { config, lib, ... }:
    let
      cfg = config.features.git-signing;
    in
    {
      options.features.git-signing = {
        enable = lib.mkEnableOption "git commit signing with a host-supplied key";

        format = lib.mkOption {
          type = lib.types.enum [ "ssh" "openpgp" ];
          default = "ssh";
          description = ''
            git `gpg.format`. "ssh" covers SSH keys including TPM-/SE-/YubiKey-backed
            ones via an ssh agent; "openpgp" is a GPG key.
          '';
        };

        key = lib.mkOption {
          type = lib.types.str;
          example = "~/.ssh/id_ecdsa.pub";
          description = ''
            git `user.signingkey`. For format = "ssh" this is the PUBLIC key path
            (git fetches the private op from the agent); for "openpgp" it's the GPG
            key id.
          '';
        };

        signByDefault = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = ''
            git `commit.gpgsign`. Signs every commit. Fails closed when the signing
            backend is unreachable -- set false to sign only on `git commit -S`.
          '';
        };

        allowedSignersFile = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "~/.ssh/allowed_signers";
          description = ''
            git `gpg.ssh.allowedSignersFile` (ssh format only). Needed for local
            `git log --show-signature` verification; ignored for openpgp.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        programs.git.settings = {
          commit.gpgsign = cfg.signByDefault;
          user.signingkey = cfg.key;
          gpg = {
            format = cfg.format;
          } // lib.optionalAttrs (cfg.format == "ssh" && cfg.allowedSignersFile != null) {
            ssh.allowedSignersFile = cfg.allowedSignersFile;
          };
        };
      };
    };
}
