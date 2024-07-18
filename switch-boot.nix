{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.switch-boot;
  hekate-ver = "6.2.1";
  nyx-ver = "1.6.3";
  hekate =
    pkgs.fetchzip {
      url = "https://github.com/CTCaer/hekate/releases/download/v${hekate-ver}/hekate_ctcaer_${hekate-ver}_Nyx_${nyx-ver}.zip";
      hash = "sha256-KqGioq7+KcdOE2YJNAoZN63WS3xedvdIvQITC1eX14g=";
      stripRoot = false;
    }
    + "/hekate_ctcaer_${hekate-ver}.bin";
in {
  options = {
    services.switch-boot = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
      payload = mkOption {
        type = types.path;
        default = hekate;
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.services.switch-boot = {
      enable = true;
      description = "Switch payload injector";
      serviceConfig = {
        # fusee-launcher and fusee-nano not working
        ExecStart = "${pkgs.jre}/bin/java -jar ${pkgs.ns-usbloader}/share/java/ns-usbloader.jar -r ${cfg.payload}";
      };
    };
    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7321", TAG+="systemd", ENV{SYSTEMD_WANTS}="switch-boot.service"
    '';
  };
}
