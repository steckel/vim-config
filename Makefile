.DEFAULT_GOAL := install
ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
VIM_DIR := $(HOME)/.vim
VIM_PACKAGE_DIR := $(VIM_DIR)/pack
VIM_LABS_DIR ?= $(ROOT_DIR)/../vim-labs
VARIANTS_DIR := $(ROOT_DIR)/variants

# Automatically include latest nvm Node.js in PATH if available (for vim-labs MCP install)
NVM_NODE_BIN := $(lastword $(wildcard $(HOME)/.nvm/versions/node/v*/bin))
ifneq ($(NVM_NODE_BIN),)
  export PATH := $(NVM_NODE_BIN):$(PATH)
endif

# ==============================================================================
# Modular Variant Discovery Engine
# ==============================================================================
# Variants are modular configurations located in $(VARIANTS_DIR)/<variant_name>
# (often maintained in environment-specific branches such as 'work').
#
# Each variant directory may provide:
#   1. detect.sh (or detect): An executable script that exits 0 if the host
#      environment matches the variant, and prints a human-readable description.
#   2. variant.mk: A Makefile fragment included by this root Makefile.
#
# Override variant manually if desired:
#   make VARIANT=work
#   make VARIANT=none
# ==============================================================================
DETECTED_VARIANT := $(shell \
	if [ -d "$(VARIANTS_DIR)" ]; then \
		for dir in "$(VARIANTS_DIR)"/*; do \
			if [ -d "$$dir" ]; then \
				detector=""; \
				if [ -x "$$dir/detect.sh" ]; then \
					detector="$$dir/detect.sh"; \
				elif [ -x "$$dir/detect" ]; then \
					detector="$$dir/detect"; \
				fi; \
				if [ -n "$$detector" ] && "$$detector" >/dev/null 2>&1; then \
					basename "$$dir"; \
					exit 0; \
				fi; \
			fi; \
		done; \
	fi \
)

# Check if current git branch matches a variant directory name
GIT_BRANCH := $(shell git -C "$(ROOT_DIR)" rev-parse --abbrev-ref HEAD 2>/dev/null)
ifneq ($(wildcard $(VARIANTS_DIR)/$(GIT_BRANCH)),)
  DETECTED_VARIANT := $(GIT_BRANCH)
endif

VARIANT ?= $(DETECTED_VARIANT)
ifneq ($(filter none off 0 false,$(VARIANT)),)
  override VARIANT :=
endif

VARIANT_DIR := $(VARIANTS_DIR)/$(VARIANT)
VARIANT_MK  := $(VARIANT_DIR)/variant.mk

ifneq ($(wildcard $(VARIANT_MK)),)
  include $(VARIANT_MK)
endif

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

.PHONY: hooks
hooks:
	@echo "Installing git safety hooks (pre-commit, pre-push)..."
	@chmod +x "$(ROOT_DIR)/hooks/pre-commit" "$(ROOT_DIR)/hooks/pre-push"
	@ln -snf "$(ROOT_DIR)/hooks/pre-commit" "$(ROOT_DIR)/.git/hooks/pre-commit"
	@ln -snf "$(ROOT_DIR)/hooks/pre-push" "$(ROOT_DIR)/.git/hooks/pre-push"

.PHONY: check-variant
check-variant:
ifneq ($(VARIANT),)
  ifneq ($(wildcard $(VARIANT_MK)),)
	@echo "==> Active variant: '$(VARIANT)' (loaded from $(VARIANT_DIR))"
  else
	@echo "==> [Notice] Detected '$(VARIANT)' environment, but '$(VARIANT_DIR)' is not present."
	@echo "    If this configuration lives on a dedicated branch, switch with:"
	@echo "      git checkout $(VARIANT) && make"
  endif
else
	@echo "==> Active variant: none (standard baseline install)"
endif

.PHONY: install
install: install-vim-labs hooks check-variant
	@echo "symlinking configuration files...."
	@ln -snf "$(ROOT_DIR)/plugins" "$(VIM_PACKAGE_DIR)"
	@ln -snf "$(ROOT_DIR)/vimrc" "$(HOME)/.vimrc"
	@[ -L "$(VIM_DIR)/colors" ] && rm -f "$(VIM_DIR)/colors" || true
ifneq ($(wildcard $(VARIANT_MK)),)
	@$(MAKE) variant-install
endif
