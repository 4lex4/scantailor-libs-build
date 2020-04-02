@echo off
setlocal EnableDelayedExpansion

if "%MINGW%"=="" (
  exit /b 1
)

:: setting the paths
set PATH_TO_TOOLS=C:\
set MSYS2_DIR_NAME=msys*

set PATH_TO_LIBS=%~dp0..

set jpeg_dir_name=jpeg-[0-9]*
set png_dir_name_1=libpng-[0-9]*.[0-9]*.[0-9]*
set png_dir_name_2=lpng[0-9]*
set tiff_dir_name=tiff-[0-9]*.[0-9]*.[0-9]*

for /f "delims=" %%a in ('dir "%PATH_TO_TOOLS%" /b /Ad ^| findstr /r /C:"%MSYS2_DIR_NAME%"') do set msys2_dir=%PATH_TO_TOOLS%%%a
if not exist "!msys2_dir!" (
  echo ERROR: msys2 not found. Exiting... >&2
  echo. & pause
  exit /b 1
)
set MSYS2_SHELL="!msys2_dir!\msys2_shell.cmd"

for /f "delims=" %%a in ('dir "%PATH_TO_LIBS%" /b /Ad ^| findstr /r /C:"%jpeg_dir_name%"') do set jpeg_dir=%PATH_TO_LIBS%\%%a
for /f "delims=" %%a in ('dir "%PATH_TO_LIBS%" /b /Ad ^| findstr /r /C:"%png_dir_name_1%"') do set png_dir=%PATH_TO_LIBS%\%%a
for /f "delims=" %%a in ('dir "%PATH_TO_LIBS%" /b /Ad ^| findstr /r /C:"%png_dir_name_2%"') do set png_dir=%PATH_TO_LIBS%\%%a
for /f "delims=" %%a in ('dir "%PATH_TO_LIBS%" /b /Ad ^| findstr /r /C:"%tiff_dir_name%"') do set tiff_dir=%PATH_TO_LIBS%\%%a

call :configure "jpeg" "!jpeg_dir!"
call :configure "png" "!png_dir!"
call :configure "tiff" "!tiff_dir!" "--disable-zstd --disable-lzma --disable-webp --disable-jbig"

exit /b %ERRORLEVEL%


::::::::::::::::::::::::::::::::::::::::
:: Calls 'configure' script for a given path in msys2 environment.
:: Globals:
::   MINGW  MinGW-w64 toolchain version
::   MSYS2_SHELL  The path to msys2_shell.cmd
:: Arguments:
::   Name of the target configured
::   The directory with the 'configure' script.
::   Arguments for the configure script
:: Return:
::   None
::::::::::::::::::::::::::::::::::::::::
:configure
setlocal
set name=%~1
set dir=%~2
set arguments=%~3

if exist "%dir%" (
  call %MSYS2_SHELL% -%MINGW% -where "%dir%" -c "./configure %arguments%"
) else (
  echo ERROR: %name% not found. >&2
  pause
)

endlocal
exit /b %ERRORLEVEL%