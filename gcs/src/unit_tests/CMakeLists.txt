include_directories ( "${GALERA_SOURCE_DIR}/gcs/src" )
add_compile_definitions ( GCS_CORE_TESTING )
add_compile_definitions ( GCS_DUMMY_TESTING )

set ( gcs_tests_compile_options "${gcs_compile_options}" )

SET ( GCS_TESTS_SOURCES
		gcs_tests.cpp
		gcs_fifo_test.cpp
		../gcs_fifo_lite.cpp
		gcs_sm_test.cpp
		../gcs_sm.cpp
		gcs_comp_test.cpp
		../gcs_comp_msg.cpp
		gcs_state_msg_test.cpp
		../gcs_state_msg.cpp
		gcs_backend_test.cpp
		../gcs_backend.cpp
		gcs_proto_test.cpp
		../gcs_act_proto.cpp
		gcs_defrag_test.cpp
		../gcs_defrag.cpp
		gcs_node_test.cpp
		../gcs_node.cpp
		gcs_group_test.cpp
		gcs_memb_test.cpp
		../gcs_group.cpp
		gcs_core_test.cpp
		../gcs_core.cpp
		../gcs_dummy.cpp
		../gcs_msg_type.cpp
		../gcs.cpp
		../gcs_params.cpp
		gcs_fc_test.cpp
		../gcs_fc.cpp
		)

add_executable ( gcs_tests ${GCS_TESTS_SOURCES} )
target_compile_options ( gcs_tests PRIVATE ${gcs_tests_compile_options} )
target_link_libraries ( gcs_tests PRIVATE gcache gcomm galerautilsxx ${LINKS_TST} ${LINKS} )



add_test ( NAME gcs_tests COMMAND gcs_tests )
