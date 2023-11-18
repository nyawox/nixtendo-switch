{
  description = "Simple automatic nintendo switch payload injector module for nixos";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      flake.nixosModules.nix-switch-boot = {
        imports = [./switch-boot.nix];
      };
    };
}
