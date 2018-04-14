/* rxclass.h
 * Copyright (c) 2017, Peter Ohler
 * All rights reserved.
 */

#ifndef __OJ_RXCLASS_H__
#define __OJ_RXCLASS_H__

#include <stdbool.h>
#include "ruby.h"

struct _RxC;

typedef struct _RxClass {
    struct _RxC	*head;
    struct _RxC	*tail;
    char	err[128];
} *RxClass;

extern void	oj_rxclass_init(RxClass rc);
extern void	oj_rxclass_cleanup(RxClass rc);
extern int	oj_rxclass_append(RxClass rc, const char *expr, VALUE clas);
extern VALUE	oj_rxclass_match(RxClass rc, const char *str, int len);
extern void	oj_rxclass_copy(RxClass src, RxClass dest);
extern void	oj_rxclass_rappend(RxClass rc, VALUE rx, VALUE clas);

#endif /* __OJ_RXCLASS_H__ */
