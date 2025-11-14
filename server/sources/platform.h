#ifndef PLATFORM_HEADER
#define PLATFORM_HEADER


// -------------------------
// Platform detection
// -------------------------
#if defined(_WIN32) || defined(_WIN64)
#define PLATFORM_WINDOWS 1
#elif defined(__APPLE__) || defined(__MACH__)
#define PLATFORM_MAC 1
#elif defined(__linux__)
#define PLATFORM_LINUX 1
#elif defined(__unix__)
#define PLATFORM_UNIX 1
#else
#error "Unknown platform!"
#endif

// -------------------------
// Compiler detection
// -------------------------
#if defined(_MSC_VER)
#define COMPILER_MSVC 1
#elif defined(__clang__)
#define COMPILER_CLANG 1
#elif defined(__GNUC__)
#define COMPILER_GCC 1
#else
#error "Unknown compiler!"
#endif

#endif