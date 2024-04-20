{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.switch-presence;
  presence-client = pkgs.stdenvNoCC.mkDerivation {
    pname = "presence-client";
    version = "unstable-2023-12-19";
    src = pkgs.fetchFromGitHub {
      owner = "lenooby09";
      repo = "presenceclient";
      rev = "890c510f27add83eaa0217444d7385cceb45ee08";
      hash = "sha256-34rCyEJ9jiAYxrOMo5uzuX1mi7Kw5vcZZc4p0NuIkeE=";
    };
    # Runtime dependencies
    propagatedBuildInputs = [
      (pkgs.python3.withPackages (pythonPackages:
        with pythonPackages; [
          requests
          pypresence
          python-dotenv
        ]))
    ];
    installPhase = ''
      install -Dm755 PresenceClient/PresenceClient-Py/presence-client.py $out/bin/presence-client
      sed -i '1 i #!/usr/bin/env python3' $out/bin/presence-client
    '';
  };
in {
  options = {
    services.switch-presence = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      args = mkOption {
        type = types.str;
        default = "--ignore-tinfoil --low-latancy";
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
    systemd.user.services.switch-presence = {
      enable = true;
      description = "Nintendo switch discord rich presence client";
      wantedBy = ["default.target"];
      serviceConfig = {
        EnvironmentFile = config.services.switch-presence.environmentFile;
        ExecStart = "${presence-client}/bin/presence-client ${config.services.switch-presence.args}";
        Restart = "on-failure";
        RestartSec = "60s";
      };
    };
  };
}
