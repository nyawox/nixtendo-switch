{
  description = "NixOS module for hacked nintendo switch";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    presence-client = {
      url = "github:LeNooby09/PresenceClient";
      flake = false;
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      flake.nixosModules = {
        nixtendo-switch = {
          imports = [
            ./switch-boot.nix
            ./switch-presence.nix
          ];
        };
      };
    };
}
