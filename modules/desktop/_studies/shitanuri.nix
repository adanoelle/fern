# Study: John Singer Sargent (palette `shitanuri`, raw umber x terre verte).
{ fetchurl }:
let
  nga = "https://api.nga.gov/iiif/718e014f-fb5f-4702-a95a-db496abefeb7";
in
{
  painter = "John Singer Sargent";
  paintings = [
    {
      name = "nonchaloir";
      title = "Nonchaloir (Repose)";
      year = "1911";
      collection = "National Gallery of Art, Washington, object 35080";
      # Ready-cropped by the NGA's IIIF server (master is 18332x15338).
      # Ultrawide: a 2.4:1 band from ~18% to ~68% of the canvas height.
      # It keeps her head clear of the bar plus the clasped hands, shawl
      # and gilt table.
      ready = {
        ultrawide = fetchurl {
          name = "sargent-nonchaloir-ultrawide.jpg";
          url = "${nga}/0,2760,18332,7673/3440,1440/0/default.jpg";
          hash = "sha256-KkYKXQip0BPY4Lej3MS6u1jNZbnihJRNCbd6d6B1iyQ=";
        };
        panel = fetchurl {
          name = "sargent-nonchaloir-panel.jpg";
          url = "${nga}/full/2400,/0/default.jpg";
          hash = "sha256-Ib87L3l9H1H/dttAcSuk7MCFlOpc7+d5XYnWu2B0HeU=";
        };
      };
    }
  ];
}
