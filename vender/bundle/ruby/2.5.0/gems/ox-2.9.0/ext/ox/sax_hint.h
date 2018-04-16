/* hint.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef __OX_HINT_H__
#define __OX_HINT_H__

#include <stdbool.h>

typedef enum {
    ActiveOverlay	= 0,
    InactiveOverlay	= 'i',
    BlockOverlay	= 'b',
    OffOverlay		= 'o',
    AbortOverlay	= 'a',
    NestOverlay		= 'n', // nest flag is ignored
} Overlay;

typedef struct _Hint {
    const char	*name;
    char	empty;	// must be closed or close auto it, not error
    char	nest;	// nesting allowed
    char	jump;	// jump to end <script> ... </script>
    char	overlay;// Overlay
    const char	**parents;
} *Hint;

typedef struct _Hints {
    const char	*name;
    Hint	hints; // array of hints
    int		size;
} *Hints;

extern Hints	ox_hints_html(void);
extern Hint	ox_hint_find(Hints hints, const char *name);
extern Hints	ox_hints_dup(Hints h);
extern void	ox_hints_destroy(Hints h);

#endif /* __OX_HINT_H__ */
