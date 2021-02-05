
# Modified to use pkg config and use standard var names
# Find double-precision version of FFTW3

INCLUDE(FindPkgConfig)
PKG_CHECK_MODULES(PC_FFTW3F "fftw3 >= 3.0")

IF(ANDROID)

    MESSAGE(STATUS "Looking for android fftw3")

    FIND_PATH(
        FFTW3_INCLUDE_DIRS
        NAMES fftw3.h
        HINTS ${ANDROID_SYSROOT}/include
        PATHS ${ANDROID_SYSROOT}/include
        NO_DEFAULT_PATH
        NO_SYSTEM_ENVIRONMENT_PATH
    )

    FIND_LIBRARY(
        FFTW3_LIBRARIES
        NAMES fftw3 libfftw3
        HINTS ${ANDROID_SYSROOT}/lib
        PATHS ${ANDROID_SYSROOT}/lib
        NO_DEFAULT_PATH
        NO_SYSTEM_ENVIRONMENT_PATH
    )

    FIND_LIBRARY(
        FFTW3_THREADS_LIBRARIES
        NAMES fftw3_threads libfftw3_threads
        HINTS ${ANDROID_SYSROOT}/lib
        PATHS ${ANDROID_SYSROOT}/lib
        NO_DEFAULT_PATH
        NO_SYSTEM_ENVIRONMENT_PATH
    )

ELSE()

    MESSAGE(STATUS "Looking for linux fftw3")

    FIND_PATH(
        FFTW3_INCLUDE_DIRS
        NAMES fftw3.h
        HINTS $ENV{FFTW3_DIR}/include
            ${PC_FFTW3_INCLUDE_DIR}
        PATHS /usr/local/include
        /usr/include
    )

    FIND_LIBRARY(
        FFTW3_LIBRARIES
        NAMES fftw3 libfftw3
        HINTS $ENV{FFTW3_DIR}/lib
            ${PC_FFTW3_LIBDIR}
        PATHS /usr/local/lib
            /usr/lib
            /usr/lib64
    )

    FIND_LIBRARY(
        FFTW3_THREADS_LIBRARIES
        NAMES fftw3_threads libfftw3_threads
        HINTS $ENV{FFTW3_DIR}/lib
            ${PC_FFTW3_LIBDIR}
        PATHS /usr/local/lib
            /usr/lib
            /usr/lib64
    )

ENDIF()


INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(FFTW3 DEFAULT_MSG FFTW3_LIBRARIES FFTW3_INCLUDE_DIRS)
MARK_AS_ADVANCED(FFTW3_LIBRARIES FFTW3_INCLUDE_DIRS FFTW3_THREADS_LIBRARIES)