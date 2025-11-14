#ifndef DEFINE_H
#define DEFINE_H
#include "platform.h"

#define R_ 
#define V_ volatile
#define S_ static

#define A_(x) 
#define E_(x,y) 
#define L_ 
#define N_
#define W_ 

#ifdef COMPILER_MSVC
#define R_ __restrict
#define L_ __forceinline
#define N_ __declspec(noinline)
#define A_(x) __declspec(align(x))
#endif

#ifdef COMPILER_CLANG
#define A_(x) __attribute__((aligned(x))) 
#define E_(x,y) __builtin_expect(x,y)
#define L_ static inline __attribute__((always_inline))
#define N_ static __attribute__((noinline))
#define W_ __attribute__((__stdcall__)) __attribute__((__force_align_arg_pointer__))
#define R_ __restrict__
#endif 

#ifdef COMPILER_GCC 
#define A_(x) __attribute__((aligned(x))) 
#define E_(x,y) __builtin_expect(x,y)
#define L_ static inline __attribute__((always_inline))
#define N_ static __attribute__((noinline))
#define W_ __attribute__((__stdcall__)) __attribute__((__force_align_arg_pointer__))
#define R_ __restrict__
#endif


//type define
typedef float F1;
typedef double D1;
typedef signed char SB1;typedef unsigned char B1;
typedef signed short SW1;typedef unsigned short W1;
typedef signed int SI1;typedef unsigned int I1;
typedef signed long long SL1;typedef unsigned long long L1;

#ifdef COMPILER_MSVC
#include <xmmintrin.h>  // SSE intrinsics
typedef __m128 F4;
#else
typedef float F4 __attribute__((vector_size(16)));
#endif

// type cast
#define F1_(x) (F1)(x)
#define D1_(x) (D1)(x)
#define SB1_(x) (SB1)(x)
#define SW1_(x) (SW1)(x)
#define SI1_(x) (SI1)(x)
#define SL1_(x) (SL1)(x)
#define B1_(x) (B1)(x)
#define W1_(x) (W1)(x)
#define I1_(x) (I1)(x)
#define L1_(x) (L1)(x)

// pointer
typedef F1* R_ F1R;  typedef F1 V_* F1V;
typedef D1* R_ D1R;  typedef D1 V_* D1V;
typedef B1* R_ B1R;  typedef B1 V_* B1V;
typedef W1* R_ W1R;  typedef W1 V_* W1V;
typedef I1* R_ I1R;  typedef I1 V_* I1V;
typedef L1* R_ L1R;  typedef L1 V_* L1V;

//pointer cast 
#define F1R_(x) ((F1R)(x))
#define D1R_(x) ((D1R)(x))
#define B1R_(x) ((B1R)(x))
#define W1R_(x) ((W1R)(x))
#define I1R_(x) ((I1R)(x))
#define L1R_(x) ((L1R)(x))

#define F1V_(x) ((F1V)(x))
#define D1V_(x) ((D1V)(x))
#define B1V_(x) ((B1V)(x))
#define W1V_(x) ((W1V)(x))
#define I1V_(x) ((I1V)(x))
#define L1V_(x) ((L1V)(x))
#endif