# SView - SVG Viewer & PWA Launcher with sView Integration
# Makefile for project management

# Variables
export PROJECT_NAME = sview
export VERSION = 1.0.0
export RUST_VERSION = 1.70
export NODE_VERSION = 18

# Directories
export SRC_DIR = src
export GUI_DIR = gui
export DIST_DIR = dist
export TARGET_DIR = target
export EXAMPLES_DIR = examples
export DOCS_DIR = docs

# Build configuration
export CARGO_FLAGS = --release --no-default-features --features=encryption,watch
export NPM_FLAGS = --production
export RUSTFLAGS = -C target-cpu=native

# Scripts directory
SCRIPTS_DIR = scripts

# Colors for output
export RED = \033[0;31m
export GREEN = \033[0;32m
export YELLOW = \033[0;33m
export BLUE = \033[0;34m
export PURPLE = \033[0;35m
export CYAN = \033[0;36m
export NC = \033[0m # No Color

# Default target
.PHONY: all
all: help

# Check requirements
.PHONY: check-requirements
check-requirements:
	@$(SCRIPTS_DIR)/check_requirements.sh

# Install dependencies
.PHONY: install-deps
install-deps:
	@$(SCRIPTS_DIR)/install_deps.sh

# Build CLI application
.PHONY: build
build:
	@$(SCRIPTS_DIR)/build_cli.sh

# Build GUI application
.PHONY: build-gui
build-gui:
	@$(SCRIPTS_DIR)/build_gui.sh

# Build everything
.PHONY: build-all
build-all: build
	@echo "$(GREEN)✅ CLI built successfully$(NC)"
	@echo ""

# Development mode
.PHONY: dev
dev:
	@echo "$(BLUE)🚀 Starting development server...$(NC)"
	@cargo watch -x run

# GUI development mode
.PHONY: dev-gui
dev-gui:
	@echo "$(BLUE)🚀 Starting GUI development server...$(NC)"
	@cd $(GUI_DIR) && npm run dev

# Run tests
.PHONY: test
test:
	@$(SCRIPTS_DIR)/run_tests.sh

# Run tests with coverage
.PHONY: test-coverage
test-coverage:
	@echo "$(BLUE)📊 Running tests with coverage...$(NC)"
	@$(SCRIPTS_DIR)/run_tests.sh --coverage

# Run linters
.PHONY: lint
lint:
	@echo "$(BLUE)🔍 Running linters...$(NC)"
	@cargo clippy -- -D warnings
	@if [ -d "$(GUI_DIR)" ]; then \
		echo "$(YELLOW)Running ESLint...$(NC)"; \
		cd $(GUI_DIR) && npx eslint . --ext .js,.jsx,.ts,.tsx; \
	fi

# Format code
.PHONY: format
format:
	@echo "$(BLUE)🎨 Formatting code...$(NC)"
	@cargo fmt --all
	@if [ -d "$(GUI_DIR)" ]; then \
		echo "$(YELLOW)Formatting frontend code...$(NC)"; \
		cd $(GUI_DIR) && npx prettier --write .; \
	fi

# Install locally
.PHONY: install
install:
	@$(SCRIPTS_DIR)/install.sh

# Uninstall
.PHONY: uninstall
uninstall:
	@echo "$(BLUE)🗑️  Uninstalling SView...$(NC)"
	@rm -f ~/.local/bin/$(PROJECT_NAME)
	@rm -rf ~/.sview
	@echo "$(GREEN)✅ SView has been uninstalled$(NC)"

# Clean build artifacts
.PHONY: clean
clean:
	@$(SCRIPTS_DIR)/clean.sh

# Clean cache
.PHONY: clean-cache
clean-cache:
	@echo "$(BLUE)🧹 Cleaning cache...$(NC)"
	@cargo clean
	@if [ -d "$(GUI_DIR)" ]; then \
		cd $(GUI_DIR) && rm -rf node_modules; \
	fi

# Release build
.PHONY: release
release: clean test build-all
	@$(SCRIPTS_DIR)/create_release.sh

# Create distribution packages
.PHONY: package
package: build-all
	@$(SCRIPTS_DIR)/package_release.sh

# Publish to PyPI using Poetry
.PHONY: publish
publish:
	@echo "$(BLUE)📦 Publishing to PyPI...$(NC)"
	poetry version patch
	poetry publish --build

# Push changes to remote repository
.PHONY: push
push:
	@$(SCRIPTS_DIR)/push.sh
	@echo ""
