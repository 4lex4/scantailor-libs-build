@echo off
setlocal EnableDelayedExpansion
chcp 437 >nul

:: checking for administrative permissions
net session >nul 2>nul
IF !ERRORLEVEL! neq 0 (
	echo ERROR: Administrative permissions required. Exiting... >&2
	echo. & pause
	exit /b 2
)

:: setting the paths
set PATH_TO_TOOLS=C:\
set MINGW32_PATH=%PATH_TO_TOOLS%\mingw32
set MINGW64_PATH=%PATH_TO_TOOLS%\mingw64
set MSYS2_DIR_NAME=msys*

for /f "delims=" %%a in ('dir "%PATH_TO_TOOLS%" /b /Ad ^| findstr /r /C:"%MSYS2_DIR_NAME%"') do set msys2_dir=%PATH_TO_TOOLS%%%a

if not exist "!msys2_dir!" (
	echo ERROR: msys2 not found. Exiting... >&2
	echo. & pause
	exit /b 1
)

if exist "%MINGW32_PATH%" (
	set link=!msys2_dir!\mingw32
  call :folder_is_empty "!link!\bin"
  if !ERRORLEVEL! equ 1 (
    rd /s /q "!link!" >nul 2>nul
    mklink /d !link! %MINGW32_PATH% >nul
    if !ERRORLEVEL! equ 0 (
      echo INFO: mingw32 is ready to use with msys2.
    )
  ) else (
    echo INFO: mingw32 has already been installed.
  )
)

if exist "%MINGW64_PATH%" (
	set link=!msys2_dir!\mingw64
  call :folder_is_empty "!link!\bin"
  if !ERRORLEVEL! equ 1 (
    rd /s /q "!link!" >nul 2>nul
    mklink /d !link! %MINGW64_PATH% >nul
    if !ERRORLEVEL! equ 0 (
      echo INFO: mingw64 is ready to use with msys2.
    )
  ) else (
    echo INFO: mingw64 has already been installed.
  )
)

echo. & pause
exit /b %ERRORLEVEL%

:folder_is_empty
for /F %%a in ('dir /b "%~1" 2^>nul') do (
  exit /b 0
)
exit /b 1
