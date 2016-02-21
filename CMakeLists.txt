CMAKE_MINIMUM_REQUIRED(VERSION 2.8.4)

PROJECT("libs build")

INCLUDE(cmake/SetDefaultBuildType.cmake)
INCLUDE(cmake/ListItemsPrepend.cmake)

IF (CMAKE_COMPILER_IS_GNUCC AND CMAKE_COMPILER_IS_GNUCXX)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
	set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS "-static-libgcc -static-libstdc++")
ENDIF ()

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

configure_file(${JPEG_DIR}/jconfig.vc
               ${JPEG_DIR}/jconfig.h)
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

configure_file(${PNG_DIR}/scripts/pnglibconf.h.prebuilt
               ${PNG_DIR}/pnglibconf.h)
SET(
        libpng_sources
        png.c pngset.c pngget.c pngrutil.c pngtrans.c pngwutil.c pngread.c
        pngrio.c pngwio.c pngwrite.c pngrtran.c pngwtran.c pngmem.c
        pngerror.c pngpread.c
)
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

configure_file(${TIFF_DIR}/libtiff/tif_config.vc.h
               ${TIFF_DIR}/libtiff/tif_config.h
               @ONLY)
configure_file(${TIFF_DIR}/libtiff/tiffconf.vc.h
               ${TIFF_DIR}/libtiff/tiffconf.h
               @ONLY)
			   
IF(MINGW)
	FILE(READ "${TIFF_DIR}/libtiff/tif_config.h" tif_config_h)
	FILE(READ "${TIFF_DIR}/libtiff/tiffconf.h" tiffconf_h)
	FILE(READ "${TIFF_DIR}/libtiff/tiffiop.h" tiffiop_h)
	STRING(REPLACE "__int64" "long long" tif_config_h "${tif_config_h}")
	STRING(REPLACE "__int64" "long long" tiffconf_h "${tiffconf_h}")
	
	STRING(REPLACE "snprintf" "dummy" tif_config_h "${tif_config_h}")
	STRING(REPLACE "snprintf" "dummy" tiffiop_h "${tiffiop_h}")
	
	FILE(WRITE "${TIFF_DIR}/libtiff/tif_config.h" "${tif_config_h}")
	FILE(WRITE "${TIFF_DIR}/libtiff/tiffconf.h" "${tiffconf_h}")
	FILE(WRITE "${TIFF_DIR}/libtiff/tiffiop.h" "${tiffiop_h}")
	
	SET(tif_config_h "")
	SET(tiffconf_h "")
	SET(tiffiop_h "")
ENDIF()

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

#================================= Boost ================================#

IF(MINGW)
	SET(boost_toolset gcc)
ELSEIF(MSVC)
	SET(boost_toolset msvc)
ELSE(MINGW)
	MESSAGE(FATAL_ERROR "Unsupported platform. MinGW and MSVC are only supported.")
ENDIF(MINGW)

SET(boost_build_script "${CMAKE_BINARY_DIR}/build-boost.bat")

ADD_CUSTOM_COMMAND(
        OUTPUT "${boost_build_script}"
        COMMAND "${CMAKE_COMMAND}"
        "-DTARGET_FILE=${boost_build_script}"
		"-DTOOLSET=${boost_toolset}"
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

FILE(READ "${QT_DIR}/qtbase/mkspecs/win32-g++/qmake.conf" qmake_conf)
STRING(REPLACE "QMAKE_CFLAGS_DEBUG      = -g" "QMAKE_CFLAGS_DEBUG      = -g -Wa,-mbig-obj" qmake_conf "${qmake_conf}")
FILE(WRITE "${QT_DIR}/qtbase/mkspecs/win32-g++/qmake.conf" "${qmake_conf}")
SET(qmake_conf "")

FILE(TO_NATIVE_PATH "${JPEG_DIR}" JPEG_INCLUDE_DIR)
FILE(TO_NATIVE_PATH "${ZLIB_DIR}" ZLIB_INCLUDE_DIR)
FILE(TO_NATIVE_PATH "${PNG_DIR}" PNG_INCLUDE_DIR)
FILE(TO_NATIVE_PATH "${QT_DIR}" QT_DIR_NATIVE)

IF(MINGW)
	SET(platform win32-g++)
	SET(make_command "mingw32-make -j$ENV{NUMBER_OF_PROCESSORS}")
ELSEIF(MSVC)
	#MESSAGE("MSVC=${MSVC} | MSVC10=${MSVC10} | MSVC80=${MSVC80}" )
	SET(make_command nmake)
	IF(MSVC60 OR MSVC70)
		MESSAGE(FATAL_ERROR "This Visual Studio version is too old and is not supported")
	ELSEIF(MSVC71)
		SET(platform win32-msvc2003)
	ELSEIF(MSVC80)
		SET(platform win32-msvc2005)
		SET(force_frame_pointer TRUE)
	ELSEIF(MSVC90)
		SET(platform win32-msvc2008)
		SET(force_frame_pointer TRUE)
	ELSE()
		# Visual Studio 2010 or above.
		SET(platform win32-msvc2010)
		SET(force_frame_pointer TRUE)
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
        -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/generate_qt_build_script.cmake"
        DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/cmake/generate_qt_build_script.cmake"
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
