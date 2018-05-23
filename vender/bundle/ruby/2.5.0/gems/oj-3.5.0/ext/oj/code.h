/* code.h
 * Copyright (c) 2017, Peter Ohler
 * All rights reserved.
 */

#ifndef __OJ_CODE_H__
#define __OJ_CODE_H__

#include <ruby.h>

#include "oj.h"

typedef void	(*EncodeFunc)(VALUE obj, int depth, Out out);
typedef VALUE	(*DecodeFunc)(VALUE clas, VALUE args);

typedef struct _Code {
    const char	*name;
    VALUE	clas;
    EncodeFunc	encode;
    DecodeFunc	decode;
    bool	active; // For compat mode.
} *Code;

// Used by encode functions.
typedef struct _Attr {
    const char	*name;
    int		len;
    VALUE	value;
    long	num;
    VALUE	time;
} *Attr;

extern bool	oj_code_dump(Code codes, VALUE obj, int depth, Out out);
extern VALUE	oj_code_load(Code codes, VALUE clas, VALUE args);
extern void	oj_code_set_active(Code codes, VALUE clas, bool active);
extern bool	oj_code_has(Code codes, VALUE clas, bool encode);

extern void	oj_code_attrs(VALUE obj, Attr attrs, int depth, Out out, bool with_class);

extern struct _Code	oj_compat_codes[];

#endif /* __OJ_CODE_H__ */
