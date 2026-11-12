# Study: John Singer Sargent (palette `shitanuri`, raw umber x terre verte).
{ fetchurl }:
let
  nga = "https://api.nga.gov/iiif/718e014f-fb5f-4702-a95a-db496abefeb7";
  commons = "https://upload.wikimedia.org/wikipedia/commons";
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
    {
      name = "el-jaleo";
      title = "El Jaleo";
      year = "1882";
      collection = "Isabella Stewart Gardner Museum, Boston (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "sargent-el-jaleo.jpg";
        url = "${commons}/9/92/EL_JALEO-SINGER.jpg";
        hash = "sha256-EAZ0lJ6PeBnPx/8XwNzXcd/sR15rE21gQ896Kc7OYq4=";
      };
      # From the guitars on the wall down to the dancer's skirt.
      ultrawide.top = 200;
      panel.top = 40;
    }
    {
      name = "dinner-table";
      palette = "lampshade";
      title = "A Dinner Table at Night";
      year = "1884";
      collection = "Fine Arts Museums of San Francisco (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "sargent-dinner-table-at-night.jpg";
        url = "${commons}/d/d9/John_Singer_Sargent_-_Le_verre_de_porto_%28A_Dinner_Table_at_Night%29_-_Google_Art_Project.jpg";
        hash = "sha256-J0qwoPIXrG/8VJg+Vwn8WGvrAGb0azbhS9mSqS8DaHg=";
      };
      # The three red lamps, her face, and the near edge of the table.
      ultrawide.top = 250;
      panel.top = 100;
    }
    {
      name = "carnation-lily";
      palette = "lantern";
      title = "Carnation, Lily, Lily, Rose";
      year = "1885-86";
      collection = "Tate Britain, London (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "sargent-carnation-lily-lily-rose.jpg";
        url = "${commons}/e/ed/John_Singer_Sargent_-_Carnation%2C_Lily%2C_Lily%2C_Rose_-_Google_Art_Project.jpg";
        hash = "sha256-oflaPrZGGRCrJnPdR6Xok2z0cCyNYQkxxnWn0SukxTY=";
      };
      # A tall canvas: the band is the two girls' heads and the lit
      # lanterns.
      ultrawide.top = 200;
      panel.top = 160;
    }
  ];
}
