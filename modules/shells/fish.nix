# modules/shells/fish.nix — Fish shell (garden stack)
{ inputs, ... }:
{
  den.aspects.fish.homeManager =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      palette = inputs.garden-shell.lib.palette.colors;
      # Strip leading # for fish's bare-hex format
      bare = color: builtins.substring 1 6 color;
    in
    {
      programs.fish = {
        enable = true;

        # ── Garden prompt ────────────────────────────────────
        functions = {
          # Two-line prompt with ✧ character
          fish_prompt = ''
            set -l last_status $status

            # Information line
            set -l cwd (prompt_pwd --full-length-dirs 2)

            # Git info
            set -l git_branch ""
            set -l git_dirty ""
            if command git rev-parse --is-inside-work-tree &>/dev/null
              set git_branch (command git branch --show-current 2>/dev/null)
              set -l dirty_count (command git status --porcelain 2>/dev/null | wc -l | string trim)
              if test "$dirty_count" -gt 0
                set git_dirty "·$dirty_count"
              end
            end

            # Left side: path + git
            set_color ${bare palette.text-3}
            echo -n $cwd
            if test -n "$git_branch"
              echo -n " "
              set_color ${bare palette.text-4}
              echo -n "$git_branch$git_dirty"
            end

            echo  # newline

            # ✧ prompt character with color states
            if test $last_status -ne 0
              set_color ${bare palette.urgent}
            else if test -n "$IN_NIX_SHELL"
              set_color ${bare palette.accent}
            else if test -n "$VIRTUAL_ENV"
              set_color ${bare palette.ok}
            else
              set_color ${bare palette.text-1}
            end
            echo -n "✧ "
            set_color normal
          '';

          fish_right_prompt = ''
            # Right side: hostname (if SSH) + garden channel
            set -l parts

            if test -n "$SSH_CONNECTION"
              set -a parts (set_color ${bare palette.urgent})(hostname -s)(set_color normal)
            end

            if test -n "$GARDEN_CHANNEL"
              set -l channel_str "$GARDEN_CHANNEL"
              if test -n "$GARDEN_PAGE"
                set channel_str "$GARDEN_CHANNEL:$GARDEN_PAGE"
              end
              set -a parts (set_color ${bare palette.text-4})$channel_str(set_color normal)
            end

            echo -n (string join " " $parts)
          '';

          # Yazi cd-on-exit wrapper
          y = ''
            set -l tmp (mktemp)
            yazi --cwd-file=$tmp $argv
            set -l cwd (cat $tmp)
            if test -n "$cwd" -a "$cwd" != "$PWD"
              cd $cwd
            end
            rm -f $tmp
          '';
        };

        # ── Garden channel detection ─────────────────────────
        interactiveShellInit = ''
          # GARDEN_CHANNEL is the name of the focused Niri workspace,
          # shown in the right prompt. Windows only carry a workspace id,
          # so the name comes from the workspace list. Cleared when the
          # workspace is unnamed or there is no Niri session (SSH, TTY).
          function __garden_update_channel --on-event fish_prompt
            set -l ws
            if set -q NIRI_SOCKET; and command -q niri
              set ws (niri msg -j workspaces 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[] | select(.is_focused) | .name // empty' 2>/dev/null)
            end
            if test -n "$ws"
              set -gx GARDEN_CHANNEL $ws
            else
              set -e GARDEN_CHANNEL
            end
          end

          # Long-command notification (>10s)
          function __garden_notify_on_long_command --on-event fish_postexec
            set -l duration $CMD_DURATION
            if test $duration -gt 10000
              set -l seconds (math "$duration / 1000")
              notify-send "fish" "Command completed in {$seconds}s: $argv[1]" 2>/dev/null
            end
          end

          # Fish colors managed by garden.terminal aspect (universal vars
          # set by garden-themes apply, sourced from mutable theme file).

          # Vi mode
          fish_vi_key_bindings
        '';

        # ── Abbreviations ────────────────────────────────────
        # The git shortcuts are defined once, as shell aliases, in
        # modules/git/aliases.nix. Here the common ones also become
        # abbreviations, so they expand in place as you type.
        shellAbbrs = lib.filterAttrs (
          name: _:
          builtins.elem name [
            "g"
            "ga"
            "gaa"
            "gc"
            "gcm"
            "gco"
            "gp"
            "gl"
            "gd"
            "gds"
            "gg"
            "gst"
            "gstp"
          ]
        ) config.home.shellAliases;
      };

      # Packages needed by fish integration
      home.packages = with pkgs; [
        jq
        libnotify
      ];
    };
}
