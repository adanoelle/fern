# nix/modules/desktop/greetd.nix
{ pkgs, ... }:

{
  # --- Greetd + ReGreet setup (uses Cage automatically)
  services.greetd.enable = true;
  programs.regreet.enable = true;

  # --- Optional ReGreet theming (no theme for now, placeholder included)
  programs.regreet.settings = {
    GTK = {
      application_prefer_dark_theme = true;
    };
  };

  # --- Seat management
  services.seatd.enable = true;

  environment.systemPackages = with pkgs; [
    hyprland
    sway
    wl-clipboard
    quickshell
  ];

  # --- Seat group access for your user
  users.users.ada.extraGroups = [ "video" "input" "seat" ];
}
