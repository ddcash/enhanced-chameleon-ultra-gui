cmake_minimum_required(VERSION 3.10)
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
  target_compile_features(${TARGET} PUBLIC cxx_std_14)
  target_compile_options(${TARGET} PRIVATE -Wall -Werror)
  target_compile_options(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:-O3>")
  target_compile_definitions(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:NDEBUG>")
endfunction()

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

# Flutter library and tool build rules.
add_subdirectory(${FLUTTER_MANAGED_DIR})

# System-level dependencies.
find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)
apply_standard_settings(${BINARY_NAME})
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

# Add dependency libraries
target_link_libraries(${BINARY_NAME} PRIVATE
  PkgConfig::GTK
)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "APPLICATION_ID=\"${APPLICATION_ID}\"")

# Install
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION bin)
install(FILES "${FLUTTER_LIBRARY}" DESTINATION lib)

# Install so files
install(DIRECTORY "${CMAKE_SOURCE_DIR}/linux/" DESTINATION .
  FILES_MATCHING PATTERN "*.so*")