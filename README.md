# JNI Architecture Mismatch Demo

This project demonstrates a **runtime failure** that occurs when a 64-bit JVM attempts to load a 32-bit native library through JNI (Java Native Interface).

## 🎯 Objective

Prove that:
> **A 64-bit JVM cannot load a 32-bit native library**

This results in the error:
```
java.lang.UnsatisfiedLinkError: Can't load IA 32-bit .dll on a AMD 64-bit platform
```

## 🐳 Quick Start with Docker

The easiest way to test both scenarios is using Docker:

```bash
# Run automated tests for both 32-bit and 64-bit JVMs
./test-docker.sh
```

Or test individually:

```bash
# Test with 64-bit JVM (will FAIL)
docker build -f Dockerfile.64bit -t jni-mismatch-demo:64bit .
docker run --rm jni-mismatch-demo:64bit

# Test with 32-bit JVM (will SUCCEED)
docker build -f Dockerfile.32bit -t jni-mismatch-demo:32bit .
docker run --rm jni-mismatch-demo:32bit
```

Using Docker Compose:
```bash
# Test 64-bit JVM
docker-compose run --rm test-64bit

# Test 32-bit JVM
docker-compose run --rm test-32bit
```

---

## 📁 Project Structure

This is a multi-module Java project with three modules:

```
NativeLib-Architecture-Test/
├── native-lib/          # Module 1: JNI native library wrapper
│   ├── src/main/java/com/example/native/
│   │   └── NativeMath.java
│   └── src/main/native/
│       ├── nativemath.c
│       └── com_example_native_NativeMath.h
│
├── service-lib/         # Module 2: Service layer
│   └── src/main/java/com/example/service/
│       └── MathService.java
│
├── app-main/            # Module 3: Application entry point
│   └── src/main/java/com/example/app/
│       └── MainApp.java
│
├── build.sh             # Build script for Linux/macOS
├── build.bat            # Build script for Windows
├── run.sh               # Run script for Linux/macOS
└── run.bat              # Run script for Windows
```

### Dependency Chain

```
app-main → service-lib → native-lib → libnativemath.so (32-bit)
```

---

## 🔧 Module Details

### Module 1: native-lib

**Purpose:** JNI wrapper for native code

**Java Class:** [`NativeMath.java`](native-lib/src/main/java/com/example/nativelib/NativeMath.java)
- Package: `com.example.nativelib`
- Loads native library: `System.loadLibrary("nativemath")`
- Native method: `public native int add(int a, int b)`

**Native Code:** [`nativemath.c`](native-lib/src/main/native/nativemath.c)
- Implements: `Java_com_example_native_NativeMath_add`
- Returns sum of two integers
- **CRITICAL:** Compiled as **32-bit ONLY**

### Module 2: service-lib

**Purpose:** Service layer that uses native functionality

**Java Class:** [`MathService.java`](service-lib/src/main/java/com/example/service/MathService.java)
- Package: `com.example.service`
- Uses `NativeMath` internally
- Method: `public int computeSum(int a, int b)`

### Module 3: app-main

**Purpose:** Application entry point

**Java Class:** [`MainApp.java`](app-main/src/main/java/com/example/app/MainApp.java)
- Package: `com.example.app`
- Calls `MathService`
- Prints JVM architecture information
- Handles `UnsatisfiedLinkError` gracefully

---

## 🏗️ Building the Project

### Prerequisites

- **JDK 8 or higher**
- **C Compiler:**
  - Linux: GCC with 32-bit support (`gcc-multilib`)
  - macOS: Xcode Command Line Tools
  - Windows: Visual Studio (x86 tools) or MinGW (32-bit)

### Linux/macOS

```bash
# Install 32-bit development libraries (Ubuntu/Debian)
sudo apt-get install gcc-multilib

# Build the project
chmod +x build.sh
./build.sh
```

### Windows

```cmd
REM Use Visual Studio x86 Native Tools Command Prompt
REM OR ensure 32-bit MinGW is in PATH

build.bat
```

### Build Output

After successful build:
```
build/
├── dist/
│   ├── native-lib.jar
│   ├── service-lib.jar
│   └── app-main.jar
└── native-lib/lib/
    └── libnativemath.so (32-bit)  # or nativemath.dll on Windows
```

---

## 🚀 Running the Application

### Linux/macOS

```bash
chmod +x run.sh
./run.sh
```

### Windows

```cmd
run.bat
```

---

## 📊 Expected Behavior

### Scenario 1: 32-bit JVM ✅ SUCCESS

**Command:**
```bash
# Use 32-bit JVM
/path/to/32bit/java -jar build/dist/app-main.jar
```

**Expected Output:**
```
==========================================
  JNI Architecture Mismatch Demo
==========================================

JVM Information:
  Java Version: 1.8.0_xxx
  OS Architecture: x86
  JVM Architecture: 32-bit

=== JNI Library Loading ===
JVM Architecture: x86
Attempting to load 'nativemath' library...
SUCCESS: Native library loaded successfully!

[MathService] Initializing service...
[MathService] computeSum(15, 27) called
[Native Code] add(15, 27) called
[Native Code] This is a 32-bit native library
[Native Code] Returning: 42

==========================================
  RESULT: 15 + 27 = 42
==========================================

SUCCESS: Application completed successfully!
```

### Scenario 2: 64-bit JVM ❌ FAILURE

**Command:**
```bash
# Use 64-bit JVM (default on most systems)
java -jar build/dist/app-main.jar
```

**Expected Output:**
```
==========================================
  JNI Architecture Mismatch Demo
==========================================

JVM Information:
  Java Version: 1.8.0_xxx
  OS Architecture: amd64
  JVM Architecture: 64-bit

  WARNING: Running on 64-bit JVM!
  This will FAIL to load the 32-bit native library.

=== JNI Library Loading ===
JVM Architecture: amd64
Attempting to load 'nativemath' library...
FAILED: Could not load native library!

==========================================
  FAILURE: Native Library Load Error
==========================================

Error Message: Can't load IA 32-bit .dll on a AMD 64-bit platform

CAUSE: Architecture Mismatch!
The JVM is 64-bit, but the native library is 32-bit.
A 64-bit JVM cannot load a 32-bit native library.

SOLUTION: Run with a 32-bit JVM to match the 32-bit native library.
==========================================
```

---

## 🔍 Why This Happens

### The Root Cause: JNI Architecture Constraint

JNI (Java Native Interface) requires **exact architecture matching** between:
1. The JVM process architecture (32-bit or 64-bit)
2. The native library architecture (32-bit or 64-bit)

### Technical Explanation

1. **Memory Address Space:**
   - 32-bit processes use 32-bit pointers (4 bytes)
   - 64-bit processes use 64-bit pointers (8 bytes)
   - These are fundamentally incompatible

2. **Calling Conventions:**
   - Different register usage
   - Different stack alignment
   - Different parameter passing mechanisms

3. **Binary Format:**
   - 32-bit: ELF32 (Linux), PE32 (Windows), Mach-O 32-bit (macOS)
   - 64-bit: ELF64 (Linux), PE32+ (Windows), Mach-O 64-bit (macOS)

4. **Operating System Loader:**
   - The OS loader cannot load a 32-bit shared library into a 64-bit process
   - This is enforced at the OS level, not just by Java

### Why It Works on 32-bit JVM

When running on a 32-bit JVM:
- JVM process is 32-bit
- Native library is 32-bit
- ✅ Architecture match → successful load

### Why It Fails on 64-bit JVM

When running on a 64-bit JVM:
- JVM process is 64-bit
- Native library is 32-bit
- ❌ Architecture mismatch → `UnsatisfiedLinkError`

---

## 🛠️ How JNI Causes the Issue

### The Loading Process

1. **Java Code Execution:**
   ```java
   static {
       System.loadLibrary("nativemath");  // Triggers native library load
   }
   ```

2. **JVM Native Library Search:**
   - Searches in `java.library.path`
   - Finds `libnativemath.so` or `nativemath.dll`

3. **OS Loader Invocation:**
   - JVM asks OS to load the library into its process space
   - OS checks binary format and architecture

4. **Architecture Verification:**
   - OS verifies: Is library architecture == process architecture?
   - If NO → **Load fails with error**

5. **Error Propagation:**
   - OS returns error to JVM
   - JVM throws `UnsatisfiedLinkError`
   - Error message: "Can't load IA 32-bit .dll on a AMD 64-bit platform"

### The Static Block Trap

The `static` block in [`NativeMath.java`](native-lib/src/main/java/com/example/nativelib/NativeMath.java:8-25) is executed when the class is first loaded:

```java
static {
    System.loadLibrary("nativemath");
}
```

This means:
- The error occurs **before** any method is called
- It happens during class initialization
- Cannot be caught or recovered from easily
- Propagates up the entire call stack

---

## 🎓 Key Learnings

### 1. Architecture Matching is Mandatory

JNI requires **exact** architecture matching. There is no compatibility layer.

### 2. Static Blocks Execute Early

Native library loading in static blocks means errors occur during class loading, not method invocation.

### 3. Multi-Module Dependencies

The error propagates through the entire dependency chain:
```
MainApp → MathService → NativeMath → [LOAD FAILURE]
```

### 4. Platform-Specific Builds

Native libraries must be built for each target architecture:
- 32-bit JVM → 32-bit native library
- 64-bit JVM → 64-bit native library

### 5. No Runtime Detection

Java cannot detect architecture mismatch until load time. The error is not preventable through code.

---

## 🔧 Troubleshooting

### Error: "gcc: error: unrecognized command line option '-m32'"

**Solution:** Install 32-bit development libraries
```bash
# Ubuntu/Debian
sudo apt-get install gcc-multilib

# Fedora/RHEL
sudo yum install glibc-devel.i686
```

### Error: "Cannot find JNI headers"

**Solution:** Ensure JAVA_HOME is set correctly
```bash
export JAVA_HOME=/path/to/jdk
```

### Error: "Library not found at runtime"

**Solution:** Check library path
```bash
# Linux
export LD_LIBRARY_PATH=build/native-lib/lib:$LD_LIBRARY_PATH

# macOS
export DYLD_LIBRARY_PATH=build/native-lib/lib:$DYLD_LIBRARY_PATH

# Windows
set PATH=build\native-lib\lib;%PATH%
```

---

## 🐳 Docker Testing Details

### Why Use Docker?

Docker provides isolated environments to test both 32-bit and 64-bit JVMs without needing to install multiple Java versions on your host system.

### Docker Images

1. **Dockerfile.64bit** - Uses standard 64-bit OpenJDK image
   - Base: `openjdk:11-jdk-slim` (amd64 architecture)
   - Expected: FAILURE when loading 32-bit native library

2. **Dockerfile.32bit** - Uses 32-bit OpenJDK image
   - Base: `i386/openjdk:11-jdk-slim` (i386 architecture)
   - Expected: SUCCESS when loading 32-bit native library

### Test Script

The [`test-docker.sh`](test-docker.sh) script automates the entire testing process:
1. Builds the project locally
2. Creates Docker images for both architectures
3. Runs tests in both containers
4. Shows clear results for each scenario

### Docker Compose

The [`docker-compose.yml`](docker-compose.yml) defines two services:
- `test-64bit` - Demonstrates the failure case
- `test-32bit` - Demonstrates the success case

---

## 📚 References

- [JNI Specification](https://docs.oracle.com/javase/8/docs/technotes/guides/jni/)
- [System.loadLibrary() Documentation](https://docs.oracle.com/javase/8/docs/api/java/lang/System.html#loadLibrary-java.lang.String-)
- [UnsatisfiedLinkError Documentation](https://docs.oracle.com/javase/8/docs/api/java/lang/UnsatisfiedLinkError.html)
- [Docker Multi-Architecture Images](https://docs.docker.com/build/building/multi-platform/)

---

## 📝 License

This is a demonstration project for educational purposes.

---

## 👤 Author

Created to demonstrate JNI architecture mismatch behavior in Java applications.