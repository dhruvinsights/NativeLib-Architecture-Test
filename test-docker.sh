#!/bin/bash

# Docker testing script for JNI Architecture Mismatch Demo

set -e

echo "=========================================="
echo "  JNI Architecture Mismatch - Docker Test"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed."
    echo "Please install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "ERROR: Docker Compose is not installed."
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "Docker and Docker Compose are installed."
echo ""

# Build the project locally first
echo "=========================================="
echo "Step 1: Building project locally"
echo "=========================================="
if [ ! -f "build.sh" ]; then
    echo "ERROR: build.sh not found"
    exit 1
fi

chmod +x build.sh
./build.sh

if [ $? -ne 0 ]; then
    echo "ERROR: Local build failed"
    exit 1
fi
echo ""

# Build Docker images
echo "=========================================="
echo "Step 2: Building Docker images"
echo "=========================================="
echo ""

echo "Building 64-bit JVM image (will compile 32-bit native library)..."
docker build -f Dockerfile.64bit -t jni-mismatch-demo:64bit .
echo ""

echo "Note: Both containers use 64-bit JVM"
echo "The difference is in the native library architecture"
echo ""

# Test with 64-bit JVM + 32-bit library (Expected to FAIL)
echo "=========================================="
echo "Step 3: Testing 64-bit JVM with 32-bit Library"
echo "=========================================="
echo "Expected Result: FAILURE (UnsatisfiedLinkError)"
echo ""

docker run --rm jni-mismatch-demo:64bit || echo ""
echo ""
echo "Test completed (failure is expected - architecture mismatch)"
echo ""

# Summary
echo "=========================================="
echo "  Test Summary"
echo "=========================================="
echo ""
echo "✓ 64-bit JVM with 32-bit library: Should have FAILED with UnsatisfiedLinkError"
echo ""
echo "This demonstrates that:"
echo "  - A 64-bit JVM cannot load a 32-bit native library"
echo "  - The error occurs at runtime when System.loadLibrary() is called"
echo "  - This is an architecture mismatch enforced by the operating system"
echo ""
echo "=========================================="

# Made with Bob
