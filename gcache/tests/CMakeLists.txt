include_directories ( "${GALERA_SOURCE_DIR}/gcache/src" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )

file (GLOB GCACHE_TESTS "*.cpp" )

add_executable ( gcache_tests EXCLUDE_FROM_ALL ${GCACHE_TESTS} )
target_link_libraries ( gcache_tests PRIVATE gcache galerautilsxx galerautils ${LINKS} )