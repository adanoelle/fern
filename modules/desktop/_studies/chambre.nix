# Study: Suzanne Valadon (palette `chambre`, bedspread blue x peach x stripe green).
{ fetchurl }:
let
  commons = "https://upload.wikimedia.org/wikipedia/commons";
in
{
  painter = "Suzanne Valadon";
  paintings = [
    {
      name = "chambre-bleue";
      title = "The Blue Room (La Chambre bleue)";
      year = "1923";
      collection = "Centre Pompidou, Paris (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "valadon-la-chambre-bleue.jpg";
        url = "${commons}/3/34/Suzanne_Valadon_-_La_chambre_bleue.jpg";
        hash = "sha256-V/sWL04r2mffykuGCq5dFB7HjLV3qgn6EJYc03KeBTM=";
      };
      # The whole figure, cigarette to bare feet, and her books.
      ultrawide.top = 170;
      panel.top = 80;
    }
    {
      name = "famille";
      title = "Family Portrait (Portrait de famille)";
      year = "1912";
      collection = "Musée d'Orsay, Paris (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "valadon-portrait-de-famille.jpg";
        url = "${commons}/d/d1/Portrait_de_famille%2C_1912_-_Suzanne_Valadon.jpg";
        hash = "sha256-OA7elARJT8rMUf58g86aQJ0CfaccmU4JBUGz813RZQA=";
      };
      # A photograph of the framed canvas: left and right trim the frame.
      # Utter, Valadon herself, and her mother; her son is below the crop.
      ultrawide = {
        left = 150;
        right = 845;
        top = 170;
      };
      panel = {
        left = 150;
        right = 845;
        top = 140;
      };
    }
  ];
}
