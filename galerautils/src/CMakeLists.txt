SET ( GALERAUTILS_SOURCES
		gu_abort.c
		gu_dbug.c
		gu_fifo.c
		gu_lock_step.c
		gu_log.c
		gu_mem.c
		gu_mmh3.c
		gu_spooky.c
		gu_crc32c.c
		gu_rand.c
		gu_threads.c
		gu_hexdump.c
		gu_to.c
		gu_utils.c
		gu_uuid.c
		gu_backtrace.c
		gu_limits.c
		gu_time.c
		gu_init.c
		)

include_directories ( "${GALERA_SOURCE_DIR}" )

add_library ( galeracommon STATIC ${GALERAUTILS_SOURCES} )

add_definitions("-DWITH_GALERA")
if ( CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64" )
	SET ( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -msse4.2" )
endif()

add_library ( galerautils STATIC ${GALERA_SOURCE_DIR}/www.evanjones.ca/crc32c.c )
target_link_libraries ( galerautils galeracommon )


include_directories ( "${GALERA_SOURCE_DIR}/common" )
SET ( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-old-style-cast" )

SET ( GALERAUTILSXX_SOURCES
		gu_vlq.cpp
		gu_datetime.cpp
		gu_exception.cpp
		gu_serialize.cpp
		gu_logger.cpp
		gu_prodcons.cpp
		gu_regex.cpp
		gu_string_utils.cpp
		gu_uri.cpp
		gu_buffer.cpp
		gu_utils++.cpp
		gu_config.cpp
		gu_fdesc.cpp
		gu_mmap.cpp
		gu_alloc.cpp
		gu_rset.cpp
		gu_resolver.cpp
		gu_histogram.cpp
		gu_stats.cpp
		gu_asio.cpp
		gu_debug_sync.cpp
		gu_thread.cpp
		)

add_library ( gu_hexdumpxx STATIC gu_hexdump.cpp )
add_library ( gu_uuidxx STATIC gu_uuid.cpp )

add_library ( galerautilsxx STATIC ${GALERAUTILSXX_SOURCES} )
target_link_libraries ( galerautilsxx gu_hexdumpxx )
target_link_libraries ( galerautilsxx gu_uuidxx )