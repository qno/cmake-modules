# - try to find DirectDraw library (part of DirectX SDK)
#
# Cache Variables: (probably not for direct use in your scripts)
#  DIRECTDRAW_DXGUID_LIBRARY
#  DIRECTDRAW_DXERR_LIBRARY
#  DIRECTDRAW_DDRAW_LIBRARY
#  DIRECTDRAW_INCLUDE_DIR
#
# Non-cache variables you should use in your CMakeLists.txt:
#  DIRECTDRAW_LIBRARIES
#  DIRECTDRAW_INCLUDE_DIRS
#  DIRECTDRAW_FOUND - if this is not true, do not attempt to use this library
#
# Requires these CMake modules:
#  FindPackageHandleStandardArgs (known included with CMake >=2.6.2)
#
# Author: 2014, Silvio Kunaschk (silvio.kunaschk@gmail.com) 
#
# based on FindDirectInput.cmake by Ryan Pavlik
# Original Author:
# 2011 Ryan Pavlik <rpavlik@iastate.edu> <abiryan@ryand.net>
# http://academic.cleardefinition.com
# Iowa State University HCI Graduate Program/VRAC
#
# Copyright Iowa State University 2011.
# Distributed under the Boost Software License, Version 1.0.
# (See accompanying file LICENSE_1_0.txt or copy at
# http://www.boost.org/LICENSE_1_0.txt)
#


set(DIRECTDRAW_ROOT_DIR
	"${DIRECTDRAW_ROOT_DIR}"
	CACHE
	PATH
	"Root directory to search for DirectX/DIRECTDRAW")

if(MSVC)
	file(TO_CMAKE_PATH "$ENV{ProgramFiles}" _PROG_FILES)
	file(TO_CMAKE_PATH "$ENV{ProgramFiles(x86)}" _PROG_FILES_X86)
	if(_PROG_FILES_X86)
		set(_PROG_FILES "${_PROG_FILES_X86}")
	endif()
	if(CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(_lib_suffixes lib/x64 lib)
	else()
		set(_lib_suffixes lib/x86 lib)
	endif()
	macro(_append_dxsdk_in_inclusive_range _low _high)
		if((NOT MSVC_VERSION LESS ${_low}) AND (NOT MSVC_VERSION GREATER ${_high}))
			list(APPEND DXSDK_DIRS ${ARGN})
		endif()
	endmacro()
	_append_dxsdk_in_inclusive_range(1500 1600 "${_PROG_FILES}/Microsoft DirectX SDK (June 2010)")
	_append_dxsdk_in_inclusive_range(1400 1600
		"${_PROG_FILES}/Microsoft DirectX SDK (February 2010)"
		"${_PROG_FILES}/Microsoft DirectX SDK (August 2009)"
		"${_PROG_FILES}/Microsoft DirectX SDK (March 2009)"
		"${_PROG_FILES}/Microsoft DirectX SDK (November 2008)"
		"${_PROG_FILES}/Microsoft DirectX SDK (August 2008)"
		"${_PROG_FILES}/Microsoft DirectX SDK (June 2008)"
		"${_PROG_FILES}/Microsoft DirectX SDK (March 2008)")
	_append_dxsdk_in_inclusive_range(1310 1500
		"${_PROG_FILES}/Microsoft DirectX SDK (November 2007)"
		"${_PROG_FILES}/Microsoft DirectX SDK (August 2007)"
		"${_PROG_FILES}/Microsoft DirectX SDK (June 2007)"
		"${_PROG_FILES}/Microsoft DirectX SDK (April 2007)"
		"${_PROG_FILES}/Microsoft DirectX SDK (February 2007)"
		"${_PROG_FILES}/Microsoft DirectX SDK (December 2006)"
		"${_PROG_FILES}/Microsoft DirectX SDK (October 2006)"
		"${_PROG_FILES}/Microsoft DirectX SDK (August 2006)"
		"${_PROG_FILES}/Microsoft DirectX SDK (June 2006)"
		"${_PROG_FILES}/Microsoft DirectX SDK (April 2006)"
		"${_PROG_FILES}/Microsoft DirectX SDK (February 2006)")

	file(TO_CMAKE_PATH "$ENV{DXSDK_DIR}" ENV_DXSDK_DIR)
	if(ENV_DXSDK_DIR)
		list(APPEND DXSDK_DIRS ${ENV_DXSDK_DIR})
	endif()
else()
	set(_lib_suffixes lib)
	set(DXSDK_DIRS /mingw)
endif()

find_path(DIRECTDRAW_INCLUDE_DIR
	NAMES
	ddraw.h
	PATHS
	${DXSDK_DIRS}
	HINTS
	"${DIRECTDRAW_ROOT_DIR}"
	PATH_SUFFIXES
	include)

find_library(DIRECTDRAW_DXGUID_LIBRARY
	NAMES
	dxguid
	PATHS
	${DXSDK_DIRS}
	HINTS
	"${DIRECTDRAW_ROOT_DIR}"
	PATH_SUFFIXES
	${_lib_suffixes})

if(DIRECTDRAW_DXGUID_LIBRARY)
	get_filename_component(_ddraw_lib_dir
		${DIRECTDRAW_DXGUID_LIBRARY}
		PATH)
endif()

find_library(DIRECTDRAW_DDRAW_LIBRARY
	NAMES
	ddraw
	PATHS
	${DXSDK_DIRS}
	HINTS
	"${_ddraw_lib_dir}"
	"${DIRECTDRAW_ROOT_DIR}"
	PATH_SUFFIXES
	${_lib_suffixes})

find_library(DIRECTDRAW_DXERR_LIBRARY
	NAMES
	dxerr
	dxerr9
	dxerr8
	PATHS
	${DXSDK_DIRS}
	HINTS
	"${_ddraw_lib_dir}"
	"${DIRECTDRAW_ROOT_DIR}"
	PATH_SUFFIXES
	${_lib_suffixes})
set(DIRECTDRAW_EXTRA_CHECK)
if(DIRECTDRAW_INCLUDE_DIR)
	if(MSVC80)
		set(DXSDK_DEPRECATION_BUILD 1962)
	endif()

	if(DXSDK_DEPRECATION_BUILD)
		include(CheckCSourceCompiles)
		set(_ddraw_old_includes ${CMAKE_REQUIRED_INCLUDES})
		set(CMAKE_REQUIRED_INCLUDES "${DIRECTDRAW_INCLUDE_DIR}")
		check_c_source_compiles(
			"
			#include <dxsdkver.h>
			#if _DXSDK_BUILD_MAJOR >= ${DXSDK_DEPRECATION_BUILD}
			#error
			#else
			int main(int argc, char * argv[]) {
				return 0;
			}
			"
			DIRECTDRAW_SDK_SUPPORTS_COMPILER)
		set(DIRECTDRAW_EXTRA_CHECK DIRECTDRAW_SDK_SUPPORTS_COMPILER)
		set(CMAKE_REQUIRED_INCLUDES "${_ddraw_old_includes}")
	endif()
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DIRECTDRAW
	DEFAULT_MSG
	DIRECTDRAW_DDRAW_LIBRARY
	DIRECTDRAW_DXGUID_LIBRARY
	DIRECTDRAW_DXERR_LIBRARY
	DIRECTDRAW_INCLUDE_DIR
	${DIRECTDRAW_EXTRA_CHECK})

if(DIRECTDRAW_FOUND)
	set(DIRECTDRAW_LIBRARIES
		"${DIRECTDRAW_DXGUID_LIBRARY}"
		"${DIRECTDRAW_DXERR_LIBRARY}"
		"${DIRECTDRAW_DDRAW_LIBRARY}")

	set(DIRECTDRAW_INCLUDE_DIRS "${DIRECTDRAW_INCLUDE_DIR}")

	mark_as_advanced(DIRECTDRAW_ROOT_DIR)
endif()

mark_as_advanced(DIRECTDRAW_DDRAW_LIBRARY
	DIRECTDRAW_DXGUID_LIBRARY
	DIRECTDRAW_DXERR_LIBRARY
	DIRECTDRAW_INCLUDE_DIR)

