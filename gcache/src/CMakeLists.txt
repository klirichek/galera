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

add_executable ( test EXCLUDE_FROM_ALL test.cpp )
target_link_libraries ( test PRIVATE gcache galerautilsxx galerautils ${LINKS} )
