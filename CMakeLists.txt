cmake_minimum_required ( VERSION 3.12 )
project ( GALERA )

set ( CMAKE_CXX_STANDARD 11 )

SET ( GALERA_CMAKE_DIR "${GALERA_SOURCE_DIR}/cmake" )
SET ( CMAKE_MODULE_PATH "${GALERA_SOURCE_DIR}/cmake" )

set ( DIAGNOSTIC 1 )

option ( DBUG "dbug is a kind of debug" OFF )
set ( DEBUG_LEVEL 3 CACHE INT "debug build with optimization level n" )

# Optimization level
#set ( OPT_FLAGS "-g -O3 -fno-omit-frame-pointer -DNDEBUG")

if ( DEBUG_LEVEL GREATER -1 AND DEBUG_LEVEL LESS 3 )
	SET ( OPT_FLAGS "-g -O${DEBUG_LEVEL} -fno-inline" )
elseif ( DEBUG_LEVEL EQUAL 3 )
	SET (OPT_FLAGS "-g -O3 -fno-omit-frame-pointer")
	add_definitions ("-DNDEBUG")
endif()

if ( DBUG )
	add_definitions ( "-DGU_DBUG_ON" )
endif()

OPTION ( WITH_BOOST "disable or enable boost libraries" ON )
OPTION ( WITH_BOOST_POOL "use or not use boost pool allocator" OFF )
OPTION ( SYSTEM_ASIO "use system asio library, if available" TRUE )
OPTION ( TESTS "internal tests" OFF )
OPTION ( DETERMINISTIC_TESTS "deterministics tesets" OFF )
OPTION ( STRICT_BUILD_FLAGS "Strict build flags" OFF )

OPTION ( PSI "Psi flag option" OFF )
if ( PSI )
	set ( OPT_FLAGS "${OPT_FLAGS} -DHAVE_PSI_INTERFACE")
endif()

include ( helpers )
# fixme - do the way how galera originally determines it
SET (GALERA_VER '3.35')
SET (GALERA_REV 'XXXX')

message (STATUS "Signature: version: ${GALERA_VER}, revision: ${GALERA_REV}")

set ( CC_FLAGS "${OPT_FLAGS}" )
set ( LINKS "" )

set ( CMAKE_THREAD_PREFER_PTHREAD_FLAG 1 )
set ( CMAKE_THREAD_PREFER_PTHREAD 1 )
find_package ( Threads REQUIRED )
list (APPEND LINKS "${CMAKE_THREAD_LIBS_INIT}")

# Add paths is extra_sysroot argument was specified
set ( EXTRA_SYSROOT "" CACHE PATH "a path to extra development environment (Fink, Homebrew, MacPorts, MinGW)" )

if ( CMAKE_SYSTEM_NAME STREQUAL "Darwin" )
	find_program ( PORTPR port )
	find_program ( BREWPR brew )
	find_program ( FINKPR brew )
	if ( PORTPR )
		set ( EXTRA_SYSROOT "/opt/local" )
	elseif ( BREWPR )
		set ( EXTRA_SYSROOT "/usr/local" )
	elseif ( FINKPR )
		set ( EXTRA_SYSROOT "/sw" )
	endif ()
	mark_as_advanced ( PORTPR BREWPR FINKPR )
endif ()

if ( EXTRA_SYSROOT )
	set ( LIBPATH "${LIBPATH} ${EXTRA_SYSROOT}/lib" )
	include_directories ( SYSTEM "${EXTRA_SYSROOT}/include")
#	set ( CC_FLAGS "${CC_FLAGS} -I${EXTRA_SYSROOT}/include" )
endif ()

# Common C/CXX flags
# These should be kept minimal as they are appended after C/CXX specific flags
set ( CC_FLAGS "${CC_FLAGS} -fPIC -Wall -Wextra -Wno-unused-parameter" )

set ( CMAKE_C_FLAGS "-std=c99 -fno-strict-aliasing -pipe ${CMAKE_C_FLAGS}" )
set ( CMAKE_CXX_FLAGS "-pipe -Wno-long-long -Wno-deprecated ${CMAKE_CXX_FLAGS} ${CFLAGS}" )

if ( CMAKE_SYSTEM_NAME STREQUAL "Linux" )
	message (STATUS "Build for linux...")
	add_definitions("-D_XOPEN_SOURCE=600")
endif()
add_definitions ("-DHAVE_COMMON_H")

include_directories ("${GALERA_SOURCE_DIR}/wsrep/src")

if ( NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin" )
	find_library ( LIBRARIES_RT rt )
	if ( NOT LIBRARIES_RT )
		message ( FATAL_ERROR "rt library not found" )
	endif()
	list ( APPEND LINKS "${LIBRARIES_RT}" )
endif ()

check_include_file ( "sys/epoll.h" HAVE_SYS_EPOLL_H )
if ( HAVE_SYS_EPOLL_H )
	add_definitions ( "-DGALERA_USE_GU_NETWORK" )
endif ()

check_headers ( "byteswap.h;endian.h;execinfo.h" )

add_definitions ( "-DHAVE_STD_ARRAY" )
add_definitions ( "-DHAVE_STD_UNORDERED_MAP" )

include ( CheckIncludeFileCXX )

CHECK_INCLUDE_FILE_CXX ( "boost/shared_ptr.hpp" HAVE_BOOST_SHARED_PTR_HPP )
if ( HAVE_BOOST_SHARED_PTR_HPP )
	add_definitions ( "-DHAVE_BOOST_SHARED_PTR_HPP" )
else()
	message(WARNING "Add '#include <algorithm>' to the top of galera/wsdb.cpp to make it work")
	add_definitions ( "-DHAVE_STD_SHARED_PTR" )
endif()

if (WITH_BOOST)
	add_definitions("-DBOOST_DATE_TIME_POSIX_TIME_STD_CONFIG=1")
	find_package ( Boost COMPONENTS system )
	list ( APPEND LINKS "${Boost_system_LIBRARY}" )
endif()

if ( WITH_BOOST_POOL )
	CHECK_INCLUDE_FILE_CXX ( "boost/pool/pool_alloc.hpp" HAVE_BOOST_POOL_POOL_ALLOC_HPP )
	if ( HAVE_BOOST_POOL_POOL_ALLOC_HPP )
		add_definitions ("-DGALERA_USE_BOOST_POOL_ALLOC=1" )
	endif()
	# fixme! that is switched off by default
endif()

if ( BREWPR )
	SET ( OPENSSL_ROOT_DIR "/usr/local/opt/openssl" )
endif ()

find_package ( OpenSSL REQUIRED )
list ( APPEND LINKS "${OPENSSL_LIBRARIES}" )
include_directories ( ${OPENSSL_INCLUDE_DIR} )

if ( SYSTEM_ASIO )
	CHECK_INCLUDE_FILE_CXX ( "asio.hpp" HAVE_ASIO_HPP )
	CheckSystemASIOVersion ( ASIO )
	if (ASIO AND HAVE_ASIO_HPP)
		add_definitions ( "-DHAVE_ASIO_HPP" )
	else()
		set (SYSTEM_ASIO FALSE)
		message ( STATUS "Falling back to bundled asio" )
	endif()
endif()

# that is for CheckIncludeFileCxx (internally it links a test prog)
populate_env ()
set ( CMAKE_REQUIRED_LIBRARIES "${LINKS}" )

if (NOT SYSTEM_ASIO)
	# Make sure that -Iasio goes before other paths (e.g. -I/usr/local/include)
	# that may contain a system wide installed asio. We should use the bundled
	# asio if "scons system_asio=0" is specified. Thus use Prepend().
	include_directories( BEFORE "${GALERA_SOURCE_DIR}/asio")
	CHECK_INCLUDE_FILE_CXX ( "asio.hpp" HAVE_ASIO_HPP_NSYS )
	if ( HAVE_ASIO_HPP_NSYS )
		set (HAVE_ASIO_HPP 1)
		add_definitions ( "-DHAVE_ASIO_HPP" )
	else()
		message (FATAL_ERROR "asio headers not found or not usable")
	endif()
endif()


populate_env ()
set ( CMAKE_REQUIRED_LIBRARIES "${LINKS}" )
CHECK_INCLUDE_FILE_CXX ( "asio/ssl.hpp" HAVE_ASIO_SSL_HPP "${CMAKE_CXX_FLAGS} ${CC_FLAGS}" )
if ( NOT HAVE_ASIO_SSL_HPP )
	message ( STATUS "SSL support required but asio/ssl.hpp was not found or not usable" )
	message ( FATAL_ERROR "check that SSL devel headers are installed and usable" )
endif ()

CheckSetEcdhAuto ( ecdhauto )
if ( ecdhauto )
	add_definitions("-DOPENSSL_HAS_SET_ECDH_AUTO")
endif()

CheckSetTmpEcdh ( tmpecdh )
if ( tmpecdh )
	add_definitions("-DOPENSSL_HAS_SET_TMP_ECDH")
endif()

if ( STRICT_BUILD_FLAGS )
	SET (CC_FLAGS "${CC_FLAGS} -Werror -pedantic")
endif()

CheckWeffcpp ( weffcpp )
if ( weffcpp )
	SET (CMAKE_CXX_FLAGS "-Weffc++ ${CMAKE_CXX_FLAGS}")
endif()

SET ( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CC_FLAGS}")
SET ( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CC_FLAGS}" )

set (LINKS_TST "")

# m.b. this is need only for tests?
find_library ( LIBRARIES_CHECK check )
list ( APPEND LINKS "${LIBRARIES_CHECK}" )
list ( APPEND LINKS_TST "${LIBRARIES_CHECK}" )

find_library ( LIBRARIES_M m )
list ( APPEND LINKS "${CMAKE_THREAD_LIBS_INIT}" )

# m.b. this is need only for tests?
find_library ( LIBRARIES_SUBUNIT subunit )
if ( LIBRARIES_SUBUNIT )
	list ( APPEND LINKS "${LIBRARIES_SUBUNIT}" )
	list ( APPEND LINKS_TST "${LIBRARIES_SUBUNIT}" )
endif()

#fixme! tests are not enabled now for simplicitly, todo it later.
if ( DETERMINISTIC_TESTS )
	set ($ENV{GALERA_TEST_DETERMINISTIC} 1)
endif()

diag ( CMAKE_SYSTEM_NAME )
diag ( CMAKE_SYSTEM_VERSION )
diag ( CMAKE_SYSTEM_PROCESSOR )
diag ( CMAKE_C_FLAGS )
diag ( CMAKE_CXX_FLAGS )

add_subdirectory ( galerautils )
add_subdirectory ( gcache )
add_subdirectory ( gcomm )
add_subdirectory ( gcs )
add_subdirectory ( galera )
add_subdirectory ( garb )

#diag ( CMAKE_SYSTEM_NAME )
#diag ( CMAKE_SYSTEM_VERSION )
#diag ( CMAKE_SYSTEM_PROCESSOR )
#diag ( CMAKE_C_FLAGS )
#diag ( CMAKE_CXX_FLAGS )
#diag ( LINK_LIBRARIES )

