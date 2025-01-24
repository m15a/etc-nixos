{
  config,
  lib,
  pkgs,
  ...
}:

let
  ldmcfg = config.services.xserver.displayManager.lightdm;
  cfg = config.services.lightlocker;

  wrapped =
    let
      args = [
        "--lock-after-screensaver=${toString cfg.lockAfterScreensaver}"
        (if cfg.lateLocking then "--late-locking" else "--no-late-locking")
        (if cfg.lockOnSuspend then "--lock-on-suspend" else "--no-lock-on-suspend")
        (if cfg.lockOnLid then "--lock-on-lid" else "--no-lock-on-lid")
        (if cfg.idleHint then "--idle-hint" else "--no-idle-hint")
      ] ++ cfg.extraOptions;
    in
    pkgs.buildEnv {
      name = "${cfg.package.name}-wrapped";
      paths = [ cfg.package ];
      pathsToLink = [
        "/etc"
        "/share"
      ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        makeWrapper "${cfg.package}/bin/light-locker" "$out/bin/light-locker" \
            ${lib.concatMapStringsSep " " (a: "--add-flags ${a}") args}
        ln -s ${cfg.package}/bin/light-locker-command $out/bin/
      '';
    };
in

{
  options = {
    services.light-locker = {
      enable = lib.mkEnableOption "light-locker";
      package = lib.mkPackageOption pkgs "lightloker" { };
      lockAfterScreensaver = lib.mkOption {
        type = lib.types.int;
        default = 0;
        description = ''
          Timeout in seconds to lock the screen after the screensaver started.
          Use 0 to disable this.
        '';
      };
      lateLocking = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to lock the screen on screensaver deactivation.
        '';
      };
      lockOnSuspend = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to lock the screen on suspend/resume.
        '';
      };
      lockOnLid = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to lock the screen on lid close.
        '';
      };
      idleHint = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to set the session idle hint while the screensaver is active.
        '';
      };
      extraOptions = lib.mkOption {
        default = [ ];
        example = [ "--debug" ];
        type = with lib.types; listOf str;
        description = ''
          Additional command-line arguments to pass to
          <command>light-locker</command>.
        '';
      };
    };
  };

  config = lib.mkIf (ldmcfg.enable && cfg.enable) {
    services.xserver.displayManager.sessionCommands = ''
      ${wrapped}/bin/light-locker &
    '';
    environment.systemPackages = [ wrapped ];
  };
}
