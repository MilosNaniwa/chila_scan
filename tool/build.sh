#!/bin/sh

flutter clean

VERSION_CODE=$(expr $(date +%s) / 10)

flutter build ios --release --build-number=${VERSION_CODE}

#flutter build appbundle --release --build-number=${VERSION_CODE} --target-platform android-arm64
flutter build apk --release --build-number=${VERSION_CODE} --target-platform android-arm64

exit 0
