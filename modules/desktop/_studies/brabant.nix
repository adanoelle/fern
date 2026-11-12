# Bruegel: the one green daylight study. Ovid's Icarus as a pair of
# legs in the corner of a working landscape. Crops are in thousandths
# of the source (see ../wallpaper.nix).
{ fetchurl }:
let
  commons = "https://upload.wikimedia.org/wikipedia/commons";
in
{
  painter = "Pieter Bruegel the Elder";

  paintings = [
    {
      name = "icarus";
      title = "Landscape with the Fall of Icarus";
      year = "c. 1560";
      collection = "Royal Museums of Fine Arts of Belgium, Brussels; long attributed to Bruegel, perhaps an early copy (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "bruegel-fall-of-icarus.jpg";
        url = "${commons}/4/48/Landschaft_mit_Sturz_des_Ikarus_Pieter_Breughel_d_%C3%84.jpg";
        hash = "sha256-RHb1jgbYbfeBVKGEnMbf2O5E+T9gozeqNYvR/PZaCgI=";
      };
      # Sun on the horizon down to the ploughman; Icarus's legs stay in at
      # lower right.
      ultrawide.top = 200;
      panel.top = 20;
    }
  ];
}
