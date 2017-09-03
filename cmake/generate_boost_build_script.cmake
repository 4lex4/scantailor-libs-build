FILE(
        WRITE "${TARGET_FILE}"
        "bootstrap.bat ${TOOLSET}\n"
        "b2 toolset=${TOOLSET} link=static threading=multi --build-type=complete stage\n"
)
