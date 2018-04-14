/* err.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef __OX_ERR_H__
#define __OX_ERR_H__

#include "ruby.h"

#define set_error(err, msg, xml, current) _ox_err_set_with_location(err, msg, xml, current, __FILE__, __LINE__)

typedef struct _Err {
    VALUE	clas;
    char	msg[128];
} *Err;

extern VALUE	ox_arg_error_class;
extern VALUE	ox_parse_error_class;

extern void	ox_err_set(Err e, VALUE clas, const char *format, ...);
extern void	_ox_err_set_with_location(Err err, const char *msg, const char *xml, const char *current, const char* file, int line);
extern void	ox_err_raise(Err e);

inline static void
err_init(Err e) {
    e->clas = Qnil;
    *e->msg = '\0';
}

inline static int
err_has(Err e) {
    return (Qnil != e->clas);
}

#endif /* __OX_ERR_H__ */
