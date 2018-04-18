cmake_minimum_required(VERSION 3.1.0)

project("libs build")

include(cmake/SetDefaultBuildType.cmake)
include(cmake/ListItemsPrepend.cmake)

# setting compiler flags
set(CMAKE_CXX_STANDARD 17)

if (MSVC)
    set(WIN_XP FALSE CACHE BOOLEAN "Whether to build for Windows XP.")
    
    if (WIN_XP)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /D_USING_V110_SDK71_")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /D_USING_V110_SDK71_")
        set(CMAKE_EXE_LINKER_FLAGS "/SUBSYSTEM:CONSOLE,5.01 /SUBSYSTEM:WINDOWS,5.01 ${CMAKE_EXE_LINKER_FLAGS}")
    endif()

    # Disable checked iterators for extra performance.
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /D_SECURE_SCL=0")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /D_SECURE_SCL=0")
endif()

set(
    CMAKE_C_FLAGS "${CMAKE_C_FLAGS}"
    CACHE STRING "Common C flags for all build configurations." FORCE
)
set(
    CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}"
    CACHE STRING "Common C++ flags for all build configurations." FORCE
)
set(
    CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}"
    CACHE STRING "Common link flags for all build configurations." FORCE
)

st_set_default_build_type(Release)

get_filename_component(source_outer_dir "${PROJECT_SOURCE_DIR}/.." ABSOLUTE)

file(GLOB jpeg_dirs "${source_outer_dir}/jpeg-[0-9]*")
file(GLOB zlib_dirs "${source_outer_dir}/zlib-[0-9]*.[0-9]*.[0-9]*")
file(GLOB png_dirs1 "${source_outer_dir}/libpng-[0-9]*.[0-9]*.[0-9]*")
file(GLOB png_dirs2 "${source_outer_dir}/lpng[0-9]*")
file(GLOB tiff_dirs "${source_outer_dir}/tiff-[0-9]*.[0-9]*.[0-9]*")
file(GLOB qt_dirs "${source_outer_dir}/qt-*-*-[0-9]*.[0-9]*")
file(GLOB boost_dirs "${source_outer_dir}/boost_[0-9]*_[0-9]*_[0-9]*")

find_path(
        JPEG_DIR jpeglib.h HINTS ${jpeg_dirs}
        DOC "Path to jpeg source directory."
)
find_path(
        ZLIB_DIR zlib.h HINTS ${zlib_dirs}
        DOC "Path to zlib source directory."
)
find_path(
        PNG_DIR png.h HINTS ${png_dirs1} ${png_dirs2}
        DOC "Path to libpng source directory."
)
find_path(
        TIFF_DIR libtiff/tiff.h HINTS ${tiff_dirs}
        DOC "Path to top-level tiff source directory."
)
find_path(
        QT_DIR configure HINTS ${qt_dirs}
        DOC "Path to top-level Qt source directory."
)
find_path(
        BOOST_DIR boost/foreach.hpp HINTS ${boost_dirs}
        DOC "Path to top-level Boost source directory."
)

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
        jmorecfg_h "${jmorecfg_h}"
    )
    string(
        REGEX REPLACE "#define[ \t]+EXTERN\\(type\\)[^\n]*"
        "#ifdef JPEG_BUILD\n#define EXTERN(type) extern __declspec(dllexport) type\n#else\n#define EXTERN(type) extern __declspec(dllimport) type\n#endif"
        jmorecfg_h "${jmorecfg_h}"
    )
    file(WRITE "${JPEG_DIR}/jmorecfg.h" "${jmorecfg_h}")
    file(WRITE "${JPEG_DIR}/jmorecfg.h.orig" "${jmorecfg_h_orig}")
    set(jmorecfg_h "")
    set(jmorecfg_h_orig "")
endif()

set(
    libjpeg_sources
    jaricom.c jcapimin.c jcapistd.c jcarith.c jccoefct.c jccolor.c
    jcdctmgr.c jchuff.c jcinit.c jcmainct.c jcmarker.c jcmaster.c
    jcomapi.c jcparam.c jcprepct.c jcsample.c jctrans.c jdapimin.c
    jdapistd.c jdarith.c jdatadst.c jdatasrc.c jdcoefct.c jdcolor.c
    jddctmgr.c jdhuff.c jdinput.c jdmainct.c jdmarker.c jdmaster.c
    jdmerge.c jdpostct.c jdsample.c jdtrans.c jerror.c jfdctflt.c
    jfdctfst.c jfdctint.c jidctflt.c jidctfst.c jidctint.c jquant1.c
    jquant2.c jutils.c jmemmgr.c jmemnobs.c
)

if (MSVC)
    configure_file("${JPEG_DIR}/jconfig.vc" "${JPEG_DIR}/jconfig.h" COPYONLY)
endif()
if (MINGW)
    list(APPEND libjpeg_sources jconfig.h)
endif()

list_items_prepend(libjpeg_sources "${JPEG_DIR}/")

add_library(${JPEG_LIBRARY_NAME} SHARED ${libjpeg_sources})
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
        DEBUG_POSTFIX "d"
)


#=================================== ZLIB ===================================#

set(
        zlib_sources
        adler32.c compress.c crc32.c deflate.c inffast.c inflate.c
        inftrees.c trees.c uncompr.c zutil.c
)

list_items_prepend(zlib_sources "${ZLIB_DIR}/")

add_library(${ZLIB_LIBRARY_NAME} SHARED ${zlib_sources})
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
        DEBUG_POSTFIX "d"
)


#================================== LIBPNG ==================================#

include_directories(${ZLIB_DIR})

configure_file(
    "${PNG_DIR}/scripts/pnglibconf.h.prebuilt"
    "${PNG_DIR}/pnglibconf.h" COPYONLY
)

set(
        libpng_sources
        png.c pngset.c pngget.c pngrutil.c pngtrans.c pngwutil.c pngread.c
        pngrio.c pngwio.c pngwrite.c pngrtran.c pngwtran.c pngmem.c
        pngerror.c pngpread.c
)

if (MINGW)
    list(APPEND libpng_sources config.h)
endif()
    
list_items_prepend(libpng_sources "${PNG_DIR}/")

add_library(${PNG_LIBRARY_NAME} SHARED ${libpng_sources})
target_link_libraries(${PNG_LIBRARY_NAME} ${ZLIB_LIBRARY_NAME})
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
        DEBUG_POSTFIX "d"
)


#=================================== TIFF ===================================#

include_directories("${JPEG_DIR}") # ZLIB_DIR already included above
    
set(
        libtiff_sources
        tiff.h tiffio.h tiffvers.h
        tif_aux.c tif_close.c tif_codec.c tif_color.c tif_compress.c tif_dir.c tif_dirinfo.c
        tif_dirread.c tif_dirwrite.c tif_dumpmode.c tif_error.c tif_extension.c tif_fax3.c
        tif_fax3sm.c tif_flush.c tif_getimage.c tif_jbig.c tif_jpeg.c tif_jpeg_12.c tif_luv.c
        tif_lzma.c tif_lzw.c tif_next.c tif_ojpeg.c tif_open.c tif_packbits.c tif_pixarlog.c
        tif_predict.c tif_print.c tif_read.c tif_strip.c tif_swab.c tif_thunder.c tif_tile.c
        tif_version.c tif_warning.c tif_write.c tif_zip.c
        libtiff.def
)

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
        "${tiff_vc_config}" "${TIFF_DIR}/libtiff/tif_config.h" COPYONLY
    )
    configure_file(
        "${TIFF_DIR}/libtiff/tiffconf.vc.h"
        "${TIFF_DIR}/libtiff/tiffconf.h" COPYONLY
    )
endif()
if (MINGW)
    list(APPEND libtiff_sources tif_config.h tiffconf.h)
endif()

list_items_prepend(libtiff_sources "${TIFF_DIR}/libtiff/")

add_library(${TIFF_LIBRARY_NAME} SHARED ${libtiff_sources})
target_link_libraries(
        ${TIFF_LIBRARY_NAME}
        ${PNG_LIBRARY_NAME} ${JPEG_LIBRARY_NAME} ${ZLIB_LIBRARY_NAME}
)
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
        DEBUG_POSTFIX "d"
)

target_compile_definitions(${TIFF_LIBRARY_NAME} PRIVATE 
        CCITT_SUPPORT=1 PACKBITS_SUPPORT=1 LZW_SUPPORT=1
        THUNDER_SUPPORT=1 NEXT_SUPPORT=1 LOGLUV_SUPPORT=1 MDI_SUPPORT=1 ZIP_SUPPORT=1
        PIXARLOG_SUPPORT=1 JPEG_SUPPORT=1 OJPEG_SUPPORT=1
        #JBIG_SUPPORT=1 #LZMA_SUPPORT=1
)

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

set(boost_build_script "${CMAKE_BINARY_DIR}/build-boost.bat")

add_custom_command(
        OUTPUT "${boost_build_script}"
        COMMAND "${CMAKE_COMMAND}"
        "-DTARGET_FILE=${boost_build_script}"
        "-DTOOLSET=${boost_toolset}"
        "-DEXTRA_PARAMS=${extra_params}"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/generate_boost_build_script.cmake"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/cmake/generate_boost_build_script.cmake"
        VERBATIM
)

add_custom_target(
        Boost ALL
        COMMAND "${boost_build_script}"
        DEPENDS "${boost_build_script}"
        WORKING_DIRECTORY "${boost_dirs}"
)

#=================================== Qt ===================================#

file(TO_NATIVE_PATH "${JPEG_DIR}" JPEG_INCLUDE_DIR)
file(TO_NATIVE_PATH "${ZLIB_DIR}" ZLIB_INCLUDE_DIR)
file(TO_NATIVE_PATH "${PNG_DIR}" PNG_INCLUDE_DIR)

set(QTBASE_DIR "${QT_DIR}/qtbase")

if (MSVC)
    # Find all *.conf files under mkspecs that mention -Zc:wchar_t- and remove
    # that minus at the end.  That's necessary to make Qt compatible with other
    # libraries that use wchar_t stuff.
    file(GLOB_RECURSE conf_files "${QTBASE_DIR}/mkspecs/*.conf")
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
    set(platform win32-g++)
    set(make_command "mingw32-make -j $ENV{NUMBER_OF_PROCESSORS}")
elseif (MSVC)
    find_program(JOM_EXECUTABLE jom HINTS "${source_outer_dir}")
    if (JOM_EXECUTABLE)
        file(TO_NATIVE_PATH "${JOM_EXECUTABLE}" make_command)
        set(make_command "${make_command} -j $ENV{NUMBER_OF_PROCESSORS}")
    else()
        set(make_command nmake)
        message(STATUS "Note that building Qt with NMAKE is slow. Consider using JOM instead. \
        Drop jom.exe to the folder with other dependencies and/or set JOM_EXECUTABLE to point to it.")
    endif()
    
    set(platform win32-msvc)
    
    # Qt 5.6.3 is the latest version that supports Win XP
    if (WIN_XP)
        set(platform win32-msvc2017)
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
set(qt_build_script_dependency "${CMAKE_CURRENT_SOURCE_DIR}/cmake/generate_qt_build_script.cmake")
if (WIN_XP)
    set(qt_build_script_dependency "${CMAKE_CURRENT_SOURCE_DIR}/cmake/generate_qt_build_script_xp.cmake")
endif()

add_custom_command(
        OUTPUT "${qt_build_script}"
        COMMAND "${CMAKE_COMMAND}"
        "-DTARGET_FILE=${qt_build_script}"
        "-DPLATFORM=${platform}"
        "-DBUILD_TYPE=${QT_BUILD_TYPE}"
        "-DMAKE_COMMAND=${make_command}"
        "-DJPEG_INCLUDE_DIR=${JPEG_INCLUDE_DIR}"
        "-DZLIB_INCLUDE_DIR=${ZLIB_INCLUDE_DIR}"
        "-DPNG_INCLUDE_DIR=${PNG_INCLUDE_DIR}"
        "-DJPEG_LINK_DIR=$<TARGET_LINKER_FILE_DIR:${JPEG_LIBRARY_NAME}>"
        "-DZLIB_LINK_DIR=$<TARGET_LINKER_FILE_DIR:${ZLIB_LIBRARY_NAME}>"
        "-DPNG_LINK_DIR=$<TARGET_LINKER_FILE_DIR:${PNG_LIBRARY_NAME}>"
        -P "${qt_build_script_dependency}"
        DEPENDS "${qt_build_script_dependency}"
        VERBATIM
)

add_custom_target(
        Qt ALL
        COMMAND "${qt_build_script}"
        DEPENDS "${qt_build_script}"
        WORKING_DIRECTORY "${QT_DIR}"
)

add_dependencies(
        Qt ${ZLIB_LIBRARY_NAME} ${JPEG_LIBRARY_NAME}
        ${PNG_LIBRARY_NAME} ${TIFF_LIBRARY_NAME}
)

add_custom_command(
            TARGET Qt
            PRE_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE_DIR:${JPEG_LIBRARY_NAME}>/$<TARGET_FILE_NAME:${JPEG_LIBRARY_NAME}>" "${QT_DIR}/qtbase/bin"
)
add_custom_command(
            TARGET Qt
            PRE_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE_DIR:${ZLIB_LIBRARY_NAME}>/$<TARGET_FILE_NAME:${ZLIB_LIBRARY_NAME}>" "${QT_DIR}/qtbase/bin"
)
add_custom_command(
            TARGET Qt
            PRE_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy "$<TARGET_FILE_DIR:${PNG_LIBRARY_NAME}>/$<TARGET_FILE_NAME:${PNG_LIBRARY_NAME}>" "${QT_DIR}/qtbase/bin"
)
