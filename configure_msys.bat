@echo off
setlocal EnableDelayedExpansion

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

call :configure_msys "!msys2_dir!" "32" "%MINGW32_PATH%"
call :configure_msys "!msys2_dir!" "64" "%MINGW64_PATH%"

echo. & pause
exit /b %ERRORLEVEL%


:configure_msys
setlocal
set msysPath=%~1
set version=%~2
set mingwPath=%~3
if exist "%mingwPath%" (
  set link=%msysPath%\mingw%version%
  call :folder_is_empty "!link!\bin"
  if !ERRORLEVEL! equ 1 (
    rd /s /q "!link!" >nul 2>nul
    mklink /d !link! %mingwPath% >nul
    if !ERRORLEVEL! equ 0 (
      echo INFO: mingw%version% is ready to use with msys2.
    )
  ) else (
    echo INFO: mingw%version% has already been installed.
  )
)
endlocal
exit /b %ERRORLEVEL%

::::::::::::::::::::::::::::::::::::::::
:: Check whether the folder is emtpy.
:: Arguments:
::   The directory to check.
:: Return:
::   ERRORLEVEL set to 0 if the given
::   folder not empty and 1 otherwise.
::::::::::::::::::::::::::::::::::::::::
:folder_is_empty
for /f %%a in ('dir /b "%~1" 2^>nul') do (
  exit /b 0
)
exit /b 1