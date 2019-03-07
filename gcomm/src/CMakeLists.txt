SET ( LIBGCOMM_SOURCES
		conf.cpp
		defaults.cpp
		datagram.cpp
		evs_consensus.cpp
		evs_input_map2.cpp
		evs_message2.cpp
		evs_node.cpp
		evs_proto.cpp
		gmcast.cpp
		gmcast_proto.cpp
		pc.cpp
		pc_proto.cpp
		protonet.cpp
		protostack.cpp
		transport.cpp
		uuid.cpp
		view.cpp
		socket.cpp
		)

include_directories ( "${GALERA_SOURCE_DIR}" )
include_directories ( "${GALERA_SOURCE_DIR}/common" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcomm/src" )

SET ( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-strict-aliasing" )

SET ( LIBCOMM_ASIO_SOURCES "")
if ( HAVE_ASIO_HPP )
	SET ( LIBCOMM_ASIO_SOURCES
			asio_tcp.cpp
			asio_udp.cpp
			asio_protonet.cpp
			)
endif()


add_library ( gcomm STATIC ${LIBGCOMM_SOURCES} ${LIBCOMM_ASIO_SOURCES})