/* parse.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef __OJ_PARSE_H__
#define __OJ_PARSE_H__

#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#include "ruby.h"
#include "oj.h"
#include "val_stack.h"
#include "circarray.h"
#include "reader.h"
#include "rxclass.h"

struct _RxClass;

typedef struct _NumInfo {
    int64_t	i;
    int64_t	num;
    int64_t	div;
    int64_t	di;
    const char	*str;
    size_t	len;
    long	exp;
    int		big;
    int		infinity;
    int		nan;
    int		neg;
    int		hasExp;
    int		no_big;
} *NumInfo;

typedef struct _ParseInfo {
    // used for the string parser
    const char		*json;
    const char		*cur;
    const char		*end;
    // used for the stream parser
    struct _Reader	rd;

    struct _Err		err;
    struct _Options	options;
    VALUE		handler;
    struct _ValStack	stack;
    CircArray		circ_array;
    struct _RxClass	str_rx;
    int			expect_value;
    int			max_depth; // just for the json gem
    VALUE		proc;
    VALUE		(*start_hash)(struct _ParseInfo *pi);
    void		(*end_hash)(struct _ParseInfo *pi);
    VALUE		(*hash_key)(struct _ParseInfo *pi, const char *key, size_t klen);
    void		(*hash_set_cstr)(struct _ParseInfo *pi, Val kval, const char *str, size_t len, const char *orig);
    void		(*hash_set_num)(struct _ParseInfo *pi, Val kval, NumInfo ni);
    void		(*hash_set_value)(struct _ParseInfo *pi, Val kval, VALUE value);

    VALUE		(*start_array)(struct _ParseInfo *pi);
    void		(*end_array)(struct _ParseInfo *pi);
    void		(*array_append_cstr)(struct _ParseInfo *pi, const char *str, size_t len, const char *orig);
    void		(*array_append_num)(struct _ParseInfo *pi, NumInfo ni);
    void		(*array_append_value)(struct _ParseInfo *pi, VALUE value);

    void		(*add_cstr)(struct _ParseInfo *pi, const char *str, size_t len, const char *orig);
    void		(*add_num)(struct _ParseInfo *pi, NumInfo ni);
    void		(*add_value)(struct _ParseInfo *pi, VALUE val);
    VALUE		err_class;
    bool		has_callbacks;
} *ParseInfo;

extern void	oj_parse2(ParseInfo pi);
extern void	oj_set_error_at(ParseInfo pi, VALUE err_clas, const char* file, int line, const char *format, ...);
extern VALUE	oj_pi_parse(int argc, VALUE *argv, ParseInfo pi, char *json, size_t len, int yieldOk);
extern VALUE	oj_num_as_value(NumInfo ni);

extern void	oj_set_strict_callbacks(ParseInfo pi);
extern void	oj_set_object_callbacks(ParseInfo pi);
extern void	oj_set_compat_callbacks(ParseInfo pi);
extern void	oj_set_wab_callbacks(ParseInfo pi);

extern void	oj_sparse2(ParseInfo pi);
extern VALUE	oj_pi_sparse(int argc, VALUE *argv, ParseInfo pi, int fd);

static inline void
parse_info_init(ParseInfo pi) {
    memset(pi, 0, sizeof(struct _ParseInfo));
}

static inline bool
empty_ok(Options options) {
    switch (options->mode) {
    case ObjectMode:
    case WabMode:
	return true;
    case CompatMode:
    case RailsMode:
	return false;
    case StrictMode:
    case NullMode:
    case CustomMode:
    default:
	break;
    }
    return Yes == options->empty_string;
}

#endif /* __OJ_PARSE_H__ */
