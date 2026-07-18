{ den, ... }:
{
  den.aspects.node-ts = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          nodejs_24
          pnpm
          yarn
          deno
          # aws-cdk was removed from nixpkgs with the nodePackages set;
          # install via `npm install -g aws-cdk` if needed.
          jq
          parallel
        ];

        programs.nix-ld.enable = true;
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          eslint_d
          prettier
          typescript
          typescript-language-server
          tailwindcss
          deno
          coc-jest
          playwright-test
        ];

        programs.helix = {
          enable = true;
          languages = {
            language-server.tsls = {
              command = "typescript-language-server";
              args = [ "--stdio" ];
            };
            language = [
              {
                name = "typescript";
                language-servers = [ "tsls" ];
                formatter = {
                  command = "prettier";
                  args = [
                    "--stdin-filepath"
                    "file.ts"
                  ];
                };
              }
              {
                name = "javascript";
                language-servers = [ "tsls" ];
                formatter = {
                  command = "prettier";
                  args = [
                    "--stdin-filepath"
                    "file.js"
                  ];
                };
              }
            ];
          };
        };

        programs.direnv.enable = true;
        programs.direnv.nix-direnv.enable = true;
      };
  };
}
