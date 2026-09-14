# modules/shells/zsh.nix — zsh shell (portable mirror of fish config)
#
# Mirrors the Fish shell experience: vi mode, two-line garden prompt,
# git aliases, yazi wrapper. The generated ~/.zshrc is self-contained
# and portable to remote systems where Fish/Nix aren't available:
#   scp ~/.zshrc olcf-home:.zshrc
#
# Tool integrations (eza, bat, zoxide, fzf, direnv) are guarded with
# command -v so they gracefully degrade when not installed.
{ den, ... }:
{
  den.aspects.zsh = {
    homeManager =
      { ... }:
      {
        programs.zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = false;
          syntaxHighlighting.enable = false;

          history = {
            size = 50000;
            save = 50000;
            ignoreDups = true;
            ignoreAllDups = true;
            ignoreSpace = true;
            share = true;
            extended = true;
          };

          initExtra = ''
            # Vi mode
            bindkey -v
            export KEYTIMEOUT=1

            # Restore bindings that vi mode overrides
            bindkey '^?' backward-delete-char
            bindkey '^w' backward-kill-word
            bindkey '^l' clear-screen
            bindkey '^r' history-incremental-search-backward

            # Tab completion styling
            zstyle ':completion:*' menu select
            zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

            # Two-line prompt mirroring fish_prompt:
            #   ~/path branch
            #   ✧
            autoload -Uz vcs_info
            precmd() { vcs_info }
            setopt prompt_subst
            zstyle ':vcs_info:git:*' formats ' %F{yellow}%b%f'
            PROMPT='%F{blue}%2~%f''${vcs_info_msg_0_}
            %(?,%F{white},%F{red})✧%f '
            RPROMPT='%(?,,%F{red}%?%f)'

            # Yazi cd-on-exit wrapper (mirrors fish y function)
            function y() {
              local tmp=$(mktemp)
              yazi --cwd-file="$tmp" "$@"
              local cwd=$(cat "$tmp")
              if [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
                cd "$cwd"
              fi
              rm -f "$tmp"
            }

            # Conditional tool integrations — graceful when unavailable
            command -v eza &>/dev/null && {
              alias l='eza -l'
              alias la='eza -la'
              alias lt='eza -lT --level=2'
              alias ll='eza -l --sort=modified --reverse'
            }
            command -v bat &>/dev/null && \
              export MANPAGER="sh -c 'col -bx | bat -l man -p'"
            command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
            command -v fzf &>/dev/null && \
              { source <(fzf --zsh 2>/dev/null) || true; }
            command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
          '';
        };
      };
  };
}
