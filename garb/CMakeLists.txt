include_directories ( "${GALERA_SOURCE_DIR}" )
include_directories ( "${GALERA_SOURCE_DIR}/common" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcs/src" )

add_compile_definitions ( GCS_FOR_GARB )
add_compile_definitions ( GALERA_VER=\"${GALERA_VER}\" )
add_compile_definitions ( GALERA_REV=\"${GALERA_REV}\" )

SET ( GARB_SOURCES
		garb_logger.cpp
		garb_gcs.cpp
		garb_recv_loop.cpp
		garb_main.cpp
		garb_config.cpp
		)

# headers added is just to reveal them in IDE
set ( GARB_HEADERS
		garb_config.hpp
		garb_gcs.hpp
		garb_logger.hpp
		garb_recv_loop.hpp
		)

add_executable ( garbd ${GARB_SOURCES} ${GARB_HEADERS} )

if ( WITH_BOOST )
	find_package ( Boost COMPONENTS program_options )
	if ( Boost_PROGRAM_OPTIONS_FOUND )
		target_link_libraries ( garbd ${Boost_PROGRAM_OPTIONS_LIBRARY} )
	endif ()
endif ()
target_link_libraries ( garbd gcs4garb gcomm galerautilsxx ${LINKS} )
target_compile_options ( garbd PRIVATE ${cc_flags} ${cxx_flags} )


if ( SPLIT_SYMBOLS )
	install_dbg ( garbd )
endif()
install ( TARGETS garbd RUNTIME DESTINATION bin COMPONENT applications )