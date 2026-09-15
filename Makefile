.DEFAULT_GOAL := install
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
VIM_DIR := $(HOME)/.vim
VIM_PACKAGE_DIR := $(VIM_DIR)/pack
VIM_LABS_DIR ?= $(ROOT_DIR)/../vim-labs

.PHONY: directories
directories:
	@mkdir -p "$(VIM_DIR)"
	@mkdir -p "$(VIM_PACKAGE_DIR)"

.PHONY: git-submodules
git-submodules:
	@echo "initializing and updating git submodules..."
	@git -C "$(ROOT_DIR)" submodule update --init --recursive

.PHONY: install-vim-labs
install-vim-labs: git-submodules directories
	@python3 "$(ROOT_DIR)/vendor/vim-labs/scripts/install.py" --vim-dir "$(VIM_DIR)"

# Switch only the Vim Labs package links to an editable checkout. The pinned
# submodule remains unchanged. `make install-vim-labs` switches them back.
.PHONY: install-dev
install-dev: directories
	@python3 "$(VIM_LABS_DIR)/scripts/install.py" --vim-dir "$(VIM_DIR)"

# The `solarized` target is gone. It symlinked
# $(ROOT_DIR)/vim/pack/plugins/start/vim-colors-solarized/colors into ~/.vim,
# but no vim/pack/ directory exists in this repo -- the plugin lives at
# plugins/start/. The link it produced was always dangling, and nothing
# noticed because vim finds the colorscheme on its own: plugins/ is symlinked
# into ~/.vim/pack, and vim adds pack/*/start/* to runtimepath at startup,
# colors/ included. Run `make install` on an existing machine to drop the
# stale ~/.vim/colors link.

.PHONY: install
install: install-vim-labs
	@echo "symlinking configuration files...."
	@ln -snf "$(ROOT_DIR)/plugins" "$(VIM_PACKAGE_DIR)"
	@ln -snf "$(ROOT_DIR)/vimrc" "$(HOME)/.vimrc"
	@# Drop the dangling ~/.vim/colors link the old solarized target left
	@# behind. Guarded on -L so a real colors/ directory is never touched.
	@[ -L "$(VIM_DIR)/colors" ] && rm -f "$(VIM_DIR)/colors" || true
