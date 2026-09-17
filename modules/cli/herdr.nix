# modules/cli/herdr.nix — herdr terminal multiplexer with AI agent awareness
#
# Keybindings follow the Niri/Ghostty/tmux/vi-mode stack:
#   Prefix:  Super+Space (tmux keeps Ctrl+Space — never nest the two anyway)
#   Panes:   h/j/k/l     (navigate), v/s (split), x (close), q (detach)
# h/j/k/l, v, x and q are herdr's own defaults; only the prefix, the
# split-down key and the settings key are overridden. Run
# `herdr config check` after changing anything here.
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
      # in-app theme editor (edit the [theme] block below instead).
      xdg.configFile."herdr/config.toml".text = ''
        onboarding = false

        # $SHELL is still bash on the Ubuntu laptop (fish is not chsh'd), so
        # name the shell explicitly. Non-login is right: fish sources the
        # home-manager session variables from config.fish either way.
        [terminal]
        default_shell = "${lib.getExe pkgs.fish}"
        shell_mode = "non_login"

        [keys]
        # Super+Space. Niri leaves it unbound and Ghostty passes it through
        # via the kitty keyboard protocol, which herdr enables. tmux keeps
        # Ctrl+Space, so the two never collide.
        prefix = "cmd+space"
        split_horizontal = "prefix+s"   # split down, as in tmux (default: prefix+minus)
        settings = "prefix+shift+s"     # frees prefix+s for the split

        # Follow the host terminal's ANSI palette (the garden/fern-shell
        # theme in Ghostty) instead of a built-in herdr theme.
        [theme]
        name = "terminal"
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
