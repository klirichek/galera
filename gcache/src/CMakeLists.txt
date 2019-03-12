include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )

SET ( GCACHE_SOURCES
		GCache_seqno.cpp
		gcache_params.cpp
		gcache_page.cpp
		gcache_page_store.cpp
		gcache_rb_store.cpp
		gcache_mem_store.cpp
		GCache_memops.cpp
		GCache.cpp
		)

add_library ( gcache STATIC ${GCACHE_SOURCES} )
target_compile_options ( gcache PRIVATE ${cc_flags} ${cxx_flags} )

if ( TESTS )
	add_executable ( test_gcache test.cpp )
	target_link_libraries ( test_gcache PUBLIC gcache galerautilsxx ${LINKS} )
	target_compile_options ( test_gcache PUBLIC ${cc_flags} ${cxx_flags} )
	add_test ( NAME test_gcache COMMAND test_gcache )
endif ()
