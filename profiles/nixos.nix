{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../modules/environment/hidpi.nix
    # ../modules/programs/dunst.nix
    ../modules/programs/feh.nix
    # ../modules/programs/polybar.nix
    # ../modules/programs/rofi.nix
    ../modules/programs/services/light-locker.nix
    ../users/mnacamura.nix
  ];

  boot = {
    extraModprobeConfig = ''
      # https://github.com/NixOS/nixpkgs/issues/57053
      options cfg80211 ieee80211_regdom="JP"
    '';
    loader.systemd-boot = {
      enable = true;
      consoleMode = "auto";
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    swraid.enable = false;
    tmp.useTmpfs = true;
  };

  nix.settings.trusted-users = [ "@wheel" ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
