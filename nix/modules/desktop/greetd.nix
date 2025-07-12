# nix/modules/desktop/greetd.nix
{ config, pkgs, ... }:

let
  greeter = pkgs.greetd.tuigreet;            # pick pkgs.gtkgreet for a GUI greeter
in
{
  ##################  core packages  ##################
  environment.systemPackages = [
    greeter
    pkgs.hyprland
    pkgs.wl-clipboard
  ];

  ##################  seatd (DRM / input) #############
  services.seatd.enable = true;

  ##################  greetd service ##################
  services.greetd = {
    enable = true;

    # ‘greeter’ user is auto‑created; no need to define it.
    settings = {
      # login prompt appears on tty1 by default
      default_session = {
        command = "${greeter}/bin/tuigreet \\
                     --time            \\
                     --cmd Hyprland    \\
                     --remember \\
                     --remember-user-session";
        user = "greeter";
      };

      # (optional) offer additional sessions in the chooser
      sessions = [
        { name = "Hyprland"; command = "Hyprland";              user = "ada"; }
        { name = "sway";     command = "${pkgs.sway}/bin/sway"; user = "ada"; }
      ];
    };
  };

  ##################  user account ####################
  users.users.ada = {
    isNormalUser = true;
    extraGroups  = [ "video" "input" "seat" ];   # seat = talk to seatd
  };
}
