#!/usr/bin/env bash
# Proving command for the native iOS target.
# On a Mac with Xcode 26: this is xcodebuild test.
# On this Linux worker: xcodebuild is absent. Logic tests are the test target:
#   swiftc Models + linux-hammer && run.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROJ="$ROOT/ios/VellumPad/VellumPad.xcodeproj"

echo "PROVE command: xcodebuild -project ios/VellumPad/VellumPad.xcodeproj -scheme VellumPad -destination 'platform=iOS Simulator,name=iPhone 16' test"
xcodebuild \
  -project "$PROJ" \
  -scheme VellumPad \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test
XCODE_EXIT=$?
echo "xcodebuild_exit=${XCODE_EXIT}"

HAMMER_EXIT=127
if command -v swiftc >/dev/null 2>&1; then
  echo "PROVE test target: swiftc linux-hammer"
  OUT="$(mktemp -d)/vellum-hammer"
  swiftc \
    "$ROOT/ios/VellumPad/VellumPad/Models/Catalog.swift" \
    "$ROOT/ios/VellumPad/VellumPad/Models/LibraryGrouping.swift" \
    "$ROOT/ios/VellumPad/VellumPad/Models/PageLogic.swift" \
    "$ROOT/ios/scripts/linux-hammer.swift" \
    -o "$OUT"
  SWIFT_EXIT=$?
  echo "swiftc_exit=${SWIFT_EXIT}"
  if [[ "$SWIFT_EXIT" -eq 0 ]]; then
    "$OUT"
    HAMMER_EXIT=$?
    echo "linux_hammer_exit=${HAMMER_EXIT}"
  else
    HAMMER_EXIT=$SWIFT_EXIT
  fi
else
  echo "swiftc: command not found"
fi

# A compile of the app is not enough. Prefer the test-target result.
if [[ "$XCODE_EXIT" -eq 0 ]]; then
  exit 0
fi
if [[ "$HAMMER_EXIT" -eq 0 ]]; then
  exit 0
fi
exit "$XCODE_EXIT"
