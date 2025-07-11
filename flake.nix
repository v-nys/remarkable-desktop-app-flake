{
  description = "Run installed reMarkable app via Wine";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

    in
    {

      packages.x86_64-linux.default = pkgs.writeShellApplication {
        name = "remarkable";
        runtimeInputs = [ pkgs.wineWowPackages.waylandFull ];
        text = ''
          PREFIX_TEMPLATE="${self}/wineprefix"
          WINEPREFIX="''${XDG_DATA_HOME:-$HOME/.local/share}/remarkable-wineprefix"

            if [ ! -d "$WINEPREFIX" ]; then
              echo "First launch: copying Wine prefix to $WINEPREFIX..."
              mkdir -p "$(dirname "$WINEPREFIX")"
              cp -r "$PREFIX_TEMPLATE" "$WINEPREFIX"
            fi
          export WINEPREFIX
          export WINEARCH=win64
          export WINEDLLOVERRIDES="qnetworklistmanager=b"
          exec wine ${self}/remarkable/reMarkable.exe
        '';
      };

      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with nixpkgs.legacyPackages.x86_64-linux; [
          wineWowPackages.waylandFull
          winetricks
          bash
        ];

        shellHook = ''
          PREFIX_TEMPLATE="${self}/wineprefix"
          WINEPREFIX="''${XDG_DATA_HOME:-$HOME/.local/share}/remarkable-wineprefix"

            if [ ! -d "$WINEPREFIX" ]; then
              echo "First launch: copying Wine prefix to $WINEPREFIX..."
              mkdir -p "$(dirname "$WINEPREFIX")"
              cp -r "$PREFIX_TEMPLATE" "$WINEPREFIX"
            fi
          export WINEPREFIX
          export WINEARCH=win64
          export WINEDLLOVERRIDES="qnetworklistmanager=b"
          echo "To run, run: wine remarkable/reMarkable.exe"
        '';
      };
    };
}
