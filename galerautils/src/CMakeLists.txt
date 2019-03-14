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

SET ( GALERAUTILS_HEADERS
		galerautils.h
		gu_abort.h
		gu_arch.h
		gu_assert.h
		gu_atomic.h
		gu_backtrace.h
		gu_buf.h
		gu_byteswap.h
		gu_conf.h
		gu_config.h
		gu_crc32c.h
		gu_dbug.h
		gu_errno.h
		gu_fifo.h
		gu_fnv.h
		gu_hash.h
		gu_hexdump.h
		gu_init.h
		gu_int128.h
		gu_limits.h
		gu_lock_step.h
		gu_log.h
		gu_macros.h
		gu_mem.h
		gu_mmh3.h
		gu_rand.h
		gu_spooky.h
		gu_str.h
		gu_system.h
		gu_threads.h
		gu_time.h
		gu_to.h
		gu_types.h
		gu_utils.h
		gu_uuid.h
		)

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

SET ( GALERAUTILSXX_HEADERS
		gu_alloc.hpp
		gu_array.hpp
		gu_asio.hpp
		gu_assert.hpp
		gu_atomic.hpp
		gu_backtrace.hpp
		gu_barrier.hpp
		gu_buffer.hpp
		gu_buf.hpp
		gu_byteswap.hpp
		gu_cond.hpp
		gu_config.hpp
		gu_convert.hpp
		gu_crc.hpp
		gu_datetime.hpp
		gu_debug_sync.hpp
		gu_digest.hpp
		gu_exception.hpp
		gu_fdesc.hpp
		gu_hexdump.hpp
		gu_histogram.hpp
		gu_lock.hpp
		gu_logger.hpp
		gu_macros.hpp
		gu_mem_pool.hpp
		gu_mmap.hpp
		gu_monitor.hpp
		gu_mutex.hpp
		gu_prodcons.hpp
		gu_progress.hpp
		gu_regex.hpp
		gu_reserved_container.hpp
		gu_resolver.hpp
		gu_rset.hpp
		gu_serializable.hpp
		gu_serialize.hpp
		gu_shared_ptr.hpp
		gu_stats.hpp
		gu_status.hpp
		gu_string.hpp
		gu_string_utils.hpp
		gu_thread.hpp
		gu_throw.hpp
		gu_types.hpp
		gu_unordered.hpp
		gu_uri.hpp
		gu_utils.hpp
		gu_uuid.hpp
		gu_vector.hpp
		gu_vlq.hpp
		)

add_library ( crc32 OBJECT ${GALERA_SOURCE_DIR}/www.evanjones.ca/crc32c.c
				${GALERA_SOURCE_DIR}/www.evanjones.ca/crc32c.h)
target_compile_options ( crc32 PRIVATE ${cc_flags} ${c_flags} )

target_compile_definitions ( crc32 PRIVATE WITH_GALERA )
if ( CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64" )
	target_compile_options( crc32 PRIVATE "-msse4.2" )
endif ()

add_library ( galerautils OBJECT ${GALERAUTILS_SOURCES} ${GALERAUTILS_HEADERS} )
target_compile_options ( galerautils PRIVATE ${cc_flags} ${c_flags} )

add_library ( galerautilsxx STATIC  ${GALERAUTILSXX_SOURCES} ${GALERAUTILSXX_HEADERS} $<TARGET_OBJECTS:galerautils> $<TARGET_OBJECTS:crc32> )

target_compile_options (galerautilsxx PRIVATE ${cc_flags} ${cxx_flags} -Wno-old-style-cast)
target_include_directories(galerautilsxx PRIVATE "${GALERA_SOURCE_DIR}/common")
