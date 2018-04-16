/*
 * Copyright (c) 2008-2010 Wayne Meissner
 *
 * Copyright (c) 2008-2013, Ruby FFI project contributors
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the Ruby FFI project nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef _MSC_VER
# include <sys/param.h>
#endif
# include <sys/types.h>
#ifndef _MSC_VER
# include <stdint.h>
# include <stdbool.h>
#else
# include "win32/stdint.h"
# include "win32/stdbool.h"
#endif
#include <ruby.h>
#include <ctype.h>
#include "rbffi_endian.h"
#include "Platform.h"

#if defined(__GNU__) || defined(__GLIBC__)
# include <gnu/lib-names.h>
#endif

static VALUE PlatformModule = Qnil;

/*
 * Determine the cpu type at compile time - useful for MacOSX where the the
 * system installed ruby incorrectly reports 'host_cpu' as 'powerpc' when running
 * on intel.
 */
#if defined(__x86_64__) || defined(__x86_64) || defined(__amd64) || defined(_M_X64) || defined(_M_AMD64)
# define CPU "x86_64"

#elif defined(__i386__) || defined(__i386) || defined(_M_IX86)
# define CPU "i386"

#elif defined(__ppc64__) || defined(__powerpc64__) || defined(_M_PPC)
# define CPU "ppc64"

#elif defined(__ppc__) || defined(__powerpc__) || defined(__powerpc)
# define CPU "ppc"

/*
 * Need to check for __sparcv9 first, because __sparc will be defined either way.
 * Note that __sparcv9 seems to only be set for Solaris. On Linux, __sparc will
 * be set, along with __arch64__ if a 64-bit platform.
 */
#elif defined(__sparcv9__) || defined(__sparcv9)
# define CPU "sparcv9"

#elif defined(__sparc__) || defined(__sparc)
# if defined(__arch64__)
#  define CPU "sparcv9"
# else
#  define CPU "sparc"
# endif

#elif defined(__arm__) || defined(__arm)
# define CPU "arm"

#elif defined(__mips__) || defined(__mips)
# define CPU "mips"

#elif defined(__s390__)
# define CPU "s390"

#else
# define CPU "unknown"
#endif

static void
export_primitive_types(VALUE module)
{
#define S(name, T) do { \
    typedef struct { char c; T v; } s; \
    rb_define_const(module, #name "_ALIGN", INT2NUM((sizeof(s) - sizeof(T)) * 8)); \
    rb_define_const(module, #name "_SIZE", INT2NUM(sizeof(T)* 8)); \
} while(0)
    S(INT8, char);
    S(INT16, short);
    S(INT32, int);
    S(INT64, long long);
    S(LONG, long);
    S(FLOAT, float);
    S(DOUBLE, double);
    S(ADDRESS, void*);
#undef S
}

void
rbffi_Platform_Init(VALUE moduleFFI)
{
    PlatformModule = rb_define_module_under(moduleFFI, "Platform");
    rb_define_const(PlatformModule, "BYTE_ORDER", INT2FIX(BYTE_ORDER));
    rb_define_const(PlatformModule, "LITTLE_ENDIAN", INT2FIX(LITTLE_ENDIAN));
    rb_define_const(PlatformModule, "BIG_ENDIAN", INT2FIX(BIG_ENDIAN));
    rb_define_const(PlatformModule, "CPU", rb_str_new2(CPU));
#if defined(__GNU__) || defined(__GLIBC__)
    rb_define_const(PlatformModule, "GNU_LIBC", rb_str_new2(LIBC_SO));
#endif
    export_primitive_types(PlatformModule);
}

