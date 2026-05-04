@echo off
REM Run script for JNI Architecture Mismatch Demo (Windows)

setlocal

echo ==========================================
echo   Running JNI Architecture Mismatch Demo
echo ==========================================
echo.

REM Check if build exists
if not exist build\dist\app-main.jar (
    echo ERROR: Application not built. Run build.bat first.
    exit /b 1
)

set NATIVE_LIB_PATH=build\native-lib\lib
set PATH=%NATIVE_LIB_PATH%;%PATH%

echo Classpath:
echo   - build\dist\app-main.jar
echo   - build\dist\service-lib.jar
echo   - build\dist\native-lib.jar
echo.
echo Native Library Path: %NATIVE_LIB_PATH%
echo.
echo ==========================================
echo.

REM Run the application
java -Djava.library.path="%NATIVE_LIB_PATH%" ^
     -cp "build\dist\app-main.jar;build\dist\service-lib.jar;build\dist\native-lib.jar" ^
     com.example.app.MainApp

set EXIT_CODE=%ERRORLEVEL%

echo.
if %EXIT_CODE% EQU 0 (
    echo Application exited successfully (exit code: 0)
) else (
    echo Application exited with error (exit code: %EXIT_CODE%)
)

endlocal
exit /b %EXIT_CODE%

@REM Made with Bob
