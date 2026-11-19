# Study: Élisabeth Vigée Le Brun (palette `paille`, sky grey x dress rose x cornflower).
{ fetchurl }:
let
  commons = "https://upload.wikimedia.org/wikipedia/commons";
in
{
  painter = "Élisabeth Vigée Le Brun";
  paintings = [
    {
      name = "straw-hat";
      title = "Self-Portrait in a Straw Hat";
      year = "after 1782";
      collection = "The National Gallery, London (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "vigee-le-brun-self-portrait-in-a-straw-hat.jpg";
        url = "${commons}/3/35/Self-portrait_in_a_Straw_Hat_by_Elisabeth-Louise_Vig%C3%A9e-Lebrun.jpg";
        hash = "sha256-9rRI6MRPMumTdqhSHgwf5O7dX+sLB0sLSQhMnGF7Wgc=";
      };
      # The hat, its flowers and feather, and her face against the sky.
      ultrawide.top = 150;
      panel.top = 140;
    }
    {
      name = "with-julie";
      title = "Self-Portrait with Her Daughter Julie";
      year = "1789";
      collection = "Musée du Louvre, Paris (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "vigee-le-brun-self-portrait-with-julie.jpg";
        url = "${commons}/3/3e/Self-portrait_with_Her_Daughter_by_Elisabeth-Louise_Vig%C3%A9e_Le_Brun.jpg";
        hash = "sha256-F0tNNCZ9+ROam7Fr1mTXL89pOosFC65+3zUePcAA6n0=";
      };
      # The two faces and the child's arms around her neck.
      ultrawide.top = 180;
      panel.top = 150;
    }
    {
      name = "marie-antoinette";
      title = "Marie Antoinette with a Rose";
      year = "1783";
      collection = "Château de Versailles (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "vigee-le-brun-marie-antoinette-with-a-rose.jpg";
        url = "${commons}/5/5f/Louise_Elisabeth_Vig%C3%A9e-Lebrun_-_Marie-Antoinette_dit_%C2%AB_%C3%A0_la_Rose_%C2%BB_-_Google_Art_Project.jpg";
        hash = "sha256-XisBuHd9PTZRAw8A2pPS8v5fuLQdPmD+gglAVrSc26k=";
      };
      # From the plumes down to the rose in her hand.
      ultrawide.top = 100;
      panel.top = 80;
    }
    {
      name = "julie-mirror";
      title = "Julie Le Brun Looking in a Mirror";
      year = "1787";
      collection = "The Metropolitan Museum of Art, New York, 2019.141.23 (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "vigee-le-brun-julie-looking-in-a-mirror.jpg";
        url = "${commons}/a/ad/Elisabeth_Louise_Vig%C3%A9e_Le_Brun_-_Julie_Le_Brun_%281780%E2%80%931819%29_Looking_in_a_Mirror_-_2019.141.23_-_Metropolitan_Museum_of_Art.jpg";
        hash = "sha256-sSRPxs+tYuv5Wl2BwlKNoOvSZLOeImXo9oJ/e8q7l3Y=";
      };
      # Left and right trim the edge of the panel. The child and her
      # reflection, which looks out at us and not at her.
      ultrawide = {
        left = 20;
        right = 980;
        top = 225;
      };
      panel = {
        left = 20;
        right = 980;
        top = 140;
      };
    }
  ];
}
