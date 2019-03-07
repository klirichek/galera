
include_directories ( "${GALERA_SOURCE_DIR}/common" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcomm/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcache/src" )

add_definitions ( "-DGCS_USE_GCOMM" )
add_definitions ( "-DGALERA_LOG_H_ENABLE_CXX" )

string ( REPLACE "-Wold-style-cast" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" )
string ( REPLACE "-Weffc++" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" )

string ( REPLACE "-pedantic" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" )
SET ( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-missing-field-initializers" )
SET ( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-variadic-macros" )

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

add_definitions ( "-DGCS_FOR_GARB" )
add_library ( gcs4garb STATIC ${LIBGCS_SOURCES} )

