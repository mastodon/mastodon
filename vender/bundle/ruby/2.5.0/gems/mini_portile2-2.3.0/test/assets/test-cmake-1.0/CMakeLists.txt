# CMakeLists files in this project can
# refer to the root source directory of the project as ${HELLO_SOURCE_DIR} and
# to the root binary directory of the project as ${HELLO_BINARY_DIR}.
cmake_minimum_required (VERSION 2.8.7)
project (HELLO)
add_executable (hello hello.c)
install (TARGETS hello DESTINATION bin)
