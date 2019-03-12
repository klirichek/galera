include_directories ( "${GALERA_SOURCE_DIR}/gcache/src" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )

file (GLOB GCACHE_TESTS "*.cpp" )

add_executable ( gcache_tests ${GCACHE_TESTS} )
target_link_libraries ( gcache_tests PRIVATE gcache galerautilsxx ${LINKS_TST} ${LINKS} )
target_compile_options ( gcache_tests PUBLIC ${cc_flags} ${cxx_flags} )

add_test ( NAME gcache_tests COMMAND gcache_tests )