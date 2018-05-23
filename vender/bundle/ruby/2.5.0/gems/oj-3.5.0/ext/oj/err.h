/* err.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 *  - Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 
 *  - Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 
 *  - Neither the name of Peter Ohler nor the names of its contributors may be
 *    used to endorse or promote products derived from this software without
 *    specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef __OJ_ERR_H__
#define __OJ_ERR_H__

#include "ruby.h"
// Needed to silence 2.4.0 warnings.
#ifndef NORETURN
# define NORETURN(x) x
#endif

#define set_error(err, eclas, msg, json, current) _oj_err_set_with_location(err, eclas, msg, json, current, __FILE__, __LINE__)

typedef struct _Err {
    VALUE	clas;
    char	msg[128];
} *Err;

extern VALUE	oj_parse_error_class;

extern void	oj_err_set(Err e, VALUE clas, const char *format, ...);
extern void	_oj_err_set_with_location(Err err, VALUE eclas, const char *msg, const char *json, const char *current, const char* file, int line);

NORETURN(extern void	oj_err_raise(Err e));

#define raise_error(msg, json, current) _oj_raise_error(msg, json, current, __FILE__, __LINE__)

NORETURN(extern void	_oj_raise_error(const char *msg, const char *json, const char *current, const char* file, int line));


inline static void
err_init(Err e) {
    e->clas = Qnil;
    *e->msg = '\0';
}

inline static int
err_has(Err e) {
    return (Qnil != e->clas);
}

#endif /* __OJ_ERR_H__ */
