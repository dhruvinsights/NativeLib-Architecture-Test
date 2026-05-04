# Running on Linux (Fyre Machine)

## Prerequisites

Your Linux machine needs:
- JDK 8 or higher
- GCC with 32-bit support (`gcc-multilib`)
- Make

## Setup Instructions

### 1. Transfer Project to Linux Machine

```bash
# On your Mac, create a tarball
tar -czf NativeLib-Architecture-Test.tar.gz NativeLib-Architecture-Test/

# Transfer to Linux (replace with your details)
scp NativeLib-Architecture-Test.tar.gz user@fyre-machine:/path/to/destination/

# On Linux machine, extract
tar -xzf NativeLib-Architecture-Test.tar.gz
cd NativeLib-Architecture-Test
```

### 2. Install Dependencies

```bash
# For Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk gcc-multilib g++-multilib make

# For RHEL/CentOS/Fedora
sudo yum install -y java-17-openjdk-devel gcc gcc-c++ glibc-devel.i686 libgcc.i686

# Verify installations
java -version
gcc --version
```

### 3. Build the Project

```bash
# Make scripts executable
chmod +x build.sh run.sh

# Build everything
./build.sh
```

**Expected Output:**
```
==========================================
  Building JNI Architecture Mismatch Demo
==========================================

Detected OS: Linux

...

✓ 32-bit native library compiled: build/native-lib/lib/libnativemath.so
```

### 4. Run the Application

```bash
# This will use your system's default JVM (likely 64-bit)
./run.sh
```

**Expected Result on 64-bit JVM:**
```
==========================================
  FAILURE: Native Library Load Error
==========================================

Error Message: Can't load IA 32-bit .so on a AMD 64-bit platform

CAUSE: Architecture Mismatch!
The JVM is 64-bit, but the native library is 32-bit.
```

### 5. Verify the Native Library Architecture

```bash
# Check the native library file
file build/native-lib/lib/libnativemath.so

# Should show: ELF 32-bit LSB shared object, Intel 80386
```

### 6. Test with 32-bit JVM (Optional)

If you have a 32-bit JVM installed:

```bash
# Find 32-bit JVM
update-alternatives --list java

# Run with 32-bit JVM
/path/to/32bit/java -Djava.library.path=build/native-lib/lib \
  -cp build/dist/app-main.jar:build/dist/service-lib.jar:build/dist/native-lib.jar \
  com.example.app.MainApp
```

**Expected Result on 32-bit JVM:**
```
==========================================
  RESULT: 15 + 27 = 42
==========================================

SUCCESS: Application completed successfully!
```

## Troubleshooting

### Error: "gcc: error: unrecognized command line option '-m32'"

**Solution:** Install 32-bit development libraries
```bash
# Ubuntu/Debian
sudo apt-get install gcc-multilib g++-multilib

# RHEL/CentOS
sudo yum install glibc-devel.i686 libgcc.i686
```

### Error: "Cannot find JNI headers"

**Solution:** Set JAVA_HOME
```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
```

### Error: "Library not found at runtime"

**Solution:** Set library path
```bash
export LD_LIBRARY_PATH=build/native-lib/lib:$LD_LIBRARY_PATH
./run.sh
```

## What You'll See

On a Linux x86_64 system with proper 32-bit support:

1. **Build succeeds** - Creates actual 32-bit `.so` file
2. **64-bit JVM fails** - Cannot load 32-bit library (demonstrates the issue)
3. **32-bit JVM succeeds** - Loads 32-bit library correctly (if available)

This is the **real demonstration** of JNI architecture mismatch!