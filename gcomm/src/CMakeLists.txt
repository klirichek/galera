include_directories ( "${GALERA_SOURCE_DIR}" )
include_directories ( "${GALERA_SOURCE_DIR}/common" )
include_directories ( "${GALERA_SOURCE_DIR}/galerautils/src" )
include_directories ( "${GALERA_SOURCE_DIR}/gcomm/src" )

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

SEt ( LIBCOMM_HEADERS
		defaults.hpp
		evs_consensus.hpp
		evs_input_map2.hpp
		evs_message2.hpp
		evs_node.hpp
		evs_proto.hpp
		evs_seqno.hpp
		gmcast.hpp
		gmcast_link.hpp
		gmcast_message.hpp
		gmcast_node.hpp
		gmcast_proto.hpp
		pc.hpp
		pc_message.hpp
		pc_proto.hpp
		profile.hpp
		protocol_version.hpp
		socket.hpp
		)

SET ( LIBCOMM_ASIO_SOURCES "")
SET ( LIBCOMM_ASIO_HEADERS "" )
if ( HAVE_ASIO_HPP )
	SET ( LIBCOMM_ASIO_SOURCES
			asio_tcp.cpp
			asio_udp.cpp
			asio_protonet.cpp
			)
	SET ( LIBCOMM_ASIO_HEADERS
			asio_protonet.hpp
			asio_tcp.hpp
			asio_udp.hpp
			)
endif()

add_library ( gcomm STATIC ${LIBGCOMM_SOURCES} ${LIBCOMM_ASIO_SOURCES}
		${LIBCOMM_HEADERS} ${LIBCOMM_ASIO_HEADERS})
target_compile_options ( gcomm PRIVATE ${cc_flags} ${cxx_flags} -fno-strict-aliasing )
