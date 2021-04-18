# Generated from top

cmake_minimum_required (VERSION 2.6)

project (top)

# Configure ouput folder for generated binary
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_SOURCE_DIR}/bin)

# Definitions configured and used in subdirectories
set(extra_definitions)
set(extra_includes)
set(extra_libraries)

# Runtime libraries inclusion
include_directories(
	${PROJECT_BINARY_DIR}/libs # to find config.h
	libs/orcc-native/include
	libs/orcc-runtime/include
)

# Compile required libs
add_subdirectory(libs)

# Compile application
add_subdirectory(src)
