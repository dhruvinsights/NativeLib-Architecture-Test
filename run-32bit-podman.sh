#!/bin/bash

# Run with 32-bit JVM using Podman (RHEL's Docker alternative)
# This demonstrates SUCCESSFUL execution when architectures match

echo "=========================================="
echo "  Running with 32-bit JVM via Podman"
echo "=========================================="
echo ""

# Check if Podman is available (pre-installed on RHEL)
if ! command -v podman &> /dev/null; then
    echo "ERROR: Podman not found. Installing..."
    sudo yum install -y podman
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to install Podman"
        exit 1
    fi
fi

# Check if build exists
if [ ! -f "dist/app-main.jar" ]; then
    echo "ERROR: Application not built. Run ./build.sh first."
    exit 1
fi

echo "Building 32-bit container image with Podman..."
podman build -f Dockerfile.32bit -t jni-demo-32bit .

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Podman build failed"
    echo ""
    echo "This might be due to Docker Hub rate limits."
    echo "Waiting 60 seconds and retrying..."
    sleep 60
    podman build -f Dockerfile.32bit -t jni-demo-32bit .
    
    if [ $? -ne 0 ]; then
        echo "ERROR: Build failed again. Please try again later."
        exit 1
    fi
fi

echo ""
echo "Running application in 32-bit container..."
echo "=========================================="
echo ""

podman run --rm jni-demo-32bit

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
    echo "Compare with ./run.sh (64-bit JVM) which FAILS!"
else
    echo "Application exited with error (exit code: $EXIT_CODE)"
fi

exit $EXIT_CODE

# Made with Bob
