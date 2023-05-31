Including `<cub/cub.cuh>` and ` <immintrin.h>` breaks compilation with GCC 12, if the SSE2 instruction set is enabled.

Here is a simple reproducer, `test.cu`:
```c++
#include <cub/cub.cuh>
#include <immintrin.h>

__global__
void unused() {}
```

Compiling with
```bash
/usr/local/cuda-12.1/bin/nvcc -ccbin g++-12 --compiler-options "-msse2" test.cu -c -o test.o
```
fails with
```
/usr/lib/gcc/x86_64-linux-gnu/12/include/avx512fp16intrin.h(38): error: vector_size attribute requires an arithmetic or enum type
                  __v8hf __attribute__ ((__vector_size__ (16)));
                                         ^

/usr/lib/gcc/x86_64-linux-gnu/12/include/avx512fp16intrin.h(39): error: vector_size attribute requires an arithmetic or enum type
                  __v16hf __attribute__ ((__vector_size__ (32)));
                                          ^

/usr/lib/gcc/x86_64-linux-gnu/12/include/avx512fp16intrin.h(40): error: vector_size attribute requires an arithmetic or enum type
                  __v32hf __attribute__ ((__vector_size__ (64)));

(... 95 more errors ...)

Killed
```

---

This is caused by:
  - the header `.../include/cub/cub.cuh` indirectly includes the header `.../include/cuda/std/detail/__config`
  - `.../include/cuda/std/detail/__config` defines `_Float16` as
    ```c++
    #define _Float16 __half
    ```
  - this conflicts with GCC's use of `_Float16` on ARM, and x86 systems with SSE2 starting with GCC 12.

Usage of `_Float16` with GCC is documented in https://gcc.gnu.org/onlinedocs/gcc-12.3.0/gcc/Floating-Types.html,
and it is used in GCC's headers `<avx512fp16vlintrin.h>` and `<avx512fp16intrin.h>`, that are included by `<immintrin.h>`.

---

A simple workaround seems to be to `#undef _Float16` after including `<cub/cub.cuh>`, but this may lead to other
conflicts in a more realistic program.

For the simple reproducer above, this:
```c++
#include <cub/cub.cuh>
#undef _Float16
#include <immintrin.h>

__global__
void unused() {}
```
compiles fine.
