# Study: James McNeill Whistler (palette `nocturne`, thames grey x moon gold).
{ fetchurl }:
{
  painter = "James McNeill Whistler";
  paintings = [
    {
      name = "southampton-water";
      title = "Nocturne: Blue and Gold — Southampton Water";
      year = "1872";
      collection = "Art Institute of Chicago, artwork 56905";
      # 3000 px is the largest size the Art Institute's IIIF serves.
      src = fetchurl {
        name = "whistler-nocturne-southampton-water.jpg";
        url = "https://www.artic.edu/iiif/2/50034c7f-ce51-00f1-430e-a6f7efc233fc/full/3000,/0/default.jpg";
        hash = "sha256-aoIr5lgw917p32b1kMv3MY0vFCJ7uZVsBZ3hGKx0+M4=";
      };
      # The moon in the upper third, the boats below it.
      ultrawide.top = 80;
    }
  ];
}
