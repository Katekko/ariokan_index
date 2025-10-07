#!/usr/bin/env bash
# Simplified coverage script
# 1. Run flutter tests with coverage (generates coverage/lcov.info)
# 2. Pipe diff vs target branch into pull_request_coverage to produce pull_request_coverage.md
# If pull_request_coverage tool is missing, a warning is shown and exit code remains 0.
#
# Usage: check-coverage.sh [branch]
#   branch: Optional. The branch to diff against (default: main)

set -euo pipefail

# Accept target branch as first argument, default to 'main'
TARGET_BRANCH="${1:-main}"

# --- Color / formatting helpers -------------------------------------------------
# Respect NO_COLOR (https://no-color.org/) and only emit colors when stdout is a TTY.
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  _CLR_BOLD="\033[1m"
  _CLR_BLUE="\033[34m"
  _CLR_GREEN="\033[32m"
  _CLR_YELLOW="\033[33m"
  _CLR_RED="\033[31m"
  _CLR_DIM="\033[2m"
  _CLR_RESET="\033[0m"
else
  _CLR_BOLD=""; _CLR_BLUE=""; _CLR_GREEN=""; _CLR_YELLOW=""; _CLR_RED=""; _CLR_DIM=""; _CLR_RESET="";
fi

step() { echo -e "${_CLR_BOLD}${_CLR_BLUE}==>${_CLR_RESET} $*"; }
info() { echo -e "${_CLR_DIM}INFO:${_CLR_RESET} $*"; }
warn() { echo -e "${_CLR_YELLOW}WARNING:${_CLR_RESET} $*" >&2; }
error() { echo -e "${_CLR_RED}ERROR:${_CLR_RESET} $*" >&2; }
success() { echo -e "${_CLR_GREEN}$*${_CLR_RESET}"; }

step "Removing existing coverage data"
if [ -d "coverage" ]; then
  rm -rf coverage
  info "Removed coverage directory"
fi

step "Generating full coverage test files"
if command -v full_coverage >/dev/null 2>&1; then
  full_coverage
  success "Full coverage test files generated"
else
  error "full_coverage tool not found. Install with: dart pub global activate full_coverage"
  error "Continuing without full_coverage..."
fi

step "Running flutter tests with coverage"
flutter test --coverage

step "Cleaning up full_coverage_test.dart"
if [ -f "test/full_coverage_test.dart" ]; then
  rm test/full_coverage_test.dart
  info "Removed test/full_coverage_test.dart"
fi

step "Generating pull request diff coverage (origin/${TARGET_BRANCH})"
if command -v pull_request_coverage >/dev/null 2>&1; then
  # Allow caller to override threshold; default 100 to keep strictness unless relaxed explicitly.
  : "${MIN_DIFF_COVERAGE:=100}"

  # We want to always write a markdown file even on failure, without aborting script earlier.
  set +e
  git diff "origin/${TARGET_BRANCH}" | pull_request_coverage \
    --minimum-coverage "${MIN_DIFF_COVERAGE}" \
    --report-fully-covered-files false \
    --output-mode markdown \
    --markdown-mode dart \
    --fully-tested-message "All covered" \
    > missing_coverage.md
  pr_cov_exit=$?
  set -e

  if [ $pr_cov_exit -ne 0 ]; then
    if grep -q "MISSING TEST" missing_coverage.md 2>/dev/null; then
      warn "Diff coverage below threshold (${MIN_DIFF_COVERAGE}%). See missing_coverage.md"
    else
      error "Tool likely failed (not just low coverage). Contents of missing_coverage.md may be incomplete."
    fi
  else
    success "missing_coverage.md written"
  fi
else
  error "pull_request_coverage tool not found in PATH. Skipping diff coverage markdown."
fi

success "Done."
