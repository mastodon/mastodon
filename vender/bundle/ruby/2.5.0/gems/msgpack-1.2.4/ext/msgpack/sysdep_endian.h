/*
 * MessagePack for Ruby
 *
 * Copyright (C) 2008-2013 Sadayuki Furuhashi
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */
#ifndef MSGPACK_RUBY_SYSDEP_ENDIAN_H__
#define MSGPACK_RUBY_SYSDEP_ENDIAN_H__

/* including arpa/inet.h requires an extra dll on win32 */
#ifndef _WIN32
#include <arpa/inet.h>  /* __BYTE_ORDER */
#endif

/*
 * Use following command to add consitions here:
 *   cpp -dM `echo "#include <arpa/inet.h>" > test.c; echo test.c` | grep ENDIAN
 */
#if !defined(__LITTLE_ENDIAN__) && !defined(__BIG_ENDIAN__)  /* Mac OS X */
#  if defined(_LITTLE_ENDIAN) \
        || ( defined(__BYTE_ORDER) && defined(__LITTLE_ENDIAN) \
                && __BYTE_ORDER == __LITTLE_ENDIAN ) /* Linux */ \
        || ( defined(__BYTE_ORDER__) && defined(__ORDER_LITTLE_ENDIAN__) \
                && __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__ ) /* Solaris */
#    define __LITTLE_ENDIAN__
#  elif defined(_BIG_ENDIAN) \
        || (defined(__BYTE_ORDER) && defined(__BIG_ENDIAN) \
                && __BYTE_ORDER == __BIG_ENDIAN) /* Linux */ \
        || (defined(__BYTE_ORDER__) && defined(__ORDER_BIG_ENDIAN__) \
                && __BYTE_ORDER__ == __ORDER_BIG_ENDIAN__) /* Solaris */
#    define __BIG_ENDIAN__
#  elif defined(_WIN32)  /* Win32 */
#    define __LITTLE_ENDIAN__
#  endif
#endif


#endif

