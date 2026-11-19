# Study: Artemisia Gentileschi (palette `giuditta`, bitumen x gown gold x lapis).
{ fetchurl }:
let
  commons = "https://upload.wikimedia.org/wikipedia/commons";
in
{
  painter = "Artemisia Gentileschi";
  paintings = [
    {
      name = "la-pittura";
      title = "Self-Portrait as the Allegory of Painting (La Pittura)";
      year = "1638-39";
      collection = "Royal Collection, London (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "gentileschi-la-pittura.jpg";
        url = "${commons}/0/05/Self-portrait_as_the_Allegory_of_Painting_%28La_Pittura%29_-_Artemisia_Gentileschi.jpg";
        hash = "sha256-PSItViFOSL+usU2vFbHfpxBaGabjFYJQSjSM/i6REAI=";
      };
      # The raised arm and brush, and her face turned to the canvas.
      ultrawide.top = 90;
      panel.top = 80;
    }
    {
      name = "esther";
      title = "Esther before Ahasuerus";
      year = "c. 1628-35";
      collection = "The Metropolitan Museum of Art, New York (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "gentileschi-esther-before-ahasuerus.jpg";
        url = "${commons}/b/bf/Gentileschi%2C_Artemisia_-_Esther_before_Ahasuerus_-_c._1628%E2%80%931635.jpg";
        hash = "sha256-GiImtFLdIbGC42BCdjQ1V8JxBd25m3Kk8tnTOF8mFus=";
      };
      # From the king's plumed hat down to Esther's knees.
      ultrawide.top = 0;
      panel.top = 40;
    }
    {
      name = "judith";
      title = "Judith Beheading Holofernes (detail: Judith and Abra)";
      year = "c. 1620";
      collection = "Gallerie degli Uffizi, Florence (reproduction: Wikimedia Commons)";
      src = fetchurl {
        name = "gentileschi-judith-beheading-holofernes.jpg";
        url = "${commons}/5/50/Artemisia_Gentileschi_-_Giuditta_decapita_Oloferne_-_Google_Art_Project-Adjust.jpg";
        hash = "sha256-IpUneYA+A/HD4on8XOiU5sHzeWf1FywUO5JNOIMBySA=";
      };
      # A detail: the two women's faces and braced arms. Both crops stop
      # above the sword's work.
      ultrawide = {
        left = 250;
        top = 160;
      };
      panel = {
        left = 300;
        top = 150;
      };
    }
  ];
}
