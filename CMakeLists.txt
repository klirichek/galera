cmake_minimum_required ( VERSION 3.12 )
project ( GALERA )

set ( CMAKE_CXX_STANDARD 11 )

SET ( GALERA_CMAKE_DIR "${GALERA_SOURCE_DIR}/cmake" )
SET ( CMAKE_MODULE_PATH "${GALERA_SOURCE_DIR}/cmake" )
SET ( EXTRA_LIBRARIES )
SET ( EXTRA_SEARCHD_LIBRARIES )


option ( DEBUG_LEVEL "debug build with optimization level n" OFF )

# initial value, to be refactored
SET (OPT_FLAGS ' -g -O3 -fno-omit-frame-pointer -DNDEBUG')

OPTION ( WITH_BOOST "disable or enable boost libraries" ON )
OPTION ( WITH_BOOST_POOL "use or not use boost pool allocator" OFF )
OPTION ( SYSTEM_ASIO "use system asio library, if available" ON )

# fixme - do the way how galera originally determines it
SET (GALERA_VER '3.35')
SET (GALERA_REV 'XXXX')



#message ( STATUS "Looking for threads library" )
find_package ( Threads REQUIRED )

include ( helpers )
list ( APPEND EXTRA_LIBRARIES ${CMAKE_THREAD_LIBS_INIT} )
#ac_check_func_ex ( "pthread_mutex_timedlock" "" "${CMAKE_THREAD_LIBS_INIT}" )

#message ( STATUS "Checking for endianess" )
#include ( SphEndianess )


set ( EXTRA_SYSROOT "" CACHE PATH "a path to extra development environment (Fink, Homebrew, MacPorts, MinGW)" )


message ( STATUS "Looking for threads library ${CMAKE_SYSTEM_NAME}" )