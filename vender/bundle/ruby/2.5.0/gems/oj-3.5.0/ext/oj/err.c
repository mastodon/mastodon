/* err.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <stdarg.h>

#include "err.h"

void
oj_err_set(Err e, VALUE clas, const char *format, ...) {
    va_list	ap;

    va_start(ap, format);
    e->clas = clas;
    vsnprintf(e->msg, sizeof(e->msg) - 1, format, ap);
    va_end(ap);
}

void
oj_err_raise(Err e) {
    rb_raise(e->clas, "%s", e->msg);
}

void
_oj_err_set_with_location(Err err, VALUE eclas, const char *msg, const char *json, const char *current, const char* file, int line) {
    int	n = 1;
    int	col = 1;

    for (; json < current && '\n' != *current; current--) {
	col++;
    }
    for (; json < current; current--) {
	if ('\n' == *current) {
	    n++;
	}
    }
    oj_err_set(err, eclas, "%s at line %d, column %d [%s:%d]", msg, n, col, file, line);
}

void
_oj_raise_error(const char *msg, const char *json, const char *current, const char* file, int line) {
    struct _Err	err;
    int		n = 1;
    int		col = 1;

    for (; json < current && '\n' != *current; current--) {
	col++;
    }
    for (; json < current; current--) {
	if ('\n' == *current) {
	    n++;
	}
    }
    oj_err_set(&err, oj_parse_error_class, "%s at line %d, column %d [%s:%d]", msg, n, col, file, line);
    rb_raise(err.clas, "%s", err.msg);
}
