{ pkgs, ... }:

{
  #  Packages for day‑to‑day coding                                   
  home.packages = with pkgs; [
    # Lint / format
    eslint_d              # 50× faster daemon
    prettier
    nodePackages.prettier

    # Language server & tools
    nodePackages.typescript            # tsc
    nodePackages.typescript-language-server
    tailwindcss
    deno

    # Testing / E2E
    nodePackages.coc-jest
    playwright-test      # Playwright CLI (& browsers fetched on first run)
  ];

  # --- Helix editor integration (new HM syntax)                          
  programs.helix = {
    enable = true;

    languages = {
      language-server.tsls = {          # TypeScript‑Language‑Server
        command = "typescript-language-server";
        args    = [ "--stdio" ];
      };

      language = [
        {
          name             = "typescript";
          language-servers = [ "tsls" ];
          formatter        = { command = "prettier"; args = [ "--stdin-filepath" "file.ts" ]; };
        }
        {
          name = "javascript";
          language-servers = [ "tsls" ];
          formatter        = { command = "prettier"; args = [ "--stdin-filepath" "file.js" ]; };
        }
      ];
    };
  };

  # --- Direnv + pnpm / Deno automatic
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
}

