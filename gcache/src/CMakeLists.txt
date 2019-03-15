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

set ( GCACHE_HEADERS
		gcache_bh.hpp
		GCache.hpp
		gcache_limits.hpp
		gcache_memops.hpp
		gcache_mem_store.hpp
		gcache_page.hpp
		gcache_page_store.hpp
		gcache_rb_store.hpp
		gcache_seqno.hpp
		gcache_types.hpp
		)

add_library ( gcache STATIC ${GCACHE_SOURCES} ${GCACHE_HEADERS} )
target_compile_options ( gcache PRIVATE ${cc_flags} ${cxx_flags} )

if ( GALERA_TESTING )
	add_executable ( test_gcache test.cpp )
	target_link_libraries ( test_gcache PUBLIC gcache galerautilsxx ${LINKS} )
	target_compile_options ( test_gcache PUBLIC ${cc_flags} ${cxx_flags} )
	add_test ( NAME test_gcache COMMAND test_gcache )
endif ()
