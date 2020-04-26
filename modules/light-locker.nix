{ config, lib, pkgs, ... }:

with lib;

let
  ldmcfg = config.services.xserver.displayManager.lightdm;
  cfg = config.programs.light-locker;

  wrapped = let
      args = map escapeShellArg ([
        "--lock-after-screensaver=${toString cfg.lockAfterScreensaver}"
        (if cfg.lateLocking then "--late-locking" else "--no-late-locking")
        (if cfg.lockOnSuspend then "--lock-on-suspend" else "--no-lock-on-suspend")
        (if cfg.lockOnLid then "--lock-on-lid" else "--no-lock-on-lid")
        (if cfg.idleHint then "--idle-hint" else "--no-idle-hint")
      ] ++ cfg.extraOptions);
  in
  pkgs.buildEnv {
    name = cfg.package.name + "-wrapped";
    paths = [ cfg.package ];
    pathsToLink = [ "/etc" "/share" ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      makeWrapper "${cfg.package}/bin/light-locker" "$out/bin/light-locker" \
          ${concatMapStringsSep " " (a: "--add-flags ${a}") args}
      for path in ${cfg.package}/bin/*; do
          name="$(basename "$path")"
          if [ "$name" != light-locker ]; then
              ln -s "$path" "$out/bin/$name"
          fi
      done
    '';
  };
in

{
  options = {
    programs.light-locker = {
      enable = mkEnableOption "light-locker";

      package = mkOption {
        type        = types.package;
        default     = pkgs.lightlocker;
        defaultText = "pkgs.lightlocker";
        example     = literalExample "pkgs.lightlocker";
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

      lockOnLid = mkOption {
        type        = types.bool;
        default     = true;
        description = ''
          Whether to lock the screen on lid close.
        '';
      };

      idleHint = mkOption {
        type        = types.bool;
        default     = true;
        description = ''
          Whether to set the session idle hint while the screensaver is active.
        '';
      };

      extraOptions = mkOption {
        default = [ ];
        example = [ "--debug" ];
        type = types.listOf types.str;
        description = ''
          Additional command-line arguments to pass to
          <command>light-locker</command>.
        '';
      };
    };
  };

  config = mkIf (ldmcfg.enable && cfg.enable) {
    services.xserver.displayManager.sessionCommands = ''
      ${wrapped}/bin/light-locker &
    '';

    environment.systemPackages = [ wrapped ];
  };
}
