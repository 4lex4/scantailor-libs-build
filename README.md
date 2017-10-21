Building libraries for Scan Tailor Advanced
============================================

Scan Tailor Advanced: https://github.com/4lex4/scantailor-advanced

This is a build dependencies project for Scan Tailor Advanced on **Windows**.

**Linux** users need not in it as they can just download [dependencies](#dependencies) and [instruments](#instruments)
from repositories or build them from the sources directly.
 

#### <u>Contents</u>:
* [Dependencies](#dependencies)
* [Instruments](#instruments)
* [Instructions](#instructions)

Dependencies
------------

Download the <u>sources</u> of:

1. [Boost 1.x.x](http://www.boost.org/)
2. [libpng 1.x.x](https://sourceforge.net/projects/libpng/files/)
3. [zlib 1.x.x](https://sourceforge.net/projects/libpng/files/zlib/)
4. [jpeg v9x](http://ijg.org/)
5. [libtiff 4.x.x](http://www.simplesystems.org/libtiff/)
6. [Qt 5.x.x](https://www1.qt.io/download-open-source/) (the <u>source package</u> only!)

Instruments
----------

Download the next instruments:

1. [CMake](https://cmake.org/download/)
2. [MinGW-w64](https://sourceforge.net/projects/mingw-w64/) (for 32 and 64 bit Windows)
3. [msys2](http://www.msys2.org/)

Instructions
----------

1. Download the sources of [Scan Tailor Advanced](https://github.com/4lex4/scantailor-advanced/releases/).
2. Clone this project. (Push the 'Clone or download' button above)
3. Unpack ScanTailor sources into a folder.
4. Create the empty folder named `libs` near the ScanTailor sources folder. (not inside)
5. Unpack all the dependencies into the libs folder.
6. Unpack the folder of this project there.

    You must have gotten a catalog structure similar to this:
    ~~~~
     ..\
        |
        |--libs
        |   |--boost_1_xx_x
        |   |--jpeg-9x
        |   |--libpng-1.x.xx
        |   |--scantailor-libs-build-master
        |   |--jpeg-9x
        |   |--qt-everywhere-opensource-src-5.x.x
        |   |--tiff-4.x.x
        |   |--zlib-1.x.x
        |   
        |--scantailor-advanced-1.x.x
        |
    ~~~~ 
7. Install mingw64 to the path `C:\mingw64` / `C:\mingw32`
8. Install msys2 to the path `C:\msys64` / `C:\msys32`
9. Add mingw64 to the `PATH` environment variable:

   a) go to: My Computer -> Right click -> Properties -> Advanced system settings;
   
   b) click Environment variables;
   
   c) Find `Path` variable in the system variables tab and paste
       `;C:\mingw64\bin` / `;C:\mingw32\bin` at the end of its value.
10. Install CMake.
11. Run script `configure_msys.bat` with administrative permissions.
12. Run script `configure_libs_x32.bat` / `configure_libs_x64.bat`
13. Open the command prompt (`cmd`) and enter, 
    having `_Your_path_to_the_folder_` replaced with your folder containing the libs:
    ~~~~
    cd /d "_Your_path_to_the_folder_\libs\scantailor-libs-build-master"
    mkdir build
    cd build
    cmake -G "MinGW Makefiles" --build ..
    ~~~~
    ~~~~
    mingw32-make -j%NUMBER_OF_PROCESSORS%
    ~~~~
    ~~~~
    cd ..\..
    for /f "delims=" %a in ('dir /b /Ad ^| findstr /r /C:"qt-.*-[0-9]*\.[0-9]*"') do set qt_dir=%a
    cd %qt_dir%
    mingw32-make -j%NUMBER_OF_PROCESSORS%
    ~~~~
    ~~~~
    cd ..
    for /f "delims=" %a in ('dir /b /Ad ^| findstr /r /C:"boost_[0-9]*_[0-9]*_[0-9]*"') do set boost_dir=%a
    cd %boost_dir%
    b2 toolset=gcc link=static threading=multi --build-type=complete stage
    ~~~~
14. Build scantailor.
    Open the command prompt (`cmd`) and enter, 
    having `_Your_path_to_the_folder_\scantailor-advanced-1.x.x` replaced
    with your path to scantailor-advanced sources:
    ~~~~
    cd /d "_Your_path_to_the_folder_\scantailor-advanced-1.x.x"
    mkdir build
    cd build
    cmake -G "MinGW Makefiles" --build ..
    ~~~~
    ~~~~
    mingw32-make -j%NUMBER_OF_PROCESSORS%
    ~~~~
15. Create a folder `bin` in `...\scantailor-advanced-1.x.x\` and move there the files
	`scantailor.exe`, `libjpeg.dll`, `libpng.dll`, `libtiff.dll` and `libz.dll`
    from `...\scantailor-advanced-1.x.x\build`
16. Copy there the files either `libgcc_s_seh-1.dll` or `libgcc_s_sjlj-1.dll` or `libgcc_s_dw2-1.dll` (depending on your mingw-64 version),
    `libstdc++-6.dll` and `libwinpthread-1.dll` from `C:\mingw64\bin`
17. Copy there the files `Qt5Core.dll`, `Qt5Gui.dll`, `Qt5Network.dll`, `Qt5OpenGL.dll`, `Qt5Widgets.dll` and `Qt5Xml.dll` from
    `...\libs\qt-everywhere-opensource-src-5.x.x\qtbase\bin`
18. Create folder named `platforms` in the bin folder and copy there file `qwindows.dll` from
    `...\libs\qt-everywhere-opensource-src-5.x.x\qtbase\plugins\platforms`
19. Create folder named `imageformats` in the bin folder and copy there file `qjpeg.dll` from
    `...\libs\qt-everywhere-opensource-src-5.x.x\qtbase\plugins\imageformats`