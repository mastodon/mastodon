/* err.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <stdarg.h>

#include "err.h"

void
ox_err_set(Err e, VALUE clas, const char *format, ...) {
    va_list	ap;

    va_start(ap, format);
    e->clas = clas;
    vsnprintf(e->msg, sizeof(e->msg) - 1, format, ap);
    va_end(ap);
}

#if __GNUC__ > 4
_Noreturn void
#else
void
#endif
ox_err_raise(Err e) {
    rb_raise(e->clas, "%s", e->msg);
}

void
_ox_err_set_with_location(Err err, const char *msg, const char *xml, const char *current, const char* file, int line) {
    int	xline = 1;
    int	col = 1;

    for (; xml < current && '\n' != *current; current--) {
	col++;
    }
    for (; xml < current; current--) {
	if ('\n' == *current) {
	    xline++;
	}
    }
    ox_err_set(err, ox_parse_error_class, "%s at line %d, column %d [%s:%d]\n", msg, xline, col, file, line);
}
