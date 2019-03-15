include_directories ( "${GALERA_SOURCE_DIR}/common" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcache/src" )
add_compile_definitions ( GALERA_LOG_H_ENABLE_CXX )

set ( gcs_compile_options "${cc_flags};${cxx_flags};-Wno-missing-field-initializers;-Wno-variadic-macros;-Wno-old-style-cast" )
list ( REMOVE_ITEM gcs_compile_options -Wold-style-cast )
list ( REMOVE_ITEM gcs_compile_options -Weffc++ )
list ( REMOVE_ITEM gcs_compile_options -pedantic )

if ( GALERA_TESTING )
	add_subdirectory ( unit_tests )
endif()

include_directories ( "${GALERA_SOURCE_DIR}/gcomm/src" )

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

SET ( LIBGCS_HEADERS
		gcs_act.hpp
		gcs_act_proto.hpp
		gcs_backend.hpp
		gcs_comp_msg.hpp
		gcs_core.hpp
		gcs_defrag.hpp
		gcs_dummy.hpp
		gcs_fc.hpp
		gcs_fifo_lite.hpp
		gcs_gcache.hpp
		gcs_gcomm.hpp
		gcs_group.hpp
		gcs.hpp
		gcs_msg_type.hpp
		gcs_node.hpp
		gcs_params.hpp
		gcs_priv.hpp
		gcs_recv_msg.hpp
		gcs_seqno.hpp
		gcs_sm.hpp
		gcs_spread.hpp
		gcs_state_msg.hpp
		gcs_test.hpp
		)


add_library ( gcs STATIC ${LIBGCS_SOURCES} ${LIBGCS_HEADERS} )
target_compile_definitions ( gcs PRIVATE GCS_USE_GCOMM )
target_compile_options ( gcs PRIVATE ${gcs_compile_options} )


add_library ( gcs4garb STATIC ${LIBGCS_SOURCES} )
target_compile_definitions ( gcs4garb PUBLIC GCS_FOR_GARB GCS_USE_GCOMM )
target_compile_options ( gcs4garb PRIVATE ${gcs_compile_options} )

if ( GALERA_TESTING )
	add_executable ( gcs_test gcs_test.cpp )
	target_link_libraries ( gcs_test PRIVATE gcs gcache gcomm galerautilsxx ${LINKS} )
	target_compile_options ( gcs_test PRIVATE ${gcs_compile_options} )
#	add_test ( NAME gcs_test COMMAND gcs_test ) # orig test from SConscript also never called...
endif()
