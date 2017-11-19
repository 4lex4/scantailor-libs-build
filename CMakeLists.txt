CMAKE_MINIMUM_REQUIRED(VERSION 3.1.0)

PROJECT("libs build")

INCLUDE(cmake/SetDefaultBuildType.cmake)
INCLUDE(cmake/ListItemsPrepend.cmake)
INCLUDE(cmake/ToNativePath.cmake)

# setting compiler flags
IF (MINGW)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++14")
ENDIF ()

IF (MSVC AND WIN_XP)
	SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /D_USING_V110_SDK71_")
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /D_USING_V110_SDK71_")
	SET(CMAKE_EXE_LINKER_FLAGS "/SUBSYSTEM:CONSOLE,5.01 /SUBSYSTEM:WINDOWS,5.01 ${CMAKE_EXE_LINKER_FLAGS}")
ENDIF ()

SET(
	CMAKE_C_FLAGS "${CMAKE_C_FLAGS}"
	CACHE STRING "Common C flags for all build configurations." FORCE
)
SET(
	CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}"
	CACHE STRING "Common C++ flags for all build configurations." FORCE
)
SET(
	CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}"
	CACHE STRING "Common link flags for all build configurations." FORCE
)

ST_SET_DEFAULT_BUILD_TYPE(Release)

GET_FILENAME_COMPONENT(source_outer_dir "${PROJECT_SOURCE_DIR}/.." ABSOLUTE)

FILE(GLOB jpeg_dir_ "${source_outer_dir}/jpeg-[0-9]*")
FILE(GLOB zlib_dir_ "${source_outer_dir}/zlib-[0-9]*.[0-9]*.[0-9]*")
FILE(GLOB png_dir_1 "${source_outer_dir}/libpng-[0-9]*.[0-9]*.[0-9]*")
FILE(GLOB png_dir_2 "${source_outer_dir}/lpng[0-9]*")
FILE(GLOB tiff_dir_ "${source_outer_dir}/tiff-[0-9]*.[0-9]*.[0-9]*")
FILE(GLOB qt_dir_ "${source_outer_dir}/qt-*-*-[0-9]*.[0-9]*")
FILE(GLOB boost_dir_ "${source_outer_dir}/boost_[0-9]*_[0-9]*_[0-9]*")

FIND_PATH(
        JPEG_DIR jpeglib.h HINTS ${jpeg_dir_}
        DOC "Path to jpeg source directory."
)
FIND_PATH(
        ZLIB_DIR zlib.h HINTS ${zlib_dir_}
        DOC "Path to zlib source directory."
)
FIND_PATH(
        PNG_DIR png.h HINTS ${png_dir_1} ${png_dir_2}
        DOC "Path to libpng source directory."
)
FIND_PATH(
        TIFF_DIR libtiff/tiff.h HINTS ${tiff_dir_}
        DOC "Path to top-level tiff source directory."
)
FIND_PATH(
        QT_DIR configure HINTS ${qt_dir_}
        DOC "Path to top-level Qt source directory."
)
FIND_PATH(
        BOOST_DIR boost/foreach.hpp HINTS ${boost_dir_}
        DOC "Path to top-level Boost source directory."
)

IF (NOT JPEG_DIR)
    MESSAGE(FATAL_ERROR "JPEG source directory not found. You may specify it manually.")
ELSEIF (NOT ZLIB_DIR)
    MESSAGE(FATAL_ERROR "ZLIB source directory not found. You may specify it manually.")
ELSEIF (NOT PNG_DIR)
    MESSAGE(FATAL_ERROR "LibPNG source directory not found. You may specify it manually.")
ELSEIF (NOT TIFF_DIR)
    MESSAGE(FATAL_ERROR "TIFF source directory not found. You may specify it manually.")
ELSEIF (NOT QT_DIR)
    MESSAGE(FATAL_ERROR "Qt source directory not found. You may specify it manually.")
ELSEIF (NOT BOOST_DIR)
    MESSAGE(FATAL_ERROR "Boost source directory not found. You may specify it manually.")
ENDIF ()

IF (MINGW)
    SET(ZLIB_LIBRARY_NAME z)
    SET(PNG_LIBRARY_NAME png)
    SET(JPEG_LIBRARY_NAME jpeg)
    SET(TIFF_LIBRARY_NAME tiff)
ELSE ()
    SET(ZLIB_LIBRARY_NAME zdll)
    SET(PNG_LIBRARY_NAME libpng)
    SET(JPEG_LIBRARY_NAME libjpeg)
    SET(TIFF_LIBRARY_NAME libtiff)
ENDIF ()

#=================================== JPEG ===================================#

IF (MSVC AND (NOT EXISTS "${JPEG_DIR}/jmorecfg.h.orig"))
	# Patch jmorecfg.h to:
	# 1. Prevent double definition of INT32.
	# 2. Build a DLL rather than a static library.
	FILE(READ "${JPEG_DIR}/jmorecfg.h" jmorecfg_h_orig)
	STRING(REPLACE "XMD_H" "_BASETSD_H" jmorecfg_h "${jmorecfg_h_orig}")
	STRING(
		REGEX REPLACE "#define[ \t]+GLOBAL\\(type\\)[^\n]*"
		"#ifdef JPEG_BUILD\n#define GLOBAL(type) __declspec(dllexport) type\n#else\n#define GLOBAL(type) __declspec(dllimport) type\n#endif"
		jmorecfg_h "${jmorecfg_h}"
	)
	STRING(
		REGEX REPLACE "#define[ \t]+EXTERN\\(type\\)[^\n]*"
		"#ifdef JPEG_BUILD\n#define EXTERN(type) extern __declspec(dllexport) type\n#else\n#define EXTERN(type) extern __declspec(dllimport) type\n#endif"
		jmorecfg_h "${jmorecfg_h}"
	)
	FILE(WRITE "${JPEG_DIR}/jmorecfg.h" "${jmorecfg_h}")
	FILE(WRITE "${JPEG_DIR}/jmorecfg.h.orig" "${jmorecfg_h_orig}")
	SET(jmorecfg_h "")
	SET(jmorecfg_h_orig "")
ENDIF ()

SET(
        libjpeg_sources
        jdct.h jerror.h jinclude.h jmemsys.h jmorecfg.h jpegint.h jpeglib.h jversion.h
        jaricom.c jcapimin.c jcapistd.c jcarith.c jccoefct.c jccolor.c
        jcdctmgr.c jchuff.c jcinit.c jcmainct.c jcmarker.c jcmaster.c
        jcomapi.c jcparam.c jcprepct.c jcsample.c jctrans.c jdapimin.c
        jdapistd.c jdarith.c jdatadst.c jdatasrc.c jdcoefct.c jdcolor.c
        jddctmgr.c jdhuff.c jdinput.c jdmainct.c jdmarker.c jdmaster.c
        jdmerge.c jdpostct.c jdsample.c jdtrans.c jerror.c jfdctflt.c
        jfdctfst.c jfdctint.c jidctflt.c jidctfst.c jidctint.c
        jmemmgr.c jmemname.c
        jquant1.c jquant2.c jutils.c 
)

IF(MSVC)
    CONFIGURE_FILE("${JPEG_DIR}/jconfig.vc" "${JPEG_DIR}/jconfig.h" COPYONLY)
ENDIF (MSVC)
IF (MINGW)
    LIST(APPEND libjpeg_sources jconfig.h)
ENDIF (MINGW)

LIST_ITEMS_PREPEND(libjpeg_sources "${JPEG_DIR}/")

ADD_LIBRARY(${JPEG_LIBRARY_NAME} SHARED ${libjpeg_sources})
SET_TARGET_PROPERTIES(
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
        LINKER_LANGUAGE CXX
		DEBUG_POSTFIX "d"
)


#=================================== ZLIB ===================================#

SET(
        zlib_sources
        adler32.c compress.c crc32.c deflate.c inffast.c inflate.c
        inftrees.c trees.c uncompr.c zutil.c
)

LIST_ITEMS_PREPEND(zlib_sources "${ZLIB_DIR}/")

ADD_LIBRARY(${ZLIB_LIBRARY_NAME} SHARED ${zlib_sources})
SET_TARGET_PROPERTIES(
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

INCLUDE_DIRECTORIES(${ZLIB_DIR})

CONFIGURE_FILE(
	"${PNG_DIR}/scripts/pnglibconf.h.prebuilt"
	"${PNG_DIR}/pnglibconf.h" COPYONLY
)

SET(
        libpng_sources
        png.c pngset.c pngget.c pngrutil.c pngtrans.c pngwutil.c pngread.c
        pngrio.c pngwio.c pngwrite.c pngrtran.c pngwtran.c pngmem.c
        pngerror.c pngpread.c
)

IF (MINGW)
	LIST(APPEND libpng_sources config.h)
ENDIF (MINGW)
	
LIST_ITEMS_PREPEND(libpng_sources "${PNG_DIR}/")

ADD_LIBRARY(${PNG_LIBRARY_NAME} SHARED ${libpng_sources})
TARGET_LINK_LIBRARIES(${PNG_LIBRARY_NAME} ${ZLIB_LIBRARY_NAME})
SET_TARGET_PROPERTIES(
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

INCLUDE_DIRECTORIES("${JPEG_DIR}") # ZLIB_DIR already included above
	
SET(
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

if(WIN32_IO)
  list(APPEND libtiff_sources tif_win32.c)
else()
  list(APPEND libtiff_sources tif_unix.c)
endif()

IF(MSVC)
	SET(tiff_vc_config "${TIFF_DIR}/libtiff/tif_config.vc.h")
	IF(EXISTS "${TIFF_DIR}/libtiff/tif_config.h.vc")
		SET(tiff_vc_config "${TIFF_DIR}/libtiff/tif_config.h.vc")
	ENDIF(EXISTS "${TIFF_DIR}/libtiff/tif_config.h.vc")
	CONFIGURE_FILE(
		"${tiff_vc_config}" "${TIFF_DIR}/libtiff/tif_config.h" COPYONLY
	)
	CONFIGURE_FILE(
		"${TIFF_DIR}/libtiff/tiffconf.vc.h"
		"${TIFF_DIR}/libtiff/tiffconf.h" COPYONLY
	)
ENDIF (MSVC)
IF (MINGW)
    LIST(APPEND libtiff_sources tif_config.h tiffconf.h)
ENDIF (MINGW)

LIST_ITEMS_PREPEND(libtiff_sources "${TIFF_DIR}/libtiff/")

ADD_LIBRARY(${TIFF_LIBRARY_NAME} SHARED ${libtiff_sources})
TARGET_LINK_LIBRARIES(
        ${TIFF_LIBRARY_NAME}
        ${PNG_LIBRARY_NAME} ${JPEG_LIBRARY_NAME} ${ZLIB_LIBRARY_NAME}
)
SET_TARGET_PROPERTIES(
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

target_compile_definitions(${TIFF_LIBRARY_NAME} PRIVATE CCITT_SUPPORT=1
                                                        PACKBITS_SUPPORT=1
                                                        LZW_SUPPORT=1
                                                        THUNDER_SUPPORT=1
                                                        NEXT_SUPPORT=1
                                                        LOGLUV_SUPPORT=1
                                                        MDI_SUPPORT=1 # tries to open MS MDI as Tiff
                                                        ZIP_SUPPORT=1
                                                        PIXARLOG_SUPPORT=1
                                                        JPEG_SUPPORT=1
                                                        OJPEG_SUPPORT=1
                                                        #JBIG_SUPPORT=1
                                                        #LZMA_SUPPORT=1
														)

#================================= Boost ================================#

SET(extra_params "")
IF(MINGW)
	SET(boost_toolset gcc)
ELSEIF(MSVC)
	SET(boost_toolset msvc)
	IF(WIN_XP)
		SET(extra_params "define=_USING_V110_SDK71_ define=BOOST_USE_WINAPI_VERSION=0x0501")
	ENDIF()
ELSE(MINGW)
	MESSAGE(FATAL_ERROR "Unsupported platform. MinGW and MSVC are only supported.")
ENDIF(MINGW)

SET(boost_build_script "${CMAKE_BINARY_DIR}/build-boost.bat")

ADD_CUSTOM_COMMAND(
        OUTPUT "${boost_build_script}"
        COMMAND "${CMAKE_COMMAND}"
        "-DTARGET_FILE=${boost_build_script}"
		"-DTOOLSET=${boost_toolset}"
		"-DEXTRA_PARAMS=${extra_params}"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/generate_boost_build_script.cmake"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/cmake/generate_boost_build_script.cmake"
        VERBATIM
)

ADD_CUSTOM_TARGET(
        Boost ALL
        COMMAND "${boost_build_script}"
        DEPENDS "${boost_build_script}"
        WORKING_DIRECTORY "${boost_dir_}"
)

#=================================== Qt ===================================#

FILE(TO_NATIVE_PATH "${JPEG_DIR}" JPEG_INCLUDE_DIR)
FILE(TO_NATIVE_PATH "${ZLIB_DIR}" ZLIB_INCLUDE_DIR)
FILE(TO_NATIVE_PATH "${PNG_DIR}" PNG_INCLUDE_DIR)
FILE(TO_NATIVE_PATH "${QT_DIR}" QT_DIR_NATIVE)

SET(QTBASE_DIR "${QT_DIR}/qtbase")

IF(MSVC)
	# Find all *.conf files under mkspecs that mention -Zc:wchar_t- and remove
	# that minus at the end.  That's necessary to make Qt compatible with other
	# libraries that use wchar_t stuff.
	FILE(GLOB_RECURSE conf_files "${QTBASE_DIR}/mkspecs/*.conf")
	FOREACH(conf_file ${conf_files})
		IF(NOT EXISTS "${conf_file}.orig")
			FILE(READ "${conf_file}" contents)
			STRING(REGEX REPLACE "-Zc:wchar_t-" "-Zc:wchar_t" new_contents "${contents}")
			IF(NOT "${contents}" STREQUAL "${new_contents}")
				# Make a backup copy
				CONFIGURE_FILE("${conf_file}" "${conf_file}.orig" COPYONLY)
				FILE(WRITE "${conf_file}" "${new_contents}")
			ENDIF()
		ENDIF()
	ENDFOREACH()
ENDIF(MSVC)

IF(MINGW)
	SET(platform win32-g++)
	SET(make_command "mingw32-make -j$ENV{NUMBER_OF_PROCESSORS}")
ELSEIF(MSVC)
	FIND_PROGRAM(JOM_EXECUTABLE jom HINTS "${source_outer_dir}")
	IF(JOM_EXECUTABLE)
		TO_NATIVE_PATH("${JOM_EXECUTABLE}" make_command)
		SET(make_command "${make_command} -j $ENV{NUMBER_OF_PROCESSORS}")
	ELSE()
		SET(make_command nmake)
		MESSAGE(STATUS "Note that building Qt with NMAKE is slow. Consider using JOM instead. \
		Drop jom.exe to the folder with other dependencies and/or set JOM_EXECUTABLE to point to it.")
	ENDIF()
	
	SET(platform win32-msvc)
	
	# Qt 5.6.3 is the latest version that supports Win XP
	IF(WIN_XP)
		SET(platform win32-msvc2017)
	ENDIF()
ELSE(MINGW)
	MESSAGE(FATAL_ERROR "Unsupported platform.")
ENDIF(MINGW)

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
	SET(QT_BUILD_TYPE -debug)
else()
	SET(QT_BUILD_TYPE -release)
endif()


SET(qt_build_script "${CMAKE_BINARY_DIR}/build-qt.bat")
SET(qt_build_script_dependency "${CMAKE_CURRENT_SOURCE_DIR}/cmake/generate_qt_build_script.cmake")
IF (WIN_XP)
	SET(qt_build_script_dependency "${CMAKE_CURRENT_SOURCE_DIR}/cmake/generate_qt_build_script_xp.cmake")
ENDIF()

ADD_CUSTOM_COMMAND(
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

ADD_CUSTOM_TARGET(
		Qt ALL
		COMMAND "${qt_build_script}"
		DEPENDS "${qt_build_script}"
		WORKING_DIRECTORY "${QT_DIR}"
)

ADD_DEPENDENCIES(
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
