{
  description = "High-performance, cross-platform command-line tool for visualizing and exploring your file system usage";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsFor.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              go
              golangci-lint
            ];
          };
        }
      );

      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor.${system};
        in
        {
          noxdir = pkgs.buildGoModule {
            pname = "noxdir";
            version = "0.7.0";
            src = ./.;
            vendorHash = "sha256-NtrTLF6J+4n+bnVsfs+WAmlYeL0ElJzwaiK1sk59z9k=";
            ldflags = [
              "-s"
              "-w"
            ];
            subPackages = [ "." ];
          };

          default = self.packages.${system}.noxdir;
        }
      );
    };
}
