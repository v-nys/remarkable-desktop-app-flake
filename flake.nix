{
  description = "Run installed reMarkable app via Wine";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      remarkableApp = pkgs.writeShellApplication {
        name = "remarkable";
        runtimeInputs = [ pkgs.wineWowPackages.waylandFull ];
        text = ''
          export WINEPREFIX=`${self}/wineprefix`
          export WINEARCH=win64
          export WINEDLLOVERRIDES="qnetworklistmanager=b"
          exec wine `${self}/remarkable/reMarkable.exe`
        '';
      };
    in
    {

      packages.x86_64-linux.default = remarkableApp;

      devShells.x86_64-linux.default = pkgs.mkShell {
        packages = with nixpkgs.legacyPackages.x86_64-linux; [
          wineWowPackages.waylandFull
          winetricks
          bash
          remarkableApp
        ];

        shellHook = ''
          export WINEPREFIX=${self}/wineprefix
          export WINEARCH=win64
          export WINEDLLOVERRIDES="qnetworklistmanager=b"
          echo "To run, run: remarkable"
        '';
      };
    };
}
