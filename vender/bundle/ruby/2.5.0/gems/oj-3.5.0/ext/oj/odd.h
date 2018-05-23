/* odd.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef __OJ_ODD_H__
#define __OJ_ODD_H__

#include <stdbool.h>

#include "ruby.h"

#define MAX_ODD_ARGS	10

typedef VALUE	(*AttrGetFunc)(VALUE obj);

typedef struct _Odd {
    const char	*classname;
    size_t	clen;
    VALUE	clas;			// Ruby class or module
    VALUE	create_obj;
    ID		create_op;
    int		attr_cnt;
    bool	is_module;
    bool	raw;
    const char	*attr_names[MAX_ODD_ARGS]; // NULL terminated attr names
    ID		attrs[MAX_ODD_ARGS];	   // 0 terminated attr IDs
    AttrGetFunc	attrFuncs[MAX_ODD_ARGS];
} *Odd;

typedef struct _OddArgs {
    Odd		odd;
    VALUE	args[MAX_ODD_ARGS];
} *OddArgs;

extern void	oj_odd_init(void);
extern Odd	oj_get_odd(VALUE clas);
extern Odd	oj_get_oddc(const char *classname, size_t len);
extern OddArgs	oj_odd_alloc_args(Odd odd);
extern void	oj_odd_free(OddArgs args);
extern int	oj_odd_set_arg(OddArgs args, const char *key, size_t klen, VALUE value);
extern void	oj_reg_odd(VALUE clas, VALUE create_object, VALUE create_method, int mcnt, VALUE *members, bool raw);

#endif /* __OJ_ODD_H__ */
