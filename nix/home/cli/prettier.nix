{ config, pkgs, ... }:

let
  prettierConfig = ''
    {
      "printWidth": 80,
      "proseWrap": "always",
      "tabWidth": 2,
      "trailingComma": "none",
      "semi": false,
      "singleQuote": true
    }
  '';
in {
  home.packages = with pkgs; [
    prettier
  ];

  home.file.".prettierrc".text = prettierConfig;

  programs.nushell.shellAliases = {
    mdfmt = "prettier --write ";
  };
}
