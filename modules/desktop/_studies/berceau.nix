# Study: Berthe Morisot (palette `berceau`, muslin white x jacket blue x rose).
{ fetchurl }:
let
  commons = "https://upload.wikimedia.org/wikipedia/commons";
in
{
  painter = "Berthe Morisot";
  paintings = [
    {
      name = "summers-day";
      title = "Summer's Day";
      year = "c. 1879";
      collection = "The National Gallery, London (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "morisot-summers-day.jpg";
        url = "${commons}/1/12/Berthe_Morisot_-_Jour_d%27%C3%A9t%C3%A9%2C_1879.jpg";
        hash = "sha256-+/xdbJ15xDLfPSjrl+Xx8U70mlNfX2Esr/pWzl1UcDQ=";
      };
      # Both women, hats to hands. The canvas is wider than the panel,
      # so the panel takes the whole painting.
      ultrawide.top = 40;
    }
    {
      name = "cradle";
      title = "The Cradle";
      year = "1872";
      collection = "Musée d'Orsay, Paris (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "morisot-the-cradle.jpg";
        url = "${commons}/c/ca/Berthe_Morisot_-_The_Cradle_-_Google_Art_Project.jpg";
        hash = "sha256-sfs7bHYI5u/yxz6MniZU4+EW9BJmy+qwweKstNDWuyQ=";
      };
      # The band is the mother and the veil; the panel reaches down to
      # the sleeping child.
      ultrawide.top = 270;
      panel.top = 280;
    }
    {
      name = "toilette";
      title = "Woman at Her Toilette";
      year = "1875-80";
      collection = "Art Institute of Chicago, artwork 11723";
      # 3000 px is the largest size the Art Institute's IIIF serves.
      src = fetchurl {
        name = "morisot-woman-at-her-toilette.jpg";
        url = "https://www.artic.edu/iiif/2/78c80988-6524-cec7-c661-a4c0a706d06f/full/3000,/0/default.jpg";
        hash = "sha256-9Cy45BoUsP6zk+0s1KM26CuiDGSdMlQ++jLUHBo7Mso=";
      };
      # Her head and bare shoulder against the mirror.
      ultrawide.top = 80;
      panel.top = 60;
    }
  ];
}
