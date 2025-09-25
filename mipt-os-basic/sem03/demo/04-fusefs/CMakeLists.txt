cmake_minimum_required(VERSION 3.19)
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

project(fuse-example)

find_package(FUSE REQUIRED)

set(CMAKE_CXX_FLAGS -D_FILE_OFFSET_BITS=64)

add_executable(fuse-example main.cpp)
target_include_directories(fuse-example PUBLIC ${FUSE_INCLUDE_DIR})
target_link_libraries(fuse-example ${FUSE_LIBRARIES})