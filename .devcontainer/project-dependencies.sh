#!/bin/bash
# Project-specific dependencies for claude-auto-code
# This file is sourced by post-create.sh
set -e

echo "==> Installing project-specific dependencies..."

# Install Python via mise
mise use python@3.11

# Install sqlite for features database
brew install sqlite

# Activate mise in current shell
eval "$(mise activate bash)"

# Install Python dependencies
echo "==> Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

# Install Playwright browsers for browser automation
echo "==> Installing Playwright browsers..."
playwright install chromium --with-deps || echo "Playwright browser install skipped (optional)"

# Install UI dependencies
echo "==> Installing UI dependencies..."
cd ui && npm install && cd ..

echo "==> Project dependencies installed!"
