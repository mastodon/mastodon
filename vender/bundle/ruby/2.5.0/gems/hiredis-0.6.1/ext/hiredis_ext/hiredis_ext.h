#ifndef __HIREDIS_EXT_H
#define __HIREDIS_EXT_H

/* Defined for Rubinius. This indicates a char* obtained
 * through RSTRING_PTR is never modified in place. With this
 * define Rubinius can disable the slow copy back mechanisms
 * to make sure strings are updated at the Ruby side.
 */
#define RSTRING_NOT_MODIFIED

#include "hiredis.h"
#include "ruby.h"

/* Defined in hiredis_ext.c */
extern VALUE mod_hiredis;

/* Defined in reader.c */
extern redisReplyObjectFunctions redisExtReplyObjectFunctions;
extern VALUE klass_reader;
extern void InitReader(VALUE module);

/* Defined in connection.c */
extern VALUE klass_connection;
extern VALUE error_eof;
extern void InitConnection(VALUE module);

/* Borrowed from Nokogiri */
#ifndef RSTRING_PTR
#define RSTRING_PTR(s) (RSTRING(s)->ptr)
#endif

#ifndef RSTRING_LEN
#define RSTRING_LEN(s) (RSTRING(s)->len)
#endif

#ifndef RARRAY_PTR
#define RARRAY_PTR(a) RARRAY(a)->ptr
#endif

#ifndef RARRAY_LEN
#define RARRAY_LEN(a) RARRAY(a)->len
#endif

#endif
