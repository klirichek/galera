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

add_executable ( check_gcomm EXCLUDE_FROM_ALL ${GCOMM_CHECK} )
target_link_libraries ( check_gcomm PRIVATE gcomm galerautilsxx galerautils ${LINKS} )