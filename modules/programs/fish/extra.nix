{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.fish;

  inherit (config.nixpkgs) hostPlatform;

  setUmask = ''
    if [ (id -u) -ge 501 ]  # normal user
        [ (id -un) = (id -gn) ]
        and umask 0007
        or  umask 0077
    else
        umask 0022
    end
  '';

  # https://github.com/LnL7/nix-darwin/issues/122#issuecomment-1659465635
  setPaths =
    let
      paths = lib.concatMapStringsSep " " (
        p: "\"${p}/bin\""
      ) config.environment.profiles;
    in
    ''
      fish_add_path --move --prepend --path ${paths}
      set fish_user_paths $fish_user_paths
    '';

  basicAbbrs = ''
    abbr --add l   -- ls
    abbr --add la  -- ls -a
    abbr --add ll  -- ls -l
    abbr --add lla -- ls -la
    abbr --add h   -- history
    abbr --add d   -- dirh
    abbr --add nd  -- nextd
    abbr --add pd  -- prevd
  '';

  customLs = ''
    function ls
        command ls -Fh --color --time-style=long-iso $argv
    end
  '';
in

{
  config = lib.mkIf cfg.enable {
    environment.shells = lib.mkMerge [
      (lib.mkIf hostPlatform.isDarwin [
        "/run/current-system/sw/bin/fish"
        (lib.getExe cfg.package)
      ])
    ];
    programs.fish.loginShellInit = lib.mkMerge [
      setUmask
      (lib.mkIf hostPlatform.isDarwin setPaths)
    ];
    programs.fish.interactiveShellInit = lib.mkMerge [
      basicAbbrs
      (lib.mkIf (!config.programs.lsd.enable) customLs)
    ];
  };
}
