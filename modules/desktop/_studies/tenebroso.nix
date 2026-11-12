# Study: Caravaggio (palette `tenebroso`, bone black x ochre x crimson).
{ fetchurl }:
let
  commons = "https://upload.wikimedia.org/wikipedia/commons";
  bacchus = fetchurl {
    name = "caravaggio-bacchus.jpg";
    url = "${commons}/4/4f/Bacchus-Caravaggio_%281598%29.jpg";
    hash = "sha256-fujLY5LHHzX5nFcnRdzwP4I8X8UKIoAtnw0evuFAi2s=";
  };
in
{
  painter = "Caravaggio";
  paintings = [
    {
      name = "denial";
      title = "The Denial of Saint Peter";
      year = "1610";
      collection = "The Metropolitan Museum of Art, object 437986";
      src = fetchurl {
        name = "caravaggio-denial-of-saint-peter.jpg";
        url = "https://images.metmuseum.org/CRDImages/ep/original/DP-12413-001.jpg";
        hash = "sha256-VmYWhyymiqkwGpH06OvXYxQzzEI1j5Y+MjDL5t2RPeo=";
      };
      # The three heads and the pointing hands.
      ultrawide.top = 100;
    }
    {
      name = "musicians";
      palette = "chiaro";
      title = "The Musicians";
      year = "1597";
      collection = "The Metropolitan Museum of Art, object 435844";
      src = fetchurl {
        name = "caravaggio-musicians.jpg";
        url = "https://images.metmuseum.org/CRDImages/ep/original/DP-687-001.jpg";
        hash = "sha256-gtV8biaDQVTdLHZxfzAN+rEqd9qNjU2Re3NnQQjdNoM=";
      };
      # left/right trim the sliver of frame in the photograph. The band
      # holds all four faces, the red drape and the lute's neck.
      ultrawide = {
        left = 12;
        right = 988;
        top = 35;
      };
      panel = {
        left = 12;
        right = 988;
        top = 30;
      };
    }
    {
      name = "bacchus";
      palette = "chiaro";
      title = "Bacchus";
      year = "c. 1596";
      collection = "Gallerie degli Uffizi, Florence (reproduction: Wikimedia Commons)";
      src = bacchus;
      # A nearly square canvas: the band is his face and shoulder, down
      # to the rim of the offered glass.
      ultrawide.top = 170;
      panel.top = 70;
    }
    {
      name = "bacchus-fruit";
      palette = "chiaro";
      title = "Bacchus (detail: hands, glass and fruit)";
      year = "c. 1596";
      collection = "Gallerie degli Uffizi, Florence (reproduction: Wikimedia Commons)";
      src = bacchus;
      ultrawide.top = 555;
      panel.top = 380;
    }
    {
      name = "judith";
      title = "Judith Beheading Holofernes (detail: Judith and Abra)";
      year = "c. 1599";
      collection = "Palazzo Barberini, Rome (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "caravaggio-judith.jpg";
        url = "${commons}/9/9d/Judith_Beheading_Holofernes-Caravaggio_%28c.1598-9%29.jpg";
        hash = "sha256-w7V49ugzaIvFtrfkrGM+3jY+nHVa1J2Spftu6mZWt/s=";
      };
      # Both crops stay on the right and upper part of the canvas: the
      # curtain, Judith and Abra, with Holofernes out of frame.
      ultrawide = {
        left = 310;
        top = 0;
      };
      panel = {
        left = 560;
        top = 90;
      };
    }
  ];
}
