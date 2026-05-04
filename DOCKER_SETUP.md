# Docker Setup Instructions

## Issue: Docker Daemon Not Running

If you see this error:
```
Cannot connect to the Docker daemon at unix:///Users/dhruv_insights/.colima/default/docker.sock. Is the docker daemon running?
```

This means Docker is not running on your system.

## Solutions

### Option 1: Start Colima (Recommended for macOS)

You're using Colima as your Docker runtime. Start it with:

```bash
# Start Colima
colima start

# Verify it's running
docker ps
```

### Option 2: Use Docker Desktop

If you prefer Docker Desktop:

1. Install Docker Desktop from: https://www.docker.com/products/docker-desktop
2. Start Docker Desktop application
3. Wait for it to fully start (whale icon in menu bar should be steady)
4. Verify: `docker ps`

### Option 3: Test Without Docker

You can test the project locally without Docker:

```bash
# Build the project
./build.sh

# Run with your system's JVM
./run.sh
```

**Note:** This will use your system's default JVM. On most modern systems, this is 64-bit, so you'll see the expected failure demonstrating the architecture mismatch.

## After Starting Docker

Once Docker is running, you can use the Docker testing:

```bash
# Run automated tests
./test-docker.sh

# Or manually
docker build -f Dockerfile.64bit -t jni-mismatch-demo:64bit .
docker run --rm jni-mismatch-demo:64bit

docker build -f Dockerfile.32bit -t jni-mismatch-demo:32bit .
docker run --rm jni-mismatch-demo:32bit
```

## Verifying Docker is Running

```bash
# Check Docker version
docker --version

# Check if daemon is running
docker ps

# Check Colima status (if using Colima)
colima status