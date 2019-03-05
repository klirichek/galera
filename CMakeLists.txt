cmake_minimum_required ( VERSION 3.12 )
project ( GALERA )


function( DIAG VARR )
	if ( DIAGNOSTIC )
		message ( STATUS "${VARR} -> ${${VARR}}" )
	endif ()
endfunction()

function( DIAGS MSG )
	if ( DIAGNOSTIC )
		message ( STATUS "${MSG}" )
	endif ()
endfunction()

set (DIAGNOSTIC 1)

set ( CMAKE_CXX_STANDARD 11 )

SET ( GALERA_CMAKE_DIR "${GALERA_SOURCE_DIR}/cmake" )
SET ( CMAKE_MODULE_PATH "${GALERA_SOURCE_DIR}/cmake" )
SET ( EXTRA_LIBRARIES )
SET ( EXTRA_SEARCHD_LIBRARIES )


option ( DEBUG_LEVEL "debug build with optimization level n" OFF )

# initial value, to be refactored
SET (OPT_FLAGS ' -g -O3 -fno-omit-frame-pointer -DNDEBUG')

OPTION ( WITH_BOOST "disable or enable boost libraries" ON )
OPTION ( WITH_BOOST_POOL "use or not use boost pool allocator" OFF )
OPTION ( SYSTEM_ASIO "use system asio library, if available" ON )

# fixme - do the way how galera originally determines it
SET (GALERA_VER '3.35')
SET (GALERA_REV 'XXXX')


include ( helpers )

# Add paths is extra_sysroot argument was specified
set ( EXTRA_SYSROOT "" CACHE PATH "a path to extra development environment (Fink, Homebrew, MacPorts, MinGW)" )

if ( CMAKE_SYSTEM_NAME STREQUAL "Darwin" )
	find_program ( PORTPR port )
	find_program ( BREWPR brew )
	find_program ( FINKPR brew )
	if ( PORTPR )
		set ( EXTRA_SYSROOT "/opt/local" )
	elseif( BREWPR )
		set ( EXTRA_SYSROOT "/usr/local" )
	elseif ( FINKPR )
		set ( EXTRA_SYSROOT "/sw" )
	endif()
	mark_as_advanced ( PORTPR BREWPR FINKPR )
endif()

# fixme! found proper cmake-style way to do this
if ( EXTRA_SYSROOT )
	set ( LIBPATH  "${EXTRA_SYSROOT}/lib")
	set ( CCFLAGS " -I ${EXTRA_SYSROOT}/include" )
endif()

if ( CMAKE_SYSTEM_NAME STREQUAL "Linux" )
	add_definitions("-D_XOPEN_SOURCE=600")
endif()
add_definitions ("-DHAVE_COMMON_H")

set ( CMAKE_CC_FLAGS " -fPIC -Wall -Wextra -Wno-unused-parameter")

set ( CMAKE_C_FLAGS "-std=c99 -fno-strict-aliasing -pipe ${CMAKE_C_FLAGS}" )
set ( CMAKE_CXX_FLAGS "-Wno-long-long -Wno-deprecated -ansi ${CMAKE_CXX_FLAGS} ${CFLAGS}" )
# -pipe

# todo
# Some compilers (gcc <= 4.8 at least) produce a bogus warning for the code
# below when -Weffc++ is used.

#find if malloc_trim() is available
set ( _test_source "
#include <openssl/ssl.h>
int main() { SSL_CTX* ctx=NULL; return !SSL_CTX_set_ecdh_auto(ctx, 1); }")

include ( CheckCXXSourceCompiles )
CHECK_CXX_SOURCE_COMPILES ( "${_test_source}" CheckSetEcdhAuto )
message (STATUS "Checking for SSL_CTX_set_ecdh_auto () ... ${CheckSetEcdhAuto}" )



#message ( STATUS "Looking for threads library" )
find_package ( Threads REQUIRED )


list ( APPEND EXTRA_LIBRARIES ${CMAKE_THREAD_LIBS_INIT} )
#ac_check_func_ex ( "pthread_mutex_timedlock" "" "${CMAKE_THREAD_LIBS_INIT}" )

#message ( STATUS "Checking for endianess" )
#include ( SphEndianess )

message ( STATUS "Checking for library functions" )
ac_search_libs ( "rt" "clock_gettime" EXTRA_LIBRARIES )
ac_check_headers ( "sys/epoll.h;byteswap.h;endian.h;execinfo.h" )

add_definitions ( "-DHAVE_STD_ARRAY" )
add_definitions ( "-DHAVE_STD_SHARED_PTR" )
add_definitions ( "-DHAVE_STD_UNORDERED_MAP" )

CheckSystemASIOVersion ( asio )


diag ( asio )
diag ( CMAKE_SYSTEM_NAME )
diag ( CMAKE_SYSTEM_VERSION )
diag ( CMAKE_SYSTEM_PROCESSOR )

diag ( EXTRA_SYSROOT )
diag ( LIBPATH )
diag ( CCFLAGS )