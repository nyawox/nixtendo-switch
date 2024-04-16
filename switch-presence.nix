{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.switch-presence;
  presence-client-src =
    pkgs.fetchFromGitHub {
      owner = "lenooby09";
      repo = "presenceclient";
      rev = "890c510f27add83eaa0217444d7385cceb45ee08";
      hash = "sha256-34rCyEJ9jiAYxrOMo5uzuX1mi7Kw5vcZZc4p0NuIkeE=";
    }
    + "/PresenceClient/PresenceClient-Py/presence-client.py";
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
          $switch_presence_ip: The IP address of your device.
          $switch_presence_id: The Client ID of your Discord Rich Presence application.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.services.switch-presence = {
      enable = true;
      description = "Nintendo switch presence client";
      serviceConfig = {
        EnvironmentFile = config.services.switch-presence.environmentFile;
        ExecStart = "${presence-client}/bin/presence-client $switch_presence_ip $switch_presence_id";
      };
    };
  };
}
