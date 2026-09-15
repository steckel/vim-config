# Dotfiles Variants

This directory provides a modular extension system for platform- and organization-specific Vim configurations.

## Architecture

The `master` branch maintains the core Vim configuration and the generic variant discovery engine. Specific variants can be implemented and maintained on separate Git branches (e.g. `work`, `corp`, etc.).

This separation ensures:
1. The `master` branch remains clean and free of proprietary tooling, company hostnames, or corporate paths.
2. Variant-specific branches can cleanly merge or rebase from `master` while maintaining their own isolated `variants/<name>/` directory.

## Variant Structure

Each variant lives in its own subdirectory:

```text
variants/<variant_name>/
├── detect.sh        # Executable script returning 0 if current machine matches
├── variant.mk       # Makefile rules included automatically when active
└── vimrc            # Variant Vim configuration (symlinked to ~/.vimrc.variant)
```

## Manual Override

You can manually force a specific variant or disable variant detection:

```bash
# Force a specific variant
make VARIANT=work

# Force standard personal profile (disable variants)
make VARIANT=none
```
