SET ( GARB_SOURCES
		garb_logger.cpp
		garb_gcs.cpp
		garb_recv_loop.cpp
		garb_main.cpp
		garb_config.cpp
		)

include_directories ( "${GALERA_SOURCE_DIR}" )
include_directories ( "${GALERA_SOURCE_DIR}/common" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcs/src" )

add_definitions ( "-DGCS_FOR_GARB" )
add_definitions ( "-DGALERA_VER=\"${GALERA_VER}\"" )
add_definitions ( "-DGALERA_REV=\"${GALERA_REV}\"" )

add_executable ( garbd ${GARB_SOURCES} )
target_link_libraries ( garbd galerautils )
target_link_libraries ( garbd galerautilsxx )
target_link_libraries ( garbd gcomm )
target_link_libraries ( garbd gcs4garb )

if ( WITH_BOOST )
	find_package ( Boost COMPONENTS program_options )
	if ( Boost_program_options_FOUND )
		target_link_libraries ( garbd ${Boost_program_options_LIBRARY} )
	endif ()
endif ()