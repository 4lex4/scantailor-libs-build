file(
        WRITE "${TARGET_FILE}"
        "call "
        "bootstrap.bat ${TOOLSET}\n"
        "if %ERRORLEVEL% EQU 0 call "
        "b2 -q --with-test toolset=${TOOLSET} address-model=${ADDRESS_MODEL} variant=${BUILD_TYPE}"
        " link=static runtime-link=static threading=multi ${EXTRA_PARAMS} -j $ENV{NUMBER_OF_PROCESSORS} stage\n"
)