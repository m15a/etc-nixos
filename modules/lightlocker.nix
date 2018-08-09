{ config, lib, pkgs, ... }:

with lib;

let
  ldmcfg = config.services.xserver.displayManager.lightdm;
  cfg = config.programs.lightlocker;
in

{
  options = {
    programs.lightlocker = {
      enable = mkEnableOption "light-locker";

      package = mkOption {
        type        = types.package;
        default     = pkgs.lightlocker;
        defaultText = "pkgs.lightlocker";
        example     = "pkgs.lightlocker";
        description = ''
          light-locker package to use.
        '';
      };

      lockAfterScreensaver = mkOption {
        type        = types.int;
        default     = 0;
        description = ''
          Timeout in seconds to lock the screen after the screensaver started.
          Use 0 to disable this.
        '';
      };

      lateLocking = mkOption {
        type        = types.bool;
        default     = true;
        description = ''
          Whether to lock the screen on screensaver deactivation.
        '';
      };

      lockOnSuspend = mkOption {
        type        = types.bool;
        default     = true;
        description = ''
          Whether to lock the screen on suspend/resume.
        '';
      };

      idleHint = mkOption {
        type        = types.bool;
        default     = true;
        description = ''
          Whether to set the session idle hint while the screensaver is active.
        '';
      };
    };
  };

  config = mkIf (ldmcfg.enable && cfg.enable) {
    systemd.user.services.light-locker = {
      description = "light-locker service";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      script = ''
        XDG_SESSION_PATH=$(echo "$XDG_SESSION_PATH") \
          ${pkgs.lightlocker}/bin/light-locker \
          --lock-after-screensaver=${toString cfg.lockAfterScreensaver} \
          ${if cfg.lateLocking then "--late-locking" else "--no-late-locking"} \
          ${if cfg.lockOnSuspend then "--lock-on-suspend" else "--no-lock-on-suspend"} \
          ${if cfg.idleHint then "--idle-hint" else "--no-idle-hint"}
      '';

      serviceConfig.Restart = "always";
    };

    environment.systemPackages = [ cfg.package ];
  };
}
