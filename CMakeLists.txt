########################################################################
# Top Level CMakeLists.txt
#
########################################################################

########################################################################
# Project setup
########################################################################
cmake_minimum_required(VERSION 3.9)
project(fun_ofdm)

# Version Number: 1.0
set(fun_ofdm_VERSION_MAJOR 1)
set(fun_ofdm_VERSION_MINOR 1)
set(fun_ofdm_VERSION_PATCH 0)

#set(CMAKE_BUILD_TYPE "Debug")
set(CMAKE_BUILD_TYPE "Release")

#select the release build type by default to get optimization flags
if(NOT CMAKE_BUILD_TYPE)
   set(CMAKE_BUILD_TYPE "Release")
   message(STATUS "Build type not specified: defaulting to release.")
endif()
set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE} CACHE STRING "")

message(STATUS "Build type is " ${CMAKE_BUILD_TYPE})

# Set binary output to fun_ofdm/build/bin & library output to fun_ofdm/build/lib
if(CMAKE_BUILD_TYPE MATCHES Debug)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin/)
	set(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib/)
endif()

# Set binary output to fun_ofdm/bin & library output to fun_ofdm/lib
if(CMAKE_BUILD_TYPE MATCHES Release)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/bin/)
	set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib/)
endif()

# Tell cmake to look in ./cmake/Modules to find instructions to find external modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/Modules)

########################################################################
# Compiler specific setup
########################################################################
# C++ Compile Flags
set(CMAKE_CXX_FLAGS "-m64 -std=c++11 -mssse3 -msse4.1")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3") # Optimization!!

########################################################################
# Find build dependencies
########################################################################

# Find boost
IF(ANDROID)
    IF((DEFINED ANDROID_ABI) AND (DEFINED ANDROID_ARCH) AND (DEFINED ANDROID_SYSROOT))
        SET(CMAKE_C_COMPILER "${ANDROID_ARCH}-linux-android${ANDROID_ABI}-clang")
        SET(CMAKE_CXX_COMPILER "${ANDROID_ARCH}-linux-android${ANDROID_ABI}-clang++")

        EXECUTE_PROCESS(COMMAND "which" "${CMAKE_C_COMPILER}" OUTPUT_VARIABLE COMPILER_PATH)
        EXECUTE_PROCESS(COMMAND "dirname" "${COMPILER_PATH}" OUTPUT_VARIABLE COMPILER_DIR)

        SET(NDK_ROOTDIR "${COMPILER_DIR}/..")

        MESSAGE(STATUS "Using c++ compiler: ${CMAKE_CXX_COMPILER}")

        SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-unused-command-line-argument")
        SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fexceptions -static-libstdc++ -Wno-unused-command-line-argument")

        INCLUDE_DIRECTORIES("${ANDROID_SYSROOT}/include")
        LINK_DIRECTORIES("${ANDROID_SYSROOT}/system/lib64")
        LINK_DIRECTORIES("${ANDROID_SYSROOT}/system/vendor/lib64")

        FIND_LIBRARY(OpenCL 2.2 REQUIRED
            HINTS "${ANDROID_SYSROOT}/system/vendor/lib64"
        )

        LIST(APPEND INCLUDE_PATHS
            "${ANDROID_SYSROOT}/include"
            "${NDK_ROOTDIR}/sysroot/include"
            "${NDK_ROOTDIR}/sysroot/usr/include"
            "${NDK_ROOTDIR}/sysroot/usr/local/include"
            "${NDK_ROOTDIR}/sysroot/usr/include/aarch64-linux-android"
        )

        unset(BOOST_INCLUDEDIR)
        unset(BOOST_LIBRARYDIR)

        set(Boost_NO_BOOST_CMAKE ON)
        set(Boost_NO_SYSTEM_PATHS ON)
        set(Boost_USE_STATIC_LIBS ON)
        set(Boost_COMPILER "-clang")
        set(Boost_ARCHITECTURE "-a64")

        list(APPEND BOOST_INCLUDEDIR "${ANDROID_SYSROOT}/include")
        list(APPEND BOOST_LIBRARYDIR "${ANDROID_SYSROOT}/lib")

        message(STATUS "${BOOST_INCLUDEDIR}")

    ELSE()
        MESSAGE(ERROR "Android build requires ANDROID_ABI, ANDROID_ARCH, and ANDROID_SYSROOT to be defined")
    ENDIF()

ELSE()

    if(UNIX AND EXISTS "/usr/lib64")
        list(APPEND BOOST_LIBRARYDIR "/usr/lib64") #fedora 64-bit fix
    endif(UNIX AND EXISTS "/usr/lib64")


ENDIF()

# If you want to use a boost version greater than 1.69.0 then you will have to
# add it to this list
set(Boost_ADDITIONAL_VERSIONS
    "1.35.0" "1.35" "1.36.0" "1.36" "1.37.0" "1.37" "1.38.0" "1.38" "1.39.0" "1.39"
    "1.40.0" "1.40" "1.41.0" "1.41" "1.42.0" "1.42" "1.43.0" "1.43" "1.44.0" "1.44"
    "1.45.0" "1.45" "1.46.0" "1.46" "1.47.0" "1.47" "1.48.0" "1.48" "1.49.0" "1.49"
    "1.50.0" "1.50" "1.51.0" "1.51" "1.52.0" "1.52" "1.53.0" "1.53" "1.54.0" "1.54"
    "1.55.0" "1.55" "1.56.0" "1.56" "1.57.0" "1.57" "1.58.0" "1.58" "1.59.0" "1.59"
    "1.60.0" "1.60" "1.61.0" "1.61" "1.62.0" "1.62" "1.63.0" "1.63" "1.64.0" "1.64"
    "1.65.0" "1.65" "1.66.0" "1.66" "1.67.0" "1.67" "1.68.0" "1.68" "1.69.0" "1.69"
)

find_package(Boost "1.59" COMPONENTS filesystem system thread) # Might need more components

if(NOT Boost_FOUND)
    message(FATAL_ERROR "Boost required to compile fun_ofdm")
endif()

IF(ANDROID)
    list(REMOVE_ITEM Boost_LIBRARIES "-lpthread")
ENDIF()

# Find UHD
find_package(UHD)
if(NOT UHD_FOUND)
    message(FATAL_ERROR "UHD required to compile fun_ofdm")
else()
    message("Found UHD in ${UHD_DIR} lib in ${UHD_LIBRARY_DIR}")
endif()

# Find fftw3
find_package(FFTW3)
if(NOT FFTW3_FOUND)
    message(FATAL_ERROR "FFTW3 required to compile fun_ofdm")
endif()

find_package(Threads)
if(NOT Threads_FOUND)
    message(FATAL_ERROR "Threads required to compile fun_ofdm")
endif()

########################################################################
# Create uninstall target
########################################################################
configure_file(
    ${CMAKE_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
@ONLY)

add_custom_target(uninstall
    ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
)

########################################################################
# Make sure /usr/local/include is in the include path
# TODO: Make this configurable in case things aren't installed here
########################################################################
include_directories("/usr/local/include")
include_directories("/opt/local/include")

########################################################################
# Add subdirectories
########################################################################
add_subdirectory(src)
add_subdirectory(examples)

