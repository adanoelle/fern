# modules/cli/herdr.nix — herdr terminal multiplexer with AI agent awareness
#
# Keybindings follow the Niri/Ghostty/tmux/vi-mode stack:
#   Prefix:  Ctrl+Space  (same as tmux — never nest the two)
#   Panes:   h/j/k/l     (navigate), v/s (split)
#
# Staying fresh: the package comes straight from upstream's flake
# (inputs.herdr → overlays.nix). `just bump herdr` pins the newest commit;
# .github/workflows/update-flake-lock.yml opens a weekly PR doing the same.
#
# Claude Code integration: `herdr integration install claude` drops a
# SessionStart hook into ~/.claude/hooks and registers it in
# ~/.claude/settings.json so herdr learns each pane's session id and can
# `claude --resume` it after a server restart. The install is idempotent
# and version-aware, so it is re-run on every activation; that keeps the
# hook script in step with the herdr binary after a bump.
_: {
  den.aspects.herdr.homeManager =
    { pkgs, lib, ... }:
    {
      home.packages = [ pkgs.herdr ];

      # config.toml is a read-only store symlink. herdr writes to it in two
      # cases: dismissing first-run onboarding (declared off here) and the
      # in-app theme editor (use the [theme] block below instead).
      xdg.configFile."herdr/config.toml".text = ''
        onboarding = false

        [keys]
        prefix = "ctrl+space"

        [keys.pane]
        navigate_left = "h"
        navigate_down = "j"
        navigate_up = "k"
        navigate_right = "l"
        split_vertical = "v"
        split_horizontal = "s"
        close = "x"

        [theme]
        name = "catppuccin-frappe"
      '';

      # Keep the Claude Code integration installed and current.
      # settings.json stays a mutable file owned by Claude Code; herdr edits
      # it in place (jsonc-aware) and leaves every other key alone.
      home.activation.herdr-claude-integration = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -d "$HOME/.claude" ]; then
          run ${lib.getExe pkgs.herdr} integration install claude >/dev/null \
            || echo "herdr: claude integration install failed (non-fatal)" >&2
        fi
      '';
    };
}
