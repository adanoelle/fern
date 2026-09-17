# modules/cli/claude-code.nix — Claude Code CLI plus the hooks that make
# many parallel sessions across many repos bearable.
#
# Two hook scripts are linked into ~/.claude/hooks and registered in
# ~/.claude/settings.json on activation:
#
#   claude-notify   Notification hook → desktop toast via notify-send, so a
#                   session that is blocked on approval or has gone idle
#                   surfaces on the desktop no matter which Niri workspace
#                   or herdr pane it lives in. The toast names the repo.
#
#   claude-brief    SessionStart hook → injects the vault "project brief"
#                   for this repo into the session context. Opt-in per
#                   repo: put the path of the project note (usually
#                   ~/work/notes/projects/<slug>.md) on the first line of
#                   <repo>/.claude/brief. Only the Overview, Current Focus,
#                   newest Log entry and Open Questions sections are sent,
#                   capped at 120 lines, so a long log never floods context.
#
# settings.json stays a mutable file owned by Claude Code (/config writes
# to it). The activation script merges the two hooks in with jq only when
# they are missing, and never touches anything else in the file. herdr's
# own Claude integration (modules/cli/herdr.nix) uses the same approach.
_: {
  den.aspects.claude-code.homeManager =
    { pkgs, lib, ... }:
    let
      claude-notify = pkgs.writeShellApplication {
        name = "claude-notify";
        runtimeInputs = [
          pkgs.jq
          pkgs.libnotify
        ];
        text = ''
          # Claude Code "Notification" hook: JSON on stdin, toast on the desktop.
          input=$(cat)
          kind=$(jq -r '.notification_type // ""' <<<"$input")
          message=$(jq -r '.message // "Claude Code needs you"' <<<"$input")
          cwd=$(jq -r '.cwd // ""' <<<"$input")
          project=''${cwd##*/}
          [ -n "$project" ] || project="claude"

          case "$kind" in
            permission_prompt)
              urgency=critical
              summary="$project: approval needed"
              ;;
            idle_prompt)
              urgency=normal
              summary="$project: waiting for you"
              ;;
            agent_needs_input | elicitation_dialog)
              urgency=normal
              summary="$project: input needed"
              ;;
            *)
              urgency=low
              summary="$project"
              ;;
          esac

          notify-send --app-name="Claude Code" --urgency="$urgency" \
            "$summary" "$message" || true
        '';
      };

      claude-brief = pkgs.writeShellApplication {
        name = "claude-brief";
        runtimeInputs = [
          pkgs.jq
          pkgs.gawk
        ];
        text = ''
          # Claude Code "SessionStart" hook: print the repo's project brief
          # from the notes vault so it lands in the session context.
          input=$(cat)
          dir=''${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd // ""' <<<"$input")}
          pointer="$dir/.claude/brief"
          [ -f "$pointer" ] || exit 0

          note=$(head -n 1 "$pointer")
          note=''${note/#\~/$HOME}
          if [ ! -f "$note" ]; then
            echo "claude-brief: project note not found: $note" >&2
            exit 0
          fi

          echo "Project brief from $note (vault note; read it in full for the log)."
          echo
          awk '
            /^## / {
              section = $0
              keep = (section ~ /^## (Overview|Current Focus|Open Questions|Log)/)
              entries = 0
            }
            keep && section ~ /^## Log/ && /^### / {
              entries++
              if (entries > 1) keep = 0
            }
            keep { print }
          ' "$note" | head -n 120
        '';
      };

      hooksDir = "$HOME/.claude/hooks";
    in
    {
      home.packages = [
        pkgs.claude-code
        claude-notify
        claude-brief
      ];

      home.file.".claude/hooks/claude-notify".source = lib.getExe claude-notify;
      home.file.".claude/hooks/claude-brief".source = lib.getExe claude-brief;

      # Register the hooks in ~/.claude/settings.json if they are missing.
      home.activation.claude-code-hooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        settings="$HOME/.claude/settings.json"
        ensure_hook() {
          # ensure_hook <event> <matcher> <command>
          if ! ${lib.getExe pkgs.jq} -e --arg ev "$1" --arg cmd "$3" \
              '(.hooks[$ev] // [])[] | .hooks[]? | select(.command == $cmd)' \
              "$settings" >/dev/null 2>&1; then
            ${lib.getExe pkgs.jq} --arg ev "$1" --arg m "$2" --arg cmd "$3" \
              '.hooks[$ev] = ((.hooks[$ev] // []) + [{matcher: $m, hooks: [{type: "command", command: $cmd}]}])' \
              "$settings" > "$settings.tmp" && mv "$settings.tmp" "$settings"
          fi
        }
        if [ -z "''${DRY_RUN:-}" ]; then
          mkdir -p "$HOME/.claude"
          [ -s "$settings" ] || echo '{}' > "$settings"
          ensure_hook Notification "permission_prompt|idle_prompt|agent_needs_input|elicitation_dialog" \
            '"${hooksDir}/claude-notify"'
          ensure_hook SessionStart "startup|resume|clear|compact" \
            '"${hooksDir}/claude-brief"'
        fi
      '';
    };
}
