/* reader.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef __OJ_READER_H__
#define __OJ_READER_H__

typedef struct _Reader {
    char	base[0x00001000];
    char	*head;
    char	*end;
    char	*tail;
    char	*read_end;	/* one past last character read */
    char	*pro;		/* protection start, buffer can not slide past this point */
    char	*str;		/* start of current string being read */
    long	pos;
    int		line;
    int		col;
    int		free_head;
    int		(*read_func)(struct _Reader *reader);
    union {
	int		fd;
	VALUE		io;
	const char	*in_str;
    };
} *Reader;

extern void	oj_reader_init(Reader reader, VALUE io, int fd, bool to_s);
extern int	oj_reader_read(Reader reader);

static inline char
reader_get(Reader reader) {
    //printf("*** drive get from '%s'  from start: %ld	buf: %p	 from read_end: %ld\n", reader->tail, reader->tail - reader->head, reader->head, reader->read_end - reader->tail);
    if (reader->read_end <= reader->tail) {
	if (0 != oj_reader_read(reader)) {
	    return '\0';
	}
    }
    if ('\n' == *reader->tail) {
	reader->line++;
	reader->col = 0;
    }
    reader->col++;
    reader->pos++;
    
    return *reader->tail++;
}

static inline void
reader_backup(Reader reader) {
    reader->tail--;
    reader->col--;
    reader->pos--;
    if (0 >= reader->col) {
	reader->line--;
	// allow col to be negative since we never backup twice in a row
    }
}

static inline void
reader_protect(Reader reader) {
    reader->pro = reader->tail;
    reader->str = reader->tail; // can't have str before pro
}

static inline void
reader_release(Reader reader) {
    reader->pro = 0;
}

/* Starts by reading a character so it is safe to use with an empty or
 * compacted buffer.
 */
static inline char
reader_next_non_white(Reader reader) {
    char	c;

    while ('\0' != (c = reader_get(reader))) {
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
reader_next_white(Reader reader) {
    char	c;

    while ('\0' != (c = reader_get(reader))) {
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

static inline int
reader_expect(Reader reader, const char *s) {
    for (; '\0' != *s; s++) {
	if (reader_get(reader) != *s) {
	    return -1;
	}
    }
    return 0;
}

static inline void
reader_cleanup(Reader reader) {
    if (reader->free_head && 0 != reader->head) {
	xfree((char*)reader->head);
	reader->head = 0;
	reader->free_head = 0;
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

#endif /* __OJ_READER_H__ */
