#!/bin/bash

# Run with 32-bit JVM using Docker
# This demonstrates SUCCESSFUL execution when architectures match

echo "=========================================="
echo "  Running with 32-bit JVM via Docker"
echo "=========================================="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker not found. Please install Docker."
    exit 1
fi

# Check if build exists
if [ ! -f "dist/app-main.jar" ]; then
    echo "ERROR: Application not built. Run ./build.sh first."
    exit 1
fi

echo "Building 32-bit Docker image..."
docker build -f Dockerfile.32bit -t jni-demo-32bit .

if [ $? -ne 0 ]; then
    echo "ERROR: Docker build failed"
    exit 1
fi

echo ""
echo "Running application in 32-bit container..."
echo "=========================================="
echo ""

docker run --rm jni-demo-32bit

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
