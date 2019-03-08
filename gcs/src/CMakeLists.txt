include_directories ( "${GALERA_SOURCE_DIR}/common" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcomm/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcache/src" )

string ( REPLACE "-Wold-style-cast" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" )
string ( REPLACE "-Weffc++" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" )
string ( REPLACE "-pedantic" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" )

add_compile_options ( "-Wno-missing-field-initializers" )
add_compile_options ( "-Wno-variadic-macros" )
add_compile_definitions ( GCS_USE_GCOMM )
add_compile_definitions ( GALERA_LOG_H_ENABLE_CXX )

SET ( LIBGCS_SOURCES
		gcs_params.cpp
		gcs_conf.cpp
		gcs_fifo_lite.cpp
		gcs_msg_type.cpp
		gcs_comp_msg.cpp
		gcs_sm.cpp
		gcs_backend.cpp
		gcs_dummy.cpp
		gcs_act_proto.cpp
		gcs_defrag.cpp
		gcs_state_msg.cpp
		gcs_node.cpp
		gcs_group.cpp
		gcs_core.cpp
		gcs_fc.cpp
		gcs.cpp
		gcs_gcomm.cpp
		)

add_library ( gcs STATIC ${LIBGCS_SOURCES} )

add_library ( gcs4garb STATIC ${LIBGCS_SOURCES} )
target_compile_definitions ( gcs4garb PRIVATE GCS_FOR_GARB )

add_executable ( gcs_test EXCLUDE_FROM_ALL gcs_test.cpp )
target_link_libraries ( gcs_test PRIVATE gcs gcache gcomm galerautilsxx galerautils ${LINKS} )
