# Nix development template

Nix flake template for Nix projects. The development shell provides `nixfmt`, `deadnix`, and `statix`, and the same tools are enabled as git pre-commit hooks. The flake is built with [purr](https://flakehub.com/f/nixcafe/purr) and [git-hooks.nix](https://flakehub.com/f/cachix/git-hooks.nix).

This repository is part of the [develop-templates](https://github.com/nixcafe/develop-templates) collection.

## Quick start

Create a project from the template:

```bash
nix flake init -t "github:nixcafe/develop-templates#nix" --refresh
```

To use a shorter registry name:

```bash
nix registry add beans "github:nixcafe/develop-templates"
nix flake init -t beans#nix
```

If you use [cattery-modules](https://github.com/nixcafe/cattery-modules), the `beans` registry entry already exists.

You can also create a GitHub repository from this template:

```bash
gh repo create my-nix-project --template nixcafe-develop/nix --clone
```

Enter the development shell:

```bash
direnv allow
# or without direnv:
nix develop
```

## What's included

| Tool | Purpose | Link |
|------|---------|------|
| `nixfmt` | Nix formatter | [nixfmt](https://github.com/NixOS/nixfmt) |
| `deadnix` | Finds dead code in Nix files | [deadnix](https://github.com/astro/deadnix) |
| `statix` | Reports Nix anti-patterns | [statix](https://github.com/oppiliappan/statix) |

All three are available in the shell and run as pre-commit hooks. The `deadnix` hook reports dead code and fails the commit; it does not edit files. Run `deadnix --edit .` to remove dead code.

## Customization

### Add packages

Edit `develop/shells/default/default.nix` and add entries to `packages`:

```nix
packages = with pkgs; [
  nixfmt
  deadnix
  statix
  just
  alejandra
];
```

The file already wires the git hook shell hook and `enabledPackages`. Keep those lines when you edit it.

### Pre-commit hooks

Edit `develop/checks/git-hooks/default.nix` to enable, disable, or configure hooks. The file enables all three by default:

```nix
{ inputs, system, ... }:
inputs.git-hooks.lib.${system}.run {
  src = ../../..;

  hooks = {
    nixfmt.enable = true;
    deadnix.enable = true;
    statix.enable = true;
  };
}
```

To add another hook, enable it in the `hooks` attrset. See [git-hooks.nix](https://github.com/cachix/git-hooks.nix) for the full hook list.

### statix configuration

Tune the linter in `statix.toml` at the repository root:

```toml
disabled = ["repeated_keys"]
ignore = ['.direnv']
nix_version = '2.4'
```

### nixpkgs configuration

The flake sets `nixpkgsConfig.allowUnfree = true` in `flake.nix`. Add other nixpkgs options to the same attrset.

## Project structure

```
.
├── flake.nix                          # flake entrypoint
├── statix.toml                        # statix linter configuration
├── .envrc                             # direnv integration (use flake)
├── .gitignore
└── develop/
    ├── checks/
    │   └── git-hooks/
    │       └── default.nix            # pre-commit hooks
    └── shells/
        └── default/
            └── default.nix            # dev shell packages and shell hook
```

## Flake inputs

| Input | URL |
|-------|-----|
| `nixpkgs` | `https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz` |
| `purr` | `https://flakehub.com/f/nixcafe/purr/0.1.*.tar.gz` |
| `git-hooks` | `https://flakehub.com/f/cachix/git-hooks.nix/0.1.*.tar.gz` |

`git-hooks` follows the `nixpkgs` input. `purr` uses `nixpkgs-lib` and does not add another nixpkgs.

## Useful commands

```bash
nix develop               # enter the development shell
nix flake check           # run all checks, including the git hooks
nix fmt                   # format Nix files with nixfmt
statix check .            # lint all Nix files
deadnix -f .              # report dead code; exits 1 if found
deadnix --edit .          # remove dead code
```
