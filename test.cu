#include <cub/cub.cuh>

/*
The header /usr/local/cuda-12.1/include/cub/cub.cuh indirectly includes the
header /usr/local/cuda-12.1/include/cuda/std/detail/__config, that defines
_Float16 as

#define _Float16 __half

This conflicts with GCC's use of _Float16 on ARM and on x86 systems with SSE2,
according to ISO/IEC TS 18661-3:2015.

_Float16 is used in GCC's headers avx512fp16vlintrin.h and avx512fp16intrin.h,
that are included by <immintrin.h>

On those systems, including <immintrin.h> after <cub/cub.cuh> causes a syntax
error at compilation.

Uncomment the next line to work around the issue.
*/

//#undef _Float16

#include <immintrin.h>

__global__
void unused() {}
