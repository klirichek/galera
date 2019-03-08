include_directories ( "${GALERA_SOURCE_DIR}" )
include_directories ( "${GALERA_SOURCE_DIR}/common" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcs/src" )

add_compile_definitions ( "GCS_FOR_GARB" )
add_compile_definitions ( "GALERA_VER=\"${GALERA_VER}\"" )
add_compile_definitions ( "GALERA_REV=\"${GALERA_REV}\"" )

SET ( GARB_SOURCES
		garb_logger.cpp
		garb_gcs.cpp
		garb_recv_loop.cpp
		garb_main.cpp
		garb_config.cpp
		)

add_executable ( garbd ${GARB_SOURCES} )

if ( WITH_BOOST )
	find_package ( Boost COMPONENTS program_options )
	if ( Boost_PROGRAM_OPTIONS_FOUND )
		target_link_libraries ( garbd ${Boost_PROGRAM_OPTIONS_LIBRARY} )
	endif ()
endif ()
target_link_libraries ( garbd gcs4garb gcomm galerautilsxx galerautils ${LINKS} )
