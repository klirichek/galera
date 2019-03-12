include_directories ( "${GALERA_SOURCE_DIR}" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )

link_libraries ( galerautilsxx ${LINKS_TST} ${LINKS} )

add_executable ( gu_tests
		gu_tests.c
		gu_mem_test.c
		gu_bswap_test.c
		gu_fnv_test.c
		gu_mmh3_test.c
		gu_spooky_test.c
		gu_crc32c_test.c
		gu_hash_test.c
		gu_time_test.c
		gu_fifo_test.c
		gu_uuid_test.c
		gu_dbug_test.c
		gu_lock_step_test.c
		gu_str_test.c
		gu_utils_test.c
		)

add_executable ( gu_testspp
		gu_atomic_test.cpp
		gu_vector_test.cpp
		gu_string_test.cpp
		gu_vlq_test.cpp
		gu_digest_test.cpp
		gu_mem_pool_test.cpp
		gu_alloc_test.cpp
		gu_rset_test.cpp
		gu_string_utils_test.cpp
		gu_uri_test.cpp
		gu_config_test.cpp
		gu_net_test.cpp
		gu_datetime_test.cpp
		gu_histogram_test.cpp
		gu_stats_test.cpp
		gu_thread_test.cpp
		gu_tests++.cpp
		)

add_executable ( gu_to_test
		gu_to_test.c
		)

add_executable ( avalanche
		avalanche.c
		)

target_compile_options ( gu_tests PRIVATE ${cc_flags} ${c_flags})
target_compile_options ( gu_testspp PRIVATE ${cc_flags} ${cxx_flags} )
target_compile_options ( gu_to_test PRIVATE ${cc_flags} ${c_flags} )
target_compile_options ( avalanche PRIVATE ${cc_flags} ${c_flags} )

add_test ( NAME gu_tests COMMAND gu_tests )
add_test ( NAME gu_testspp COMMAND gu_testspp )
add_test ( NAME gu_to_test COMMAND gu_to_test )
add_test ( NAME avalanche COMMAND avalanche )