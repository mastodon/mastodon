/* trace.h
 * Copyright (c) 2018, Peter Ohler
 * All rights reserved.
 */

#include "parse.h"
#include "trace.h"

#define MAX_INDENT	256

static void
fill_indent(char *indent, int depth) {
    if (MAX_INDENT <= depth) {
	depth = MAX_INDENT - 1;
    } else if (depth < 0) {
	depth = 0;
    }
    memset(indent, ' ', depth);
    indent[depth] = '\0';
}

void
oj_trace(const char *func, VALUE obj, const char *file, int line, int depth, TraceWhere where) {
    char	fmt[64];
    char	indent[MAX_INDENT];

    depth *= 2;
    fill_indent(indent, depth);
    sprintf(fmt, "#0:%%13s:%%3d:Oj:%c:%%%ds %%s %%s\n", where, depth);
    printf(fmt, file, line, indent, func, rb_obj_classname(obj));
}

void
oj_trace_parse_call(const char *func, ParseInfo pi, const char *file, int line, VALUE obj) {
    char	fmt[64];
    char	indent[MAX_INDENT];
    int		depth = stack_size(&pi->stack) * 2;
    
    fill_indent(indent, depth);
    sprintf(fmt, "#0:%%13s:%%3d:Oj:-:%%%ds %%s %%s\n", depth);
    printf(fmt, file, line, indent, func, rb_obj_classname(obj));
}

void
oj_trace_parse_in(const char *func, ParseInfo pi, const char *file, int line) {
    char	fmt[64];
    char	indent[MAX_INDENT];
    int		depth = stack_size(&pi->stack) * 2;
    
    fill_indent(indent, depth);
    sprintf(fmt, "#0:%%13s:%%3d:Oj:}:%%%ds %%s\n", depth);
    printf(fmt, file, line, indent, func);
}

void
oj_trace_parse_hash_end(ParseInfo pi, const char *file, int line) {
    char	fmt[64];
    char	indent[MAX_INDENT];
    int		depth = stack_size(&pi->stack) * 2 - 2;
    Val		v = stack_peek(&pi->stack);
    VALUE	obj = v->val;
    
    fill_indent(indent, depth);
    sprintf(fmt, "#0:%%13s:%%3d:Oj:{:%%%ds hash_end %%s\n", depth);
    printf(fmt, file, line, indent, rb_obj_classname(obj));
}

void
oj_trace_parse_array_end(ParseInfo pi, const char *file, int line) {
    char	fmt[64];
    char	indent[MAX_INDENT];
    int		depth = stack_size(&pi->stack) * 2;
    
    fill_indent(indent, depth);
    sprintf(fmt, "#0:%%13s:%%3d:Oj:{:%%%ds array_ned\n", depth);
    printf(fmt, file, line, indent);
}
