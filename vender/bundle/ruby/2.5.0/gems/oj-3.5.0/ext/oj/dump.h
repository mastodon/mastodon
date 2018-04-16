/* dump.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef __OJ_DUMP_H__
#define __OJ_DUMP_H__

#include <ruby.h>

#include "oj.h"

#define MAX_DEPTH 1000

// Extra padding at end of buffer.
#define BUFFER_EXTRA 10

extern void	oj_dump_nil(VALUE obj, int depth, Out out, bool as_ok);
extern void	oj_dump_true(VALUE obj, int depth, Out out, bool as_ok);
extern void	oj_dump_false(VALUE obj, int depth, Out out, bool as_ok);
extern void	oj_dump_fixnum(VALUE obj, int depth, Out out, bool as_ok);
extern void	oj_dump_bignum(VALUE obj, int depth, Out out, bool as_ok);
extern void	oj_dump_float(VALUE obj, int depth, Out out, bool as_ok);
extern void	oj_dump_str(VALUE obj, int depth, Out out, bool as_ok);
extern void	oj_dump_sym(VALUE obj, int depth, Out out, bool as_ok);
extern void	oj_dump_class(VALUE obj, int depth, Out out, bool as_ok);

extern void	oj_dump_raw(const char *str, size_t cnt, Out out);
extern void	oj_dump_cstr(const char *str, size_t cnt, bool is_sym, bool escape1, Out out);
extern void	oj_dump_ruby_time(VALUE obj, Out out);
extern void	oj_dump_xml_time(VALUE obj, Out out);
extern void	oj_dump_time(VALUE obj, Out out, int withZone);
extern void	oj_dump_obj_to_s(VALUE obj, Out out);

extern const char*	oj_nan_str(VALUE obj, int opt, int mode, bool plus, int *lenp);

extern void	oj_grow_out(Out out, size_t len);
extern long	oj_check_circular(VALUE obj, Out out);

extern void	oj_dump_strict_val(VALUE obj, int depth, Out out);
extern void	oj_dump_null_val(VALUE obj, int depth, Out out);
extern void	oj_dump_obj_val(VALUE obj, int depth, Out out);
extern void	oj_dump_compat_val(VALUE obj, int depth, Out out, bool as_ok);
extern void	oj_dump_rails_val(VALUE obj, int depth, Out out);
extern void	oj_dump_custom_val(VALUE obj, int depth, Out out, bool as_ok);
extern void	oj_dump_wab_val(VALUE obj, int depth, Out out);

extern VALUE	oj_add_to_json(int argc, VALUE *argv, VALUE self);
extern VALUE	oj_remove_to_json(int argc, VALUE *argv, VALUE self);

extern int	oj_dump_float_printf(char *buf, size_t blen, VALUE obj, double d, const char *format);

extern bool	oj_dump_ignore(Options opts, VALUE obj);

inline static void
assure_size(Out out, size_t len) {
    if (out->end - out->cur <= (long)len) {
	oj_grow_out(out, len);
    }
}

inline static void
fill_indent(Out out, int cnt) {
    if (0 < out->indent) {
	cnt *= out->indent;
	*out->cur++ = '\n';
	for (; 0 < cnt; cnt--) {
	    *out->cur++ = ' ';
	}
    }
}

inline static void
dump_ulong(unsigned long num, Out out) {
    char	buf[32];
    char	*b = buf + sizeof(buf) - 1;

    *b-- = '\0';
    if (0 < num) {
	for (; 0 < num; num /= 10, b--) {
	    *b = (num % 10) + '0';
	}
	b++;
    } else {
	*b = '0';
    }
    for (; '\0' != *b; b++) {
	*out->cur++ = *b;
    }
    *out->cur = '\0';
}

#endif /* __OJ_DUMP_H__ */
