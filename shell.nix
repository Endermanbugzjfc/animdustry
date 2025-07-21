let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs {};

  nixpkgs-lock = fetchTarball "https://github.com/NixOS/nixpkgs/archive/a71323f68d4377d12c04a5410e214495ec598d4c.tar.gz";
  pkgs-lock = import nixpkgs-lock {};
in pkgs.mkShellNoCC {
  packages = [
    pkgs.git
    pkgs.cacert

    pkgs.nimble
    pkgs.nim_lk

    pkgs-lock.gcc12
    pkgs-lock.nim

    pkgs-lock.xorg.libX11
    pkgs-lock.xorg.libXcursor
    pkgs-lock.xorg.libXrandr
    pkgs-lock.xorg.libXinerama
    pkgs-lock.xorg.libXi
    pkgs-lock.libGL
    pkgs-lock.xorg.libXxf86vm
  ];

  shellHook = ''
    IMPURE_CACHE=false

    if [ -d "$NIMBLE_DIR" ]; then
      export PATH="$PATH:/home/$NIMBLE_DIR/bin"
      echo "Using env NIMBLE_DIR might cause inconsistent behaviour"

      if [ ! -z "$(ls $NIMBLE_DIR)" ]; then IMPURE_CACHE=true; fi
    else
      DEFAULT_NIMBLE_DIR="/home/$(whoami)/.nimble"
      export PATH="$PATH:$DEFAULT_NIMBLE_DIR/bin"

      if [ ! -z "$(ls $DEFAULT_NIMBLE_DIR)" ]; then IMPURE_CACHE=true; fi
    fi

    [ $IMPURE_CACHE ] && echo "Existing Nimble cache might cause inconsistent behaviour"
  '';
}
