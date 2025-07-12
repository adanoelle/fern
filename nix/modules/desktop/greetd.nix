# nix/modules/desktop/greetd.nix  -- using regreet
{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    cage
    greetd.regreet                # the greeter
    hyprland
    wl-clipboard
  ];

  # --- seatd (DRM / input)
  services.seatd.enable = true;
  programs.regreet.enable = true;   # pulls regreet + cage

  services.greetd = {
    enable = true;

    settings = {
      # regreet binary becomes the greeter
      default_session = {
        command = "${pkgs.cage}/bin/cage -s ${pkgs.greetd.regreet}/bin/regreet";
        user    = "greeter";    # regreet runs as its own user
      };

      sessions = [
        # ——— Main Caelestia desktop ——————————
        {
          name    = "Caelestia";
          command = "Hyprland --config $HOME/.config/hypr/caelestia.conf";
          user    = "ada";
        }

        # ——— Plain Hyprland fallback ——————————
        {
          name    = "Hyprland";
          command = "Hyprland";
          user    = "ada";
        }

        # ——— Second fallback: sway ————————————
        {
          name    = "Sway";
          command = "${pkgs.sway}/bin/sway";
          user    = "ada";
        }
      ];
    };
  };

  users.users.ada = {
    isNormalUser = true;
    extraGroups  = [ "video" "input" "seat" ];  # access seatd, GPU
  };
}

