# Titian: Ovid in Venetian colour. Three of his mythologies, two of
# them from the "poesie" he painted for Philip II out of the
# Metamorphoses. Crops are in thousandths of the source (see
# ../wallpaper.nix).
{ fetchurl }:
let
  commons = "https://upload.wikimedia.org/wikipedia/commons";
in
{
  painter = "Titian";

  paintings = [
    {
      name = "bacchus-ariadne";
      title = "Bacchus and Ariadne";
      year = "1520-23";
      collection = "National Gallery, London (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "titian-bacchus-and-ariadne.jpg";
        url = "${commons}/b/be/Titian_Bacchus_and_Ariadne.jpg";
        hash = "sha256-nsiV4gEBh5SLiqammbwfOydRm3/E6cmHYr78zqBU+7Y=";
      };
      # Ariadne, the leaping Bacchus and his train; sky and feet trimmed.
      ultrawide.top = 250;
      panel.top = 250;
    }
    {
      name = "europa";
      title = "The Rape of Europa";
      year = "1559-62";
      collection = "Isabella Stewart Gardner Museum, Boston (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "titian-rape-of-europa.jpg";
        url = "${commons}/3/38/Titian_-_Rape_of_Europa_-_Google_Art_Project.jpg";
        hash = "sha256-Hc3HcYT7hMjQJeDgrsniuww1ScvW5/XbOK28LFgC1+0=";
      };
      # Europa and the bull against the far shore; the cupids overhead are
      # trimmed from the ultrawide.
      ultrawide.top = 330;
      panel.top = 200;
    }
    {
      name = "actaeon";
      title = "The Death of Actaeon";
      year = "c. 1559-75";
      collection = "National Gallery, London (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "titian-death-of-actaeon.jpg";
        url = "${commons}/4/4d/Actaeon.jpg";
        hash = "sha256-8MiH5A32WifrPT9K2MYo6fOZIFZ1hpcg0KtXqyRCOhI=";
      };
      # Diana drawing her bow, Actaeon falling among the hounds.
      ultrawide.top = 240;
      panel.top = 150;
    }
  ];
}
