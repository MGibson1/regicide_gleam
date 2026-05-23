{
  description = "Nix flake for development of gage";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {self, ...} @ inputs: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      inputs.nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [self.overlays.default];
          };
        });
  in {
    overlays.default = final: prev: rec {
      # ==== ERLANG ====

      # use specific version of Erlang
      erlang = final.beam.interpreters.erlang_28;

      # ==== BEAM packages ====

      # all BEAM packages will be compile with your preferred erlang version
      pkgs-beam = final.beam.packagesWith erlang;

      # ==== Elixir ====

      # use specific version of Elixir
      elixir = pkgs-beam.elixir_1_19;
    };

    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        nativeBuildInputs = [pkgs.pkg-config];
        packages = with pkgs; [
          # use the Elixr/OTP versions defined above; will also install OTP, mix, hex, rebar3
          elixir
          gleam
          erlang # needed by gleam
          rebar3 # needed by gleam, not actually installed by elixir
          pkgs-beam.hex # needed for erlang b3 dep

          # mix needs it for downloading dependencies
          git

          watchexec
          just
          just-lsp
          concurrently

          # typescript stuff for javascript target
          nodejs_24
        ];
      };
    });
  };
}
