include_directories ( "${GALERA_SOURCE_DIR}" )

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


add_library ( crc32 OBJECT ${GALERA_SOURCE_DIR}/www.evanjones.ca/crc32c.c )

target_compile_definitions ( crc32 PUBLIC WITH_GALERA )
if ( CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64" )
	target_compile_options( crc32 PRIVATE "-msse4.2" )
endif ()

add_library ( galerautils STATIC ${GALERAUTILS_SOURCES} $<TARGET_OBJECTS:crc32>)

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
		gu_hexdump.cpp
		gu_uuid.cpp
		)

add_library ( galerautilsxx STATIC ${GALERAUTILSXX_SOURCES} )
target_compile_options (galerautilsxx PRIVATE "-Wno-old-style-cast")
target_include_directories(galerautilsxx PRIVATE "${GALERA_SOURCE_DIR}/common")
