/* sax.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef __OX_SAX_H__
#define __OX_SAX_H__

#include <stdbool.h>

#include "sax_buf.h"
#include "sax_has.h"
#include "sax_stack.h"
#include "sax_hint.h"
#include "ox.h"

typedef struct _SaxOptions {
    int			symbolize;
    int			convert_special;
    int			smart;
    SkipMode		skip;
    char		strip_ns[64];
    Hints		hints;
} *SaxOptions;

typedef struct _SaxDrive {
    struct _Buf		buf;
    struct _NStack	stack;	/* element name stack */
    VALUE		handler;
    VALUE		value_obj;
    struct _SaxOptions	options;
    int			err;
    int			blocked;
    bool		abort;
    struct _Has		has;
#if HAS_ENCODING_SUPPORT
    rb_encoding *encoding;
#elif HAS_PRIVATE_ENCODING
    VALUE	encoding;
#else
    const char	*encoding;
#endif
} *SaxDrive;

extern void	ox_collapse_return(char *str);
extern void	ox_sax_parse(VALUE handler, VALUE io, SaxOptions options);
extern void	ox_sax_drive_cleanup(SaxDrive dr);
extern void	ox_sax_drive_error(SaxDrive dr, const char *msg);
extern int	ox_sax_collapse_special(SaxDrive dr, char *str, int pos, int line, int col);

extern VALUE	ox_sax_value_class;

extern VALUE	str2sym(SaxDrive dr, const char *str, const char **strp);

#endif /* __OX_SAX_H__ */
