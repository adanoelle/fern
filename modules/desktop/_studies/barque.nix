# Study: Mary Cassatt (palette `barque`, prussian water x boat chartreuse x rose).
{ fetchurl }:
let
  commons = "https://upload.wikimedia.org/wikipedia/commons";
in
{
  painter = "Mary Cassatt";
  paintings = [
    {
      name = "boating-party";
      title = "The Boating Party";
      year = "1893-94";
      collection = "National Gallery of Art, Washington (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "cassatt-the-boating-party.jpg";
        url = "${commons}/d/d8/Mary_Cassatt_-_The_Boating_Party_-_Google_Art_Project.jpg";
        hash = "sha256-cpmuXW7hd0r9YKFA6KRHFqe0lAQfHjX7jLNKAk33NZM=";
      };
      # From the far shore down to the oarsman's hands on the oar.
      ultrawide.top = 0;
      panel.top = 20;
    }
    {
      name = "childs-bath";
      title = "The Child's Bath";
      year = "1893";
      collection = "Art Institute of Chicago, artwork 111442";
      # 3000 px tall is the largest size the Art Institute's IIIF serves.
      src = fetchurl {
        name = "cassatt-the-childs-bath.jpg";
        url = "https://www.artic.edu/iiif/2/3b885ae0-4d46-5fe4-d70a-00474827f02c/full/3000,/0/default.jpg";
        hash = "sha256-dFHBP2y0fwdWRdi+z07Vlz9lgTMy1po22fRRIhzHHBc=";
      };
      # A tall canvas: the band is the two heads bent together.
      ultrawide.top = 70;
      panel.top = 80;
    }
    {
      name = "blue-armchair";
      title = "Little Girl in a Blue Armchair";
      year = "1878";
      collection = "National Gallery of Art, Washington, 1983.1.18 (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "cassatt-little-girl-in-a-blue-armchair.jpg";
        url = "${commons}/c/cb/Mary_Cassatt_-_Little_Girl_in_a_Blue_Armchair_-_NGA_1983.1.18.jpg";
        hash = "sha256-UekGRTLFD5XkS5y7QWvnUjfdceZWUhIiGCDFRhJXl7c=";
      };
      # The girl sprawled in her chair and the dog asleep in the next.
      ultrawide.top = 90;
      panel.top = 40;
    }
    {
      name = "in-the-loge";
      title = "In the Loge";
      year = "1878";
      collection = "Museum of Fine Arts, Boston (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "cassatt-in-the-loge.jpg";
        url = "${commons}/8/87/Mary_Stevenson_Cassatt_-_In_the_Loge_-_Google_Art_Project.jpg";
        hash = "sha256-wfkdszJDpt3ASayiHvWsdT7wzvNAdrTzuI9KUqFLIC4=";
      };
      # Her opera glasses, and the man across the house watching her.
      ultrawide.top = 110;
      panel.top = 100;
    }
  ];
}
