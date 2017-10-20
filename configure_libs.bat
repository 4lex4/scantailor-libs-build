@echo off
setlocal EnableDelayedExpansion
chcp 437 >nul

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

for /f "delims=" %%a in ('dir "%PATH_TO_LIBS%" /b /Ad ^| findstr /r /C:"%jpeg_dir_name%"') do set jpeg_dir=%PATH_TO_LIBS%\%%a

if exist "!jpeg_dir!" (
	call !msys2_dir!\msys2_shell.cmd -%MINGW% -where "!jpeg_dir!" -c "./configure"
) else (
	echo ERROR: jpeg_dir not found. >&2
	pause
)

for /f "delims=" %%a in ('dir "%PATH_TO_LIBS%" /b /Ad ^| findstr /r /C:"%png_dir_name_1%"') do set png_dir=%PATH_TO_LIBS%\%%a
for /f "delims=" %%a in ('dir "%PATH_TO_LIBS%" /b /Ad ^| findstr /r /C:"%png_dir_name_2%"') do set png_dir=%PATH_TO_LIBS%\%%a

if exist "!png_dir!" (
	call !msys2_dir!\msys2_shell.cmd -%MINGW% -where "!png_dir!" -c "./configure"
) else (
	echo ERROR: png_dir not found. >&2
	pause
)

for /f "delims=" %%a in ('dir "%PATH_TO_LIBS%" /b /Ad ^| findstr /r /C:"%tiff_dir_name%"') do set tiff_dir=%PATH_TO_LIBS%\%%a

if exist "!tiff_dir!" (
	call !msys2_dir!\msys2_shell.cmd -%MINGW% -where "!tiff_dir!" -c "./configure"
) else (
	echo ERROR: tiff_dir not found. >&2
	pause
)