# modules/cli/kakoune.nix — Kakoune editor (garden stack)
{ den, ... }:
{
  den.aspects.kakoune.homeManager = { pkgs, ... }:
    let
      # Mokume palette (hardcoded — will be generated from palettes.json later)
      gardenKakTheme = ''
        # garden.kak — mokume palette

        # UI
        face global Default            rgb:8b9bb0,rgb:2c3444
        face global StatusLine         rgb:6b7a8d,rgb:252d3b
        face global StatusLineMode     rgb:d4c5a9,rgb:252d3b
        face global StatusLineInfo     rgb:505e70,rgb:252d3b
        face global StatusLineValue    rgb:c9b88c,rgb:252d3b
        face global StatusCursor       rgb:252d3b,rgb:d4c5a9
        face global Prompt             rgb:c9b88c,rgb:252d3b
        face global MenuForeground     rgb:d4c5a9,rgb:3d4759
        face global MenuBackground     rgb:8b9bb0,rgb:343d4f
        face global Information        rgb:8b9bb0,rgb:343d4f
        face global Error              rgb:c4796b,rgb:2c3444

        # Selections
        face global PrimarySelection   default,rgb:3d4759+g
        face global SecondarySelection default,rgb:343d4f+g
        face global PrimaryCursor      rgb:252d3b,rgb:d4c5a9
        face global SecondaryCursor    rgb:252d3b,rgb:8b9bb0

        # Line numbers
        face global LineNumbers        rgb:505e70
        face global LineNumberCursor   rgb:6b7a8d
        face global LineNumbersWrapped rgb:3a4456

        # Matching & whitespace
        face global MatchingChar       rgb:c9b88c+b
        face global Whitespace         rgb:3a4456
        face global BufferPadding      rgb:3a4456

        # Syntax — structure quiet, content prominent
        face global value              rgb:c9b88c
        face global type               rgb:8b9bb0
        face global variable           rgb:d4c5a9
        face global module             rgb:8b9bb0
        face global function           rgb:d4c5a9
        face global string             rgb:7c9a7c
        face global keyword            rgb:6b7a8d
        face global operator           rgb:6b7a8d
        face global attribute          rgb:c9b88c
        face global comment            rgb:505e70+i
        face global documentation      rgb:6b7a8d
        face global meta               rgb:c9b88c
        face global builtin            rgb:8b9bb0+b
      '';
    in
    {
      home.packages = with pkgs; [
        kakoune
        kakoune-lsp
      ];

      # Garden colorscheme
      xdg.configFile."kak/colors/garden.kak".text = gardenKakTheme;

      # Kakoune config
      xdg.configFile."kak/kakrc".text = ''
        # Load garden colorscheme (generated override takes priority)
        evaluate-commands %sh{
          f="/tmp/garden-themes/kak/colors/garden.kak"
          if [ -f "$f" ]; then
            printf 'source "%s"\n' "$f"
          else
            printf 'colorscheme garden\n'
          fi
        }

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
