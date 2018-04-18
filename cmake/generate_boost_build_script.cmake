file(
        WRITE "${TARGET_FILE}"
        "bootstrap.bat ${TOOLSET}\n"
        "b2 -q --with-test toolset=${TOOLSET} link=static threading=multi ${EXTRA_PARAMS} -j $ENV{NUMBER_OF_PROCESSORS} stage\n"
)
