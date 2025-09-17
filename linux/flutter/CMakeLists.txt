# This file controls Flutter-level build steps. It should not be edited.
cmake_minimum_required(VERSION 3.14)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Configuration provided via flutter tool.
include(${EPHEMERAL_DIR}/generated_config.cmake)

# TODO: Move this logic into the flutter tool itself.
set(WRAPPER_ROOT "${EPHEMERAL_DIR}/cpp_client_wrapper")
set(WRAPPER_SRCS
    "${WRAPPER_ROOT}/core_implementations.cc"
    "${WRAPPER_ROOT}/standard_method_codec.cc"
    "${WRAPPER_ROOT}/plugin_registrar.cc"
    "${WRAPPER_ROOT}/flutter_engine.cc"
    "${WRAPPER_ROOT}/flutter_view_controller.cc"
)

# Wrapper sources needed for a plugin.
set(PLUGIN_WRAPPER_SRCS
    "${WRAPPER_ROOT}/plugin_registrar.cc"
)
set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/libflutter_linux_gtk.so")

# Published to parent scope for install step.
set(FLUTTER_LIBRARY ${FLUTTER_LIBRARY} PARENT_SCOPE)
set(FLUTTER_ICU_DATA_FILE "${EPHEMERAL_DIR}/icudtl.dat" PARENT_SCOPE)
set(PROJECT_BUILD_DIR "${PROJECT_DIR}/build/" PARENT_SCOPE)
set(AOT_LIBRARY "${PROJECT_DIR}/build/lib/libapp.so" PARENT_SCOPE)

list(APPEND FLUTTER_LIBRARY_HEADERS
  "flutter_export.h"
  "flutter_messenger.h"
  "flutter_plugin_registrar.h"
  "flutter_texture_registrar.h"
)
list(TRANSFORM FLUTTER_LIBRARY_HEADERS PREPEND "${EPHEMERAL_DIR}/")
add_library(flutter INTERFACE)
target_include_directories(flutter INTERFACE
  "${EPHEMERAL_DIR}"
)
target_link_libraries(flutter INTERFACE "${FLUTTER_LIBRARY}")
target_link_libraries(flutter INTERFACE
  dl
)
add_dependencies(flutter flutter_assemble)

# === Flutter tool generated code ===

set(FLUTTER_TARGET_PLATFORM "linux-x64")
set(FLUTTER_TARGET_ARCH "x64")