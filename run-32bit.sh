#!/bin/bash

# Run script for JNI Architecture Mismatch Demo with 32-bit JVM
# This demonstrates SUCCESSFUL execution when architectures match

set -e

echo "=========================================="
echo "  Running with 32-bit JVM (Expected SUCCESS)"
echo "=========================================="
echo ""

# Check if build exists
if [ ! -f "dist/app-main.jar" ]; then
    echo "ERROR: Application not built. Run ./build.sh first."
    exit 1
fi

# Check for 32-bit JVM
if ! command -v java &> /dev/null; then
    echo "ERROR: java not found. Please install 32-bit JDK."
    exit 1
fi

# Set library path
NATIVE_LIB_PATH="build/native-lib/lib"
export LD_LIBRARY_PATH="$NATIVE_LIB_PATH:$LD_LIBRARY_PATH"
echo "Set LD_LIBRARY_PATH=$NATIVE_LIB_PATH"
echo ""

echo "Classpath:"
echo "  - dist/app-main.jar"
echo "  - dist/service-lib.jar"
echo "  - dist/native-lib.jar"
echo ""
echo "Native Library Path: $NATIVE_LIB_PATH"
echo ""
echo "=========================================="
echo ""

# Try to find 32-bit JVM
JAVA_32BIT=""

# Common locations for 32-bit JVM on Linux
POSSIBLE_PATHS=(
    "/usr/lib/jvm/java-17-openjdk-17.0.19.0.10-2.el9.i686/bin/java"
    "/usr/lib/jvm/java-11-openjdk-11.0.25.0.9-2.el9.i686/bin/java"
    "/usr/lib/jvm/java-8-openjdk-8.0.432.b06-2.el9.i686/bin/java"
    "/usr/lib/jvm/jre-1.8.0-openjdk.i686/bin/java"
    "/usr/lib/jvm/jre-11-openjdk.i686/bin/java"
    "/usr/lib/jvm/jre-17-openjdk.i686/bin/java"
)

for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -f "$path" ]; then
        JAVA_32BIT="$path"
        echo "Found 32-bit JVM: $JAVA_32BIT"
        break
    fi
done

if [ -z "$JAVA_32BIT" ]; then
    echo "ERROR: 32-bit JVM not found!"
    echo ""
    echo "Please install 32-bit JDK:"
    echo "  sudo yum install -y java-17-openjdk.i686"
    echo "  OR"
    echo "  sudo yum install -y java-11-openjdk.i686"
    echo ""
    echo "Then run this script again."
    exit 1
fi

# Verify it's actually 32-bit
ARCH=$("$JAVA_32BIT" -version 2>&1 | grep -i "32-bit\|i386\|i686" || echo "")
if [ -z "$ARCH" ]; then
    echo "WARNING: Could not verify JVM is 32-bit"
    echo "Attempting to run anyway..."
    echo ""
fi

# Run the application with 32-bit JVM
"$JAVA_32BIT" -Djava.library.path="$NATIVE_LIB_PATH" \
     -cp "dist/app-main.jar:dist/service-lib.jar:dist/native-lib.jar" \
     com.example.app.MainApp

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo "=========================================="
    echo "  SUCCESS! Application ran successfully"
    echo "=========================================="
    echo ""
    echo "This proves:"
    echo "  ✓ 32-bit JVM can load 32-bit native library"
    echo "  ✓ JNI works when architectures match"
    echo "  ✓ Native code executed correctly"
    echo ""
else
    echo "Application exited with error (exit code: $EXIT_CODE)"
fi

exit $EXIT_CODE

# Made with Bob
