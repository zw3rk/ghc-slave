cmake_minimum_required(VERSION 3.4.1)

add_library( native-lib     SHARED src/main/cpp/GHCSlave.c    )

find_library( log-lib   log )
find_library( c-lib     c )
find_library( hs-lib
              hs
              PATHS ${PROJECT_SOURCE_DIR}/hs-libs/${ANDROID_ABI}
              NO_CMAKE_FIND_ROOT_PATH )

target_link_libraries( native-lib
                       ${c-lib}

                       ${hs-lib}

                       ${log-lib}
                       ${c-lib} )
