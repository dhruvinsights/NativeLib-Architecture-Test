#!/bin/bash

# Build script for JNI Architecture Mismatch Demo
# This script builds all three modules and the 32-bit native library

set -e  # Exit on error

echo "=========================================="
echo "  Building JNI Architecture Mismatch Demo"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect OS
OS_TYPE=$(uname -s)
echo "Detected OS: $OS_TYPE"
echo ""

# Check for Java compiler
if ! command -v javac &> /dev/null; then
    echo -e "${RED}ERROR: javac not found. Please install JDK.${NC}"
    exit 1
fi

# Check for GCC
if ! command -v gcc &> /dev/null; then
    echo -e "${RED}ERROR: gcc not found. Please install GCC.${NC}"
    exit 1
fi

# Create output directories
echo "Creating output directories..."
mkdir -p build/native-lib/classes
mkdir -p build/service-lib/classes
mkdir -p build/app-main/classes
mkdir -p build/native-lib/lib
mkdir -p dist
echo ""

# Step 1: Compile native-lib Java code
echo "=========================================="
echo "Step 1: Compiling native-lib Java code"
echo "=========================================="
javac -d build/native-lib/classes \
    native-lib/src/main/java/com/example/nativelib/NativeMath.java

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ native-lib Java compilation successful${NC}"
else
    echo -e "${RED}✗ native-lib Java compilation failed${NC}"
    exit 1
fi
echo ""

# Step 2: Generate JNI header (if needed)
echo "=========================================="
echo "Step 2: Generating JNI header"
echo "=========================================="
echo "Using pre-generated header: native-lib/src/main/native/com_example_nativelib_NativeMath.h"
echo ""

# Step 3: Compile native library as 32-bit
echo "=========================================="
echo "Step 3: Compiling 32-bit native library"
echo "=========================================="
echo -e "${YELLOW}IMPORTANT: Compiling as 32-bit ONLY${NC}"
echo ""

# Get Java include paths
if [ -n "$JAVA_HOME" ]; then
    JAVA_HOME_PATH="$JAVA_HOME"
else
    # Try to find JAVA_HOME from javac location
    JAVAC_PATH=$(which javac)
    if [ -n "$JAVAC_PATH" ]; then
        # On macOS, javac might be a wrapper, use java_home command
        if command -v /usr/libexec/java_home &> /dev/null; then
            JAVA_HOME_PATH=$(/usr/libexec/java_home)
        else
            # Fallback: try to resolve from javac path
            JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f "$JAVAC_PATH" 2>/dev/null || echo "$JAVAC_PATH")))
        fi
    fi
fi

echo "Java Home: $JAVA_HOME_PATH"

# Verify JNI headers exist
if [ ! -f "$JAVA_HOME_PATH/include/jni.h" ]; then
    echo -e "${RED}ERROR: Cannot find jni.h in $JAVA_HOME_PATH/include${NC}"
    echo "Please set JAVA_HOME to your JDK installation directory"
    echo "Example: export JAVA_HOME=\$(/usr/libexec/java_home)"
    exit 1
fi

if [ "$OS_TYPE" = "Linux" ]; then
    echo "Compiling for Linux (32-bit)..."
    
    # Check if 32-bit development libraries are installed
    if ! gcc -m32 -v &> /dev/null; then
        echo -e "${RED}ERROR: 32-bit compilation not supported.${NC}"
        echo "Install 32-bit development libraries:"
        echo "  Ubuntu/Debian: sudo apt-get install gcc-multilib"
        echo "  Fedora/RHEL: sudo yum install glibc-devel.i686"
        exit 1
    fi
    
    gcc -m32 -shared -fPIC \
        -I"$JAVA_HOME_PATH/include" \
        -I"$JAVA_HOME_PATH/include/linux" \
        -I"native-lib/src/main/native" \
        native-lib/src/main/native/nativemath.c \
        -o build/native-lib/lib/libnativemath.so
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 32-bit native library compiled: build/native-lib/lib/libnativemath.so${NC}"
        file build/native-lib/lib/libnativemath.so
    else
        echo -e "${RED}✗ Native library compilation failed${NC}"
        exit 1
    fi
    
elif [ "$OS_TYPE" = "Darwin" ]; then
    echo "Compiling for macOS..."
    echo -e "${YELLOW}WARNING: Modern macOS (especially Apple Silicon) does not support 32-bit compilation${NC}"
    echo -e "${YELLOW}Building as 64-bit for demonstration purposes${NC}"
    echo ""
    echo "To properly test 32-bit vs 64-bit mismatch, use Docker:"
    echo "  colima start"
    echo "  ./test-docker.sh"
    echo ""
    
    # Detect architecture
    ARCH=$(uname -m)
    if [ "$ARCH" = "arm64" ]; then
        echo "Detected Apple Silicon (ARM64)"
        echo "Building native library for ARM64..."
        gcc -dynamiclib \
            -I"$JAVA_HOME_PATH/include" \
            -I"$JAVA_HOME_PATH/include/darwin" \
            -I"native-lib/src/main/native" \
            native-lib/src/main/native/nativemath.c \
            -o build/native-lib/lib/libnativemath.dylib
    else
        echo "Detected Intel Mac (x86_64)"
        echo "Attempting 32-bit compilation (may fail on modern macOS)..."
        gcc -m32 -dynamiclib \
            -I"$JAVA_HOME_PATH/include" \
            -I"$JAVA_HOME_PATH/include/darwin" \
            -I"native-lib/src/main/native" \
            native-lib/src/main/native/nativemath.c \
            -o build/native-lib/lib/libnativemath.dylib 2>/dev/null
        
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}32-bit compilation failed (expected on modern macOS)${NC}"
            echo "Falling back to 64-bit compilation for demonstration..."
            gcc -dynamiclib \
                -I"$JAVA_HOME_PATH/include" \
                -I"$JAVA_HOME_PATH/include/darwin" \
                -I"native-lib/src/main/native" \
                native-lib/src/main/native/nativemath.c \
                -o build/native-lib/lib/libnativemath.dylib
        fi
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Native library compiled: build/native-lib/lib/libnativemath.dylib${NC}"
        file build/native-lib/lib/libnativemath.dylib
        echo ""
        echo -e "${YELLOW}NOTE: On macOS, this built a 64-bit library (32-bit not supported)${NC}"
        echo -e "${YELLOW}The application will run successfully, but won't demonstrate the mismatch${NC}"
        echo -e "${YELLOW}Use Docker to see the actual 32-bit vs 64-bit failure${NC}"
    else
        echo -e "${RED}✗ Native library compilation failed${NC}"
        exit 1
    fi
else
    echo -e "${RED}ERROR: Unsupported OS: $OS_TYPE${NC}"
    echo "For Windows, use build.bat instead"
    exit 1
fi
echo ""

# Step 4: Create native-lib JAR
echo "=========================================="
echo "Step 4: Creating native-lib JAR"
echo "=========================================="
cd build/native-lib/classes
jar cf ../../dist/native-lib.jar com/example/nativelib/*.class
cd ../../..
echo -e "${GREEN}✓ Created: dist/native-lib.jar${NC}"
echo ""

# Step 5: Compile service-lib
echo "=========================================="
echo "Step 5: Compiling service-lib"
echo "=========================================="
javac -cp build/dist/native-lib.jar \
    -d build/service-lib/classes \
    service-lib/src/main/java/com/example/service/MathService.java

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ service-lib compilation successful${NC}"
else
    echo -e "${RED}✗ service-lib compilation failed${NC}"
    exit 1
fi

cd build/service-lib/classes
jar cf ../../dist/service-lib.jar com/example/service/*.class
cd ../../..
echo -e "${GREEN}✓ Created: dist/service-lib.jar${NC}"
echo ""

# Step 6: Compile app-main
echo "=========================================="
echo "Step 6: Compiling app-main"
echo "=========================================="
javac -cp build/dist/native-lib.jar:build/dist/service-lib.jar \
    -d build/app-main/classes \
    app-main/src/main/java/com/example/app/MainApp.java

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ app-main compilation successful${NC}"
else
    echo -e "${RED}✗ app-main compilation failed${NC}"
    exit 1
fi

cd build/app-main/classes
jar cfe ../../dist/app-main.jar com.example.app.MainApp com/example/app/*.class
cd ../../..
echo -e "${GREEN}✓ Created: dist/app-main.jar${NC}"
echo ""

# Summary
echo "=========================================="
echo "  Build Complete!"
echo "=========================================="
echo ""
echo "Output files:"
echo "  - build/dist/native-lib.jar"
echo "  - build/dist/service-lib.jar"
echo "  - build/dist/app-main.jar"
echo "  - build/native-lib/lib/libnativemath.so (32-bit)"
echo ""
echo "To run the application:"
echo "  ./run.sh"
echo ""

# Made with Bob
