Building ScanTailor Advanced and its dependencies
=================================================

ScanTailor Advanced: https://github.com/4lex4/scantailor-advanced

This is an instruction for building ScanTailor Advanced and its dependencies for **Windows** and **Linux**. 

#### <u>Contents</u>:
* [Dependencies](#dependencies)
* [Tools](#tools)
* [ScanTailor building options](#scantailor-building-options)
* [Instructions](#instructions)
  * [**Windows**](#windows)
    * [Preparing to building](#windows-preparing-to-building)
    * [Building with MinGW](#windows-building-with-mingw)
      * [Tools](#windows-mingw-tools)
      * [Preparing tools](#windows-mingw-preparing-tools)
      1. [Building dependencies](#windows-mingw-building-dependencies)
      2. [Building ScanTailor](#windows-mingw-building-scantailor)
    * [Building with MSVC](#windows-building-with-msvc)
      * [Tools](#windows-msvc-tools)
      * [Preparing tools](#windows-msvc-preparing-tools)
      * [Building for Windows 7 and higher](#windows-msvc-building-for-windows-7-and-higher)
        1. [Building dependencies](#windows-msvc-building-dependencies)
        2. [Building ScanTailor](#windows-msvc-building-scantailor)
      * [Building for Windows XP](#windows-msvc-building-for-windows-xp)
        1. [Building dependencies](#windows-msvc-winxp-building-dependencies)
        2. [Building ScanTailor](#windows-msvc-winxp-building-scantailor)
  * [**Linux**](#linux)
    1. [Getting dependencies](#linux-getting-dependencies)
       * [Downloading from repositories](#linux-downloading-from-repositories)
       * [Building from sources](#linux-building-from-sources)
    2. [Building ScanTailor](#linux-building-scantailor)
* [Packaging](#packaging)

Dependencies
------------
1. [Boost 1.60.x or higher](http://www.boost.org/)
2. [libpng 1.x.x](https://sourceforge.net/projects/libpng/files/)
3. [zlib 1.x.x](https://sourceforge.net/projects/libpng/files/zlib/)
4. [jpeg 9x](http://www.ijg.org/files/)
5. [libtiff 4.x.x](http://www.simplesystems.org/libtiff/)
6. [Qt 5.6.x or higher](https://download.qt.io/archive/qt/) (Note: Qt 5.6.x are the latest versions that support Windows XP)

Tools
-----
1. [CMake 3.9.x or higher](https://cmake.org/download/)

ScanTailor building options
-----
Usage: `cmake -D <option>=<value> ...`

Useful options:  
* `CMAKE_INSTALL_PREFIX=<path>` - install ScanTailor Advanced into the `path` after building.  
* `PORTABLE_VERSION=[ON|OFF]` - whether to build portable version. If enabled, ScanTailor tries to store its settings 
    and files inside the application folder if possible, else ScanTailor stores those in the system specific paths. 
    If disabled, the settings and files are always stored in the system specific paths.  

Instructions
----------
### Windows
Supported toolchains for Windows are MinGW and MSVC.

#### <a name="windows-preparing-to-building"></a> <u>Preparing to building</u>
1. Download the sources of [ScanTailor Advanced](https://github.com/4lex4/scantailor-advanced/releases/)
2. Clone [this project](https://github.com/4lex4/scantailor-libs-build). (Push the 'Clone or download' button above)
3. Unpack ScanTailor Advanced sources into a folder
4. Create the empty folder named `libs` near the ScanTailor sources folder (but not inside)
5. Download and unpack the sources of all [the dependencies](#dependencies) listed into the libs folder
6. Unpack the folder of this project there.  
   You must have gotten a catalog structure similar to this:

   ~~~~
   ..\
    |
    |-- libs
    |   |-- boost_1_xx_x
    |   |-- jpeg-9
    |   |-- libpng-1.x.xx
    |   |-- scantailor-libs-build-master
    |   |-- jpeg-9x
    |   |-- qt-everywhere-opensource-src-5.x.x
    |   |-- tiff-4.x.x
    |   |-- zlib-1.x.x
    |   
    |-- scantailor-advanced-x.x.x
    |
   ~~~~

7. Install [CMake](#tools)

#### <a name="windows-building-with-mingw"></a> <u>Building with MinGW</u>
#### <a name="windows-mingw-tools"></a> Tools
1. [MinGW-w64](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/)
   (for 32 and 64 bit Windows; `posix` and `dwarf` / `seh` versions recommended)
2. [msys2](http://www.msys2.org/)

#### <a name="windows-mingw-preparing-tools"></a> Preparing tools
1. Install mingw64 into the path `C:\mingw64` / `C:\mingw32`
2. Install msys2 into the path `C:\msys64` / `C:\msys32`
3. Run script `configure_msys.bat` with administrative permissions 
4. Add mingw into the `PATH` environment variable:  
   1. Go to: My Computer -> Right click -> Properties -> Advanced system settings  
   2. Click Environment variables  
   3. Find `Path` variable in the system variables tab and paste
      `;C:\mingw64\bin` / `;C:\mingw32\bin` at the end of its value

#### <a name="windows-mingw-building-dependencies"></a> Building dependencies 
1. Run script `configure_libs_x32.bat` / `configure_libs_x64.bat`
2. Open the command prompt (`cmd`), navigate to the `scantailor-libs-build-master`
   directory (`cd /d "<path>"`) and enter:

   ~~~~
   mkdir build & cd build
   cmake -G "MinGW Makefiles" --build ..
   mingw32-make -j %NUMBER_OF_PROCESSORS%
   ~~~~

>***Note**: when building successfully done the `qt-everywhere-opensource-src-5.x.x` and `boost_1_xx_x` folders can be removed to free up disk space.*

#### <a name="windows-mingw-building-scantailor"></a> Building ScanTailor
1. Open the command prompt (`cmd`), navigate to the `scantailor-advanced-x.x.x`
   directory (`cd /d "<path>"`) and enter:

   ~~~~
   mkdir build & cd build
   cmake -G "MinGW Makefiles" --build ..
   mingw32-make -j %NUMBER_OF_PROCESSORS%
   ~~~~

#### <a name="windows-building-with-msvc"></a> <u>Building with MSVC</u>
#### <a name="windows-msvc-tools"></a> Tools
1. [Visual Studio](https://www.visualstudio.com/) (version 2015 or higher \[with the Win XP compability package\] required)
2. [Jom](http://wiki.qt.io/Jom)

#### <a name="windows-msvc-preparing-tools"></a> Preparing tools
1. Place `jom.exe` into the `%ProgramFiles(x86)%\Jom\` folder
2. Add Jom into the `PATH` environment variable:  
   1. go to: My Computer -> Right click -> Properties -> Advanced system settings  
   2. click Environment variables  
   3. Find `Path` variable in the system variables tab and paste
      `;%ProgramFiles(x86)%\Jom\` at the end of its value

#### <a name="windows-msvc-building-for-windows-7-and-higher"></a> *<u>Building for Windows 7 and higher</u>*
#### <a name="windows-msvc-building-dependencies"></a> Building dependencies
1. Open the Native Tools Command Prompt for VS, navigate to the `scantailor-libs-build-master`
   directory (`cd /d "<path>"`) and enter:

   ~~~~
   mkdir build & cd build
   cmake -G "NMake Makefiles JOM" -D CMAKE_BUILD_TYPE=Release --build ..
   jom -j %NUMBER_OF_PROCESSORS%
   ~~~~

>***Note**: when building successfully done the `qt-everywhere-opensource-src-5.x.x` and `boost_1_xx_x` folders can be removed to free up disk space.*

#### <a name="windows-msvc-building-scantailor"></a> Building ScanTailor
1. Open the Native Tools Command Prompt for VS, navigate to the `scantailor-advanced-x.x.x`
   directory (`cd /d "<path>"`) and enter:

   ~~~~
   mkdir build & cd build
   cmake -G "NMake Makefiles JOM" -D CMAKE_BUILD_TYPE=Release --build ..
   jom -j %NUMBER_OF_PROCESSORS%
   ~~~~

#### <a name="windows-msvc-building-for-windows-xp"></a> *<u>Building for Windows XP</u>*
#### <a name="windows-msvc-winxp-building-dependencies"></a> Building dependencies
1. <a name="configure-environment-msvc-winxp"></a> 
   Configure some environment variables. Open the Native Tools Command Prompt for VS and enter:

   ~~~~
   set INCLUDE=%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.1A\Include;%INCLUDE%
   set PATH=%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.1A\Bin;%PATH%
   set LIB=%ProgramFiles(x86)%\Microsoft SDKs\Windows\v7.1A\Lib;%LIB%
   ~~~~

2. Navigate to the `scantailor-libs-build-master` directory (`cd /d "<path>"`) and enter:

   ~~~~
   mkdir build & cd build
   cmake -G "NMake Makefiles JOM" -D CMAKE_BUILD_TYPE=Release -D WIN_XP=ON --build ..
   jom -j %NUMBER_OF_PROCESSORS%
   ~~~~

>***Note**: when building successfully done the `qt-everywhere-opensource-src-5.x.x` and `boost_1_xx_x` folders can be removed to free up disk space.*

#### <a name="windows-msvc-winxp-building-scantailor"></a> Building ScanTailor
1. Configure some environment variables [as stated above](#configure-environment-msvc-winxp), if it has not been done yet
2. Navigate to the `scantailor-advanced-x.x.x` directory (`cd /d "<path>"`) and enter:

   ~~~~
   mkdir build & cd build
   cmake -G "NMake Makefiles JOM" -D CMAKE_BUILD_TYPE=Release -D WIN_XP=ON --build ..
   jom -j %NUMBER_OF_PROCESSORS%
   ~~~~

### Linux
#### <a name="linux-getting-dependencies"></a> Getting dependencies
Linux users have two options here: [download them from their repositories](#downloading-from-repositories) 
or [build them from sources](#building-from-sources).

#### <a name="linux-downloading-from-repositories"></a> *Downloading from repositories*
1. Just download [CMake](#tools) and [dependencies](#dependencies) developing packages from the repository and
   then [build scantailor](#build-scantailor-linux). Developing packages are usually have `-devel` or `-dev` suffix  

   Examples:  
   <details><summary><i>Ubuntu</i></summary>
   <code>
   sudo apt-get install gcc-7 g++-7 cmake libjpeg-dev libpng-dev libtiff5 libtiff5-dev libboost-test1.63-dev libboost-test1.63.0 qtbase5-dev libqt5svg5-dev qttools5-dev qttools5-dev-tools libqt5opengl5-dev libpthread-stubs0-dev
   </code>
   </details>
   <details><summary><i>OpenSUSE</i></summary>
   <code>
   sudo zypper install gcc7 gcc7-c++ cmake libjpeg8-devel libpng16-devel libtiff5 libtiff-devel libboost_test1_66_0 libboost_test1_66_0-devel libqt5-qtbase-devel libqt5-qtsvg-devel libqt5-qttools-devel pthread-stubs-devel
   </code>
   </details>

#### <a name="linux-building-from-sources"></a> *Building from sources*
1. Install [CMake](#tools), gcc, g++ and
   developing packages of Xrender, fontconfig, pthread-stubs, X11, OpenGL (Mesa) from your repository.
   Developing packages are usually have `-devel` or `-dev` suffix.  
   (Example of the package names on OpenSUSE: `libXrender-devel`, `fontconfig-devel`, `pthread-stubs-devel`, `libX11-devel`, `Mesa-devel`)  
   See [Qt Linux requirements](https://doc.qt.io/qt-5/linux-requirements.html) article for more information
2. Download and unpack [dependencies](#dependencies) sources
3. Configure some make environment variables:

   ~~~~
   export LDFLAGS="-L/usr/local/lib -L/usr/local/lib64 -Wl,--rpath=/usr/local/lib -Wl,--rpath=/usr/local/lib64"
   export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64
   export CFLAGS="-fPIC"
   export CXXFLAGS="-fPIC"
   ~~~~

4. Build libjpeg, zlib, then libpng and then libtiff with

   ~~~~
   mkdir build; cd build
   ../configure
   make -j `nproc`
   sudo make install
   ~~~~

5. Build Qt:

   ~~~~
   mkdir build; cd build
   ../configure -platform linux-g++ -release -shared \
   -system-zlib -system-libpng -system-libjpeg -system-freetype \
   -skip qt3d -skip qtactiveqt -skip qtandroidextras -skip qtcanvas3d -skip qtcharts -skip qtconnectivity \
   -skip qtdatavis3d -skip qtdeclarative -skip qtdoc -skip qtimageformats -skip qtgamepad -skip qtgraphicaleffects \
   -skip qtlocation -skip qtmacextras -skip qtmultimedia -skip qtnetworkauth -skip qtpurchasing -skip qtquickcontrols \
   -skip qtquickcontrols2 -skip qtremoteobjects -skip qtscript -skip qtscxml -skip qtsensors \
   -skip qtspeech -skip qtvirtualkeyboard -skip qtwayland -skip qtwebchannel \
   -skip qtwebengine -skip qtwebsockets -skip qtwebview -skip qtwinextras -skip qtxmlpatterns \
   -nomake examples -nomake tests -opensource -confirm-license -no-ltcg
   make -j `nproc`
   sudo make install
   ~~~~

   After building and installing copy [findqt.sh and findqt.csh](https://files.inbox.eu/ticket/5bf43247570a1c111ed0eaa8d6a770ff87ec1b62/findqt.tar.xz) 
   into `/etc/profile.d/` folder then enter `sudo . ~/.profile && . /etc/profile` in console to apply the changes made instantly
   or [add Qt into PATH](http://doc.qt.io/qt-5/linux-building.html) yourself.

6. Build boost:

   ~~~~
   ./bootstrap.sh
   ./b2 -q --with-test toolset=gcc link=shared threading=multi -j `nproc` stage
   sudo ./b2 -q --with-test toolset=gcc link=shared threading=multi install
   ~~~~

#### <a name="linux-building-scantailor"></a> Building ScanTailor
1. Navigate to the `scantailor-advanced-x.x.x` directory (`cd "<path>"`) and enter:

   ~~~~
   mkdir build; cd build
   cmake -G "Unix Makefiles" --build ..
   make -j `nproc`
   ~~~~

2. Optionally, install ScanTailor Advanced with:

   ~~~~
   sudo make install
   ~~~~

   >***Note***: you can use `sudo make uninstall` from the build dir to uninstall ScanTailor Advanced later.

Packaging
---------
1. Build ScanTailor Advanced following the instructions above  
2. Use `cpack -G <generator> [options]` to create a package for your platform.  
   Enter `cpack --help` to see the options and generators available.

   Examples:
     1. To create a Linux DEB package use: `cpack -G "DEB"`  
     2. To create a Linux RPM package use: `cpack -G "RPM"`   
          *Note:* `rpm-build` package has to be installed. 
     3. To create an installer for Windows use: `cpack -G "NSIS"`   
          *Note:* [NSIS](https://sourceforge.net/projects/nsis/files/) has to be installed.
