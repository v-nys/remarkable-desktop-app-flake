{
  description = "Run installed reMarkable app via Wine";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      shellSetup = ''
        PREFIX_TEMPLATE="${self}/wineprefix"
        WINEPREFIX="''${XDG_DATA_HOME:-$HOME/.local/share}/remarkable-wineprefix"

        if [ ! -d "$WINEPREFIX" ]; then
          echo "First launch: copying Wine prefix to $WINEPREFIX..."
          mkdir -p "$(dirname "$WINEPREFIX")"
          cp -r "$PREFIX_TEMPLATE" "$WINEPREFIX"
          chmod -R +rw "$WINEPREFIX"
        fi

        export WINEPREFIX
        export WINEARCH=win64
        export WINEDLLOVERRIDES="qnetworklistmanager=b"
      '';
    in
    {

      packages.x86_64-linux.default =
        let
          desktopItem = pkgs.makeDesktopItem {
            name = "remarkable";
            exec = "remarkable";
            icon = "${self}/remarkable/remarkable.ico";
            comment = "reMarkable Desktop App (via Wine)";
            desktopName = "reMarkable";
            categories = [ "Office" ];
            terminal = false;
          };

          shellApp = pkgs.writeShellApplication {
            name = "remarkable";
            runtimeInputs = [ pkgs.wineWowPackages.waylandFull ];
            text = ''
              ${shellSetup}
              exec wine "${self}/remarkable/reMarkable.exe"
            '';
          };
        in
        pkgs.buildEnv {
          name = "remarkable";
          paths = [
            shellApp
            desktopItem
          ];
        };

      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with nixpkgs.legacyPackages.x86_64-linux; [
          wineWowPackages.waylandFull
          winetricks
          bash
        ];

        shellHook = ''
          ${shellSetup}
          echo "To run, run: wine remarkable/reMarkable.exe"
        '';
      };
    };
}
