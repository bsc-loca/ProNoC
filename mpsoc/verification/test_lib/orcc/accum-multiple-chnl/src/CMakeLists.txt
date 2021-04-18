# Generated from top

set(filenames
	top.c
	src1.c
	src2.c
	add1.c
	add2.c
	print1.c
	print2.c
)

# [MSVC] Ensure OpenCV imported targets are reachable in this file
# They may be imported in ${extra_libraries}
find_package(OpenCV QUIET)

include_directories(${extra_includes})
add_definitions(${extra_definitions})
add_executable(top ${filenames})

# Build library without any external library required
target_link_libraries(top orcc-native orcc-runtime ${extra_libraries})
