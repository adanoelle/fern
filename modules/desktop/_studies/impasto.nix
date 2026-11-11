# Rembrandt: lamplight out of umber. Two stories from the
# Metamorphoses, one late and nearly dark, one early and jewelled.
# Crops are in thousandths of the source (see ../wallpaper.nix).
{ fetchurl }:
let
  commons = "https://upload.wikimedia.org/wikipedia/commons";
in
{
  painter = "Rembrandt";

  paintings = [
    {
      name = "philemon-baucis";
      title = "Philemon and Baucis";
      year = "1658";
      collection = "National Gallery of Art, Washington, object 1204 (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "rembrandt-philemon-and-baucis.jpg";
        url = "${commons}/d/d6/Rembrandt_van_Rijn%2C_Philemon_and_Baucis%2C_1658%2C_NGA_1204.jpg";
        hash = "sha256-Z/Qyiuz6oGx8BETni4y3YJirbZh8J/vklqJI/aguSxU=";
      };
      # The table, the two gods and the old couple, with the hearth at left.
      ultrawide.top = 250;
      panel.top = 100;
    }
    {
      name = "europa";
      title = "The Abduction of Europa";
      year = "1632";
      collection = "J. Paul Getty Museum, Los Angeles (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "rembrandt-abduction-of-europa.jpg";
        url = "${commons}/thumb/4/4e/Rembrandt_Harmensz._van_Rijn_-_The_Abduction_of_Europa_-_Google_Art_Project.jpg/3840px-Rembrandt_Harmensz._van_Rijn_-_The_Abduction_of_Europa_-_Google_Art_Project.jpg";
        hash = "sha256-cSXMtF/Sd+HzrE1VVcrLG35MTPQtT3CvBS8j0FNGB4A=";
      };
      # The original upload is 211 MB, so this pins Commons' 3840 px
      # rendition. Europa on the bull, her companions and the carriage.
      ultrawide.top = 440;
      panel.top = 190;
    }
  ];
}
