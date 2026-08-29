#!/usr/bin/env bash
# Proving command for the native iOS target.
# On a Mac with Xcode 26: this is xcodebuild.
# On this Linux worker: xcodebuild is absent (exit 127). Logic tests run if swiftc exists.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROJ="$ROOT/ios/VellumPad/VellumPad.xcodeproj"

echo "PROVE command: xcodebuild -project ios/VellumPad/VellumPad.xcodeproj -scheme VellumPad -destination 'generic/platform=iOS' -configuration Debug build"
xcodebuild \
  -project "$PROJ" \
  -scheme VellumPad \
  -destination 'generic/platform=iOS' \
  -configuration Debug \
  build
XCODE_EXIT=$?
echo "xcodebuild_exit=${XCODE_EXIT}"

if command -v swiftc >/dev/null 2>&1; then
  echo "PROVE secondary: swiftc linux-hammer"
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
    echo "linux_hammer_exit=$?"
  fi
else
  echo "swiftc: command not found"
fi

exit "$XCODE_EXIT"
