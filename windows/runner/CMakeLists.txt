cmake_minimum_required(VERSION 3.14)
project(enhanced_chameleon_ultra_gui LANGUAGES CXX)

set(BINARY_NAME "enhanced_chameleon_ultra_gui")
set(APPLICATION_ID "com.ddcash.enhanced_chameleon_ultra_gui")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Configure build
set(CMAKE_CONFIGURATION_TYPES "Debug;Profile;Release"
  CACHE STRING "" FORCE)
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE
      STRING "Flutter build mode" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS
      "Debug" "Profile" "Release")
endif()

# Compilation settings that should be applied to most targets.
function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_17)
  target_compile_options(${TARGET} PRIVATE /W4 /WX /wd"4100")
  target_compile_options(${TARGET} PRIVATE /EHsc)
  target_compile_definitions(${TARGET} PRIVATE "_HAS_EXCEPTIONS=0")
  target_compile_definitions(${TARGET} PRIVATE "$<$<CONFIG:Debug>:_DEBUG>")
endfunction()

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

# Flutter library and tool build rules.
add_subdirectory(${FLUTTER_MANAGED_DIR})

# System-level dependencies.
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

add_executable(${BINARY_NAME}
  "main.cpp"
  "win32_window.cpp"
  "utils.cpp"
  "resource.h"
  "${BINARY_NAME}.exe.manifest"
)
apply_standard_settings(${BINARY_NAME})
target_compile_definitions(${BINARY_NAME} PRIVATE "TITLE=\"${BINARY_NAME}\"")
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Win32 dependencies
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_link_libraries(${BINARY_NAME} PRIVATE "uxtheme.lib")

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"1.0.0\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=1")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=0")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=0")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=0")

# Bundle ICU data and VS redistributables
set(REDISTRIBUTABLE_LIBRARIES)
list(APPEND REDISTRIBUTABLE_LIBRARIES ${FLUTTER_LIBRARY})
foreach(bundled_library ${FLUTTER_BUNDLED_LIBRARIES})
  install(FILES "${bundled_library}"
    DESTINATION "${INSTALL_BUNDLE_LIB_DIR}"
    COMPONENT Runtime)
  list(APPEND REDISTRIBUTABLE_LIBRARIES "${bundled_library}")
endforeach(bundled_library)

foreach(lib ${REDISTRIBUTABLE_LIBRARIES})
  get_filename_component(lib_dir "${lib}" DIRECTORY)
  get_filename_component(lib_name "${lib}" NAME)
  add_custom_command(
    TARGET ${BINARY_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      "${lib}" "$<TARGET_FILE_DIR:${BINARY_NAME}>/${lib_name}"
    COMMENT "Copying ${lib_name}"
  )
endforeach(lib)

# Copy flutter assets
file(GLOB FLUTTER_DATA_FILES "${CMAKE_SOURCE_DIR}/data/*")
foreach(data_file ${FLUTTER_DATA_FILES})
  get_filename_component(filename "${data_file}" NAME)
  add_custom_command(
    TARGET ${BINARY_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
      "${data_file}" "$<TARGET_FILE_DIR:${BINARY_NAME}>/data/${filename}"
    COMMENT "Copying ${filename}"
  )
endforeach(data_file)

# Install
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION .)
install(FILES $<TARGET_PDB_FILE:${BINARY_NAME}> DESTINATION . OPTIONAL)