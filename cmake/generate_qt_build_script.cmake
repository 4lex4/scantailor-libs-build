include(${SOURCE_DIR}/cmake/ListItemsPrepend.cmake)
include(${SOURCE_DIR}/cmake/ToNativePath.cmake)

function(configure_dirs Var NeedQuotes Prefix Glue)
  list(REMOVE_DUPLICATES ${Var})
  set(tmp_list "")
  foreach (_dir ${${Var}})
    file_to_native_path("${_dir}" native_dir_path)
    if (NeedQuotes)
      set(native_dir_path "\"${native_dir_path}\"")
    endif()
    list(APPEND tmp_list "${native_dir_path}")
  endforeach()
  if (Prefix)
    list_items_prepend(tmp_list "${Prefix}")
  endif()
  list(JOIN tmp_list "${Glue}" tmp_list)
  set(${Var} "${tmp_list}" PARENT_SCOPE)
endfunction()

configure_dirs(INCLUDE_DIRS ON "-I " " ")
configure_dirs(LINK_DIRS ON "-L " " ")
configure_dirs(RUNTIME_DIRS OFF OFF ";")

set(modules_to_skip "")
if (MODULES_TO_BUILD)
  file(GLOB all_modules "${QT_DIR}/qt*")
  foreach (_module ${all_modules})
    if (NOT IS_DIRECTORY "${_module}")
      continue()
    endif()
    get_filename_component(module_name "${_module}" NAME)
    list(FIND MODULES_TO_BUILD "${module_name}" module_found_idx)
    if (module_found_idx EQUAL -1)
      list(APPEND modules_to_skip "-skip ${module_name}")
    endif()
  endforeach()
  list(JOIN modules_to_skip " " modules_to_skip)
endif()

file_to_native_path("${INSTALL_DIR}" INSTALL_DIR)

if (WIN_XP)
  set(EXTRA_COMMANDS "set CL=/D_USING_V110_SDK71_;%CL%\n")
  set(EXTRA_OPTIONS "-target xp")
endif()

file(WRITE "${TARGET_FILE}"
    "set PATH=${RUNTIME_DIRS};%PATH%\n"
    "${EXTRA_COMMANDS}"
    "\n"
    "call configure ${EXTRA_OPTIONS} -platform ${PLATFORM} ${BUILD_TYPE} -shared"
    " -prefix \"${INSTALL_DIR}\""
    " -opengl desktop"
    " -system-zlib -system-libpng -system-libjpeg"
    " ${modules_to_skip}"
    " -nomake examples -nomake tests"
    " -opensource -confirm-license -no-ltcg"
    " ${INCLUDE_DIRS}"
    " ${LINK_DIRS}\n"
    "if %ERRORLEVEL% equ 0 call ${MAKE_COMMAND}\n"
    "if %ERRORLEVEL% equ 0 call ${MAKE_COMMAND} install\n")