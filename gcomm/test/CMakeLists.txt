include_directories ( "${GALERA_SOURCE_DIR}/common" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcomm/src" )

set (GCOMM_CHECK
		check_gcomm.cpp
		check_trace.cpp
		check_types.cpp
		check_util.cpp
		check_gmcast.cpp
		check_evs2.cpp
		check_pc.cpp
		)

add_executable ( check_gcomm ${GCOMM_CHECK} )
target_link_libraries ( check_gcomm PRIVATE gcomm galerautilsxx ${LINKS_TST} ${LINKS} )
target_compile_options ( check_gcomm PUBLIC ${cc_flags} ${cxx_flags} )

add_test ( NAME check_gcomm COMMAND check_gcomm )

add_executable ( ssl_test ssl_test.cpp )
target_link_libraries ( ssl_test PRIVATE gcomm galerautilsxx ${LINKS_TST} ${LINKS} )
target_compile_options ( ssl_test PUBLIC ${cc_flags} ${cxx_flags} )
