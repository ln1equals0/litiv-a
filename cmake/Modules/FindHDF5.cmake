# Copyright (C) 2013 Bjoern Andres, Thorsten Beier and Joerg H.~Kappes.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
#
#
# FindHDF5.cmake -- Find HDF5, a library for reading and writing self describing array data.
#

FIND_PATH(HDF5_INCLUDE_DIR hdf5.h)

FIND_LIBRARY(HDF5_CORE_LIBRARY NAMES hdf5dll hdf5  )
FIND_LIBRARY(HDF5_HL_LIBRARY NAMES hdf5_hldll hdf5_hl  )
FIND_LIBRARY(HDF5_CPP_LIBRARY NAMES hdf5_cppdll hdf5_cpp )

IF(WIN32 AND HDF5_CORE_LIBRARY MATCHES "dll.lib$")
    SET(HDF5_CFLAGS "-D_HDF5USEDLL_")
    SET(HDF5_CPPFLAGS "-D_HDF5USEDLL_ -DHDF5CPP_USEDLL")
ELSE()
    SET(HDF5_CFLAGS)
    SET(HDF5_CPPFLAGS)
ENDIF()

SET(HDF5_VERSION_MAJOR 1)
SET(HDF5_VERSION_MINOR 8)

set(HDF5_SUFFICIENT_VERSION FALSE)

TRY_COMPILE(HDF5_SUFFICIENT_VERSION
    ${CMAKE_BINARY_DIR}/cmake/checks/
    ${CMAKE_SOURCE_DIR}/cmake/checks/checkHDF5version.cpp
    COMPILE_DEFINITIONS
        "-I\"${HDF5_INCLUDE_DIR}\" -DMIN_MAJOR=${HDF5_VERSION_MAJOR} -DMIN_MINOR=${HDF5_VERSION_MINOR}"
)

if(HDF5_SUFFICIENT_VERSION)
    MESSAGE(STATUS
           "Checking HDF5 version (at least ${HDF5_VERSION_MAJOR}.${HDF5_VERSION_MINOR}): ok")
else()
    MESSAGE( STATUS "HDF5: need at least version ${HDF5_VERSION_MAJOR}.${HDF5_VERSION_MINOR}" )
endif()

set(HDF5_USES_ZLIB FALSE)
TRY_COMPILE(HDF5_USES_ZLIB
    ${CMAKE_BINARY_DIR}/cmake/checks/
    ${CMAKE_SOURCE_DIR}/cmake/checks/checkHDF5usesCompression.cpp
    COMPILE_DEFINITIONS "-I\"${HDF5_INCLUDE_DIR}\" -DH5_SOMETHING=H5_HAVE_FILTER_DEFLATE"
)

if(HDF5_USES_ZLIB)
    FIND_LIBRARY(HDF5_Z_LIBRARY NAMES zlib1 zlib z )
    set(HDF5_ZLIB_OK ${HDF5_Z_LIBRARY})
else()
    set(HDF5_ZLIB_OK TRUE)
    set(HDF5_Z_LIBRARY "")
endif()

set(HDF5_USES_SZLIB FALSE)
TRY_COMPILE(HDF5_USES_SZLIB
    ${CMAKE_BINARY_DIR}/cmake/checks/
    ${CMAKE_SOURCE_DIR}/cmake/checks/checkHDF5usesCompression.cpp
    COMPILE_DEFINITIONS "-I\"${HDF5_INCLUDE_DIR}\" -DH5_SOMETHING=H5_HAVE_FILTER_SZIP"
)

if(HDF5_USES_SZLIB)
    FIND_LIBRARY(HDF5_SZ_LIBRARY NAMES szlibdll sz )
    set(HDF5_SZLIB_OK ${HDF5_SZ_LIBRARY})
else()
    set(HDF5_SZLIB_OK TRUE)
    set(HDF5_SZ_LIBRARY "")
endif()

# handle the QUIETLY and REQUIRED arguments and set HDF5_FOUND to TRUE if
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(HDF5 DEFAULT_MSG HDF5_CORE_LIBRARY
        HDF5_HL_LIBRARY HDF5_ZLIB_OK HDF5_SZLIB_OK HDF5_INCLUDE_DIR HDF5_SUFFICIENT_VERSION)

IF(HDF5_FOUND)
    SET(HDF5_LIBRARIES ${HDF5_CORE_LIBRARY} ${HDF5_HL_LIBRARY} ${HDF5_Z_LIBRARY} ${HDF5_SZ_LIBRARY})
ELSE()
    SET(HDF5_CORE_LIBRARY HDF5_CORE_LIBRARY-NOTFOUND)
    SET(HDF5_HL_LIBRARY   HDF5_HL_LIBRARY-NOTFOUND)
    SET(HDF5_Z_LIBRARY    HDF5_Z_LIBRARY-NOTFOUND)
    SET(HDF5_SZ_LIBRARY   HDF5_SZ_LIBRARY-NOTFOUND)
ENDIF(HDF5_FOUND)
