{ den, ... }:
{
  den.aspects.greetd.nixos = { pkgs, ... }: {
    services.greetd.enable = true;
    programs.regreet.enable = true;
    services.seatd.enable = true;
    programs.hyprland.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
      ];
    };

    security.polkit.enable = true;

    environment.systemPackages = with pkgs; [
      hyprland
      sway
      wl-clipboard
      quickshell
    ];

    users.users.ada.extraGroups = [ "video" "input" "seat" ];
  };
}
