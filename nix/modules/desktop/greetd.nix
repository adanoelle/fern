# nix/modules/desktop/greetd.nix
{ pkgs, lib, ... }:

{
  # --- Display/login
  services.greetd.enable = true;
  programs.regreet.enable = true;

  # Optional: boot straight into Hyprland instead of selecting a session each time
  # services.greetd.settings.default_session.command = "Hyprland";

  # --- Seat management
  services.seatd.enable = true;

  # --- Hyprland compositor (system side)
  programs.hyprland.enable = true;

  # --- XDG portals (file pickers, screenshare, “Open With…”, etc.)
  xdg.portal = {
    enable = true;

    # Hyprland’s own portal is preferred; gtk portal fills in misc. dialogs.
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # Polkit (for auth prompts used by many desktop apps)
  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    hyprland
    sway                      # handy fallback compositor/tools
    wl-clipboard
    quickshell
  ];

  # Your user needs input/video/seat access
  users.users.ada.extraGroups = [ "video" "input" "seat" ];
}

