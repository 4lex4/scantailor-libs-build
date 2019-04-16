include(${SOURCE_DIR}/cmake/ToNativePath.cmake)

file_to_native_path("${INSTALL_DIR}" INSTALL_DIR)

file(WRITE "${TARGET_FILE}"
    "call bootstrap.bat ${TOOLSET}\n"
    "if %ERRORLEVEL% equ 0 call "
    "b2 -q --with-test toolset=${TOOLSET} address-model=${ADDRESS_MODEL} variant=${BUILD_TYPE}"
    " link=static runtime-link=shared threading=multi ${EXTRA_PARAMS} -j $ENV{NUMBER_OF_PROCESSORS}"
    " --prefix=\"${INSTALL_DIR}\" install\n")