#!/usr/bin/env bash
set -euo pipefail

# Go Mailer multi-platform release helper
# Performs pre-flight checks and prints publish commands.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Pre-flight: version alignment"
FLUTTER_VER=$(grep '^version:' sdk/flutter/pubspec.yaml | awk '{print $2}')
ANDROID_VER=$(grep 'versionName' sdk/android/go-mailer/go-mailer/build.gradle | sed -E 's/.*versionName "([^"]+)".*/\1/')
IOS_VER=$(grep 'spec.version' sdk/ios/GoMailerPushSDK.podspec | sed -E 's/.*= "([^"]+)"/\1/')
RN_VER=$(grep '"version":' sdk/react-native/package.json | head -1 | sed -E 's/.*"([0-9\.]+)".*/\1/')
DART_CONST=$(grep "static const String version" sdk/flutter/lib/go_mailer.dart | sed -E "s/.*'([0-9\.]+)'.*/\1/")

FAIL=0
for pair in \
  "Flutter pubspec=$FLUTTER_VER" \
  "Android versionName=$ANDROID_VER" \
  "iOS podspec=$IOS_VER" \
  "ReactNative package.json=$RN_VER" \
  "DartConst=$DART_CONST"; do
  echo "  $pair"
done

REF="$FLUTTER_VER"
for v in "$ANDROID_VER" "$IOS_VER" "$RN_VER" "$DART_CONST"; do
  if [[ "$v" != "$REF" ]]; then
    echo "Version mismatch: expected $REF, found $v" >&2
    FAIL=1
  fi
done

if [[ $FAIL -eq 1 ]]; then
  echo "✖ Version alignment failed. Abort." >&2
  exit 1
fi

echo "==> Checking working tree cleanliness (excluding ignored files)"
if [[ -n $(git status --porcelain | grep -v '^?? scripts/release.sh') ]]; then
  echo "Working tree not clean. Commit or stash changes first." >&2
  git status --short
  exit 1
fi

echo "==> Running Flutter unit tests"
( cd sdk/flutter && flutter test )

echo "==> Summary"
echo "Version: $REF"
echo "All checks passed. Next manual steps:" 
cat <<EOF

Publish order suggestions:
  1. Git tag & push:
     git tag -a v$REF -m "Go Mailer SDK $REF" && git push origin v$REF
  2. Flutter:
     (cd sdk/flutter && dart pub publish)
  3. iOS:
     (cd sdk/ios && pod lib lint GoMailerPushSDK.podspec --allow-warnings && pod trunk push GoMailerPushSDK.podspec)
  4. Android:
     (cd sdk/android/go-mailer && ./gradlew publishReleasePublicationToMavenCentralRepository)
  5. React Native (npm):
     (cd sdk/react-native && npm publish --access public)

After propagation, verify:
  - pub.dev shows $REF
  - CocoaPods search includes $REF
  - Maven Central artifact com.gomailer:go-mailer:$REF visible
  - npm view go-mailer version returns $REF
EOF
