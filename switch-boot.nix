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
      url = "https://github.com/CTCaer/hekate/releases/download/v6.0.7/hekate_ctcaer_6.0.7_Nyx_1.5.6.zip";
      sha256 = "18ldq8gm3k5jy0siz3ajjirr40s0095092g65zl6pjfdq11gvppn";
      stripRoot = false;
    }
    + "/hekate_ctcaer_6.0.7.bin";
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
