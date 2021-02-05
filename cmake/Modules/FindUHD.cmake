########################################################################
# Find the library for the USRP Hardware Driver
########################################################################

INCLUDE(FindPkgConfig)
PKG_CHECK_MODULES(PC_UHD uhd)

IF(ANDROID)

    FIND_PATH(
        UHD_INCLUDE_DIRS
        NAMES uhd/config.hpp
        HINTS ${ANDROID_SYSROOT}/include
        PATHS ${ANDROID_SYSROOT}/include
        NO_DEFAULT_PATH
        NO_SYSTEM_ENVIRONMENT_PATH
    )

    FIND_LIBRARY(
        UHD_LIBRARIES
        NAMES uhd
        HINTS ${ANDROID_SYSROOT}/lib
        PATHS ${ANDROID_SYSROOT}/lib
        NO_DEFAULT_PATH
        NO_SYSTEM_ENVIRONMENT_PATH
    )

ELSE()

    FIND_PATH(
        UHD_INCLUDE_DIRS
        NAMES uhd/config.hpp
        HINTS $ENV{UHD_DIR}/include
            ${PC_UHD_INCLUDEDIR}
        PATHS /usr/local/include
            /usr/include
    )

    FIND_LIBRARY(
        UHD_LIBRARIES
        NAMES uhd
        HINTS $ENV{UHD_DIR}/lib
            ${PC_UHD_LIBDIR}
        PATHS /usr/local/lib
            /usr/lib
    )

ENDIF()

INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(UHD DEFAULT_MSG UHD_LIBRARIES UHD_INCLUDE_DIRS)
MARK_AS_ADVANCED(UHD_LIBRARIES UHD_INCLUDE_DIRS)
