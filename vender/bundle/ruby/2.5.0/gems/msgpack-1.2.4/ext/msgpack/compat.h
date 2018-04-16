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
#ifndef MSGPACK_RUBY_COMPAT_H__
#define MSGPACK_RUBY_COMPAT_H__

#include <stdbool.h>
#include "ruby.h"

#if defined(HAVE_RUBY_ST_H)
#  include "ruby/st.h"  /* ruby hash on Ruby 1.9 */
#elif defined(HAVE_ST_H)
#  include "st.h"       /* ruby hash on Ruby 1.8 */
#endif


/*
 * ZALLOC_N (ruby 2.2 or later)
 */
#ifndef RB_ZALLOC_N
#  define RB_ZALLOC_N(type,n) ((type*)ruby_xcalloc((size_t)(n),sizeof(type)))
#endif
#ifndef ZALLOC_N
#  define ZALLOC_N(type,n) RB_ZALLOC_N(type,n)
#endif

/*
 * COMPAT_HAVE_ENCODING
 */
#ifdef HAVE_RUBY_ENCODING_H
#  include "ruby/encoding.h"
#  define COMPAT_HAVE_ENCODING
#endif

#if defined(__MACRUBY__)  /* MacRuby */
#  undef COMPAT_HAVE_ENCODING
#endif


/*
 * define STR_DUP_LIKELY_DOES_COPY
 * check rb_str_dup actually copies the string or not
 */
#if defined(RUBY_VM) && defined(FL_ALL) && defined(FL_USER1) && defined(FL_USER3)  /* MRI 1.9 */
#  define STR_DUP_LIKELY_DOES_COPY(str) FL_ALL(str, FL_USER1|FL_USER3)  /* same as STR_ASSOC_P(str) */

#elif defined(FL_TEST) && defined(ELTS_SHARED)  /* MRI 1.8 */
#  define STR_DUP_LIKELY_DOES_COPY(str) (!FL_TEST(str, ELTS_SHARED))

//#elif defined(RUBINIUS) || defined(JRUBY)  /* Rubinius and JRuby */
#else
#  define STR_DUP_LIKELY_DOES_COPY(str) (1)

#endif


/*
 * SIZET2NUM
 */
#ifndef SIZET2NUM   /* MRI 1.8 */
#  define SIZET2NUM(v) ULL2NUM(v)
#endif


/*
 * rb_errinfo()
 */
#if defined(RUBY_VM)  /* MRI 1.9 */
#  define COMPAT_RERAISE rb_exc_raise(rb_errinfo())

#elif defined(JRUBY)  /* JRuby */
#  define COMPAT_RERAISE rb_exc_raise(rb_gv_get("$!"))

#else  /* MRI 1.8 and Rubinius */
#  define COMPAT_RERAISE rb_exc_raise(ruby_errinfo)
#endif


/*
 * RBIGNUM_POSITIVE_P
 */
#ifndef RBIGNUM_POSITIVE_P
#  if defined(RUBINIUS)  /* Rubinius <= v1.2.3 */
#    define RBIGNUM_POSITIVE_P(b) (rb_funcall(b, rb_intern(">="), 1, INT2FIX(0)) == Qtrue)

#  elif defined(JRUBY)  /* JRuby */
#    define RBIGNUM_POSITIVE_P(b) (rb_funcall(b, rb_intern(">="), 1, INT2FIX(0)) == Qtrue)
#    define rb_big2ull(b) rb_num2ull(b)
     /*#define rb_big2ll(b) rb_num2ll(b)*/

#  else  /* MRI 1.8 */
#    define RBIGNUM_POSITIVE_P(b) (RBIGNUM(b)->sign)
#  endif
#endif


/*
 * RSTRING_PTR, RSTRING_LEN
 */
#ifndef RSTRING_PTR  /* MRI 1.8.5 */
#  define RSTRING_PTR(s) (RSTRING(s)->ptr)
#endif

#ifndef RSTRING_LEN  /* MRI 1.8.5 */
#  define RSTRING_LEN(s) (RSTRING(s)->len)
#endif


/*
 * RSTRUCT_GET
 */
#ifndef RSTRUCT_GET
#  ifdef RSTRUCT_PTR  /* MRI <= 2.0.0 */
#    define RSTRUCT_GET(st, idx)  (RSTRUCT_PTR(st)[idx])
#  else /* Rubinius */
#    define RSTRUCT_GET(st, idx)  (rb_struct_aref(st, INT2FIX(idx)))
#  endif
#endif


#endif

