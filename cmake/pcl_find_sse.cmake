###############################################################################
# Check for the presence of SSE and figure out the flags to use for it.
macro(PCL_CHECK_FOR_SSE)
    include(CheckCXXSourceRuns)
    if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
        set(SSE_FLAGS)

        check_cxx_source_runs("
            #include <mm_malloc.h>
            int main()
            {
              void* mem = _mm_malloc (100, 16);
              return 0;
            }"
            HAVE_MM_MALLOC)

        check_cxx_source_runs("
            #include <stdlib.h>
            int main()
            {
              void* mem;
              return posix_memalign (&mem, 16, 100);
            }"
            HAVE_POSIX_MEMALIGN)

        set(CMAKE_REQUIRED_FLAGS "-msse4.1")
        check_cxx_source_runs("
            #include <smmintrin.h>
            int main()
            {
                __m128 a, b;
                float vals[4] = {1, 2, 3, 4};
                const int mask = 123;
                a = _mm_loadu_ps(vals);
                b = a;
                b = _mm_dp_ps (a, a, mask);
                _mm_storeu_ps(vals,b);
                return 0;
            }"
            HAVE_SSE4_1_EXTENSIONS)

        set(CMAKE_REQUIRED_FLAGS "-msse3")
        check_cxx_source_runs("
            #include <pmmintrin.h>

            int main()
            {
                __m128d a, b;
                double vals[2] = {0};
                a = _mm_loadu_pd(vals);
                b = _mm_hadd_pd(a,a);
                _mm_storeu_pd(vals, b);
                return 0;
            }"
            HAVE_SSE3_EXTENSIONS)

        set(CMAKE_REQUIRED_FLAGS "-msse2")
        check_cxx_source_runs("
            #include <emmintrin.h>

            int main()
            {
                __m128d a, b;
                double vals[2] = {0};
                a = _mm_loadu_pd(vals);
                b = _mm_add_pd(a,a);
                _mm_storeu_pd(vals,b);
                return 0;
            }"
            HAVE_SSE2_EXTENSIONS)

        set(CMAKE_REQUIRED_FLAGS "-msse")
        check_cxx_source_runs("
            #include <xmmintrin.h>
            int main()
            {
                __m128 a, b;
                float vals[4] = {0};
                a = _mm_loadu_ps(vals);
                b = a;
                b = _mm_add_ps(a,b);
                _mm_storeu_ps(vals,b);
                return 0;
            }"
            HAVE_SSE_EXTENSIONS)

       set(CMAKE_REQUIRED_FLAGS)

       if (NOT APPLE)
         SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu++0x -march=native")
       endif (NOT APPLE)

       if (HAVE_SSE4_1_EXTENSIONS)
           if (APPLE)
             SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -msse4.1 -mfpmath=sse")
           endif (APPLE)
           message(STATUS "Found SSE4.1 extensions, using flags: ${SSE_FLAGS}")
       elseif(HAVE_SSE3_EXTENSIONS)
           if (APPLE)
             SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -msse3 -mfpmath=sse")
           endif (APPLE)
           message(STATUS "Found SSE3 extensions, using flags: ${SSE_FLAGS}")
       elseif(HAVE_SSE2_EXTENSIONS)
           if (APPLE)
             SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -msse2 -mfpmath=sse")
           endif (APPLE)
           message(STATUS "Found SSE2 extensions, using flags: ${SSE_FLAGS}")
       elseif(HAVE_SSE_EXTENSIONS)
           if (APPLE)
             SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -msse -mfpmath=sse")
           endif (APPLE)
           message(STATUS "Found SSE extensions, using flags: ${SSE_FLAGS}")
       else (HAVE_SSE4_1_EXTENSIONS)
           message(STATUS "No SSE extensions found")
       endif(HAVE_SSE4_1_EXTENSIONS)

    elseif(MSVC)

        check_cxx_source_runs("
            #include <emmintrin.h>

            int main()
            {
                __m128d a, b;
                double vals[2] = {0};
                a = _mm_loadu_pd(vals);
                b = _mm_add_pd(a,a);
                _mm_storeu_pd(vals,b);
                return 0;
            }"
            HAVE_SSE2_EXTENSIONS)

        if(HAVE_SSE2_EXTENSIONS)
            SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /arch:SSE2 /fp:fast -D__SSE__ -D__SSE2__")
            message(STATUS "Found SSE2 extensions, using flags: ${SSE_FLAGS}")
        endif(HAVE_SSE2_EXTENSIONS)
    endif(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
endmacro(PCL_CHECK_FOR_SSE)