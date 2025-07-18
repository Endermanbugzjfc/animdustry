let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs {};

  nixpkgs-nim = fetchTarball "https://github.com/NixOS/nixpkgs/archive/a71323f68d4377d12c04a5410e214495ec598d4c.tar.gz";
  pkgs-nim = import nixpkgs-nim {};
in pkgs.mkShellNoCC {
  packages = with pkgs-nim; [
    nim_lk
    gcc12

    nim

    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
    libGL
    xorg.libXxf86vm
  ];
}
