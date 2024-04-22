{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.switch-boot;
  hekate =
    pkgs.fetchzip {
      url = "https://github.com/CTCaer/hekate/releases/download/v6.1.1/hekate_ctcaer_6.1.1_Nyx_1.6.1.zip";
      hash = "sha256-WEy/ftldCwU/TXXOGDkQ3Q0JaVm0NchDkkZ5PBbDlR4=";
      stripRoot = false;
    }
    + "/hekate_ctcaer_6.1.1.bin";
in {
  options = {
    services.switch-boot = {
      enable = mkOption {
        type = types.bool;
        default = false;
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.services.switch-boot = {
      enable = true;
      description = "Switch payload injector";
      serviceConfig = {
        # fusee-launcher and fusee-nano not working
        ExecStart = "${pkgs.jre}/bin/java -jar ${pkgs.ns-usbloader}/share/java/ns-usbloader.jar -r ${hekate}";
      };
    };
    services.udev.extraRules = ''
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="0955", ATTRS{idProduct}=="7321", TAG+="systemd", ENV{SYSTEMD_WANTS}="switch-boot.service"
    '';
  };
}
