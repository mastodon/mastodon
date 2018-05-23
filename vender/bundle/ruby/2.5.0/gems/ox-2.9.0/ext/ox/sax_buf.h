/* sax_buf.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef __OX_SAX_BUF_H__
#define __OX_SAX_BUF_H__

typedef struct _Buf {
    char	base[0x00001000];
    char	*head;
    char	*end;
    char	*tail;
    char	*read_end;      /* one past last character read */
    char       	*pro;           /* protection start, buffer can not slide past this point */
    char        *str;           /* start of current string being read */
    int		pos;
    int		line;
    int		col;
    int		pro_pos;
    int		pro_line;
    int		pro_col;
    int		(*read_func)(struct _Buf *buf);
    union {
        int     	fd;
        VALUE   	io;
	const char	*str;
    } in;
    struct _SaxDrive	*dr;
} *Buf;

typedef struct _CheckPt {
    int		pro_dif;
    int		pos;
    int		line;
    int		col;
    char	c;
} *CheckPt;

#define CHECK_PT_INIT { -1, 0, 0, 0, '\0' }

extern void	ox_sax_buf_init(Buf buf, VALUE io);
extern int	ox_sax_buf_read(Buf buf);

static inline char
buf_get(Buf buf) {
    //printf("*** drive get from '%s'  from start: %ld  buf: %p  from read_end: %ld\n", buf->tail, buf->tail - buf->head, buf->head, buf->read_end - buf->tail);
    if (buf->read_end <= buf->tail) {
        if (0 != ox_sax_buf_read(buf)) {
            return '\0';
        }
    }
    if ('\n' == *buf->tail) {
        buf->line++;
        buf->col = 0;
    } else {
	buf->col++;
    }
    buf->pos++;

    return *buf->tail++;
}

static inline void
buf_backup(Buf buf) {
    buf->tail--;
    buf->col--;
    buf->pos--;
    if (0 >= buf->col) {
	buf->line--;
	// allow col to be negative since we never backup twice in a row
    }
}

static inline void
buf_protect(Buf buf) {
    buf->pro = buf->tail;
    buf->str = buf->tail; // can't have str before pro
    buf->pro_pos = buf->pos;
    buf->pro_line = buf->line;
    buf->pro_col = buf->col;
}

static inline void
buf_reset(Buf buf) {
    buf->tail = buf->pro;
    buf->pos = buf->pro_pos;
    buf->line = buf->pro_line;
    buf->col = buf->pro_col;
}

/* Starts by reading a character so it is safe to use with an empty or
 * compacted buffer.
 */
static inline char
buf_next_non_white(Buf buf) {
    char        c;

    while ('\0' != (c = buf_get(buf))) {
	switch(c) {
	case ' ':
	case '\t':
	case '\f':
	case '\n':
	case '\r':
	    break;
	default:
	    return c;
	}
    }
    return '\0';
}

/* Starts by reading a character so it is safe to use with an empty or
 * compacted buffer.
 */
static inline char
buf_next_white(Buf buf) {
    char        c;

    while ('\0' != (c = buf_get(buf))) {
	switch(c) {
	case ' ':
	case '\t':
	case '\f':
	case '\n':
	case '\r':
	case '\0':
	    return c;
	default:
	    break;
	}
    }
    return '\0';
}

static inline void
buf_cleanup(Buf buf) {
    if (buf->base != buf->head && 0 != buf->head) {
        xfree(buf->head);
	buf->head = 0;
    }
}

static inline int
is_white(char c) {
    switch(c) {
    case ' ':
    case '\t':
    case '\f':
    case '\n':
    case '\r':
        return 1;
    default:
        break;
    }
    return 0;
}

static inline void
buf_checkpoint(Buf buf, CheckPt cp) {
    cp->pro_dif = (int)(buf->tail - buf->pro);
    cp->pos = buf->pos;
    cp->line = buf->line;
    cp->col = buf->col;
    cp->c = *(buf->tail - 1);
}

static inline int
buf_checkset(CheckPt cp) {
    return (0 <= cp->pro_dif);
}

static inline char
buf_checkback(Buf buf, CheckPt cp) {
    buf->tail = buf->pro + cp->pro_dif;
    buf->pos = cp->pos;
    buf->line = cp->line;
    buf->col = cp->col;
    return cp->c;
}

static inline void
buf_collapse_return(char *str) {
    char	*s = str;
    char	*back = str;

    for (; '\0' != *s; s++) {
	if (back != str && '\n' == *s && '\r' == *(back - 1)) {
	    *(back - 1) = '\n';
	} else {
	    *back++ = *s;
	}
    }
    *back = '\0';
}

static inline void
buf_collapse_white(char *str) {
    char	*s = str;
    char	*back = str;

    for (; '\0' != *s; s++) {
	switch(*s) {
	case ' ':
	case '\t':
	case '\f':
	case '\n':
	case '\r':
	    if (back == str || ' ' != *(back - 1)) {
		*back++ = ' ';
	    }
	    break;
	default:
	    *back++ = *s;
	    break;
	}
    }
    *back = '\0';
}

#endif /* __OX_SAX_BUF_H__ */
