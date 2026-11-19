# Study: Hilma af Klint (palette `tempel`, lilac ground x yolk yellow x vermilion).
#
# From The Paintings for the Temple. The originals are with the Hilma af
# Klint Foundation, Stockholm.
{ fetchurl }:
let
  commons = "https://upload.wikimedia.org/wikipedia/commons";
  foundation = "Hilma af Klint Foundation, Stockholm (reproduction: Wikimedia Commons)";
in
{
  painter = "Hilma af Klint";
  paintings = [
    {
      name = "adulthood";
      title = "The Ten Largest, No. 7, Adulthood";
      year = "1907";
      collection = foundation;
      src = fetchurl {
        name = "af-klint-ten-largest-7-adulthood.jpg";
        url = "${commons}/1/19/Hilma_af_Klint_%E2%80%94_The_Ten_Largest_%E2%80%94_Number_7_Adulthood.jpg";
        hash = "sha256-25CCSKg7iT8kzLk1WSbVlfpOjJhQIg/W5qfY2lWm6eE=";
      };
      # The two yellow lobes marked I and II, where they meet.
      ultrawide.top = 160;
      panel.top = 120;
    }
    {
      name = "youth";
      title = "The Ten Largest, No. 3, Youth";
      year = "1907";
      collection = foundation;
      src = fetchurl {
        name = "af-klint-ten-largest-3-youth.jpg";
        url = "${commons}/f/fd/Hilma_af_Klint_%E2%80%94_The_Ten_Largest_%E2%80%94_Number_3_Youth.jpg";
        hash = "sha256-letV8SL0puinFpUgTkjBpIUaYKg964qyR3yDCdhw/Hc=";
      };
      # The large wheel and the spirals either side of it.
      ultrawide.top = 110;
      panel.top = 60;
    }
    {
      name = "swan-17";
      title = "The Swan, No. 17";
      year = "1915";
      collection = foundation;
      src = fetchurl {
        name = "af-klint-swan-17.jpg";
        url = "${commons}/0/00/Hilma_af_Klint%2C_1915%2C_Svanen%2C_No._17.jpg";
        hash = "sha256-Fh40gmDr5DC1Km21KR93QcQjEh5BocVDX0HHQcJHN0w=";
      };
      # A square canvas: the band is centred on the disc and trims its
      # top and bottom; the panel crop holds all of it.
      ultrawide.top = 314;
      panel.top = 210;
    }
    {
      name = "altarpiece-1";
      title = "Altarpiece, No. 1, Group X";
      year = "1915";
      collection = foundation;
      src = fetchurl {
        name = "af-klint-altarpiece-1.jpg";
        url = "${commons}/3/33/Hilma_af_Klint_-_Altarpiece_No._1_Group_X_%2813919%29.jpg";
        hash = "sha256-KzgWUZbywiTmu73aMAVjMzxzgadywNJlvte3/KnJSRo=";
      };
      # The gold sun and its rays; the panel adds the top of the pyramid.
      ultrawide.top = 40;
      panel.top = 40;
    }
  ];
}
