#!/usr/bin/env bash
# Simplified coverage script
# 1. Run flutter tests with coverage (generates coverage/lcov.info)
# 2. Pipe diff vs origin/main into pull_request_coverage to produce pull_request_coverage.md
# If pull_request_coverage tool is missing, a warning is shown and exit code remains 0.

set -euo pipefail

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

step "Running flutter tests with coverage"
flutter test --coverage

step "Generating pull request diff coverage (origin/main)"
if command -v pull_request_coverage >/dev/null 2>&1; then
  # Allow caller to override threshold; default 100 to keep strictness unless relaxed explicitly.
  : "${MIN_DIFF_COVERAGE:=100}"

  # We want to always write a markdown file even on failure, without aborting script earlier.
  set +e
  tmp_report=$(mktemp)
  git diff origin/main | pull_request_coverage \
    --minimum-coverage "${MIN_DIFF_COVERAGE}" \
    --report-fully-covered-files false \
    --output-mode markdown \
    --markdown-mode dart \
    --fully-tested-message "All covered" \
    > "${tmp_report}"
  pr_cov_exit=$?
  # Only persist file if it actually contains uncovered markers
  if grep -q "MISSING TEST" "${tmp_report}" 2>/dev/null; then
    mv "${tmp_report}" missing_coverage.md
  else
    rm -f "${tmp_report}" || true
  fi
  set -e

  if [ $pr_cov_exit -ne 0 ]; then
    if [ -f missing_coverage.md ]; then
      info "Diff coverage below threshold (${MIN_DIFF_COVERAGE}%). See missing_coverage.md"
    else
      error "Diff coverage tool failed unexpectedly (no missing_coverage.md). Failing build.";
      exit 1
    fi
  else
    if [ -f missing_coverage.md ]; then
      success "missing_coverage.md written (uncovered lines present)"
    else
      success "All new/changed lines covered; no missing_coverage.md generated."
    fi
  fi
else
  warn "pull_request_coverage tool not found in PATH. Skipping diff coverage markdown."
fi

success "Done."
