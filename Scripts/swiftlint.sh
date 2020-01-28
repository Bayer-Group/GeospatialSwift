#!/bin/sh

if which swiftlint >/dev/null; then
swiftlint
#echo "⚠️ warning: SwiftLint turned off"
else
echo "⚠️ warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi
