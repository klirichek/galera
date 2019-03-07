SET (GALERAUTILS_SOURCES
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

message (STATUS "Hello from src")

include_directories ( "${GALERA_SOURCE_DIR}" )
add_definitions("-DWITH_GALERA")

add_library ( galerautils STATIC ${GALERAUTILS_SOURCES} )

install ( TARGETS galerautils ARCHIVE DESTINATION bin COMPONENT APPLICATIONS )