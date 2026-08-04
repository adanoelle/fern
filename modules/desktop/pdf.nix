# modules/desktop/pdf.nix — PDF viewer, manipulation & signing tools
_: {
  den.aspects.pdf.homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        zathura # keyboard-driven viewer
        qpdf # split, merge, rotate, encrypt
        poppler-utils # pdftotext, pdfinfo, pdfunite, pdfimages
        ocrmypdf # OCR scanned PDFs (tesseract backend)
        libreoffice-fresh # edit, fill forms, digital signatures (PAdES)
      ];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "application/pdf" = [ "org.pwmt.zathura.desktop" ];
        };
      };
    };
}
