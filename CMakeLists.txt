cmake_minimum_required(VERSION 3.9 FATAL_ERROR)

project("libs build")

# setting compiler flags
set(CMAKE_CXX_STANDARD 17)

if (NOT DEFAULT_COMPILER_FLAGS_IS_SET)
  if (MSVC)
    option(WIN_XP "Whether to build for Windows XP." OFF)
    if (WIN_XP)
      set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /D_USING_V110_SDK71_")
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /D_USING_V110_SDK71_")
      set(CMAKE_EXE_LINKER_FLAGS "/SUBSYSTEM:CONSOLE,5.01 /SUBSYSTEM:WINDOWS,5.01 ${CMAKE_EXE_LINKER_FLAGS}")
    endif()

    # Disable checked iterators for extra performance.
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /D_SECURE_SCL=0")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /D_SECURE_SCL=0")
  elseif (WIN_XP)
    unset(WIN_XP CACHE)
    message(WARNING "Only MSVC toolchain is supported to build for Windows XP.")
  endif()

  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}"
      CACHE STRING "Common C flags for all build configurations." FORCE)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}"
      CACHE STRING "Common C++ flags for all build configurations." FORCE)
  set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}"
      CACHE STRING "Common link flags for all build configurations." FORCE)

  set(DEFAULT_COMPILER_FLAGS_IS_SET YES CACHE INTERNAL "" FORCE)
endif()

include(cmake/SetDefaultBuildType.cmake)
include(cmake/ListItemsPrepend.cmake)
include(cmake/ToNativePath.cmake)

st_set_default_build_type(Release)

get_filename_component(SOURCE_OUTER_DIR "${PROJECT_SOURCE_DIR}/.." ABSOLUTE)

file(GLOB jpeg_dir_hints "${SOURCE_OUTER_DIR}/jpeg-[0-9]*")
file(GLOB zlib_dir_hints "${SOURCE_OUTER_DIR}/zlib-[0-9]*.[0-9]*.[0-9]*")
file(GLOB png_dir_hints "${SOURCE_OUTER_DIR}/libpng-[0-9]*.[0-9]*.[0-9]*")
file(GLOB tiff_dir_hints "${SOURCE_OUTER_DIR}/tiff-[0-9]*.[0-9]*.[0-9]*")
file(GLOB qt_dir_hints "${SOURCE_OUTER_DIR}/qt-*-*-[0-9]*.[0-9]*")
file(GLOB boost_dir_hints "${SOURCE_OUTER_DIR}/boost_[0-9]*_[0-9]*_[0-9]*")

find_path(
    JPEG_DIR jpeglib.h HINTS ${jpeg_dir_hints}
    DOC "Path to jpeg source directory.")
find_path(
    ZLIB_DIR zlib.h HINTS ${zlib_dir_hints}
    DOC "Path to zlib source directory.")
find_path(
    PNG_DIR png.h HINTS ${png_dir_hints}
    DOC "Path to libpng source directory.")
find_path(
    TIFF_DIR libtiff/tiff.h HINTS ${tiff_dir_hints}
    DOC "Path to top-level tiff source directory.")
find_path(
    QT_DIR configure HINTS ${qt_dir_hints}
    DOC "Path to top-level Qt source directory.")
find_path(
    BOOST_DIR boost/foreach.hpp HINTS ${boost_dir_hints}
    DOC "Path to top-level Boost source directory.")

if (NOT JPEG_DIR)
  message(FATAL_ERROR "JPEG source directory not found. You may specify it manually.")
elseif (NOT ZLIB_DIR)
  message(FATAL_ERROR "ZLIB source directory not found. You may specify it manually.")
elseif (NOT PNG_DIR)
  message(FATAL_ERROR "LibPNG source directory not found. You may specify it manually.")
elseif (NOT TIFF_DIR)
  message(FATAL_ERROR "TIFF source directory not found. You may specify it manually.")
elseif (NOT QT_DIR)
  message(FATAL_ERROR "Qt source directory not found. You may specify it manually.")
elseif (NOT BOOST_DIR)
  message(FATAL_ERROR "Boost source directory not found. You may specify it manually.")
endif()

if (MINGW)
  set(ZLIB_LIBRARY_NAME z)
  set(PNG_LIBRARY_NAME png)
  set(JPEG_LIBRARY_NAME jpeg)
  set(TIFF_LIBRARY_NAME tiff)
else()
  set(ZLIB_LIBRARY_NAME zdll)
  set(PNG_LIBRARY_NAME libpng)
  set(JPEG_LIBRARY_NAME libjpeg)
  set(TIFF_LIBRARY_NAME libtiff)
endif()

set(BOOST_INSTALL_DIR "${SOURCE_OUTER_DIR}/Boost" CACHE PATH "Boost installation directory.")
set(QT_INSTALL_DIR "${SOURCE_OUTER_DIR}/Qt" CACHE PATH "Qt installation directory.")

#=================================== JPEG ===================================#

if (MSVC AND (NOT EXISTS "${JPEG_DIR}/jmorecfg.h.orig"))
  # Patch jmorecfg.h to:
  # 1. Prevent double definition of INT32.
  # 2. Build a DLL rather than a static library.
  file(READ "${JPEG_DIR}/jmorecfg.h" jmorecfg_h_orig)
  string(REPLACE "XMD_H" "_BASETSD_H" jmorecfg_h "${jmorecfg_h_orig}")
  string(
      REGEX REPLACE "#define[ \t]+GLOBAL\\(type\\)[^\n]*"
      "#ifdef JPEG_BUILD\n#define GLOBAL(type) __declspec(dllexport) type\n#else\n#define GLOBAL(type) __declspec(dllimport) type\n#endif"
      jmorecfg_h "${jmorecfg_h}")
  string(
      REGEX REPLACE "#define[ \t]+EXTERN\\(type\\)[^\n]*"
      "#ifdef JPEG_BUILD\n#define EXTERN(type) extern __declspec(dllexport) type\n#else\n#define EXTERN(type) extern __declspec(dllimport) type\n#endif"
      jmorecfg_h "${jmorecfg_h}")
  file(WRITE "${JPEG_DIR}/jmorecfg.h" "${jmorecfg_h}")
  file(WRITE "${JPEG_DIR}/jmorecfg.h.orig" "${jmorecfg_h_orig}")
  set(jmorecfg_h "")
  set(jmorecfg_h_orig "")
endif()

set(libjpeg_sources
    jaricom.c jcapimin.c jcapistd.c jcarith.c jccoefct.c jccolor.c
    jcdctmgr.c jchuff.c jcinit.c jcmainct.c jcmarker.c jcmaster.c
    jcomapi.c jcparam.c jcprepct.c jcsample.c jctrans.c jdapimin.c
    jdapistd.c jdarith.c jdatadst.c jdatasrc.c jdcoefct.c jdcolor.c
    jddctmgr.c jdhuff.c jdinput.c jdmainct.c jdmarker.c jdmaster.c
    jdmerge.c jdpostct.c jdsample.c jdtrans.c jerror.c jfdctflt.c
    jfdctfst.c jfdctint.c jidctflt.c jidctfst.c jidctint.c jquant1.c
    jquant2.c jutils.c jmemmgr.c jmemnobs.c)

if (MSVC)
  configure_file("${JPEG_DIR}/jconfig.vc" "${JPEG_DIR}/jconfig.h" COPYONLY)
endif()
if (MINGW)
  list(APPEND libjpeg_sources jconfig.h)
endif()

list_items_prepend(libjpeg_sources "${JPEG_DIR}/")

add_library(${JPEG_LIBRARY_NAME} SHARED ${libjpeg_sources})
target_include_directories(${JPEG_LIBRARY_NAME} INTERFACE "${JPEG_DIR}")
set_target_properties(
    ${JPEG_LIBRARY_NAME} PROPERTIES
    DEFINE_SYMBOL JPEG_BUILD
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${JPEG_DIR}/stage/lib"
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${JPEG_DIR}/stage/lib"
    ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO "${JPEG_DIR}/stage/lib"
    ARCHIVE_OUTPUT_DIRECTORY_MINSIZEREL "${JPEG_DIR}/stage/lib"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG "${JPEG_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${JPEG_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${JPEG_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${JPEG_DIR}/bin"
    DEBUG_POSTFIX "d")

#=================================== ZLIB ===================================#

set(zlib_sources
    adler32.c compress.c crc32.c deflate.c inffast.c inflate.c
    inftrees.c trees.c uncompr.c zutil.c)

list_items_prepend(zlib_sources "${ZLIB_DIR}/")

add_library(${ZLIB_LIBRARY_NAME} SHARED ${zlib_sources})
target_include_directories(${ZLIB_LIBRARY_NAME} INTERFACE "${ZLIB_DIR}")
set_target_properties(
    ${ZLIB_LIBRARY_NAME} PROPERTIES
    DEFINE_SYMBOL ZLIB_DLL
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${ZLIB_DIR}/stage/lib"
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${ZLIB_DIR}/stage/lib"
    ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO "${ZLIB_DIR}/stage/lib"
    ARCHIVE_OUTPUT_DIRECTORY_MINSIZEREL "${ZLIB_DIR}/stage/lib"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG "${ZLIB_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${ZLIB_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${ZLIB_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${ZLIB_DIR}/bin"
    DEBUG_POSTFIX "d")

#================================== LIBPNG ==================================#

configure_file(
    "${PNG_DIR}/scripts/pnglibconf.h.prebuilt"
    "${PNG_DIR}/pnglibconf.h" COPYONLY)

set(libpng_sources
    png.c pngset.c pngget.c pngrutil.c pngtrans.c pngwutil.c pngread.c
    pngrio.c pngwio.c pngwrite.c pngrtran.c pngwtran.c pngmem.c
    pngerror.c pngpread.c)

if (MINGW)
  list(APPEND libpng_sources config.h)
endif()
  
list_items_prepend(libpng_sources "${PNG_DIR}/")

add_library(${PNG_LIBRARY_NAME} SHARED ${libpng_sources})
target_link_libraries(${PNG_LIBRARY_NAME} PUBLIC ${ZLIB_LIBRARY_NAME})
target_include_directories(${PNG_LIBRARY_NAME} INTERFACE "${PNG_DIR}")
set_target_properties(
    ${PNG_LIBRARY_NAME} PROPERTIES
    DEFINE_SYMBOL PNG_BUILD_DLL
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${PNG_DIR}/stage/lib"
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${PNG_DIR}/stage/lib"
    ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO "${PNG_DIR}/stage/lib"
    ARCHIVE_OUTPUT_DIRECTORY_MINSIZEREL "${PNG_DIR}/stage/lib"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG "${PNG_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${PNG_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${PNG_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${PNG_DIR}/bin"
    DEBUG_POSTFIX "d")

#=================================== TIFF ===================================#
  
set(libtiff_sources
    tiff.h tiffio.h tiffvers.h
    tif_aux.c tif_close.c tif_codec.c tif_color.c tif_compress.c tif_dir.c tif_dirinfo.c
    tif_dirread.c tif_dirwrite.c tif_dumpmode.c tif_error.c tif_extension.c tif_fax3.c
    tif_fax3sm.c tif_flush.c tif_getimage.c tif_jbig.c tif_jpeg.c tif_jpeg_12.c tif_luv.c
    tif_lzma.c tif_lzw.c tif_next.c tif_ojpeg.c tif_open.c tif_packbits.c tif_pixarlog.c
    tif_predict.c tif_print.c tif_read.c tif_strip.c tif_swab.c tif_thunder.c tif_tile.c
    tif_version.c tif_warning.c tif_write.c tif_zip.c
    libtiff.def)

if (WIN32_IO)
  list(APPEND libtiff_sources tif_win32.c)
else()
  list(APPEND libtiff_sources tif_unix.c)
endif()

if (MSVC)
  set(tiff_vc_config "${TIFF_DIR}/libtiff/tif_config.vc.h")
  if (EXISTS "${TIFF_DIR}/libtiff/tif_config.h.vc")
    set(tiff_vc_config "${TIFF_DIR}/libtiff/tif_config.h.vc")
  endif()
  configure_file(
      "${tiff_vc_config}" "${TIFF_DIR}/libtiff/tif_config.h" COPYONLY)
  configure_file(
      "${TIFF_DIR}/libtiff/tiffconf.vc.h"
      "${TIFF_DIR}/libtiff/tiffconf.h" COPYONLY)
endif()
if (MINGW)
  list(APPEND libtiff_sources tif_config.h tiffconf.h)
endif()

list_items_prepend(libtiff_sources "${TIFF_DIR}/libtiff/")

add_library(${TIFF_LIBRARY_NAME} SHARED ${libtiff_sources})
target_link_libraries(
    ${TIFF_LIBRARY_NAME} PUBLIC
    ${PNG_LIBRARY_NAME} ${JPEG_LIBRARY_NAME})
target_include_directories(${TIFF_LIBRARY_NAME} INTERFACE "${TIFF_DIR}/libtiff")
target_compile_definitions(${TIFF_LIBRARY_NAME} PRIVATE
    CCITT_SUPPORT=1 PACKBITS_SUPPORT=1 LZW_SUPPORT=1
    THUNDER_SUPPORT=1 NEXT_SUPPORT=1 LOGLUV_SUPPORT=1 MDI_SUPPORT=1 ZIP_SUPPORT=1
    PIXARLOG_SUPPORT=1 JPEG_SUPPORT=1 OJPEG_SUPPORT=1)
set_target_properties(
    ${TIFF_LIBRARY_NAME} PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY_DEBUG "${TIFF_DIR}/stage/lib"
    ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${TIFF_DIR}/stage/lib"
    ARCHIVE_OUTPUT_DIRECTORY_RELWITHDEBINFO "${TIFF_DIR}/stage/lib"
    ARCHIVE_OUTPUT_DIRECTORY_MINSIZEREL "${TIFF_DIR}/stage/lib"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG "${TIFF_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${TIFF_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${TIFF_DIR}/bin"
    RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${TIFF_DIR}/bin"
    DEBUG_POSTFIX "d")

#================================= Boost ================================#

set(extra_params "")
if (MINGW)
  set(boost_toolset gcc)
elseif (MSVC)
  set(boost_toolset msvc)
  if (WIN_XP)
    set(extra_params "define=_USING_V110_SDK71_ define=BOOST_USE_WINAPI_VERSION=0x0501")
  endif()
else()
  message(FATAL_ERROR "Unsupported platform. MinGW and MSVC are only supported.")
endif()

math(EXPR boost_address_model "${CMAKE_SIZEOF_VOID_P} * 8")
if (CMAKE_BUILD_TYPE EQUAL "Debug")
  set(BOOST_BUILD_TYPE "debug")
else()
  set(BOOST_BUILD_TYPE "release")
endif()

set(boost_build_script "${CMAKE_BINARY_DIR}/build-boost.bat")
set(boost_build_script_generator "${CMAKE_CURRENT_SOURCE_DIR}/cmake/generate_boost_build_script.cmake")

add_custom_command(
    OUTPUT "${boost_build_script}"
    COMMAND "${CMAKE_COMMAND}"
    "-DSOURCE_DIR=${CMAKE_SOURCE_DIR}"
    "-DTARGET_FILE=${boost_build_script}"
    "-DTOOLSET=${boost_toolset}"
    "-DBUILD_TYPE=${BOOST_BUILD_TYPE}"
    "-DADDRESS_MODEL=${boost_address_model}"
    "-DEXTRA_PARAMS=${extra_params}"
    "-DINSTALL_DIR=${BOOST_INSTALL_DIR}"
    -P "${boost_build_script_generator}"
    DEPENDS "${boost_build_script_generator}"
    VERBATIM)

add_custom_target(
    Boost ALL
    COMMAND cmd /c "${boost_build_script}"
    DEPENDS "${boost_build_script}"
    WORKING_DIRECTORY "${BOOST_DIR}")

add_dependencies(
    Boost ${ZLIB_LIBRARY_NAME} ${JPEG_LIBRARY_NAME}
    ${PNG_LIBRARY_NAME} ${TIFF_LIBRARY_NAME})

#=================================== Qt ===================================#

set(QT_MODULES_TO_BUILD qtbase qttools qtimageformats qtsvg)

if (MSVC)
  # Find all *.conf files under mkspecs that mention -Zc:wchar_t- and remove
  # that minus at the end.  That's necessary to make Qt compatible with other
  # libraries that use wchar_t stuff.
  set(qtbase_dir "${QT_DIR}/qtbase")
  file(GLOB_RECURSE conf_files "${qtbase_dir}/mkspecs/*.conf")
  foreach (conf_file ${conf_files})
    if (NOT EXISTS "${conf_file}.orig")
      file(READ "${conf_file}" contents)
      string(REGEX REPLACE "-Zc:wchar_t-" "-Zc:wchar_t" new_contents "${contents}")
      if (NOT "${contents}" STREQUAL "${new_contents}")
        # Make a backup copy
        configure_file("${conf_file}" "${conf_file}.orig" COPYONLY)
        file(WRITE "${conf_file}" "${new_contents}")
      endif()
    endif()
  endforeach()
endif()

if (MINGW)
  set(platform "win32-g++")
  set(make_command "mingw32-make") # -j $ENV{NUMBER_OF_PROCESSORS} isn't required as the make command must be run as a subcommand.
elseif (MSVC)
  find_program(JOM_EXECUTABLE jom HINTS "${SOURCE_OUTER_DIR}")
  if (JOM_EXECUTABLE)
    file_to_native_path("${JOM_EXECUTABLE}" make_command)
    set(make_command "\"${make_command}\" -j $ENV{NUMBER_OF_PROCESSORS}")
  else()
    set(make_command "nmake")
    message(STATUS "Note that building Qt with NMAKE is slow. Consider using JOM instead. \
    Drop jom.exe to the folder with other dependencies and/or set JOM_EXECUTABLE to point to it.")
  endif()
  
  set(platform "win32-msvc")
  if (NOT EXISTS "${QT_DIR}/qtbase/mkspecs/${platform}")
    if (MSVC_TOOLSET_VERSION EQUAL 140)
      string(APPEND platform "2015")
    elseif (MSVC_TOOLSET_VERSION EQUAL 141)
      string(APPEND platform "2017")
    endif()
  endif()
else()
  message(FATAL_ERROR "Unsupported platform.")
endif()

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  set(QT_BUILD_TYPE -debug)
else()
  set(QT_BUILD_TYPE -release)
endif()

set(qt_build_script "${CMAKE_BINARY_DIR}/build-qt.bat")
set(qt_build_script_generator "${CMAKE_CURRENT_SOURCE_DIR}/cmake/generate_qt_build_script.cmake")

set(qt_include_dirs_helper
    "$<TARGET_PROPERTY:${JPEG_LIBRARY_NAME},INTERFACE_INCLUDE_DIRECTORIES>"
    "$<TARGET_PROPERTY:${ZLIB_LIBRARY_NAME},INTERFACE_INCLUDE_DIRECTORIES>"
    "$<TARGET_PROPERTY:${PNG_LIBRARY_NAME},INTERFACE_INCLUDE_DIRECTORIES>")
set(qt_link_dirs_helper
    "$<TARGET_LINKER_FILE_DIR:${JPEG_LIBRARY_NAME}>"
    "$<TARGET_LINKER_FILE_DIR:${ZLIB_LIBRARY_NAME}>"
    "$<TARGET_LINKER_FILE_DIR:${PNG_LIBRARY_NAME}>")
set(qt_runtime_dirs_helper
    "$<TARGET_FILE_DIR:${JPEG_LIBRARY_NAME}>"
    "$<TARGET_FILE_DIR:${ZLIB_LIBRARY_NAME}>"
    "$<TARGET_FILE_DIR:${PNG_LIBRARY_NAME}>")

add_custom_command(
    OUTPUT "${qt_build_script}"
    COMMAND "${CMAKE_COMMAND}"
    "-DSOURCE_DIR=${CMAKE_SOURCE_DIR}"
    "-DTARGET_FILE=${qt_build_script}"
    "-DWIN_XP=${WIN_XP}"
    "-DPLATFORM=${platform}"
    "-DBUILD_TYPE=${QT_BUILD_TYPE}"
    "-DMAKE_COMMAND=${make_command}"
    "-DINSTALL_DIR=${QT_INSTALL_DIR}"
    "-DQT_DIR=${QT_DIR}"
    "-DMODULES_TO_BUILD=${QT_MODULES_TO_BUILD}"
    "-DINCLUDE_DIRS=${qt_include_dirs_helper}"
    "-DLINK_DIRS=${qt_link_dirs_helper}"
    "-DRUNTIME_DIRS=${qt_runtime_dirs_helper}"
    -P "${qt_build_script_generator}"
    DEPENDS "${qt_build_script_generator}"
    VERBATIM)

add_custom_target(
    Qt ALL
    COMMAND cmd /c "${qt_build_script}"
    DEPENDS "${qt_build_script}"
    WORKING_DIRECTORY "${QT_DIR}")

add_dependencies(
    Qt ${ZLIB_LIBRARY_NAME} ${JPEG_LIBRARY_NAME}
    ${PNG_LIBRARY_NAME} ${TIFF_LIBRARY_NAME} Boost)

add_custom_command(
    TARGET Qt POST_BUILD
    COMMAND "${CMAKE_COMMAND}" -E make_directory "${QT_INSTALL_DIR}/bin"
    COMMAND "${CMAKE_COMMAND}" -E copy
    "$<TARGET_FILE:${JPEG_LIBRARY_NAME}>"
    "$<TARGET_FILE:${ZLIB_LIBRARY_NAME}>"
    "$<TARGET_FILE:${PNG_LIBRARY_NAME}>"
    "${QT_INSTALL_DIR}/bin")