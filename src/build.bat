@echo off
cd /d "%~dp0"

set "EXPECTED_VENV=%cd%\venv"

REM First run / fresh clone: create the venv if it doesn't exist yet.
if not exist "venv\Scripts\python.exe" (
    echo No virtual environment found - creating one now...
    python -m venv venv
    if not exist "venv\Scripts\python.exe" (
        echo.
        echo ERROR: Failed to create the virtual environment.
        echo This can happen with the Microsoft Store version of Python.
        echo Try installing Python from https://www.python.org/downloads/
        echo ^(check "Add python.exe to PATH" during setup^), then run this again.
        echo.
        pause
        exit /b 1
    )
    echo Virtual environment created.
)

REM Activate the virtual environment
call venv\Scripts\activate.bat

REM Detect if the project folder was moved and rebuild venv if needed
if /I not "%VIRTUAL_ENV%"=="%EXPECTED_VENV%" (
    echo Project folder appears to have moved - rebuilding the virtual environment...
    call venv\Scripts\deactivate.bat >nul 2>&1
    rmdir /s /q venv
    python -m venv venv
    call venv\Scripts\activate.bat
)

REM Check if dependencies are installed; if not, install them
python -c "import pycaw, pystray, PIL, PyInstaller" 2>nul
if errorlevel 1 (
    echo Dependencies missing - installing now, this may take a moment...
    pip install -r requirements.txt
    pip install pyinstaller
)

echo.
echo Building BGM-AutoPauser ...
echo.

REM For debugging a crash with no visible error (e.g. it exits instantly
REM and no tray icon ever shows up): temporarily change console=False to
REM console=True in BGM-AutoPauser.spec, rebuild, and run the .exe
REM from an already-open Command Prompt. That keeps a terminal attached so
REM any crash/traceback actually prints somewhere instead of vanishing with
REM the hidden window. Switch back to console=False once fixed - auto_pauser.log
REM next to the exe also captures the same info either way.
pyinstaller BGM-AutoPauser.spec

echo.
if exist "dist\Background-AutoPause\BGM-AutoPauser.exe" (
    echo Build successful! Folder is in dist\Background-AutoPause\
    echo Point a shortcut's Target at BGM-AutoPauser.exe inside that folder.
    echo Add --launchPlaylist "C:\path\to\folder" to the shortcut's Arguments field
    echo if you want it to auto-launch VLC on that folder, looped and minimized.
) else (
    echo Build failed. Check the errors above.
)

pause
