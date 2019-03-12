include_directories ( "${GALERA_SOURCE_DIR}" )
include_directories ( "${GALERA_SOURCE_DIR}/common" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcache/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcs/src" )

SET ( LIBGALERAXX_SRCS
		mapped_buffer.cpp
		write_set.cpp
		data_set.cpp
		key_set.cpp
		write_set_ng.cpp
		trx_handle.cpp
		key_entry_os.cpp
		wsdb.cpp
		certification.cpp
		galera_service_thd.cpp
		wsrep_params.cpp
		replicator_smm_params.cpp
		gcs_action_source.cpp
		galera_info.cpp
		replicator.cpp
		ist.cpp
		gcs_dummy.cpp
		saved_state.cpp
		)

add_library ( galerapp STATIC ${LIBGALERAXX_SRCS} )
target_compile_options ( galerapp PRIVATE ${cc_flags} ${cxx_flags} )

# Environment to compile provider unit (part of multimaster library)
# This is needed to hardcode version and revision
# Environment for multimaster library build
add_library ( mmgalera OBJECT wsrep_provider.cpp replicator_smm.cpp replicator_str.cpp replicator_smm_stats.cpp )
target_compile_definitions ( mmgalera PRIVATE GALERA_MULTIMASTER )
target_compile_definitions ( mmgalera PRIVATE GALERA_VER=\"${GALERA_VER}\" )
target_compile_definitions ( mmgalera PRIVATE GALERA_REV=\"${GALERA_REV}\" )
target_compile_options ( mmgalera PRIVATE ${cc_flags} ${cxx_flags} )