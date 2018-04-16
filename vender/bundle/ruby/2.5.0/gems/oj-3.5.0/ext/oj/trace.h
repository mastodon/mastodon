/* trace.h
 * Copyright (c) 2018, Peter Ohler
 * All rights reserved.
 */

#ifndef __OJ_TRACE_H__
#define __OJ_TRACE_H__

#include <stdbool.h>
#include <ruby.h>

typedef enum {
    TraceIn	= '{',
    TraceOut	= '}',
    TraceCall	= '-',
} TraceWhere;

struct _ParseInfo;

extern void	oj_trace(const char *func, VALUE obj, const char *file, int line, int depth, TraceWhere where);
extern void	oj_trace_parse_in(const char *func, struct _ParseInfo *pi, const char *file, int line);
extern void	oj_trace_parse_call(const char *func, struct _ParseInfo *pi, const char *file, int line, VALUE obj);
extern void	oj_trace_parse_hash_end(struct _ParseInfo *pi, const char *file, int line);
extern void	oj_trace_parse_array_end(struct _ParseInfo *pi, const char *file, int line);

#endif /* __OJ_TRACE_H__ */
