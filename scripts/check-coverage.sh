#!/usr/bin/env bash
# Simplified coverage script
# 1. Run flutter tests with coverage (generates coverage/lcov.info)
# 2. Pipe diff vs origin/main into pull_request_coverage to produce pull_request_coverage.md
# If pull_request_coverage tool is missing, a warning is shown and exit code remains 0.

set -euo pipefail

echo "==> Running flutter tests with coverage"
flutter test --coverage

echo "==> Generating pull request diff coverage (origin/main)"
if command -v pull_request_coverage >/dev/null 2>&1; then
  git diff origin/main | pull_request_coverage \
    --minimum-coverage 100 \
    --report-fully-covered-files false \
    --output-mode markdown \
    --markdown-mode dart \
    --fully-tested-message "All covered" \
    > missing_coverage.md || echo "WARNING: pull_request_coverage tool failed" >&2
  echo "missing_coverage.md written"
else
  echo "WARNING: pull_request_coverage tool not found in PATH. Skipping diff coverage markdown." >&2
fi

echo "Done."
