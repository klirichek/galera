if ( __cmake_helpers_included )
	return ()
endif ()
set ( __cmake_helpers_included YES )

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

# check for list of headers, ;-separated. For every existing header.h
# the HAVE_HEADER_H became defined as 1
include ( CheckIncludeFile )
function ( check_headers _HEADERS )
	foreach ( it ${_HEADERS} )
		string ( REGEX REPLACE "[/.]" "_" _it "${it}" )
		string ( TOUPPER "${_it}" _it )
		check_include_file ( "${it}" "HAVE_${_it}" )
		if ( HAVE_${_it} )
			add_compile_definitions ("HAVE_${_it}")
		endif()
	endforeach ( it )
endfunction ( check_headers )

# old cmake doesn't understand $<TARGET_FILE:${BINARYNAME}>
function ( INSTALL_BINARY BINARYNAME )
		INSTALL ( PROGRAMS $<TARGET_FILE:${BINARYNAME}> DESTINATION ${BINDIR} COMPONENT APPLICATIONS )
endfunction()

function ( GET_SONAME RAWLIB OUTVAR )
	if ( NOT MSVC )
		if ( APPLE )
			GET_FILENAME_COMPONENT ( _OUTVAR ${RAWLIB} NAME )
			set ( "${OUTVAR}" "${_OUTVAR}" PARENT_SCOPE )
		else()
			if ( NOT DEFINED CMAKE_OBJDUMP )
				find_package ( BinUtils QUIET )
			endif ()
			if ( NOT DEFINED CMAKE_OBJDUMP )
				find_program ( CMAKE_OBJDUMP objdump )
			endif ()
			mark_as_advanced ( CMAKE_OBJDUMP BinUtils_DIR )
			execute_process ( COMMAND "${CMAKE_OBJDUMP}" -p "${RAWLIB}"
					WORKING_DIRECTORY "${SOURCE_DIR}"
					RESULT_VARIABLE res
					OUTPUT_VARIABLE _CONTENT
					ERROR_QUIET
					OUTPUT_STRIP_TRAILING_WHITESPACE )

			STRING ( REGEX REPLACE "\n" ";" _CONTENT "${_CONTENT}" )
			FOREACH ( LINE ${_CONTENT} )
				IF ( "${LINE}" MATCHES "^[ \t]+SONAME[ \t]+(.*)" )
					set ( "${OUTVAR}" "${CMAKE_MATCH_1}" PARENT_SCOPE)
				endif ()
			endforeach ()
		endif()
	endif()
endfunction()

# windows case. The pdbs are located in bin/config/*.pdb
function( __install_win_dbg BINARYNAME )
	set ( PDB_PATH "${CMAKE_CURRENT_BINARY_DIR}/\${CMAKE_INSTALL_CONFIG_NAME}" )
	INSTALL ( FILES ${PDB_PATH}/${BINARYNAME}.pdb DESTINATION debug COMPONENT DBGSYMBOLS )
endfunction()

# Mac OS case. We have to explicitly extract dSYM and then strip the binary
function( __install_apple_dbg BINARYNAME )

	if ( NOT DEFINED CMAKE_DSYMUTIL )
		find_program ( CMAKE_DSYMUTIL dsymutil )
	endif ()
	if ( NOT DEFINED CMAKE_DSYMUTIL )
		message ( SEND_ERROR "Missed objcopy prog. Can't split symbols!" )
		unset ( SPLIT_SYMBOLS CACHE )
	endif ()
	mark_as_advanced ( CMAKE_DSYMUTIL )

	ADD_CUSTOM_COMMAND ( TARGET ${BINARYNAME} POST_BUILD
			COMMAND ${CMAKE_DSYMUTIL} -f $<TARGET_FILE:${BINARYNAME}> -o $<TARGET_FILE:${BINARYNAME}>.dSYM
			COMMAND strip -S $<TARGET_FILE:${BINARYNAME}>
			)
	INSTALL ( FILES $<TARGET_FILE:${BINARYNAME}>.dSYM
			DESTINATION ${CMAKE_INSTALL_LIBDIR}/debug/usr/bin COMPONENT DBGSYMBOLS )
endfunction()

# non-windows case. For linux - use objcopy to make 'clean' and 'debug' binaries
function( __install_linux_dbg BINARYNAME )
	if ( NOT DEFINED CMAKE_OBJCOPY )
		find_package ( BinUtils QUIET )
	endif ()
	if ( NOT DEFINED CMAKE_OBJCOPY )
		find_program ( CMAKE_OBJCOPY objcopy )
	endif ()
	if ( NOT DEFINED CMAKE_OBJCOPY )
		message ( SEND_ERROR "Missed objcopy prog. Can't split symbols!" )
		unset ( SPLIT_SYMBOLS CACHE )
	endif ( NOT DEFINED CMAKE_OBJCOPY )
	mark_as_advanced ( CMAKE_OBJCOPY BinUtils_DIR )

	ADD_CUSTOM_COMMAND ( TARGET ${BINARYNAME} POST_BUILD
			COMMAND ${CMAKE_OBJCOPY} --only-keep-debug $<TARGET_FILE:${BINARYNAME}> $<TARGET_FILE:${BINARYNAME}>.dbg
			COMMAND ${CMAKE_OBJCOPY} --strip-all $<TARGET_FILE:${BINARYNAME}>
			COMMAND ${CMAKE_OBJCOPY} --add-gnu-debuglink=$<TARGET_FILE:${BINARYNAME}>.dbg $<TARGET_FILE:${BINARYNAME}>
			)

	INSTALL ( FILES $<TARGET_FILE:${BINARYNAME}>.dbg
			DESTINATION ${CMAKE_INSTALL_LIBDIR}/debug/usr/bin COMPONENT DBGSYMBOLS RENAME ${BINARYNAME} )
endfunction()

# add debug symbols to the target
function( INSTALL_DBG BINARYNAME )
	if ( MSVC )
		__install_win_dbg ( ${BINARYNAME})
	elseif ( APPLE )
		__install_apple_dbg ( ${BINARYNAME})
	else ()
		__install_linux_dbg ( ${BINARYNAME})
	endif ()
endfunction()

include ( CheckCXXSourceCompiles )

function ( CheckSystemASIOVersion OUTVAR )
	set ( system_asio_test_source_file "
#include <asio.hpp>
#define XSTR(x) STR(x)
#define STR(x) #x
#pragma message \"Asio version:\" XSTR(ASIO_VERSION)
#if ASIO_VERSION < 101001
#error Included asio version is too old
#elif ASIO_VERSION >= 101100
#error Included asio version is too new
#endif

int main()
{
    return 0;
}
")
	set ( CMAKE_REQUIRED_FLAGS "${CC_FLAGS}")
	get_property ( REQUIRED_DEFINITIONS DIRECTORY PROPERTY COMPILE_DEFINITIONS )
	get_property ( CMAKE_REQUIRED_INCLUDES DIRECTORY PROPERTY INCLUDE_DIRECTORIES )
	set ( CMAKE_REQUIRED_DEFINITIONS "")
	FOREACH ( def ${REQUIRED_DEFINITIONS} )
		LIST (APPEND CMAKE_REQUIRED_DEFINITIONS "-D${def}")
	endforeach()

	message ( STATUS "Checking ASIO version (>= 1.10.1 and < 1.11.0)" )
	CHECK_CXX_SOURCE_COMPILES ( "${system_asio_test_source_file}" ${OUTVAR}__res_ )
	set ( "${OUTVAR}" "${${OUTVAR}__res_}" PARENT_SCOPE )
endfunction()


function( CheckWeffcpp OUTVAR )
	set ( _test_source "
class A {};
class B : public A {};
int main() { return 0; }
" )
	set (OLDFLAGS "${CMAKE_CXX_FLAGS}")
	set ( CMAKE_CXX_FLAGS "-Weffc++ -Werror ${CMAKE_CXX_FLAGS}")
	message ( STATUS "Checking whether to enable -Weffc++" )
	CHECK_CXX_SOURCE_COMPILES ( "${_test_source}" ${OUTVAR}__res_ )
	set (CMAKE_CXX_FLAGS "${OLDFLAGS}")
	set ( "${OUTVAR}" "${${OUTVAR}__res_}" PARENT_SCOPE )
endfunction()

function( CheckSetEcdhAuto OUTVAR )
	set ( _test_source "
#include <openssl/ssl.h>
int main() { SSL_CTX* ctx=NULL; return !SSL_CTX_set_ecdh_auto(ctx, 1); }
" )
	message ( STATUS "Checking for SSL_CTX_set_ecdh_auto()" )
	CHECK_CXX_SOURCE_COMPILES ( "${_test_source}" ${OUTVAR}__res_ )
	set ( "${OUTVAR}" "${${OUTVAR}__res_}" PARENT_SCOPE )
endfunction()

function( CheckStdSharedPtr OUTVAR )
	set ( _test_source "
#include <boost/function.hpp>
#include <memory>
int main() { std::shared_ptr<int> x; auto y = boost::get_pointer(x); return 0; }
" )
	message ( STATUS "Checking for std::shared_ptr is usable ..." )
	CHECK_CXX_SOURCE_COMPILES ( "${_test_source}" ${OUTVAR}__res_ )
	set ( "${OUTVAR}" "${${OUTVAR}__res_}" PARENT_SCOPE )
endfunction()

function( CheckTr1SharedPtr OUTVAR )
	set ( _test_source "
#include <tr1/memory>
int main() { int n; std::tr1::shared_ptr<int> p(&n); return 0; }
" )
	message ( STATUS "Checking for std::tr1::shared_ptr ..." )
	CHECK_CXX_SOURCE_COMPILES ( "${_test_source}" ${OUTVAR}__res_ )
	set ( "${OUTVAR}" "${${OUTVAR}__res_}" PARENT_SCOPE )
endfunction()

function( CheckSetTmpEcdh OUTVAR )
	set ( _test_source "
#include <openssl/ssl.h>
int main() { SSL_CTX* ctx=NULL; EC_KEY* ecdh=NULL; return !SSL_CTX_set_tmp_ecdh(ctx,ecdh); }
" )

	message ( STATUS "Checking for SSL_CTX_set_tmp_ecdh_()" )
	CHECK_CXX_SOURCE_COMPILES ( "${_test_source}" ${OUTVAR}__res_ )
	set ( "${OUTVAR}" "${${OUTVAR}__res_}" PARENT_SCOPE )
endfunction()


function (populate_env)
	set ( CMAKE_REQUIRED_FLAGS "${cc_flags}" )
	get_property ( REQUIRED_DEFINITIONS DIRECTORY PROPERTY COMPILE_DEFINITIONS )
	get_property ( CMAKE_REQUIRED_INCLUDES DIRECTORY PROPERTY INCLUDE_DIRECTORIES )
	set ( CMAKE_REQUIRED_DEFINITIONS "" )
	FOREACH ( def ${REQUIRED_DEFINITIONS} )
		LIST ( APPEND CMAKE_REQUIRED_DEFINITIONS "-D${def}" )
	endforeach ()

	set ( CMAKE_REQUIRED_FLAGS "${CMAKE_REQUIRED_FLAGS}" PARENT_SCOPE )
	set ( CMAKE_REQUIRED_INCLUDES "${CMAKE_REQUIRED_INCLUDES}" PARENT_SCOPE )
	set ( CMAKE_REQUIRED_DEFINITIONS "${CMAKE_REQUIRED_DEFINITIONS}" PARENT_SCOPE )
	set ( CMAKE_REQUIRED_LIBRARIES "${LINKS}" PARENT_SCOPE )
endfunction()

function ( show_options target )
	get_property ( COMPILE_OPTIONS TARGET ${target} PROPERTY COMPILE_OPTIONS )
	message ( STATUS "Compile options for ${target} are ${COMPILE_OPTIONS}" )
endfunction()

function( remove_compile_option target option )
	show_options ( ${target} )
	get_property ( CMPOPT TARGET ${target} PROPERTY COMPILE_OPTIONS )
	list ( REMOVE_ITEM CMPOPT "${option}" )
	set_property ( TARGET ${target} PROPERTY COMPILE_OPTIONS "${CMPOPT}" )
	show_options ( ${target} )
endfunction()

function ( add_cxx_options options )
	list ( APPEND cxx_flags ${options} )
	set ( cxx_flags ${cxx_flags} PARENT_SCOPE)
endfunction()

function( add_c_options options )
	list ( APPEND c_flags ${options} )
	set ( c_flags ${c_flags} PARENT_SCOPE )
endfunction()

function( add_common_options options )
	list (APPEND cc_flags ${options} )
	set ( cc_flags ${cc_flags} PARENT_SCOPE )
endfunction()

function( add_main_library library )
	list ( APPEND LINKS ${library} )
	set ( LINKS ${LINKS} PARENT_SCOPE )

endfunction()

function( add_test_library library )
	list ( APPEND LINKS_TST ${library} )
	set ( LINKS_TST ${LINKS_TST} PARENT_SCOPE )
endfunction()

function ( get_galera_revision OUTVAR )
	SET ( GALERA_REV "XXXX" )
	if ( EXISTS "${GALERA_SOURCE_DIR}/.git" )
		find_package ( Git QUIET )
		if ( GIT_FOUND )
			execute_process ( COMMAND "${GIT_EXECUTABLE}" log --format=%h
					WORKING_DIRECTORY "${GALERA_SOURCE_DIR}"
					RESULT_VARIABLE res OUTPUT_VARIABLE _COMMITS ERROR_QUIET
					OUTPUT_STRIP_TRAILING_WHITESPACE )
			STRING ( REPLACE "\n" ";" _COMMITS "${_COMMITS}" )
			list (LENGTH _COMMITS GALERA_REV)
		endif ( GIT_FOUND )
	endif ()
	set ( "${OUTVAR}" "${GALERA_REV}" PARENT_SCOPE )
endfunction()

function( get_galera_api_version HEADER OUTVAR )
	SET ( APIVER "1" )
	if ( EXISTS "${HEADER}" )
		message (STATUS "Parsing ${HEADER} for wsrep API version")
		FILE ( READ "${HEADER}" _CONTENT )
		# replace lf into ';' (it makes list from the line)
		STRING ( REGEX REPLACE "\n" ";" _CONTENT "${_CONTENT}" )
		foreach ( LINE ${_CONTENT} )
			# match definitions like - #define NAME "VALUE"
			IF ( "${LINE}" MATCHES "^#define[ \t]+WSREP_INTERFACE_VERSION[ \t]+\"(.*)\"" )
				set ( APIVER "${CMAKE_MATCH_1}")
			endif ()
		endforeach ()
	endif()
	set ( "${OUTVAR}" "${APIVER}" PARENT_SCOPE )
endfunction()