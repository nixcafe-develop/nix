{
  inputs,
  pkgs,
  mkShell,
  system,
  ...
}:
mkShell {
  packages = with pkgs; [
    # nix stuff
    nixfmt-rfc-style
    deadnix
    statix
    # PatchELF is a simple utility for modifying existing ELF executables and libraries.
    # patchelf
  ];

  inherit (inputs.self.checks.${system}.pre-commit-check) shellHook;
  buildInputs = inputs.self.checks.${system}.pre-commit-check.enabledPackages;
}
