#!/bin/bash

# Run script for JNI Architecture Mismatch Demo

set -e

echo "=========================================="
echo "  Running JNI Architecture Mismatch Demo"
echo "=========================================="
echo ""

# Check if build exists
if [ ! -f "build/dist/app-main.jar" ]; then
    echo "ERROR: Application not built. Run ./build.sh first."
    exit 1
fi

# Detect OS and set library path
OS_TYPE=$(uname -s)
if [ "$OS_TYPE" = "Linux" ]; then
    NATIVE_LIB_PATH="build/native-lib/lib"
    export LD_LIBRARY_PATH="$NATIVE_LIB_PATH:$LD_LIBRARY_PATH"
    echo "Set LD_LIBRARY_PATH=$NATIVE_LIB_PATH"
elif [ "$OS_TYPE" = "Darwin" ]; then
    NATIVE_LIB_PATH="build/native-lib/lib"
    export DYLD_LIBRARY_PATH="$NATIVE_LIB_PATH:$DYLD_LIBRARY_PATH"
    echo "Set DYLD_LIBRARY_PATH=$NATIVE_LIB_PATH"
else
    echo "ERROR: Unsupported OS: $OS_TYPE"
    echo "For Windows, use run.bat instead"
    exit 1
fi

echo ""
echo "Classpath:"
echo "  - build/dist/app-main.jar"
echo "  - build/dist/service-lib.jar"
echo "  - build/dist/native-lib.jar"
echo ""
echo "Native Library Path: $NATIVE_LIB_PATH"
echo ""
echo "=========================================="
echo ""

# Run the application
java -Djava.library.path="$NATIVE_LIB_PATH" \
     -cp "build/dist/app-main.jar:build/dist/service-lib.jar:build/dist/native-lib.jar" \
     com.example.app.MainApp

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "Application exited successfully (exit code: 0)"
else
    echo "Application exited with error (exit code: $EXIT_CODE)"
fi

exit $EXIT_CODE

# Made with Bob
