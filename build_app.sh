#!/bin/bash
set -a
[ -f .env ] && . .env
set +a

# Optional version bump prompt
read -p "Do you want to bump the app version before building? (y/n) [n]: " BUMP_VERSION
if [[ "$BUMP_VERSION" =~ ^[Yy]$ ]]; then
  read -p "Which part? (major/minor/patch/build) [build]: " BUMP_TARGET
  BUMP_TARGET=${BUMP_TARGET:-build}
  dart run tool/bump_version.dart "$BUMP_TARGET"
  echo ""
fi

# If an argument is provided, use it. Otherwise, prompt the user.
if [ -n "$1" ]; then
  BUILD_TARGET=$1
else
  read -p "Enter build target (bundle/split/apk) [bundle]: " BUILD_TARGET
  BUILD_TARGET=${BUILD_TARGET:-bundle}
fi

echo "Starting Flutter release build for target: $BUILD_TARGET"

case "$BUILD_TARGET" in
  bundle)
    flutter build appbundle --release
    ;;
  split)
    flutter build apk --split-per-abi --release
    ;;
  apk)
    flutter build apk --release
    ;;
  *)
    echo "Unknown target: $BUILD_TARGET"
    echo "Options: bundle, split, apk"
    echo "Example: ./build_app.sh split"
    exit 1
    ;;
esac

if [ $? -eq 0 ]; then
  echo -e "\n✅ Build completed successfully."
else
  echo -e "\n❌ Build failed."
  exit 1
fi
