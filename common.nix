{ pkgs, ... }:

{
  fileSystems = let
    # Mount options for Btrfs on SSD
    commonMountOptions = [
      "commit=60"
      "compress=lzo"
      "defaults"
      "noatime"
    ];
  in {
    "/".options = commonMountOptions;
    "/nix".options = commonMountOptions;
    "/var".options = commonMountOptions;
    "/home".options = commonMountOptions;
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;
    tmpOnTmpfs = true;
  };

  hardware = {
    # cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;
    pulseaudio.enable = true;
  };

  networking = {
    networkmanager.enable = true;
  };

  nix = {
    trustedUsers = [ "@wheel" ];
    # useSandbox = true;
    nixPath = [
      "$HOME/.nix-defexpr/channels"
      "nixpkgs=/var/repos/nixpkgs"
      # "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=/etc/nixos/configuration.nix"
      "/nix/var/nix/profiles/per-user/root/channels"
    ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      pulseaudio = true;
    };
  };

  users.users.mnacamura = {
    isNormalUser = true;
    uid = 1000;
    description = "Mitsuhiro Nakamura";
    extraGroups = [ "users" "wheel" "networkmanager" ];
    createHome = true;
    shell = "/run/current-system/sw/bin/fish";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?
}
