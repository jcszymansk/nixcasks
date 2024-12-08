{
  description = "Homebrew Casks, nixified";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      output = args: rec {
        packages = forAllSystems (system: import ./default.nix ({
          pkgs = import nixpkgs { inherit system; };
        } // args));
        legacyPackages = packages;
      };
    };
}
