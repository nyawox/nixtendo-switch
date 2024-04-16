{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib; let
  cfg = config.services.switch-presence;
  presence-client-src = inputs.presence-client + "/PresenceClient/PresenceClient-Py/presence-client.py";
  presence-client = pkgs.stdenv.mkDerivation {
    pname = "presence-client";
    version = "unstable-2023-12-19";
    propagatedBuildInputs = [
      (pkgs.python3.withPackages (pythonPackages:
        with pythonPackages; [
          pypresence
          python-dotenv
        ]))
    ];
    dontUnpack = true;
    installPhase = "install -Dm755 ${presence-client-src} $out/bin/presence-client";
  };
in {
  options = {
    services.switch-presence = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      args = mkOption {
        type = types.string;
        default = "--ignore-tinfoil --low-latency";
      };
      environmentFile = mkOption {
        type = types.nullOr types.path;
        example = ''
          You must specify an environment file containing both
          $switch-presence-ip: The IP address of your device.
          $switch-presence-id: The Client ID of your Discord Rich Presence application.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.services.switch = {
      enable = true;
      description = "Nintendo switch presence client";
      serviceConfig = {
        EnvironmentFile = config.services.switch-presence.environmentFile;
        ExecStart = "${presence-client}/bin/presence-client $switch-presence-ip $switch-presence-id";
      };
    };
  };
}
