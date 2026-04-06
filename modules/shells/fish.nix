# modules/shells/fish.nix — Fish shell (garden stack)
{ den, ... }:
{
  den.aspects.fish.homeManager = { pkgs, lib, ... }:
    let
      # Mokume palette (hardcoded — will be generated from palettes.json later)
      mokume = {
        base = "#2c3444";
        base-hl = "#3d4759";
        text-4 = "#505e70";
        text-3 = "#6b7a8d";
        text-2 = "#8b9bb0";
        text-1 = "#d4c5a9";
        accent = "#c9b88c";
        urgent = "#c4796b";
        ok = "#7c9a7c";
      };
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
            set_color ${builtins.substring 1 6 mokume.text-3}
            echo -n $cwd
            if test -n "$git_branch"
              echo -n " "
              set_color ${builtins.substring 1 6 mokume.text-4}
              echo -n "$git_branch$git_dirty"
            end

            echo  # newline

            # ✧ prompt character with color states
            if test $last_status -ne 0
              set_color ${builtins.substring 1 6 mokume.urgent}
            else if test -n "$IN_NIX_SHELL"
              set_color ${builtins.substring 1 6 mokume.accent}
            else if test -n "$VIRTUAL_ENV"
              set_color ${builtins.substring 1 6 mokume.ok}
            else
              set_color ${builtins.substring 1 6 mokume.text-1}
            end
            echo -n "✧ "
            set_color normal
          '';

          fish_right_prompt = ''
            # Right side: hostname (if SSH) + garden channel
            set -l parts

            if test -n "$SSH_CONNECTION"
              set -a parts (set_color ${builtins.substring 1 6 mokume.urgent})(hostname -s)(set_color normal)
            end

            if test -n "$GARDEN_CHANNEL"
              set -l channel_str "$GARDEN_CHANNEL"
              if test -n "$GARDEN_PAGE"
                set channel_str "$GARDEN_CHANNEL:$GARDEN_PAGE"
              end
              set -a parts (set_color ${builtins.substring 1 6 mokume.text-4})$channel_str(set_color normal)
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
          # Detect Niri workspace for GARDEN_CHANNEL
          function __garden_update_channel --on-event fish_prompt
            if command -q niri
              set -l ws (niri msg -j focused-window 2>/dev/null | ${pkgs.jq}/bin/jq -r '.workspace_name // empty' 2>/dev/null)
              if test -n "$ws"
                set -gx GARDEN_CHANNEL $ws
              end
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

          # Fish color theme (mokume)
          set -g fish_color_cwd          ${builtins.substring 1 6 mokume.text-3}
          set -g fish_color_cwd_root     ${builtins.substring 1 6 mokume.urgent}
          set -g fish_color_command      ${builtins.substring 1 6 mokume.text-2}
          set -g fish_color_param        ${builtins.substring 1 6 mokume.text-3}
          set -g fish_color_quote        ${builtins.substring 1 6 mokume.accent}
          set -g fish_color_string       ${builtins.substring 1 6 mokume.ok}
          set -g fish_color_comment      ${builtins.substring 1 6 mokume.text-4}
          set -g fish_color_operator     ${builtins.substring 1 6 mokume.text-3}
          set -g fish_color_redirection  ${builtins.substring 1 6 mokume.text-3}
          set -g fish_color_end          ${builtins.substring 1 6 mokume.text-3}
          set -g fish_color_escape       ${builtins.substring 1 6 mokume.accent}
          set -g fish_color_error        ${builtins.substring 1 6 mokume.urgent}
          set -g fish_color_autosuggestion ${builtins.substring 1 6 mokume.text-4}
          set -g fish_color_selection    ${builtins.substring 1 6 mokume.base-hl}
          set -g fish_color_search_match ${builtins.substring 1 6 mokume.base-hl}
          set -g fish_color_cancel       ${builtins.substring 1 6 mokume.urgent}

          set -g fish_pager_color_prefix      ${builtins.substring 1 6 mokume.text-1}
          set -g fish_pager_color_completion  ${builtins.substring 1 6 mokume.text-2}
          set -g fish_pager_color_description ${builtins.substring 1 6 mokume.text-3}
          set -g fish_pager_color_selected_background ${builtins.substring 1 6 mokume.base-hl}

          # Vi mode
          fish_vi_key_bindings
        '';

        # ── Abbreviations ────────────────────────────────────
        shellAbbrs = {
          g = "git status -sb";
          ga = "git add";
          gaa = "git add --all";
          gc = "git commit";
          gcm = "git commit -m";
          gco = "git checkout";
          gp = "git push";
          gl = "git pull";
          gd = "git diff";
          gds = "git diff --staged";
          gg = "git log --graph --decorate --oneline --all";
          gst = "git stash";
          gstp = "git stash pop";
        };
      };

      # Packages needed by fish integration
      home.packages = with pkgs; [
        jq
        libnotify
      ];
    };
}
