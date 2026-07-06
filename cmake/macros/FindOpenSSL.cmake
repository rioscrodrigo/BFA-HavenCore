# - Try to find the OpenSSL encryption library
# Once done this will define
#
#  OPENSSL_ROOT_DIR - Set this variable to the root installation of OpenSSL
#
# Read-Only variables:
#  OPENSSL_FOUND - system has the OpenSSL library
#  OPENSSL_INCLUDE_DIR - the OpenSSL include directory
#  OPENSSL_LIBRARIES - The libraries needed to use OpenSSL

#=============================================================================
# Copyright 2006-2009 Kitware, Inc.
# Copyright 2006 Alexander Neundorf <neundorf@kde.org>
# Copyright 2009-2010 Mathieu Malaterre <mathieu.malaterre@gmail.com>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distributed this file outside of CMake, substitute the full
#  License text for the above reference.)

# http://www.slproweb.com/products/Win32OpenSSL.html

set(OPENSSL_EXPECTED_VERSION "3.0")
set(OPENSSL_MAX_VERSION "4.0")

SET(_OPENSSL_ROOT_HINTS
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL (32-bit)_is1;Inno Setup: App Path]"
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL (64-bit)_is1;Inno Setup: App Path]"
  )

IF(PLATFORM EQUAL 64)
  SET(_OPENSSL_ROOT_PATHS
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL (64-bit)_is1;InstallLocation]"
    "D:/Programs/OpenSSL-Win64/"
    "C:/Programs/OpenSSL-Win64/"
    "C:/OpenSSL-Win64/"
    "C:/OpenSSL/"
  )
ELSE()
  SET(_OPENSSL_ROOT_PATHS
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL (32-bit)_is1;InstallLocation]"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenSSL (32-bit)_is1;InstallLocation]"
    "D:/Programs/OpenSSL-Win32/"
    "C:/OpenSSL/"
  )
ENDIF()

FIND_PATH(OPENSSL_ROOT_DIR
  NAMES
    include/openssl/ssl.h
  HINTS
    ${_OPENSSL_ROOT_HINTS}
  PATHS
    ${_OPENSSL_ROOT_PATHS}
)
MARK_AS_ADVANCED(OPENSSL_ROOT_DIR)

# Re-use the previous path:
FIND_PATH(OPENSSL_INCLUDE_DIR openssl/ssl.h
  ${OPENSSL_ROOT_DIR}/include
)

IF(WIN32 AND NOT CYGWIN)
  # MINGW should go here too
  IF(MSVC)
    # /MD and /MDd are the standard values - if someone wants to use
    # others, the libnames have to change here too
    # use also ssl and ssleay32 in debug as fallback for openssl < 0.9.8b
    # TODO: handle /MT and static lib
    # In Visual C++ naming convention each of these four kinds of Windows libraries has it's standard suffix:
    #   * MD for dynamic-release
    #   * MDd for dynamic-debug
    #   * MT for static-release
    #   * MTd for static-debug

    # Implementation details:
    # We are using the libraries located in the VC subdir instead of the parent directory eventhough :
    # libeay32MD.lib is identical to ../libeay32.lib, and
    # ssleay32MD.lib is identical to ../ssleay32.lib

    # Since OpenSSL 1.1, lib names are like libcrypto32MTd.lib and libssl32MTd.lib
    # Since OpenSSL 3.0, lib names are like libcrypto.lib and libssl.lib
    if( "${CMAKE_SIZEOF_VOID_P}" STREQUAL "8" )
        set(_OPENSSL_MSVC_ARCH_SUFFIX "64")
        set(_OPENSSL_MSVC_ARCH_DIR   "x64")
    else()
        set(_OPENSSL_MSVC_ARCH_SUFFIX "32")
        set(_OPENSSL_MSVC_ARCH_DIR   "x86")
    endif()

    FIND_LIBRARY(LIB_EAY_DEBUG
      NAMES
        libcrypto libcrypto${_OPENSSL_MSVC_ARCH_SUFFIX}MDd libeay32MDd libeay32
      PATHS
        ${OPENSSL_ROOT_DIR}/lib/VC/${_OPENSSL_MSVC_ARCH_DIR}/MDd
        ${OPENSSL_ROOT_DIR}/lib/VC/${_OPENSSL_MSVC_ARCH_DIR}/MD
        ${OPENSSL_ROOT_DIR}/lib/VC
        ${OPENSSL_ROOT_DIR}/lib
    )

    FIND_LIBRARY(LIB_EAY_RELEASE
      NAMES
        libcrypto libcrypto${_OPENSSL_MSVC_ARCH_SUFFIX}MD libeay32MD libeay32
      PATHS
        ${OPENSSL_ROOT_DIR}/lib/VC/${_OPENSSL_MSVC_ARCH_DIR}/MD
        ${OPENSSL_ROOT_DIR}/lib/VC/${_OPENSSL_MSVC_ARCH_DIR}/MDd
        ${OPENSSL_ROOT_DIR}/lib/VC
        ${OPENSSL_ROOT_DIR}/lib
    )

    FIND_LIBRARY(SSL_EAY_DEBUG
      NAMES
        libssl libssl${_OPENSSL_MSVC_ARCH_SUFFIX}MDd ssleay32MDd ssleay32 ssl
      PATHS
        ${OPENSSL_ROOT_DIR}/lib/VC/${_OPENSSL_MSVC_ARCH_DIR}/MDd
        ${OPENSSL_ROOT_DIR}/lib/VC/${_OPENSSL_MSVC_ARCH_DIR}/MD
        ${OPENSSL_ROOT_DIR}/lib/VC
        ${OPENSSL_ROOT_DIR}/lib
    )

    FIND_LIBRARY(SSL_EAY_RELEASE
      NAMES
        libssl libssl${_OPENSSL_MSVC_ARCH_SUFFIX}MD ssleay32MD ssleay32 ssl
      PATHS
        ${OPENSSL_ROOT_DIR}/lib/VC/${_OPENSSL_MSVC_ARCH_DIR}/MD
        ${OPENSSL_ROOT_DIR}/lib/VC/${_OPENSSL_MSVC_ARCH_DIR}/MDd
        ${OPENSSL_ROOT_DIR}/lib/VC
        ${OPENSSL_ROOT_DIR}/lib
    )

    if( CMAKE_CONFIGURATION_TYPES OR CMAKE_BUILD_TYPE )
      set( OPENSSL_LIBRARIES
        optimized ${SSL_EAY_RELEASE} optimized ${LIB_EAY_RELEASE}
        debug ${SSL_EAY_DEBUG} debug ${LIB_EAY_DEBUG}
      )
    else()
      set( OPENSSL_LIBRARIES
        ${SSL_EAY_RELEASE}
        ${LIB_EAY_RELEASE}
      )
    endif()

    MARK_AS_ADVANCED(SSL_EAY_DEBUG SSL_EAY_RELEASE LIB_EAY_DEBUG LIB_EAY_RELEASE)
  ELSEIF(MINGW)

    # same player, for MingW
    FIND_LIBRARY(LIB_EAY
      NAMES
        libeay32
      PATHS
        ${OPENSSL_ROOT_DIR}/lib/MinGW
    )

    FIND_LIBRARY(SSL_EAY NAMES
      NAMES
        ssleay32
      PATHS
        ${OPENSSL_ROOT_DIR}/lib/MinGW
    )

    MARK_AS_ADVANCED(SSL_EAY LIB_EAY)

    set( OPENSSL_LIBRARIES
      ${SSL_EAY}
      ${LIB_EAY}
    )
  ELSE(MSVC)
    # Not sure what to pick for -say- intel, let's use the toplevel ones and hope someone report issues:
    FIND_LIBRARY(LIB_EAY
      NAMES
        libeay32
      PATHS
        ${OPENSSL_ROOT_DIR}/lib
        ${OPENSSL_ROOT_DIR}/lib/VC
    )

    FIND_LIBRARY(SSL_EAY
      NAMES
        ssleay32
      PATHS
        ${OPENSSL_ROOT_DIR}/lib
        ${OPENSSL_ROOT_DIR}/lib/VC
    )
    MARK_AS_ADVANCED(SSL_EAY LIB_EAY)

    SET( OPENSSL_LIBRARIES ${SSL_EAY} ${LIB_EAY} )
  ENDIF(MSVC)
ELSE(WIN32 AND NOT CYGWIN)
  FIND_LIBRARY(OPENSSL_SSL_LIBRARIES NAMES ssl ssleay32 ssleay32MD)
  FIND_LIBRARY(OPENSSL_CRYPTO_LIBRARIES NAMES crypto)
  MARK_AS_ADVANCED(OPENSSL_CRYPTO_LIBRARIES OPENSSL_SSL_LIBRARIES)

  SET(OPENSSL_LIBRARIES ${OPENSSL_SSL_LIBRARIES} ${OPENSSL_CRYPTO_LIBRARIES})

ENDIF(WIN32 AND NOT CYGWIN)

if (NOT OPENSSL_INCLUDE_DIR)
  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(OpenSSL DEFAULT_MSG
    OPENSSL_LIBRARIES
    OPENSSL_INCLUDE_DIR
  )
endif()

if (OPENSSL_INCLUDE_DIR)
  message( STATUS "Found OpenSSL library: ${OPENSSL_LIBRARIES}")
  message( STATUS "Found OpenSSL headers: ${OPENSSL_INCLUDE_DIR}")
  if (_OPENSSL_VERSION)
    set(OPENSSL_VERSION "${_OPENSSL_VERSION}")
  else (_OPENSSL_VERSION)
    # OpenSSL 3.x uses separate OPENSSL_VERSION_MAJOR/MINOR/PATCH defines
    file(STRINGS "${OPENSSL_INCLUDE_DIR}/openssl/opensslv.h" _openssl_version_major_str
         REGEX "^# *define[\t ]+OPENSSL_VERSION_MAJOR[\t ]+[0-9]+")
    if (_openssl_version_major_str)
      # OpenSSL 3.x style version detection
      string(REGEX REPLACE "^.*OPENSSL_VERSION_MAJOR[\t ]+([0-9]+).*$" "\\1"
             OPENSSL_VERSION_MAJOR "${_openssl_version_major_str}")
      file(STRINGS "${OPENSSL_INCLUDE_DIR}/openssl/opensslv.h" _openssl_version_minor_str
           REGEX "^# *define[\t ]+OPENSSL_VERSION_MINOR[\t ]+[0-9]+")
      string(REGEX REPLACE "^.*OPENSSL_VERSION_MINOR[\t ]+([0-9]+).*$" "\\1"
             OPENSSL_VERSION_MINOR "${_openssl_version_minor_str}")
      file(STRINGS "${OPENSSL_INCLUDE_DIR}/openssl/opensslv.h" _openssl_version_patch_str
           REGEX "^# *define[\t ]+OPENSSL_VERSION_PATCH[\t ]+[0-9]+")
      string(REGEX REPLACE "^.*OPENSSL_VERSION_PATCH[\t ]+([0-9]+).*$" "\\1"
             OPENSSL_VERSION_PATCH "${_openssl_version_patch_str}")
      set(OPENSSL_VERSION "${OPENSSL_VERSION_MAJOR}.${OPENSSL_VERSION_MINOR}.${OPENSSL_VERSION_PATCH}")
    else()
      # Legacy OpenSSL 1.x style: OPENSSL_VERSION_NUMBER is 0xMNNFFPPS
      file(STRINGS "${OPENSSL_INCLUDE_DIR}/openssl/opensslv.h" openssl_version_str
           REGEX "^# *define[\t ]+OPENSSL_VERSION_NUMBER[\t ]+0x[0-9][0-9][0-9][0-9][0-9][0-9].*")

      string(REGEX REPLACE "^.*OPENSSL_VERSION_NUMBER[\t ]+0x([0-9a-f])([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])([0-9a-f]).*$"
             "\\1;\\2;\\3;\\4;\\5" OPENSSL_VERSION_LIST "${openssl_version_str}")
      list(GET OPENSSL_VERSION_LIST 0 OPENSSL_VERSION_MAJOR)
      list(GET OPENSSL_VERSION_LIST 1 OPENSSL_VERSION_MINOR)
      list(GET OPENSSL_VERSION_LIST 2 OPENSSL_VERSION_FIX)
      list(GET OPENSSL_VERSION_LIST 3 OPENSSL_VERSION_PATCH)

      string(REGEX REPLACE "^0(.)" "\\1" OPENSSL_VERSION_MINOR "${OPENSSL_VERSION_MINOR}")
      string(REGEX REPLACE "^0(.)" "\\1" OPENSSL_VERSION_FIX "${OPENSSL_VERSION_FIX}")

      if (NOT OPENSSL_VERSION_PATCH STREQUAL "00")
        math(EXPR OPENSSL_VERSION_PATCH_ASCII "${OPENSSL_VERSION_PATCH} + 96")
        string(ASCII "${OPENSSL_VERSION_PATCH_ASCII}" OPENSSL_VERSION_PATCH_STRING)
      endif (NOT OPENSSL_VERSION_PATCH STREQUAL "00")

      set(OPENSSL_VERSION "${OPENSSL_VERSION_MAJOR}.${OPENSSL_VERSION_MINOR}.${OPENSSL_VERSION_FIX}${OPENSSL_VERSION_PATCH_STRING}")
    endif()
  endif (_OPENSSL_VERSION)

  message( STATUS "Found OpenSSL version: ${OPENSSL_VERSION}")

  include(EnsureVersion)
  ENSURE_VERSION("${OPENSSL_EXPECTED_VERSION}" "${OPENSSL_VERSION}" OPENSSL_VERSION_OK)
  if (NOT OPENSSL_VERSION_OK)
      message(FATAL_ERROR "BfaCore needs OpenSSL version >= ${OPENSSL_EXPECTED_VERSION} but found version ${OPENSSL_VERSION}")
  endif()
endif (OPENSSL_INCLUDE_DIR)

MARK_AS_ADVANCED(OPENSSL_INCLUDE_DIR OPENSSL_LIBRARIES)
