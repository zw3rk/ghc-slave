# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

# add_library( std-stream-lib SHARED src/main/cpp/std-stream-lib.c )

add_library( native-lib     SHARED src/main/cpp/GHCSlave.c    )

add_library( stub-lib       SHARED src/main/cpp/iostub.c      )

# add_subdirectory( src/ghc/rts )

# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

# log-lib <- log
find_library( log-lib   log )
# c-lib <- c
find_library( c-lib     c )

find_library( slave-lib GHCSlave
              PATHS "${PROJECT_SOURCE_DIR}/src/main/jniLibs/${ANDROID_ABI}"
              NO_CMAKE_FIND_ROOT_PATH )

MESSAGE( STATUS "ANDROID_ABI: " ${ANDROID_ABI} )
MESSAGE( STATUS "CMAKE_LIBRARY_OUTPUT_DIRECTORY: " ${CMAKE_LIBRARY_OUTPUT_DIRECTORY} )


# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries( # Specifies the target library.
                       native-lib

                       # Links the target library to the log library
                       # included in the NDK.
#                       link-lib
#                       rts-lib
                       ${slave-lib}

                       ${log-lib}
                       ${c-lib} )

# target_link_libraries( std-stream-lib ${log-lib} )

# set C99
# set_property(TARGET native-lib PROPERTY C_STANDARD 99)
# set_property(TARGET std-stream-lib PROPERTY C_STANDARD 99)