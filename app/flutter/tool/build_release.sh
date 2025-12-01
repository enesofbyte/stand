#!/usr/bin/env bash
set -euo pipefail

# Helper script to build signed release APK for local development.
# Expects the following environment variables:
#   KEYSTORE_PATH - path to the .jks file
#   KEYSTORE_PASSWORD
#   KEY_ALIAS
#   KEY_PASSWORD

if [ -z "${KEYSTORE_PATH:-}" ] || [ -z "${KEYSTORE_PASSWORD:-}" ] || [ -z "${KEY_ALIAS:-}" ] || [ -z "${KEY_PASSWORD:-}" ]; then
  echo "Please export KEYSTORE_PATH, KEYSTORE_PASSWORD, KEY_ALIAS, KEY_PASSWORD before running."
  exit 1
fi

pushd "$(dirname "$0")/.." >/dev/null

cat > android/key.properties <<EOF
storePassword=$KEYSTORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=$KEYSTORE_PATH
EOF

flutter pub get
flutter build apk --release

echo "Release apk built: build/app/outputs/flutter-apk/app-release.apk"
popd >/dev/null
