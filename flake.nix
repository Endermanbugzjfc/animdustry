{
  description = "Animdustry: anime gacha bullet hell rhythm game";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system:
      f nixpkgs.legacyPackages.${system}
    );
  in {
    packages = forAllSystems (pkgs: rec {
      # Pinned upstream revision, exactly as nix/package.nix declares it.
      animdustry-pinned = pkgs.callPackage ./nix/package.nix { };

      # Live working tree. Note: with a dirty tree, modified tracked files
      # are included but untracked files are not — `git add` new files first.
      animdustry = animdustry-pinned.overrideAttrs (prev: {
        version = "${prev.version}-dev";
        src = self;
      });

      default = animdustry;
    });

    devShells = forAllSystems (pkgs: let
      shells = import ./nix/shell.nix { inherit pkgs; };
    in {
      inherit (shells) lin default web;
      win = shells.win { };
    });
  };
}
