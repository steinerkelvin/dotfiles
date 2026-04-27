# Email stack: filter management as code, local Gmail mirror, indexed search.
#
# - gmailctl  : declarative Gmail filter rules (Jsonnet/YAML)
# - lieer     : Gmail API <-> maildir sync, label-preserving (provides `gmi`)
# - notmuch   : Xapian-indexed tag-based search over maildir
# - aerc      : TUI client with notmuch backend (read/triage)
# - himalaya  : scriptable email CLI, for cron jobs / vault bridges
#
# Per-account configuration (credentials, account specifics, gmailctl YAML)
# lives outside this module. See ~/sync/castle for private specifics and
# ~/data/mail for the maildir content.
#
# Sending (msmtp + OAuth) is deferred. Drafts handled via Gmail MCP for now.
_: {
  flake.homeModules.email = { pkgs, ... }: {
    home.packages = [
      pkgs.gmailctl
      pkgs.lieer
      pkgs.notmuch
      pkgs.aerc
      pkgs.himalaya
    ];
  };
}
