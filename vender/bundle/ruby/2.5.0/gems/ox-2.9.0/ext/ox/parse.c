/* parse.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "ruby.h"
#include "ox.h"
#include "err.h"
#include "attr.h"
#include "helper.h"
#include "special.h"

static void	read_instruction(PInfo pi);
static void	read_doctype(PInfo pi);
static void	read_comment(PInfo pi);
static char*	read_element(PInfo pi);
static void	read_text(PInfo pi);
/*static void	  read_reduced_text(PInfo pi); */
static void	read_cdata(PInfo pi);
static char*	read_name_token(PInfo pi);
static char*	read_quoted_value(PInfo pi);
static char*	read_hex_uint64(char *b, uint64_t *up);
static char*	read_10_uint64(char *b, uint64_t *up);
static char*	read_coded_chars(PInfo pi, char *text);
static void	next_non_white(PInfo pi);
static int	collapse_special(PInfo pi, char *str);

/* This XML parser is a single pass, destructive, callback parser. It is a
 * single pass parse since it only make one pass over the characters in the
 * XML document string. It is destructive because it re-uses the content of
 * the string for values in the callback and places \0 characters at various
 * places to mark the end of tokens and strings. It is a callback parser like
 * a SAX parser because it uses callback when document elements are
 * encountered.
 *
 * Parsing is very tolerant. Lack of headers and even mispelled element
 * endings are passed over without raising an error. A best attempt is made in
 * all cases to parse the string.
 */

static char	xml_valid_lower_chars[34] = "xxxxxxxxxooxxoxxxxxxxxxxxxxxxxxxo";

inline static int
is_white(char c) {
    switch (c) {
    case ' ':
    case '\t':
    case '\f':
    case '\n':
    case '\r':
	return 1;
    default:
	return 0;
    }
}


inline static void
next_non_white(PInfo pi) {
    for (; 1; pi->s++) {
	switch (*pi->s) {
	case ' ':
	case '\t':
	case '\f':
	case '\n':
	case '\r':
	    break;
	default:
	    return;
	}
    }
}

inline static void
next_white(PInfo pi) {
    for (; 1; pi->s++) {
	switch (*pi->s) {
	case ' ':
	case '\t':
	case '\f':
	case '\n':
	case '\r':
	case '\0':
	    return;
	default:
	    break;
	}
    }
}

static void
mark_pi_cb(void *ptr) {
    if (NULL != ptr) {
	HelperStack	stack = &((PInfo)ptr)->helpers;
	Helper		h;

	for (h = stack->head; h < stack->tail; h++) {
	    if (NoCode != h->type) {
		rb_gc_mark(h->obj);
	    }
	}
    }
}

VALUE
ox_parse(char *xml, ParseCallbacks pcb, char **endp, Options options, Err err) {
    struct _PInfo	pi;
    int			body_read = 0;
    int			block_given = rb_block_given_p();
    volatile VALUE	wrap;
    
    if (0 == xml) {
	set_error(err, "Invalid arg, xml string can not be null", xml, 0);
	return Qnil;
    }
    if (DEBUG <= options->trace) {
	printf("Parsing xml:\n%s\n", xml);
    }
    /* initialize parse info */
    helper_stack_init(&pi.helpers);
    // Protect against GC
    wrap = Data_Wrap_Struct(rb_cObject, mark_pi_cb, NULL, &pi);

    err_init(&pi.err);
    pi.str = xml;
    pi.s = xml;
    pi.pcb = pcb;
    pi.obj = Qnil;
    pi.circ_array = 0;
    pi.options = options;
    while (1) {
	next_non_white(&pi);	/* skip white space */
	if ('\0' == *pi.s) {
	    break;
	}
	if (body_read && 0 != endp) {
	    *endp = pi.s;
	    break;
	}
	if ('<' != *pi.s) {		/* all top level entities start with < */
	    set_error(err, "invalid format, expected <", pi.str, pi.s);
	    helper_stack_cleanup(&pi.helpers);
	    return Qnil;
	}
	pi.s++;		/* past < */
	switch (*pi.s) {
	case '?':	/* processing instruction */
	    pi.s++;
	    read_instruction(&pi);
	    break;
	case '!':	/* comment or doctype */
	    pi.s++;
	    if ('\0' == *pi.s) {
		set_error(err, "invalid format, DOCTYPE or comment not terminated", pi.str, pi.s);
		helper_stack_cleanup(&pi.helpers);
		return Qnil;
	    } else if ('-' == *pi.s) {
		pi.s++;	/* skip - */
		if ('-' != *pi.s) {
		    set_error(err, "invalid format, bad comment format", pi.str, pi.s);
		    helper_stack_cleanup(&pi.helpers);
		    return Qnil;
		} else {
		    pi.s++;	/* skip second - */
		    read_comment(&pi);
		}
	    } else if ((TolerantEffort == options->effort) ? 0 == strncasecmp("DOCTYPE", pi.s, 7) : 0 == strncmp("DOCTYPE", pi.s, 7)) {
		pi.s += 7;
		read_doctype(&pi);
	    } else {
		set_error(err, "invalid format, DOCTYPE or comment expected", pi.str, pi.s);
		helper_stack_cleanup(&pi.helpers);
		return Qnil;
	    }
	    break;
	case '\0':
	    set_error(err, "invalid format, document not terminated", pi.str, pi.s);
	    helper_stack_cleanup(&pi.helpers);
	    return Qnil;
	default:
	    read_element(&pi);
	    body_read = 1;
	    break;
	}
	if (err_has(&pi.err)) {
	    *err = pi.err;
	    helper_stack_cleanup(&pi.helpers);
	    return Qnil;
	}
	if (block_given && Qnil != pi.obj && Qundef != pi.obj) {
	    if (NULL != pcb->finish) {
		pcb->finish(&pi);
	    }
	    rb_yield(pi.obj);
	}
    }
    DATA_PTR(wrap) = NULL;
    helper_stack_cleanup(&pi.helpers);
    if (NULL != pcb->finish) {
	pcb->finish(&pi);
    }
    return pi.obj;
}

static char*
gather_content(const char *src, char *content, size_t len) {
    for (; 0 < len; src++, content++, len--) {
	switch (*src) {
	case '?':
	    if ('>' == *(src + 1)) {
		*content = '\0';
		return (char*)(src + 1);
	    }
	    *content = *src;
	    break;
	case '\0':
	    return 0;
	default:
	    *content = *src;
	    break;
	}
    }
    return 0;
}

/* Entered after the "<?" sequence. Ready to read the rest.
 */
static void
read_instruction(PInfo pi) {
    char		content[1024];
    struct _AttrStack	attrs;
    char		*attr_name;
    char		*attr_value;
    char		*target;
    char		*end;
    char		c;
    char		*cend;
    int			attrs_ok = 1;

    *content = '\0';
    attr_stack_init(&attrs);
    if (0 == (target = read_name_token(pi))) {
	return;
    }
    end = pi->s;
    if (0 == (cend = gather_content(pi->s, content, sizeof(content) - 1))) {
	set_error(&pi->err, "processing instruction content too large or not terminated", pi->str, pi->s);
	return;
    }
    next_non_white(pi);
    c = *pi->s;
    *end = '\0'; /* terminate name */
    if ('?' != c) {
	while ('?' != c) {
	    pi->last = 0;
	    if ('\0' == *pi->s) {
		attr_stack_cleanup(&attrs);
		set_error(&pi->err, "invalid format, processing instruction not terminated", pi->str, pi->s);
		return;
	    }
	    next_non_white(pi);
	    if (0 == (attr_name = read_name_token(pi))) {
		attr_stack_cleanup(&attrs);
		return;
	    }
	    end = pi->s;
	    next_non_white(pi);
	    if ('=' != *pi->s++) {
		attrs_ok = 0;
		break;
	    }
	    *end = '\0'; /* terminate name */
	    /* read value */
	    next_non_white(pi);
	    if (0 == (attr_value = read_quoted_value(pi))) {
		attr_stack_cleanup(&attrs);
		return;
	    }
	    attr_stack_push(&attrs, attr_name, attr_value);
	    next_non_white(pi);
	    if ('\0' == pi->last) {
		c = *pi->s;
	    } else {
		c = pi->last;
	    }
	}
	if ('?' == *pi->s) {
	    pi->s++;
	}
    } else {
	pi->s++;
    }
    if (attrs_ok) {
	if ('>' != *pi->s++) {
	    attr_stack_cleanup(&attrs);
	    set_error(&pi->err, "invalid format, processing instruction not terminated", pi->str, pi->s);
	    return;
	}
    } else {
	pi->s = cend + 1;
    }
    if (0 != pi->pcb->instruct) {
	if (attrs_ok) {
	    pi->pcb->instruct(pi, target, attrs.head, 0);
	} else {
	    pi->pcb->instruct(pi, target, attrs.head, content);
	}
    }
    attr_stack_cleanup(&attrs);
}

static void
read_delimited(PInfo pi, char end) {
    char	c;

    if ('"' == end || '\'' == end) {
	for (c = *pi->s++; end != c; c = *pi->s++) {
	    if ('\0' == c) {
		set_error(&pi->err, "invalid format, dectype not terminated", pi->str, pi->s);
		return;
	    }
	}
    } else {
	while (1) {
	    c = *pi->s++;
	    if (end == c) {
		return;
	    }
	    switch (c) {
	    case '\0':
		set_error(&pi->err, "invalid format, dectype not terminated", pi->str, pi->s);
		return;
	    case '"':
		read_delimited(pi, c);
		break;
	    case '\'':
		read_delimited(pi, c);
		break;
	    case '[':
		read_delimited(pi, ']');
		break;
	    case '<':
		read_delimited(pi, '>');
		break;
	    default:
		break;
	    }
	}
    }
}

/* Entered after the "<!DOCTYPE" sequence plus the first character after
 * that. Ready to read the rest.
 */
static void
read_doctype(PInfo pi) {
    char	*docType;

    next_non_white(pi);
    docType = pi->s;
    read_delimited(pi, '>');
    if (err_has(&pi->err)) {
	return;
    }
    pi->s--;
    *pi->s = '\0';
    pi->s++;
    if (0 != pi->pcb->add_doctype) {
	pi->pcb->add_doctype(pi, docType);
    }
}

/* Entered after "<!--". Returns error code.
 */
static void
read_comment(PInfo pi) {
    char	*end;
    char	*s;
    char	*comment;
    int		done = 0;
    
    next_non_white(pi);
    comment = pi->s;
    end = strstr(pi->s, "-->");
    if (0 == end) {
	set_error(&pi->err, "invalid format, comment not terminated", pi->str, pi->s);
	return;
    }
    for (s = end - 1; pi->s < s && !done; s--) {
	switch(*s) {
	case ' ':
	case '\t':
	case '\f':
	case '\n':
	case '\r':
	    break;
	default:
	    *(s + 1) = '\0';
	    done = 1;
	    break;
	}
    }
    *end = '\0'; /* in case the comment was blank */
    pi->s = end + 3;
    if (0 != pi->pcb->add_comment) {
	pi->pcb->add_comment(pi, comment);
    }
}

/* Entered after the '<' and the first character after that. Returns status
 * code.
 */
static char*
read_element(PInfo pi) {
    struct _AttrStack	attrs;
    const char		*attr_name;
    const char		*attr_value;
    char		*name;
    char		*ename;
    char		*end;
    char		c;
    long		elen;
    int			hasChildren = 0;
    int			done = 0;

    attr_stack_init(&attrs);
    if (0 == (ename = read_name_token(pi))) {
	return 0;
    }
    end = pi->s;
    elen = end - ename;
    next_non_white(pi);
    c = *pi->s;
    *end = '\0';
    if ('/' == c) {
	/* empty element, no attributes and no children */
	pi->s++;
	if ('>' != *pi->s) {
	    /*printf("*** '%s' ***\n", pi->s); */
	    attr_stack_cleanup(&attrs);
	    set_error(&pi->err, "invalid format, element not closed", pi->str, pi->s);
	    return 0;
	}
	pi->s++;	/* past > */
	pi->pcb->add_element(pi, ename, attrs.head, hasChildren);
	pi->pcb->end_element(pi, ename);

	attr_stack_cleanup(&attrs);
	return 0;
    }
    /* read attribute names until the close (/ or >) is reached */
    while (!done) {
	if ('\0' == c) {
	    next_non_white(pi);
	    c = *pi->s;
	}
	pi->last = 0;
	switch (c) {
	case '\0':
	    attr_stack_cleanup(&attrs);
	    set_error(&pi->err, "invalid format, document not terminated", pi->str, pi->s);
	    return 0;
	case '/':
	    /* Element with just attributes. */
	    pi->s++;
	    if ('>' != *pi->s) {
		attr_stack_cleanup(&attrs);
		set_error(&pi->err, "invalid format, element not closed", pi->str, pi->s);
		return 0;
	    }
	    pi->s++;
	    pi->pcb->add_element(pi, ename, attrs.head, hasChildren);
	    pi->pcb->end_element(pi, ename);

	    attr_stack_cleanup(&attrs);
	    return 0;
	case '>':
	    /* has either children or a value */
	    pi->s++;
	    hasChildren = 1;
	    done = 1;
	    pi->pcb->add_element(pi, ename, attrs.head, hasChildren);
	    break;
	default:
	    /* Attribute name so it's an element and the attribute will be */
	    /* added to it. */
	    if (0 == (attr_name = read_name_token(pi))) {
		attr_stack_cleanup(&attrs);
		return 0;
	    }
	    end = pi->s;
	    next_non_white(pi);
	    if ('=' != *pi->s++) {
		if (TolerantEffort == pi->options->effort) {
		    pi->s--;
		    pi->last = *pi->s;
		    *end = '\0'; /* terminate name */
		    attr_value = "";
		    attr_stack_push(&attrs, attr_name, attr_value);
		    break;
		} else {
		    attr_stack_cleanup(&attrs);
		    set_error(&pi->err, "invalid format, no attribute value", pi->str, pi->s);
		    return 0;
		}
	    }
	    *end = '\0'; /* terminate name */
	    /* read value */
	    next_non_white(pi);
	    if (0 == (attr_value = read_quoted_value(pi))) {
		return 0;
	    }
	    if (pi->options->convert_special && 0 != strchr(attr_value, '&')) {
		if (0 != collapse_special(pi, (char*)attr_value) || err_has(&pi->err)) {
		    attr_stack_cleanup(&attrs);
		    return 0;
		}
	    }
	    attr_stack_push(&attrs, attr_name, attr_value);
	    break;
	}
	if ('\0' == pi->last) {
	    c = '\0';
	} else {
	    c = pi->last;
	    pi->last = '\0';
	}
    }
    if (hasChildren) {
	char	*start;
	int	first = 1;
	
	done = 0;
	/* read children */
	while (!done) {
	    start = pi->s;
	    next_non_white(pi);
	    c = *pi->s++;
	    if ('\0' == c) {
		attr_stack_cleanup(&attrs);
		set_error(&pi->err, "invalid format, document not terminated", pi->str, pi->s);
		return 0;
	    }
	    if ('<' == c) {
		char	*slash;

		switch (*pi->s) {
		case '!':	/* better be a comment or CDATA */
		    pi->s++;
		    if ('-' == *pi->s && '-' == *(pi->s + 1)) {
			pi->s += 2;
			read_comment(pi);
		    } else if ((TolerantEffort == pi->options->effort) ?
			       0 == strncasecmp("[CDATA[", pi->s, 7) :
			       0 == strncmp("[CDATA[", pi->s, 7)) {
			pi->s += 7;
			read_cdata(pi);
		    } else {
			attr_stack_cleanup(&attrs);
			set_error(&pi->err, "invalid format, invalid comment or CDATA format", pi->str, pi->s);
			return 0;
		    }
		    break;
		case '?':	/* processing instruction */
		    pi->s++;
		    read_instruction(pi);
		    break;
		case '/':
		    slash = pi->s;
		    pi->s++;
		    if (0 == (name = read_name_token(pi))) {
			attr_stack_cleanup(&attrs);
			return 0;
		    }
		    end = pi->s;
		    next_non_white(pi);
		    c = *pi->s;
		    *end = '\0';
		    if (0 != ((TolerantEffort == pi->options->effort) ? strcasecmp(name, ename) : strcmp(name, ename))) {
			attr_stack_cleanup(&attrs);
			if (TolerantEffort == pi->options->effort) {
			    pi->pcb->end_element(pi, ename);
			    return name;
			} else {
			    set_error(&pi->err, "invalid format, elements overlap", pi->str, pi->s);
			    return 0;
			}
		    }
		    if ('>' != c) {
			attr_stack_cleanup(&attrs);
			set_error(&pi->err, "invalid format, element not closed", pi->str, pi->s);
			return 0;
		    }
		    if (first && start != slash - 1) {
			// Some white space between start and here so add as
			// text after checking skip.
			*(slash - 1) = '\0';
			switch (pi->options->skip) {
			case CrSkip: {
			    char	*s = start;
			    char	*e = start;
			
			    for (; '\0' != *e; e++) {
				if ('\r' != *e) {
				    *s++ = *e;
				}
			    }
			    *s = '\0';
			    break;
			}
			case SpcSkip:
			    *start = '\0';
			    break;
			case NoSkip:
			case OffSkip:
			default:
			    break;
			}
			if ('\0' != *start) {
			    pi->pcb->add_text(pi, start, 1);
			}
		    }
		    pi->s++;
		    pi->pcb->end_element(pi, ename);
		    attr_stack_cleanup(&attrs);
		    return 0;
		case '\0':
		    attr_stack_cleanup(&attrs);
		    if (TolerantEffort == pi->options->effort) {
			return 0;
		    } else {
			set_error(&pi->err, "invalid format, document not terminated", pi->str, pi->s);
			return 0;
		    }
		default:
		    first = 0;
		    /* a child element */
		    // Child closed with mismatched name.
		    if (0 != (name = read_element(pi))) {
			attr_stack_cleanup(&attrs);

			if (0 == ((TolerantEffort == pi->options->effort) ? strcasecmp(name, ename) : strcmp(name, ename))) {
			    pi->s++;
			    pi->pcb->end_element(pi, ename);
			    return 0;
			} else { // not the correct element yet
			    pi->pcb->end_element(pi, ename);
			    return name;
			}
		    } else if (err_has(&pi->err)) {
			return 0;
		    }
		    break;
		}
	    } else {	/* read as TEXT */
		pi->s = start;
		/*pi->s--; */
		read_text(pi);
		/*read_reduced_text(pi); */

		/* to exit read_text with no errors the next character must be < */
		if ('/' == *(pi->s + 1) &&
		    0 == ((TolerantEffort == pi->options->effort) ? strncasecmp(ename, pi->s + 2, elen) : strncmp(ename, pi->s + 2, elen)) &&
		    '>' == *(pi->s + elen + 2)) {

		    /* close tag after text so treat as a value */
		    pi->s += elen + 3;
		    pi->pcb->end_element(pi, ename);
		    attr_stack_cleanup(&attrs);
		    return 0;
		}
	    }
	}
    }
    attr_stack_cleanup(&attrs);
    return 0;
}

static void
read_text(PInfo pi) {
    char	buf[MAX_TEXT_LEN];
    char	*b = buf;
    char	*alloc_buf = 0;
    char	*end = b + sizeof(buf) - 2;
    char	c;
    int		done = 0;

    while (!done) {
	c = *pi->s++;
	switch(c) {
	case '<':
	    done = 1;
	    pi->s--;
	    break;
	case '\0':
	    set_error(&pi->err, "invalid format, document not terminated", pi->str, pi->s);
	    return;
	default:
	    if (end <= (b + (('&' == c) ? 7 : 0))) { /* extra 8 for special just in case it is sequence of bytes */
		unsigned long	size;
		
		if (0 == alloc_buf) {
		    size = sizeof(buf) * 2;
		    alloc_buf = ALLOC_N(char, size);
		    memcpy(alloc_buf, buf, b - buf);
		    b = alloc_buf + (b - buf);
		} else {
		    unsigned long	pos = b - alloc_buf;

		    size = (end - alloc_buf) * 2;
		    REALLOC_N(alloc_buf, char, size);
		    b = alloc_buf + pos;
		}
		end = alloc_buf + size - 2;
	    }
	    if ('&' == c) {
		if (0 == (b = read_coded_chars(pi, b))) {
		    return;
		}
	    } else {
		if (0 <= c && c <= 0x20) {
		    if (StrictEffort == pi->options->effort && 'x' == xml_valid_lower_chars[(unsigned char)c]) {
			set_error(&pi->err, "invalid character", pi->str, pi->s);
			return;
		    }
		    switch (pi->options->skip) {
		    case CrSkip:
			if (buf != b && '\n' == c && '\r' == *(b - 1)) {
			    *(b - 1) = '\n';
			} else {
			    *b++ = c;
			}
			break;
		    case SpcSkip:
			if (is_white(c)) {
			    if (buf == b || ' ' != *(b - 1)) {
				*b++ = ' ';
			    }
			} else {
			    *b++ = c;
			}			
			break;
		    case NoSkip:
		    case OffSkip:
		    default:
			*b++ = c;
			break;
		    }
		} else {
		    *b++ = c;
		}
	    }
	    break;
	}
    }
    *b = '\0';
    if (0 != alloc_buf) {
	pi->pcb->add_text(pi, alloc_buf, ('/' == *(pi->s + 1)));
	xfree(alloc_buf);
    } else {
	pi->pcb->add_text(pi, buf, ('/' == *(pi->s + 1)));
    }
}

#if 0
static void
read_reduced_text(PInfo pi) {
    char	buf[MAX_TEXT_LEN];
    char	*b = buf;
    char	*alloc_buf = 0;
    char	*end = b + sizeof(buf) - 2;
    char	c;
    int		spc = 0;
    int		done = 0;

    while (!done) {
	c = *pi->s++;
	switch(c) {
	case ' ':
	case '\t':
	case '\f':
	case '\n':
	case '\r':
	    spc = 1;
	    break;
	case '<':
	    done = 1;
	    pi->s--;
	    break;
	case '\0':
	    set_error(&pi->err, "invalid format, document not terminated", pi->str, pi->s);
	    return;
	default:
	    if (end <= (b + spc + (('&' == c) ? 7 : 0))) { /* extra 8 for special just in case it is sequence of bytes */
		unsigned long	size;
		
		if (0 == alloc_buf) {
		    size = sizeof(buf) * 2;
		    alloc_buf = ALLOC_N(char, size);
		    memcpy(alloc_buf, buf, b - buf);
		    b = alloc_buf + (b - buf);
		} else {
		    unsigned long	pos = b - alloc_buf;

		    size = (end - alloc_buf) * 2;
		    REALLOC(alloc_buf, char, size);
		    b = alloc_buf + pos;
		}
		end = alloc_buf + size - 2;
	    }
	    if (spc) {
		*b++ = ' ';
	    }
	    spc = 0;
	    if ('&' == c) {
		if (0 == (b = read_coded_chars(pi, b))) {
		    return;
		}
	    } else {
		*b++ = c;
	    }
	    break;
	}
    }
    *b = '\0';
    if (0 != alloc_buf) {
	pi->pcb->add_text(pi, alloc_buf, ('/' == *(pi->s + 1)));
	xfree(alloc_buf);
    } else {
	pi->pcb->add_text(pi, buf, ('/' == *(pi->s + 1)));
    }
}
#endif

static char*
read_name_token(PInfo pi) {
    char	*start;

    next_non_white(pi);
    start = pi->s;
    for (; 1; pi->s++) {
	switch (*pi->s) {
	case ' ':
	case '\t':
	case '\f':
	case '?':
	case '=':
	case '/':
	case '>':
	case '\n':
	case '\r':
	    return start;
	case '\0':
	    /* documents never terminate after a name token */
	    set_error(&pi->err, "invalid format, document not terminated", pi->str, pi->s);
	    return 0;
	    break; /* to avoid warnings */
	case ':':
	    if ('\0' == *pi->options->strip_ns) {
		break;
	    } else if ('*' == *pi->options->strip_ns && '\0' == pi->options->strip_ns[1]) {
		start = pi->s + 1;
	    } else if (0 == strncmp(pi->options->strip_ns, start, pi->s - start)) {
		start = pi->s + 1;
	    }
	    break;
	default:
	    break;
	}
    }
    return start;
}

static void
read_cdata(PInfo pi) {
    char	*start;
    char	*end;

    start = pi->s;
    end = strstr(pi->s, "]]>");
    if (end == 0) {
	set_error(&pi->err, "invalid format, CDATA not terminated", pi->str, pi->s);
	return;
    }
    *end = '\0';
    pi->s = end + 3;
    if (0 != pi->pcb->add_cdata) {
	pi->pcb->add_cdata(pi, start, end - start);
    }
}

/* Assume the value starts immediately and goes until the quote character is
 * reached again. Do not read the character after the terminating quote.
 */
static char*
read_quoted_value(PInfo pi) {
    char	*value = 0;
    
    if ('"' == *pi->s || '\'' == *pi->s) {
        char	term = *pi->s;
        
        pi->s++;	/* skip quote character */
        value = pi->s;
        for (; *pi->s != term; pi->s++) {
            if ('\0' == *pi->s) {
                set_error(&pi->err, "invalid format, document not terminated", pi->str, pi->s);
		return 0;
            }
        }
        *pi->s = '\0';	/* terminate value */
        pi->s++;	/* move past quote */
    } else if (StrictEffort == pi->options->effort) {
	set_error(&pi->err, "invalid format, expected a quote character", pi->str, pi->s);
	return 0;
    } else if (TolerantEffort == pi->options->effort) {
        value = pi->s;
        for (; 1; pi->s++) {
	    switch (*pi->s) {
	    case '\0':
                set_error(&pi->err, "invalid format, document not terminated", pi->str, pi->s);
		return 0;
	    case ' ':
	    case '/':
	    case '>':
	    case '?': // for instructions
	    case '\t':
	    case '\n':
	    case '\r':
		pi->last = *pi->s;
		*pi->s = '\0';	/* terminate value */
		pi->s++;
		return value;
	    default:
		break;
            }
        }
    } else {
        value = pi->s;
        next_white(pi);
	if ('\0' == *pi->s) {
	    set_error(&pi->err, "invalid format, document not terminated", pi->str, pi->s);
	    return 0;
        }
        *pi->s++ = '\0'; /* terminate value */
    }
    return value;
}

static char*
read_hex_uint64(char *b, uint64_t *up) {
    uint64_t	u = 0;
    char	c;

    for (; ';' != *b; b++) {
	c = *b;
	if ('0' <= c && c <= '9') {
	    u = (u << 4) | (uint64_t)(c - '0');
	} else if ('a' <= c && c <= 'f') {
	    u = (u << 4) | (uint64_t)(c - 'a' + 10);
	} else if ('A' <= c && c <= 'F') {
	    u = (u << 4) | (uint64_t)(c - 'A' + 10);
	} else {
	    return 0;
	}
    }
    *up = u;

    return b;
}

static char*
read_10_uint64(char *b, uint64_t *up) {
    uint64_t	u = 0;
    char	c;

    for (; ';' != *b; b++) {
	c = *b;
	if ('0' <= c && c <= '9') {
	    u = (u * 10) + (uint64_t)(c - '0');
	} else {
	    return 0;
	}
    }
    *up = u;

    return b;
}

static char*
read_coded_chars(PInfo pi, char *text) {
    char	*b, buf[32];
    char	*end = buf + sizeof(buf) - 1;
    char	*s;

    for (b = buf, s = pi->s; b < end; b++, s++) {
	*b = *s;
	if (';' == *s) {
	    *(b + 1) = '\0';
	    s++;
	    break;
	}
    }
    if (b > end) {
	*text++ = '&';
    } else if ('#' == *buf) {
	uint64_t	u = 0;
	
	b = buf + 1;
	if ('x' == *b || 'X' == *b) {
	    b = read_hex_uint64(b + 1, &u);
	} else {
	    b = read_10_uint64(b, &u);
	}
	if (0 == b) {
	    *text++ = '&';
	} else {
	    if (u <= 0x000000000000007FULL) {
		*text++ = (char)u;
#if HAS_PRIVATE_ENCODING
	    } else if (ox_utf8_encoding == pi->options->rb_enc ||
		       0 == strcasecmp(rb_str_ptr(rb_String(ox_utf8_encoding)), rb_str_ptr(rb_String(pi->options->rb_enc)))) {
#else
	    } else if (ox_utf8_encoding == pi->options->rb_enc) {
#endif
		text = ox_ucs_to_utf8_chars(text, u);
#if HAS_PRIVATE_ENCODING
	    } else if (Qnil == pi->options->rb_enc) {
#else
	    } else if (0 == pi->options->rb_enc) {
#endif
		pi->options->rb_enc = ox_utf8_encoding;
		text = ox_ucs_to_utf8_chars(text, u);
	    } else if (TolerantEffort == pi->options->effort) {
		*text++ = '&';
		return text;
	    } else if (u <= 0x00000000000000FFULL) {
		*text++ = (char)u;
	    } else {
		/*set_error(&pi->err, "Invalid encoding, need UTF-8 or UTF-16 encoding to parse &#nnnn; character sequences.", pi->str, pi->s); */
		set_error(&pi->err, "Invalid encoding, need UTF-8 encoding to parse &#nnnn; character sequences.", pi->str, pi->s);
		return 0;
	    }
	    pi->s = s;
	}
    } else if (0 == strcasecmp(buf, "nbsp;")) {
	pi->s = s;
	*text++ = ' ';
    } else if (0 == strcasecmp(buf, "lt;")) {
	pi->s = s;
	*text++ = '<';
    } else if (0 == strcasecmp(buf, "gt;")) {
	pi->s = s;
	*text++ = '>';
    } else if (0 == strcasecmp(buf, "amp;")) {
	pi->s = s;
	*text++ = '&';
    } else if (0 == strcasecmp(buf, "quot;")) {
	pi->s = s;
	*text++ = '"';
    } else if (0 == strcasecmp(buf, "apos;")) {
	pi->s = s;
	*text++ = '\'';
    } else {
	*text++ = '&';
    }
    return text;
}

static int
collapse_special(PInfo pi, char *str) {
    char	*s = str;
    char	*b = str;

    while ('\0' != *s) {
	if ('&' == *s) {
	    int		c;
	    char	*end;
	    
	    s++;
	    if ('#' == *s) {
		uint64_t	u = 0;
		char		x;

		s++;
		if ('x' == *s || 'X' == *s) {
		    x = *s;
		    s++;
		    end = read_hex_uint64(s, &u);
		} else {
		    x = '\0';
		    end = read_10_uint64(s, &u);
		}
		if (0 == end) {
		    if (TolerantEffort == pi->options->effort) {
			*b++ = '&';
			*b++ = '#';
			if ('\0' != x) {
			    *b++ = x;
			}
			continue;
		    }
		    return EDOM;
		}
		if (u <= 0x000000000000007FULL) {
		    *b++ = (char)u;
#if HAS_PRIVATE_ENCODING
		} else if (ox_utf8_encoding == pi->options->rb_enc ||
			   0 == strcasecmp(rb_str_ptr(rb_String(ox_utf8_encoding)), rb_str_ptr(rb_String(pi->options->rb_enc)))) {
#else
		} else if (ox_utf8_encoding == pi->options->rb_enc) {
#endif
		    b = ox_ucs_to_utf8_chars(b, u);
		    /* TBD support UTF-16 */
#if HAS_PRIVATE_ENCODING
		} else if (Qnil == pi->options->rb_enc) {
#else
		} else if (0 == pi->options->rb_enc) {
#endif
		    pi->options->rb_enc = ox_utf8_encoding;
		    b = ox_ucs_to_utf8_chars(b, u);
		} else {
		    /* set_error(&pi->err, "Invalid encoding, need UTF-8 or UTF-16 encoding to parse &#nnnn; character sequences.", pi->str, pi->s);*/
		    set_error(&pi->err, "Invalid encoding, need UTF-8 encoding to parse &#nnnn; character sequences.", pi->str, pi->s);
		    return 0;
		}
		s = end + 1;
	    } else {
		if (0 == strncasecmp(s, "lt;", 3)) {
		    c = '<';
		    s += 3;
		} else if (0 == strncasecmp(s, "gt;", 3)) {
		    c = '>';
		    s += 3;
		} else if (0 == strncasecmp(s, "amp;", 4)) {
		    c = '&';
		    s += 4;
		} else if (0 == strncasecmp(s, "quot;", 5)) {
		    c = '"';
		    s += 5;
		} else if (0 == strncasecmp(s, "apos;", 5)) {
		    c = '\'';
		    s += 5;
		} else if (TolerantEffort == pi->options->effort) {
		    *b++ = '&';
		    continue;
		} else {
		    c = '?';
		    while (';' != *s++) {
			if ('\0' == *s) {
			    set_error(&pi->err, "Invalid format, special character does not end with a semicolon", pi->str, pi->s);
			    return EDOM;
			}
		    }
		    s++;
		    set_error(&pi->err, "Invalid format, invalid special character sequence", pi->str, pi->s);
		    return 0;
		}
		*b++ = (char)c;
	    }
	} else {
	    *b++ = *s++;
	}
    }
    *b = '\0';

    return 0;
}
