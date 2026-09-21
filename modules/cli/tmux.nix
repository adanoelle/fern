# modules/cli/tmux.nix — tmux terminal multiplexer
#
# Keybindings designed for consistency with the Niri/Ghostty/vi-mode stack:
#   Niri:    Super + h/j/k/l          (windows/columns)
#   Ghostty: Alt + h/j/k/l            (panes)
#   tmux:    Ctrl-Space, then h/j/k/l (panes)
#   Fish:    vi-mode h/j/k/l          (cursor)
#
# Splits use v/s (vertical/horizontal) matching Ghostty's Alt+Shift+v/s.
# Window numbering starts at 1 to match Niri workspace numbering.
{ den, ... }:
{
  den.aspects.tmux = {
    homeManager =
      { ... }:
      {
        programs.tmux = {
          enable = true;
          prefix = "C-Space";
          keyMode = "vi";
          baseIndex = 1;
          escapeTime = 0;
          historyLimit = 50000;
          mouse = true;
          terminal = "tmux-256color";
          extraConfig = ''
            # Pane splits — v/s mirrors Ghostty Alt+Shift+v / Alt+Shift+s
            bind v split-window -h -c "#{pane_current_path}"
            bind s split-window -v -c "#{pane_current_path}"

            # Pane navigation — h/j/k/l
            bind h select-pane -L
            bind j select-pane -D
            bind k select-pane -U
            bind l select-pane -R

            # Pane resize — repeatable with -r
            bind -r H resize-pane -L 5
            bind -r J resize-pane -D 5
            bind -r K resize-pane -U 5
            bind -r L resize-pane -R 5

            # Window management
            bind n new-window -c "#{pane_current_path}"
            bind w confirm-before -p "close pane? (y/n)" kill-pane

            # Session chooser (s is taken by splits)
            bind S choose-session

            # Renumber windows when one is closed
            set -g renumber-windows on

            # True color
            set -sa terminal-features ',xterm-256color:RGB'
            set -sa terminal-features ',tmux-256color:RGB'

            # Pane numbering from 1
            set -g pane-base-index 1
          '';
        };
      };
  };
}
