#include <jni.h>
#include <stdio.h>
#include "com_example_nativelib_NativeMath.h"

/*
 * Class:     com_example_nativelib_NativeMath
 * Method:    add
 * Signature: (II)I
 *
 * This native implementation is compiled as 32-bit ONLY.
 * It will fail to load on a 64-bit JVM.
 */
JNIEXPORT jint JNICALL Java_com_example_nativelib_NativeMath_add
  (JNIEnv *env, jobject obj, jint a, jint b) {
    
    printf("[Native Code] add(%d, %d) called\n", a, b);
    printf("[Native Code] This is a 32-bit native library\n");
    
    jint result = a + b;
    printf("[Native Code] Returning: %d\n", result);
    
    return result;
}

// Made with Bob
