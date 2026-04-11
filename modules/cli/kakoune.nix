# modules/cli/kakoune.nix — Kakoune editor (garden stack)
{ den, inputs, ... }:
{
  den.aspects.kakoune.homeManager =
    { config, pkgs, ... }:
    let
      themesDir = "${config.xdg.configHome}/garden/themes";
    in
    {
      home.packages = with pkgs; [
        kakoune
        kakoune-lsp
      ];

      # Kakoune config — garden colors sourced from mutable themes dir
      xdg.configFile."kak/kakrc".text = ''
        try %{ source ${themesDir}/kak/garden.kak }

        # Line numbers
        add-highlighter global/ number-lines -relative -hlcursor

        # Soft wrap
        add-highlighter global/ wrap -word -indent

        # Clipboard integration (wl-clipboard for Wayland)
        hook global NormalKey y|d|c %{
          nop %sh{ printf '%s' "$kak_main_reg_dquote" | wl-copy 2>/dev/null }
        }
        map global user p '!wl-paste -n<ret>' -docstring 'paste from clipboard'
        map global user P '<a-!>wl-paste -n<ret>' -docstring 'paste before from clipboard'

        # LSP
        eval %sh{kak-lsp --kakoune -s $kak_session}
        hook global WinSetOption filetype=(nix|rust|python|typescript|javascript) %{
          lsp-enable-window
        }

        # User preferences
        set-option global tabstop 2
        set-option global indentwidth 2
        set-option global scrolloff 5,3
      '';

      # kak-lsp configuration
      xdg.configFile."kak-lsp/kak-lsp.toml".text = ''
        [server]
        timeout = 1800

        [language_server.nil]
        filetypes = ["nix"]
        roots = ["flake.nix", "flake.lock"]
        command = "nil"

        [language_server.rust-analyzer]
        filetypes = ["rust"]
        roots = ["Cargo.toml"]
        command = "rust-analyzer"

        [language_server.pyright]
        filetypes = ["python"]
        roots = ["pyproject.toml", "setup.py", "requirements.txt"]
        command = "pyright-langserver"
        args = ["--stdio"]

        [language_server.typescript-language-server]
        filetypes = ["typescript", "javascript"]
        roots = ["package.json", "tsconfig.json"]
        command = "typescript-language-server"
        args = ["--stdio"]
      '';
    };
}
