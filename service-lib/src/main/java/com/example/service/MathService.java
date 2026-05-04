package com.example.service;

import com.example.nativelib.NativeMath;

/**
 * Service layer that uses the native library.
 * This demonstrates the dependency chain: service-lib -> native-lib
 */
public class MathService {
    
    private final NativeMath nativeMath;
    
    public MathService() {
        System.out.println("[MathService] Initializing service...");
        this.nativeMath = new NativeMath();
        System.out.println("[MathService] Service initialized successfully");
    }
    
    /**
     * Computes the sum of two integers using native code.
     * 
     * @param a first integer
     * @param b second integer
     * @return sum of a and b
     */
    public int computeSum(int a, int b) {
        System.out.println("[MathService] computeSum(" + a + ", " + b + ") called");
        int result = nativeMath.add(a, b);
        System.out.println("[MathService] Result from native: " + result);
        return result;
    }
}

// Made with Bob
