{ ... }:

let
  # Mount options for Btrfs on SSD
  commonMountOptions = [
    "commit=60"
    "compress=lzo"
    "defaults"
    "noatime"
  ];
in

{
  fileSystems = {
    "/".options = commonMountOptions;
    "/nix".options = commonMountOptions;
    "/var".options = commonMountOptions;
    "/home".options = commonMountOptions;
  };
}
