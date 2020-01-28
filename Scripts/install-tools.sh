#!/bin/sh

### Installation script for Parrot ###

PROJECT_NAME=$(basename $PWD)

# Directories
PROJECT_DIR=$(xcodebuild -project $PROJECT_NAME.xcodeproj -showBuildSettings | grep PROJECT_DIR | sed -e 's/PROJECT_DIR = //' | sed -e 's/ //g')
TMP_DIR="$PROJECT_DIR/.tmp" # Temp directory to be used during installation
TOOLS_DIR="$PROJECT_DIR/Tools"

# Githib repos
PARROT_REPO="https://github.com/MonsantoCo/Parrot.git"

# Parrot files
PARROT_XCODEPROJ_FILE="$TMP_DIR/Parrot.xcodeproj"
PARROT_PBX_FILE="$TMP_DIR/Parrot.xcodeproj/project.pbxproj"
PARROT_RELEASE_BINARY="$TMP_DIR/build/Release/Parrot"

# Development team necessary for code-signing
DEVELOPMENT_TEAM=$(xcodebuild -project $PROJECT_NAME.xcodeproj -showBuildSettings | grep DEVELOPMENT_TEAM | sed -e 's/DEVELOPMENT_TEAM = //' | sed -e 's/ //g')

# Script clean up
function cleanupAndExit {
    rm -rf "$TMP_DIR"
    exit $1
}

# Handle ctrl^C
trap "cleanupAndExit 1" SIGINT

# Setup directories
function createDirectories {
    mkdir -p "$TOOLS_DIR"
    chflags hidden "$TOOLS_DIR"
    mkdir -p "$TMP_DIR"
}

function installParrot {
    echo "Starting Parrot installation..."

    # Clone Parrot into the TMP_DIR
    echo "Fetching Parrot from the latest master branch...\n"
    git clone --single-branch --branch master "$PARROT_REPO" "$TMP_DIR" || cleanupAndExit 1

    # Add the signing profile
    sed -i '' "s/DEVELOPMENT_TEAM = \"\";/DEVELOPMENT_TEAM = \"$DEVELOPMENT_TEAM\";/g" "$PARROT_PBX_FILE"

    # Build the Parrot Xcode project and then copy the binary to the bin directory
    echo "\nBuilding Parrot..."
    xcodebuild -project $PARROT_XCODEPROJ_FILE -quiet || cleanupAndExit 1

    # Copy binary to TOOLS_DIR
    cp "$PARROT_RELEASE_BINARY" "$TOOLS_DIR"

    echo "Parrot build complete. Binary located at $TOOLS_DIR/Parrot"
}

# Program flow
createDirectories
installParrot
cleanupAndExit 0
