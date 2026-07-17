# Nix Flake · Nix Dev Template

> purr · git-hooks · nix · nixpkgs · nix-flake

Base Nix flake development template — a minimal, reproducible dev shell with Nix formatters and git pre-commit hooks. Built on [purr](https://flakehub.com/f/nixcafe/purr) for zero-friction Nix flake scaffolding and [git-hooks.nix](https://flakehub.com/f/cachix/git-hooks.nix) for automated quality gates. Batteries included: auto-formatting, dead-code removal, and static analysis enforced before every commit.

Part of the [develop-templates](https://github.com/nixcafe/develop-templates) collection (`nix flake init`-ready).

## Quick Start

### `nix flake init`

```bash
nix flake init -t "github:nixcafe/develop-templates#nix" --refresh
```

Register a short alias:
```bash
nix registry add beans "github:nixcafe/develop-templates"
nix flake init -t beans#nix
```

> **Tip**: With [cattery-modules](https://github.com/nixcafe/cattery-modules), `beans` is pre-registered.

### Create from Template

```bash
gh repo create my-nix-project --template nixcafe/nix --clone
```

### Enter the Dev Shell

```bash
direnv allow        # auto-load flake on cd
# or without direnv:
nix develop
```

## What's Inside

| Tool     | Purpose                        | More                                          |
|----------|--------------------------------|-----------------------------------------------|
| `nixfmt` | Canonical Nix formatter        | [nixfmt](https://github.com/NixOS/nixfmt)      |
| `deadnix`| Scan & remove dead Nix code    | [deadnix](https://github.com/astro/deadnix)    |
| `statix` | Linter for Nix antipatterns    | [statix](https://github.com/oppiliappan/statix) |

All three run as git **pre-commit hooks** *and* are available inside the dev shell (`nix develop`).

## Customizing

### Add Nix Packages

Edit `develop/shells/default/default.nix` and append packages to the list:

```nix
{
  inputs,
  pkgs,
  system,
  ...
}:
pkgs.mkShell {
  packages = with pkgs; [
    nixfmt
    deadnix
    statix
    just       # command runner
    alejandra  # alternative formatter
  ];

  shellHook = ''
    ${inputs.self.checks.${system}.git-hooks.shellHook}
  '';
  buildInputs = inputs.self.checks.${system}.git-hooks.enabledPackages;
}
```

### Pre-commit Hooks

Edit `develop/checks/git-hooks/default.nix` to enable, disable, or configure hooks:

```nix
{ inputs, system, ... }:
inputs.git-hooks.lib.${system}.run {
  src = ../../..;

  hooks = {
    nixfmt.enable = true;
    deadnix.enable = true;
    statix.enable = true;
    # Add more hooks from git-hooks.nix:
    # shellcheck.enable = true;
    # actionlint.enable = true;
  };
}
```

See the full list of available hooks at [git-hooks.nix](https://github.com/cachix/git-hooks.nix).

### statix Configuration

Tune the linter in `statix.toml` at the repo root:

```toml
disabled = ["repeated_keys"]
ignore = ['.direnv']
nix_version = '2.4'
```

## Project Structure

```
.
├── flake.nix                          # Flake entrypoint
├── statix.toml                        # statix linter config
├── .envrc                             # direnv: `use flake`
├── .gitignore
│
├── develop/
│   ├── checks/
│   │   └── git-hooks/
│   │       └── default.nix            # Pre-commit hooks (nixfmt, deadnix, statix)
│   │
│   └── shells/
│       └── default/
│           └── default.nix            # Dev shell packages + shellHook
```

## Flake Inputs

| Input       | URL                                                        |
|-------------|------------------------------------------------------------|
| `nixpkgs`   | `https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz`       |
| `purr`      | `https://flakehub.com/f/nixcafe/purr/0.1.*.tar.gz`        |
| `git-hooks` | `https://flakehub.com/f/cachix/git-hooks.nix/0.1.*.tar.gz` |

All inputs follow `nixpkgs` for a single consistent package set.

## Quick Reference

```bash
nix develop               # Enter dev shell
nix flake check            # Run all checks (includes git-hooks)
nix fmt                    # Format flake.nix with nixfmt
statix check .             # Lint all Nix files
deadnix -f                # Scan and remove dead code
```
