FILE(
        WRITE "${TARGET_FILE}"
        "configure -platform ${PLATFORM} ${BUILD_TYPE} -shared"
		" -opengl desktop"
        " -system-zlib -system-libpng -system-libjpeg"
		" -skip qtquick1 -skip qtlocation"
        " -nomake examples -nomake tests"
        " -opensource -confirm-license -no-ltcg"
        " -I \"${JPEG_INCLUDE_DIR}\" -I \"${ZLIB_INCLUDE_DIR}\""
        " -I \"${PNG_INCLUDE_DIR}\" -L \"${JPEG_LINK_DIR}\" -L \"${ZLIB_LINK_DIR}\""
        " -L \"${PNG_LINK_DIR}\""
        "\n"
        "${MAKE_COMMAND}\n"
)