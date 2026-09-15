# Vim dotfiles

Vim configuration with plugins installed as native Vim packages.

## Install

```sh
git clone https://github.com/steckel/vim-dotfiles.git
cd vim-dotfiles
make install
```

This initializes the pinned Git submodules, links the configuration and existing
plugins into `~/.vim`, and installs Vim Labs components from `vendor/vim-labs`:

- `vim-code-review`: the shared review interface.
- `vim-code-review-github`: GitHub PR browsing and review actions.
- `vim9-mcp`: live Vim integration and its local MCP server.

The Vim Labs collection is a submodule outside the package-loading directory.
Its individual components are symlinked into `~/.vim/pack/vim-labs/start/` so
Vim loads them as native packages. Installation also runs `npm ci` for MCP
dependencies and generates help tags. Requirements: Vim 9.1+, Python 3.9+,
Git, and Node.js 22+ with npm. Restart Vim after installation.

Machine-specific configuration belongs in `~/.vimrc.local`. The installer does
not configure an MCP client; see the [MCP setup](https://github.com/steckel/vim-labs/blob/main/plugins/vim9-mcp/README.md).

## Local development

Clone an editable Vim Labs checkout alongside this repository, then switch the
package symlinks to it:

```sh
git clone https://github.com/steckel/vim-labs.git ../vim-labs
make install-dev
```

For a checkout elsewhere:

```sh
make install-dev VIM_LABS_DIR=/path/to/vim-labs
```

Edits in that checkout are available directly to Vim. Restart Vim to reload
already loaded scripts. This does not change the pinned submodule or rewrite
tracked package paths. Switch back to the pinned version with:

```sh
make install-vim-labs
```

Both installation modes preserve replaced package symlinks under
`~/.vim/vim-labs-backups`, including their original paths and targets. Legacy
`vim-revue` and `vim-reviewhub` package symlinks are backed up and removed from
the startup path to avoid duplicate loading. Real plugin directories/checkouts
are never replaced automatically.

To use a different Vim directory, pass `VIM_DIR=/path/to/vim-directory` to
`make install-vim-labs` or `make install-dev`. For manual installation options,
including skipping dependency installation, see the
[Vim Labs installer](https://github.com/steckel/vim-labs#install-selected-plugins).
