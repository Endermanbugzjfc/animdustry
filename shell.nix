let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-unstable";
  pkgs = import nixpkgs {};
in pkgs.mkShellNoCC {
  packages = with pkgs; [
    git
    cacert
    gcc

    nimble
    nim_lk

    nim

    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXi
    libGL
    xorg.libXxf86vm
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
