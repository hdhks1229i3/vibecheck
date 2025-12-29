# VibeCheck Construction Kit 🏗️

VERSION := 1.0.0
DIST_DIR := dist
ZIG_OUT := zig-out
BIN_NAME := vibecheck

.PHONY: all build clean test release hashes package

all: build

# -----------------------------------------------------------------------------
# Development
# -----------------------------------------------------------------------------

build:
	@echo "🔨 Building ReleaseSmall..."
	zig build -Doptimize=ReleaseSmall

test:
	@echo "🧪 Running Tests..."
	zig build test
	@echo "🔎 Running MCP Integration Test (Manual Check)..."
	# python3 test_mcp.py (If it existed)

fuzz:
	@echo "🐝 Starting Fuzzer..."
	zig build test --fuzz

clean:
	@echo "🧹 Cleaning up..."
	rm -rf $(DIST_DIR) $(ZIG_OUT) .zig-cache
	mkdir -p $(DIST_DIR)

# -----------------------------------------------------------------------------
# Git Automation
# -----------------------------------------------------------------------------

MSG ?= "chore: snapshot"

git-push:
	git push origin master

git-save: clean test
	git add .
	git commit -m $(MSG)
	git push origin master

# -----------------------------------------------------------------------------
# Release Engineering
# -----------------------------------------------------------------------------

release: clean
	@echo "🚀 Cross-compiling release artifacts..."
	mkdir -p $(DIST_DIR)
	
	@echo "🐧 Linux (x86_64)..."
	zig build -Dtarget=x86_64-linux -Doptimize=ReleaseSmall
	tar -czvf $(DIST_DIR)/$(BIN_NAME)-x86_64-linux.tar.gz -C $(ZIG_OUT)/bin $(BIN_NAME)
	
	@echo "🍎 macOS (Apple Silicon)..."
	zig build -Dtarget=aarch64-macos -Doptimize=ReleaseSmall
	tar -czvf $(DIST_DIR)/$(BIN_NAME)-aarch64-macos.tar.gz -C $(ZIG_OUT)/bin $(BIN_NAME)
	
	@echo "🍏 macOS (Intel)..."
	zig build -Dtarget=x86_64-macos -Doptimize=ReleaseSmall
	tar -czvf $(DIST_DIR)/$(BIN_NAME)-x86_64-macos.tar.gz -C $(ZIG_OUT)/bin $(BIN_NAME)
	
	@echo "🪟 Windows (x86_64)..."
	zig build -Dtarget=x86_64-windows -Doptimize=ReleaseSmall
	zip -j $(DIST_DIR)/$(BIN_NAME)-x86_64-windows.zip $(ZIG_OUT)/bin/$(BIN_NAME).exe

	@echo "📦 Generating hashes..."
	sha256sum $(DIST_DIR)/* > $(DIST_DIR)/CHECKSUMS.txt
	@cat $(DIST_DIR)/CHECKSUMS.txt

# -----------------------------------------------------------------------------
# Packaging Automation
# -----------------------------------------------------------------------------

# Usage: make update-packaging VERSION=1.0.1
# Expects RELEASE_HASH_* vars or reads from CHECKSUMS.txt (Advanced parsing would go here)
# For now, just a placeholder for the user to implement or use 'sed' scripts.

update-packaging:
	@echo "📝 Updating packaging templates (Placeholder)..."
	@echo "Run 'sha256sum dist/*' and allow me to update the files manually or implement sed logic here."
