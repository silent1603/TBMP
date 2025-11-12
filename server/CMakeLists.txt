cmake_minimum_required(VERSION 3.18)
project(TBMP-server C CXX ISPC)

# -----------------------------
# Paths
# -----------------------------
set(BIN_DIR "${CMAKE_SOURCE_DIR}/bin")
set(SOURCES_DIR "${CMAKE_SOURCE_DIR}/sources")
set(TOOLS_DIR "${CMAKE_SOURCE_DIR}/tools")
set(NINJA_BIN "${TOOLS_DIR}/ninja/bin/ninja")
set(ISPC_COMPILER "${TOOLS_DIR}/ispc/bin/ispc.exe")

# Make Ninja available to CMake
if(EXISTS "${NINJA_BIN}")
    if(WIN32)
        set(NINJA_BIN "${NINJA_BIN}.exe")
    endif()
    set(CMAKE_MAKE_PROGRAM "${NINJA_BIN}" CACHE FILEPATH "Ninja executable")
endif()

# -----------------------------
# Compiler settings
# -----------------------------
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

foreach(dir RUNTIME LIBRARY ARCHIVE)
    set(CMAKE_${dir}_OUTPUT_DIRECTORY "${BIN_DIR}")
endforeach()

# Debug flags
if(MSVC)
    string(APPEND CMAKE_C_FLAGS " /Zi")
    string(APPEND CMAKE_CXX_FLAGS " /Zi")
    string(APPEND CMAKE_EXE_LINKER_FLAGS " /DEBUG")
    string(APPEND CMAKE_SHARED_LINKER_FLAGS " /DEBUG")
else()
    string(APPEND CMAKE_C_FLAGS " -g")
    string(APPEND CMAKE_CXX_FLAGS " -g")
    set(CMAKE_C_FLAGS_RELEASE "-O2 -g -DNDEBUG")
    set(CMAKE_CXX_FLAGS_RELEASE "-O2 -g -DNDEBUG")
endif()

# -----------------------------
# Collect sources
# -----------------------------
file(GLOB_RECURSE C_SOURCES "${SOURCES_DIR}/*.c")
file(GLOB_RECURSE ISPC_SOURCES "${SOURCES_DIR}/*.ispc")

if(NOT C_SOURCES)
    message(WARNING "No C sources found under ${SOURCES_DIR}")
endif()
if(NOT ISPC_SOURCES)
    message(WARNING "No ISPC sources found under ${SOURCES_DIR}")
endif()

# -----------------------------
# Generate ISPC headers & objects
# -----------------------------
set(ISPC_HEADERS "")
set(ISPC_OBJECTS "")

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(ISPC_FLAGS -O0 -g)
else()
    set(ISPC_FLAGS -O2)
endif()

foreach(ISPC_FILE ${ISPC_SOURCES})
    get_filename_component(FILE_WE ${ISPC_FILE} NAME_WE)
    set(H_FILE "${SOURCES_DIR}/${FILE_WE}.h")        # header in source folder
    set(OBJ_FILE "${CMAKE_BINARY_DIR}/${FILE_WE}.obj")     # object in build folder

    add_custom_command(
        OUTPUT "${H_FILE}" "${OBJ_FILE}"
        COMMAND "${ISPC_COMPILER}"
            "${ISPC_FILE}"
            --target=sse2-i32x4
            --pic
            ${ISPC_FLAGS}
            -h "${H_FILE}"
            -o "${OBJ_FILE}"
        DEPENDS "${ISPC_FILE}"
        COMMENT "Compiling ISPC file: ${ISPC_FILE}"
        VERBATIM
    )

    list(APPEND ISPC_HEADERS "${H_FILE}")
    list(APPEND ISPC_OBJECTS "${OBJ_FILE}")
endforeach()

# Custom target that builds all ISPC objects
add_custom_target(ispc_build ALL
    DEPENDS ${ISPC_OBJECTS}
    COMMENT "Building all ISPC objects"
)

# -----------------------------
# Add executable
# -----------------------------
add_executable(tbmp_server ${C_SOURCES} ${ISPC_OBJECTS})

# Ensure C compilation waits for ISPC
add_dependencies(tbmp_server ispc_build)

# Include source folder for headers and ISPC-generated headers
target_include_directories(tbmp_server PRIVATE "${SOURCES_DIR}")

# -----------------------------
# Platform-specific flags
# -----------------------------
if(UNIX)
    target_compile_options(tbmp_server PRIVATE "-m64")
elseif(WIN32 AND MSVC)
    target_compile_options(tbmp_server PRIVATE /fp:fast /Oi)
endif()

# -----------------------------
# Optional linking
# -----------------------------
find_package(Threads REQUIRED)
target_link_libraries(tbmp_server PRIVATE Threads::Threads)

# -----------------------------
# Build info
# -----------------------------
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Sources directory: ${SOURCES_DIR}")
message(STATUS "ISPC headers generated in source folder")
message(STATUS "ISPC compiler: ${ISPC_COMPILER}")
