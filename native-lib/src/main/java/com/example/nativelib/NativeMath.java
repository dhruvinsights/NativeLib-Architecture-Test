package com.example.nativelib;

/**
 * JNI wrapper for native math operations.
 * This class loads a 32-bit native library.
 */
public class NativeMath {
    
    static {
        String osArch = System.getProperty("os.arch");
        String osName = System.getProperty("os.name");
        
        System.out.println("=== JNI Library Loading ===");
        System.out.println("JVM Architecture: " + osArch);
        System.out.println("Operating System: " + osName);
        System.out.println("Attempting to load 'nativemath' library...");
        
        try {
            System.loadLibrary("nativemath");
            System.out.println("SUCCESS: Native library loaded successfully!");
        } catch (UnsatisfiedLinkError e) {
            System.err.println("FAILED: Could not load native library!");
            System.err.println("Error: " + e.getMessage());
            throw e;
        }
    }
    
    /**
     * Native method to add two integers.
     * Implemented in C/C++ native code.
     */
    public native int add(int a, int b);
    
    /**
     * Test method to verify library loading.
     */
    public static void verifyLoaded() {
        System.out.println("NativeMath class loaded successfully");
    }
}

// Made with Bob
