@echo off
REM Build script for JNI Architecture Mismatch Demo (Windows)
REM This script builds all three modules and the 32-bit native library

setlocal enabledelayedexpansion

echo ==========================================
echo   Building JNI Architecture Mismatch Demo
echo ==========================================
echo.

REM Check for Java compiler
where javac >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: javac not found. Please install JDK.
    exit /b 1
)

REM Check for Visual Studio or MinGW
where cl >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    set COMPILER=MSVC
    echo Using Microsoft Visual C++ Compiler
) else (
    where gcc >nul 2>nul
    if %ERRORLEVEL% EQU 0 (
        set COMPILER=GCC
        echo Using GCC (MinGW)
    ) else (
        echo ERROR: No C compiler found. Install Visual Studio or MinGW.
        exit /b 1
    )
)
echo.

REM Create output directories
echo Creating output directories...
if not exist build\native-lib\classes mkdir build\native-lib\classes
if not exist build\service-lib\classes mkdir build\service-lib\classes
if not exist build\app-main\classes mkdir build\app-main\classes
if not exist build\native-lib\lib mkdir build\native-lib\lib
if not exist build\dist mkdir build\dist
echo.

REM Step 1: Compile native-lib Java code
echo ==========================================
echo Step 1: Compiling native-lib Java code
echo ==========================================
javac -d build\native-lib\classes native-lib\src\main\java\com\example\nativelib\NativeMath.java
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: native-lib Java compilation failed
    exit /b 1
)
echo SUCCESS: native-lib Java compilation successful
echo.

REM Step 2: Generate JNI header
echo ==========================================
echo Step 2: Generating JNI header
echo ==========================================
echo Using pre-generated header: native-lib\src\main\native\com_example_nativelib_NativeMath.h
echo.

REM Step 3: Compile native library as 32-bit
echo ==========================================
echo Step 3: Compiling 32-bit native library
echo ==========================================
echo IMPORTANT: Compiling as 32-bit ONLY
echo.

REM Find JAVA_HOME
if not defined JAVA_HOME (
    for /f "tokens=*" %%i in ('where javac') do set JAVAC_PATH=%%i
    for %%i in ("!JAVAC_PATH!") do set JAVA_BIN=%%~dpi
    for %%i in ("!JAVA_BIN!..") do set JAVA_HOME=%%~fi
)

echo Java Home: %JAVA_HOME%
echo.

if "%COMPILER%"=="MSVC" (
    echo Compiling with MSVC for Windows (32-bit)...
    echo.
    echo NOTE: You must run this from a Visual Studio x86 Native Tools Command Prompt
    echo       or use vcvarsall.bat x86 to set up the 32-bit environment
    echo.
    
    cl /LD /Fe:build\native-lib\lib\nativemath.dll ^
        /I"%JAVA_HOME%\include" ^
        /I"%JAVA_HOME%\include\win32" ^
        /I"native-lib\src\main\native" ^
        native-lib\src\main\native\nativemath.c
    
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Native library compilation failed
        echo Make sure you are using x86 (32-bit) compiler tools
        exit /b 1
    )
    
    move nativemath.dll build\native-lib\lib\ >nul 2>nul
    del nativemath.lib nativemath.exp nativemath.obj >nul 2>nul
    
) else (
    echo Compiling with GCC (MinGW) for Windows (32-bit)...
    echo.
    echo NOTE: Make sure you are using 32-bit MinGW (i686-w64-mingw32)
    echo.
    
    gcc -m32 -shared ^
        -I"%JAVA_HOME%\include" ^
        -I"%JAVA_HOME%\include\win32" ^
        -I"native-lib\src\main\native" ^
        native-lib\src\main\native\nativemath.c ^
        -o build\native-lib\lib\nativemath.dll
    
    if %ERRORLEVEL% NEQ 0 (
        echo ERROR: Native library compilation failed
        echo Make sure you have 32-bit MinGW installed
        exit /b 1
    )
)

echo SUCCESS: 32-bit native library compiled: build\native-lib\lib\nativemath.dll
echo.

REM Step 4: Create native-lib JAR
echo ==========================================
echo Step 4: Creating native-lib JAR
echo ==========================================
cd build\native-lib\classes
jar cf ..\..\dist\native-lib.jar com\example\nativelib\*.class
cd ..\..\..
echo SUCCESS: Created: build\dist\native-lib.jar
echo.

REM Step 5: Compile service-lib
echo ==========================================
echo Step 5: Compiling service-lib
echo ==========================================
javac -cp build\dist\native-lib.jar ^
    -d build\service-lib\classes ^
    service-lib\src\main\java\com\example\service\MathService.java

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: service-lib compilation failed
    exit /b 1
)
echo SUCCESS: service-lib compilation successful

cd build\service-lib\classes
jar cf ..\..\dist\service-lib.jar com\example\service\*.class
cd ..\..\..
echo SUCCESS: Created: build\dist\service-lib.jar
echo.

REM Step 6: Compile app-main
echo ==========================================
echo Step 6: Compiling app-main
echo ==========================================
javac -cp "build\dist\native-lib.jar;build\dist\service-lib.jar" ^
    -d build\app-main\classes ^
    app-main\src\main\java\com\example\app\MainApp.java

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: app-main compilation failed
    exit /b 1
)
echo SUCCESS: app-main compilation successful

cd build\app-main\classes
jar cfe ..\..\dist\app-main.jar com.example.app.MainApp com\example\app\*.class
cd ..\..\..
echo SUCCESS: Created: build\dist\app-main.jar
echo.

REM Summary
echo ==========================================
echo   Build Complete!
echo ==========================================
echo.
echo Output files:
echo   - build\dist\native-lib.jar
echo   - build\dist\service-lib.jar
echo   - build\dist\app-main.jar
echo   - build\native-lib\lib\nativemath.dll (32-bit)
echo.
echo To run the application:
echo   run.bat
echo.

endlocal

@REM Made with Bob
