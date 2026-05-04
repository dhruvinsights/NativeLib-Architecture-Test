package com.example.app;

import com.example.service.MathService;

/**
 * Main application entry point.
 * Demonstrates the full dependency chain: app-main -> service-lib -> native-lib
 * 
 * This application will:
 * - Work correctly on 32-bit JVM (loads 32-bit native library)
 * - FAIL on 64-bit JVM (cannot load 32-bit native library)
 */
public class MainApp {
    
    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("  JNI Architecture Mismatch Demo");
        System.out.println("========================================");
        System.out.println();
        
        // Print JVM information
        printJVMInfo();
        System.out.println();
        
        try {
            // Initialize service (this will trigger native library loading)
            System.out.println("[MainApp] Creating MathService...");
            MathService mathService = new MathService();
            System.out.println("[MainApp] MathService created successfully");
            System.out.println();
            
            // Perform calculations
            int a = 15;
            int b = 27;
            System.out.println("[MainApp] Computing: " + a + " + " + b);
            int result = mathService.computeSum(a, b);
            System.out.println();
            
            System.out.println("========================================");
            System.out.println("  RESULT: " + a + " + " + b + " = " + result);
            System.out.println("========================================");
            System.out.println();
            System.out.println("SUCCESS: Application completed successfully!");
            System.out.println("This means the JVM architecture matches the native library (32-bit)");
            
        } catch (UnsatisfiedLinkError e) {
            System.err.println();
            System.err.println("========================================");
            System.err.println("  FAILURE: Native Library Load Error");
            System.err.println("========================================");
            System.err.println();
            System.err.println("Error Message: " + e.getMessage());
            System.err.println();
            System.err.println("CAUSE: Architecture Mismatch!");
            System.err.println("The JVM is 64-bit, but the native library is 32-bit.");
            System.err.println("A 64-bit JVM cannot load a 32-bit native library.");
            System.err.println();
            System.err.println("SOLUTION: Run with a 32-bit JVM to match the 32-bit native library.");
            System.err.println("========================================");
            
            System.exit(1);
        } catch (Exception e) {
            System.err.println("Unexpected error: " + e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
    
    private static void printJVMInfo() {
        System.out.println("JVM Information:");
        System.out.println("  Java Version: " + System.getProperty("java.version"));
        System.out.println("  Java Vendor: " + System.getProperty("java.vendor"));
        System.out.println("  OS Name: " + System.getProperty("os.name"));
        System.out.println("  OS Version: " + System.getProperty("os.version"));
        System.out.println("  OS Architecture: " + System.getProperty("os.arch"));
        System.out.println("  JVM Architecture: " + System.getProperty("sun.arch.data.model") + "-bit");
        
        String arch = System.getProperty("os.arch");
        if (arch.contains("64")) {
            System.out.println();
            System.out.println("  WARNING: Running on 64-bit JVM!");
            System.out.println("  This will FAIL to load the 32-bit native library.");
        } else {
            System.out.println();
            System.out.println("  Running on 32-bit JVM - native library should load successfully.");
        }
    }
}

// Made with Bob
