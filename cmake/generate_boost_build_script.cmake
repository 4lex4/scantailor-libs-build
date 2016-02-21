FILE(
        WRITE "${TARGET_FILE}"
        "bootstrap.bat mingw\n"
        "b2 toolset=${TOOLSET}\n"
)
