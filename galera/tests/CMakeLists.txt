include_directories ( "${GALERA_SOURCE_DIR}" )
include_directories ( "${GALERA_SOURCE_DIR}/common" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcache/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcs/src" )
include_directories ( "${GALERA_SOURCE_DIR}/galera/src" )

add_executable ( galera_check
		galera_check.cpp
		data_set_check.cpp
		key_set_check.cpp
		write_set_ng_check.cpp
		write_set_check.cpp
		trx_handle_check.cpp
		service_thd_check.cpp
		ist_check.cpp
		saved_state_check.cpp
		)

target_link_libraries ( galera_check gcache galerapp gcs gcomm galerautilsxx ${LINKS_TST} ${LINKS} )
target_compile_options ( galera_check PUBLIC ${cc_flags} ${cxx_flags} )

add_test ( NAME galera_check COMMAND galera_check )