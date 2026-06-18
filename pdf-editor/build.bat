@echo off
setlocal enabledelayedexpansion

echo ========================================
echo  PDF Editor - Build Windows Executable
echo ========================================
echo.

cd /d "%~dp0"

where python >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not on PATH.
    echo Install Python 3.10+ from https://www.python.org/downloads/
    exit /b 1
)

echo [1/4] Creating virtual environment...
if not exist "venv" (
    python -m venv venv
)

echo [2/4] Installing dependencies...
call venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt

echo [3/4] Building executable with PyInstaller...
pyinstaller --noconfirm ^
    --onefile ^
    --windowed ^
    --name "PDF Editor" ^
    --collect-all pymupdf ^
    main.py

if errorlevel 1 (
    echo.
    echo BUILD FAILED.
    exit /b 1
)

echo.
echo [4/4] Done!
echo.
echo Executable location:
echo   %~dp0dist\PDF Editor.exe
echo.
echo You can copy "PDF Editor.exe" anywhere and run it standalone.
echo.

endlocal
