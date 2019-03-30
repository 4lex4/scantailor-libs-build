# This macro exists because file(TO_NATIVE_PATH ...) is broken on MinGW.
macro(file_to_native_path Path Out)
  if (MINGW)
    file(TO_CMAKE_PATH "${Path}" "${Out}")
    string(REPLACE "/" "\\" "${Out}" "${${Out}}")
  else()
    file(TO_NATIVE_PATH "${Path}" "${Out}")
  endif()
endmacro()