{ pkgs, ... }: {
  programs.pandoc = {
    enable = true;
    package = pkgs.pandoc;

    defaults = {
      # Input/Output
      # from = "markdown+smart+footnotes";
      # standalone = true;

      # # PDF settings
      # pdf-engine = "xelatex";

      # # Table of Contents
      # toc = true;
      # toc-depth = 3;
      # number-sections = true;

      # # Typography with Catppuccin theme
      # highlight-style = "tango";
      # tab-stop = 2;

      # Metadata
      metadata = {
        lang = "en-US";
      };
    };
  };

  # Include LaTeX for PDF generation
  home.packages = with pkgs; [
    texlive.combined.scheme-medium
  ];
}
