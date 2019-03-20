cmake_minimum_required ( VERSION 3.12 )

IF ( POLICY CMP0075 )
	CMAKE_POLICY ( SET CMP0075 NEW )
ENDIF ()

project ( GALERA CXX C )

set ( CMAKE_CXX_STANDARD 11 )

SET ( GALERA_CMAKE_DIR "${GALERA_SOURCE_DIR}/cmake" )
set ( DIAGNOSTIC 1 )

include ( GNUInstallDirs )

include ( "${GALERA_CMAKE_DIR}/galerahelpers.cmake" )


OPTION ( DBUG "dbug is a kind of debug" OFF )
set ( DEBUG_LEVEL -1 CACHE STRING "debug build with optimization level n" )
OPTION ( WITH_BOOST "disable or enable boost libraries" ON )
OPTION ( WITH_BOOST_POOL "use or not use boost pool allocator" OFF )
OPTION ( SYSTEM_ASIO "use system asio library, if available" TRUE )
OPTION ( GALERA_TESTING "internal tests" OFF )
OPTION ( DETERMINISTIC_TESTS "deterministics tesets" OFF )
OPTION ( STRICT_BUILD_FLAGS "Strict build flags" ON )
OPTION ( PSI "Psi flag option" OFF )
set ( WSREP_PATH "" CACHE
		STRING "Path to Write Set Replication API specification sources." )
OPTION ( WITH_GARBD "Build also garbd application" OFF )

# separate property sets for C and CXX
SET ( c_flags "" )
SET ( cxx_flags "" )
SET ( cc_flags "" )

add_common_options ( "-g" )

if ( DEBUG_LEVEL EQUAL 3 )
	add_common_options ( "-O3;-fno-omit-frame-pointer" )
elseif ( DEBUG_LEVEL GREATER -1 AND DEBUG_LEVEL LESS 3 )
	add_common_options ( "-O${DEBUG_LEVEL};-fno-inline" )
else()
	add_common_options ( "-O3;-fno-omit-frame-pointer" )
	add_compile_definitions ( NDEBUG )
endif ()

if ( DBUG )
	add_compile_definitions ( GU_DBUG_ON )
endif()

if ( PSI )
	add_compile_definitions ( HAVE_PSI_INTERFACE )
endif()


# fixme - do the way how galera originally determines it
SET (GALERA_VER "3.35")
get_galera_revision ( GALERA_REV )

message (STATUS "Signature: version: ${GALERA_VER}, revision: ${GALERA_REV}")

set ( LINKS "" )
set ( LINKS_TST "" )

if ( NOT MSVC )
set ( CMAKE_THREAD_PREFER_PTHREAD_FLAG 1 )
set ( CMAKE_THREAD_PREFER_PTHREAD 1 )
find_package ( Threads REQUIRED )
add_main_library ("${CMAKE_THREAD_LIBS_INIT}")
endif()

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
endif ()

# Common C/CXX flags
# These should be kept minimal as they are appended after C/CXX specific flags
add_common_options ( "-fPIC;-Wall;-Wextra;-Wno-unused-parameter" )

# separate property sets for C and CXX
add_c_options ( "-std=c99;-fno-strict-aliasing;-pipe" )
add_cxx_options ( "-pipe;-Wno-long-long;-Wno-deprecated" )
if ( CMAKE_SYSTEM_NAME STREQUAL "Linux" )
	add_compile_definitions ( _XOPEN_SOURCE=600 )
endif()
add_compile_definitions ( HAVE_COMMON_H )

# check the wsrep; extract API version from there.
if ( EXISTS "${WSREP_PATH}/wsrep_api.h" )
	include_directories ("${WSREP_PATH}")
	set (WSREP_API "${WSREP_PATH}/wsrep_api.h" )
elseif ( EXISTS "${GALERA_SOURCE_DIR}/wsrep/src/wsrep_api.h" )
	include_directories ( "${GALERA_SOURCE_DIR}/wsrep/src" )
	set ( WSREP_API "${GALERA_SOURCE_DIR}/wsrep/src/wsrep_api.h" )
else()
	message ( FATAL_ERROR
"********************************************************************************
ERROR: cannot find wsrep_api. If you build from git clone, don't forget to initialize and update submodules, wsrep will be cloned into wsrep/src source folder. It you don't know how - `git submodule init` and then `git submodule update --remote` should help.
If you intend to use it from another place, provide the path in WSREP_PATH parameter. The sources could be cloned, from https://github.com/percona/wsrep-API.git or you may have your own source.
WSREP_INTERFACE_VERSION will be used as SONAME version for resulting library.
********************************************************************************" )
endif()

get_galera_api_version( "${WSREP_API}" WSREP_INTERFACE_VERSION )


if ( NOT CMAKE_SYSTEM_NAME STREQUAL "Darwin" AND NOT MSVC )
	find_library ( LIBRARIES_RT rt )
	if ( NOT LIBRARIES_RT )
		message ( FATAL_ERROR "rt library not found" )
	endif()

	add_main_library ("${LIBRARIES_RT}" )
	mark_as_advanced ( LIBRARIES_RT )
endif ()

check_include_file ( "sys/epoll.h" HAVE_SYS_EPOLL_H )
if ( HAVE_SYS_EPOLL_H )
	add_compile_definitions ( GALERA_USE_GU_NETWORK )
endif ()

check_headers ( "byteswap.h;endian.h;execinfo.h" )

add_compile_definitions ( HAVE_STD_ARRAY )
add_compile_definitions ( HAVE_STD_UNORDERED_MAP )

CheckStdSharedPtr ( HAVE_STD_SHARED_PTR )
if ( HAVE_STD_SHARED_PTR )
	add_compile_definitions ( HAVE_STD_SHARED_PTR )
else ()
	CheckTr1SharedPtr ( HAVE_BOOST_SHARED_PTR_HPP )
	if ( HAVE_BOOST_SHARED_PTR_HPP )
		add_compile_definitions ( HAVE_BOOST_SHARED_PTR_HPP )
	else()
		message ( FATAL_ERROR "No shared ptr available")
	endif()
endif ()

include ( CheckIncludeFileCXX )

if ( WITH_BOOST )
	add_compile_definitions ( BOOST_DATE_TIME_POSIX_TIME_STD_CONFIG=1 )
	find_package ( Boost COMPONENTS system )
	add_main_library ( "${Boost_system_LIBRARY}" )
endif ()

if ( WITH_BOOST_POOL )
	CHECK_INCLUDE_FILE_CXX ( "boost/pool/pool_alloc.hpp" HAVE_BOOST_POOL_POOL_ALLOC_HPP )
	if ( HAVE_BOOST_POOL_POOL_ALLOC_HPP )
		add_compile_definitions ( GALERA_USE_BOOST_POOL_ALLOC=1 )
	endif()
	# fixme! that is switched off by default
endif()

if ( BREWPR )
	SET ( OPENSSL_ROOT_DIR "/usr/local/opt/openssl" )
endif ()

find_package ( OpenSSL REQUIRED )
add_main_library ( "${OPENSSL_LIBRARIES}" )
include_directories ( ${OPENSSL_INCLUDE_DIR} )

# these two internals came from finding openssl
mark_as_advanced ( pkgcfg_lib__OPENSSL_crypto pkgcfg_lib__OPENSSL_ssl )

if ( SYSTEM_ASIO )
	CHECK_INCLUDE_FILE_CXX ( "asio.hpp" HAVE_ASIO_HPP )
	CheckSystemASIOVersion ( ASIO )
	if (ASIO AND HAVE_ASIO_HPP)
		add_compile_definitions ( HAVE_ASIO_HPP )
	else()
		set (SYSTEM_ASIO FALSE)
		message ( STATUS "Falling back to bundled asio" )
	endif()
endif()

if (NOT SYSTEM_ASIO)
	# Make sure that -Iasio goes before other paths (e.g. -I/usr/local/include)
	# that may contain a system wide installed asio. We should use the bundled
	# asio if "scons system_asio=0" is specified. Thus use Prepend().
	include_directories( BEFORE "${GALERA_SOURCE_DIR}/asio")
	populate_env ()
	CHECK_INCLUDE_FILE_CXX ( "asio.hpp" HAVE_ASIO_HPP_NSYS )
	if ( HAVE_ASIO_HPP_NSYS )
		set (HAVE_ASIO_HPP 1)
		add_compile_definitions ( HAVE_ASIO_HPP )
	else()
		message (FATAL_ERROR "asio headers not found or not usable")
	endif()
endif()

populate_env ()
CHECK_INCLUDE_FILE_CXX ( "asio/ssl.hpp" HAVE_ASIO_SSL_HPP "${CMAKE_CXX_FLAGS}" )
if ( NOT HAVE_ASIO_SSL_HPP )
	message ( STATUS "SSL support required but asio/ssl.hpp was not found or not usable" )
	message ( FATAL_ERROR "check that SSL devel headers are installed and usable" )
endif ()

CheckSetEcdhAuto ( ecdhauto )
if ( ecdhauto )
	add_compile_definitions( OPENSSL_HAS_SET_ECDH_AUTO )
endif()

CheckSetTmpEcdh ( tmpecdh )
if ( tmpecdh )
	add_compile_definitions( OPENSSL_HAS_SET_TMP_ECDH )
endif()

if ( STRICT_BUILD_FLAGS )
	add_common_options ( "-Werror;-pedantic" )
	if ( CMAKE_CXX_COMPILER_ID MATCHES "Clang" )
		add_common_options ( "-Wno-self-assign;-Wno-gnu-zero-variadic-macro-arguments" )
		add_cxx_options ( "-Wno-variadic-macros" )
	endif ()
endif()

CheckWeffcpp ( weffcpp )
if ( weffcpp )
	add_cxx_options ( "-Weffc++" )
endif()


if ( GALERA_TESTING )
	include ( CTest )

	find_library ( LIBRARIES_CHECK check )
	if ( NOT LIBRARIES_CHECK )
		message (FATAL_ERROR "Library 'check' is not found, aborting. Consider build without testing.")
	endif()
	add_test_library ( "${LIBRARIES_CHECK}" )
	mark_as_advanced( LIBRARIES_CHECK )

	find_library ( LIBRARIES_SUBUNIT subunit )
	if ( LIBRARIES_SUBUNIT )
		add_test_library ( "${LIBRARIES_SUBUNIT}" )
	endif ()
	mark_as_advanced ( LIBRARIES_SUBUNIT )
endif ( GALERA_TESTING )

find_library ( LIBRARIES_M m )
list ( APPEND LINKS "${CMAKE_THREAD_LIBS_INIT}" )
mark_as_advanced( LIBRARIES_M )


#fixme! tests are not enabled now for simplicitly, todo it later.
if ( DETERMINISTIC_TESTS )
	set ($ENV{GALERA_TEST_DETERMINISTIC} 1)
endif()

add_subdirectory ( galerautils )
add_subdirectory ( gcache )
add_subdirectory ( gcomm )
add_subdirectory ( gcs )
add_subdirectory ( galera )
if ( WITH_GARBD )
	add_subdirectory ( garb )
endif()

set ( TARGET_NAME "galera_manticore" )

add_library ( ${TARGET_NAME} SHARED $<TARGET_OBJECTS:mmgalera> )
target_link_libraries ( ${TARGET_NAME} PRIVATE gcs galerapp gcomm gcache galerautilsxx ${LINKS} )
#set_target_properties ( galera_smm PROPERTIES VERSION ${GALERA_VER} )
set_target_properties ( ${TARGET_NAME} PROPERTIES SOVERSION "${WSREP_INTERFACE_VERSION}" )

diag ( CMAKE_CXX_COMPILER_ID )

if ( SPLIT_SYMBOLS )
	split_dbg ( ${TARGET_NAME} )
endif ()

install ( TARGETS ${TARGET_NAME} LIBRARY DESTINATION usr/lib COMPONENT applications NAMELINK_SKIP )
