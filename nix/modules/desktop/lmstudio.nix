# nix/modules/desktop/lmstudio.nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lmstudio
  ];
  
  # Enable OpenGL for GPU acceleration
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  
  # Open ports for LM Studio's local server
  networking.firewall = {
    allowedTCPPorts = [ 1234 ];
  };
}
