#ifndef __pg_h
#define __pg_h

#ifdef RUBY_EXTCONF_H
#	include RUBY_EXTCONF_H
#endif

/* System headers */
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#if !defined(_WIN32)
#	include <sys/time.h>
#endif
#if defined(HAVE_UNISTD_H) && !defined(_WIN32)
#	include <unistd.h>
#endif /* HAVE_UNISTD_H */

/* Ruby headers */
#include "ruby.h"
#ifdef HAVE_RUBY_ST_H
#	include "ruby/st.h"
#elif HAVE_ST_H
#	include "st.h"
#endif

#if defined(HAVE_RUBY_ENCODING_H) && HAVE_RUBY_ENCODING_H
#	include "ruby/encoding.h"
#	define M17N_SUPPORTED
#	ifdef HAVE_RB_ENCDB_ALIAS
		extern int rb_encdb_alias(const char *, const char *);
#		define ENC_ALIAS(name, orig) rb_encdb_alias((name), (orig))
#	elif HAVE_RB_ENC_ALIAS
		extern int rb_enc_alias(const char *, const char *);
#		define ENC_ALIAS(name, orig) rb_enc_alias((name), (orig))
#	else
		extern int rb_enc_alias(const char *alias, const char *orig); /* declaration missing in Ruby 1.9.1 */
#		define ENC_ALIAS(name, orig) rb_enc_alias((name), (orig))
#	endif


# if !defined(ENCODING_SET_INLINED)
/* Rubinius doesn't define ENCODING_SET_INLINED, so we fall back to the more
 * portable version.
 */
#  define PG_ENCODING_SET_NOCHECK(obj,i) \
	do { \
		rb_enc_set_index((obj), (i)); \
	} while(0)
# else
#  define PG_ENCODING_SET_NOCHECK(obj,i) \
	do { \
		if ((i) < ENCODING_INLINE_MAX) \
			ENCODING_SET_INLINED((obj), (i)); \
		else \
			rb_enc_set_index((obj), (i)); \
	} while(0)
# endif

#else
#	define PG_ENCODING_SET_NOCHECK(obj,i) /* nothing */
#endif

#if RUBY_VM != 1
#	define RUBY_18_COMPAT
#endif

#ifndef RARRAY_LEN
#	define RARRAY_LEN(x) RARRAY((x))->len
#endif /* RARRAY_LEN */

#ifndef RSTRING_LEN
#	define RSTRING_LEN(x) RSTRING((x))->len
#endif /* RSTRING_LEN */

#ifndef RSTRING_PTR
#	define RSTRING_PTR(x) RSTRING((x))->ptr
#endif /* RSTRING_PTR */

#ifndef StringValuePtr
#	define StringValuePtr(x) STR2CSTR(x)
#endif /* StringValuePtr */

#ifdef RUBY_18_COMPAT
#	define rb_io_stdio_file GetWriteFile
#	include "rubyio.h"
#else
#	include "ruby/io.h"
#endif

#ifdef RUBINIUS
	/* Workaround for wrong FIXNUM_MAX definition */
	typedef intptr_t native_int;
#endif

#ifndef RETURN_SIZED_ENUMERATOR
	#define RETURN_SIZED_ENUMERATOR(obj, argc, argv, size_fn) RETURN_ENUMERATOR((obj), (argc), (argv))
#endif

#ifndef HAVE_RB_HASH_DUP
	/* Rubinius doesn't define rb_hash_dup() */
	#define rb_hash_dup(tuple) rb_funcall((tuple), rb_intern("dup"), 0)
#endif

#ifndef timeradd
#define timeradd(a, b, result) \
	do { \
		(result)->tv_sec = (a)->tv_sec + (b)->tv_sec; \
		(result)->tv_usec = (a)->tv_usec + (b)->tv_usec; \
		if ((result)->tv_usec >= 1000000L) { \
			++(result)->tv_sec; \
			(result)->tv_usec -= 1000000L; \
		} \
	} while (0)
#endif

#ifndef timersub
#define timersub(a, b, result) \
	do { \
		(result)->tv_sec = (a)->tv_sec - (b)->tv_sec; \
		(result)->tv_usec = (a)->tv_usec - (b)->tv_usec; \
		if ((result)->tv_usec < 0) { \
			--(result)->tv_sec; \
			(result)->tv_usec += 1000000L; \
		} \
	} while (0)
#endif

/* PostgreSQL headers */
#include "libpq-fe.h"
#include "libpq/libpq-fs.h"              /* large-object interface */
#include "pg_config_manual.h"

#if defined(_WIN32)
#	include <fcntl.h>
typedef long suseconds_t;
#endif

#if defined(HAVE_VARIABLE_LENGTH_ARRAYS)
	#define PG_VARIABLE_LENGTH_ARRAY(type, name, len, maxlen) type name[(len)];
#else
	#define PG_VARIABLE_LENGTH_ARRAY(type, name, len, maxlen) \
		type name[(maxlen)] = {(len)>(maxlen) ? (rb_raise(rb_eArgError, "Number of " #name " (%d) exceeds allowed maximum of " #maxlen, (len) ), (type)1) : (type)0};

	#define PG_MAX_COLUMNS 4000
#endif

/* The data behind each PG::Connection object */
typedef struct {
	PGconn *pgconn;

	/* Cached IO object for the socket descriptor */
	VALUE socket_io;
	/* Proc object that receives notices as PG::Result objects */
	VALUE notice_receiver;
	/* Proc object that receives notices as String objects */
	VALUE notice_processor;
	/* Kind of PG::TypeMap object for casting query params */
	VALUE type_map_for_queries;
	/* Kind of PG::TypeMap object for casting result values */
	VALUE type_map_for_results;
	/* IO object internally used for the trace stream */
	VALUE trace_stream;
	/* Cached Encoding object */
	VALUE external_encoding;
	/* Kind of PG::Coder object for casting ruby values to COPY rows */
	VALUE encoder_for_put_copy_data;
	/* Kind of PG::Coder object for casting COPY rows to ruby values */
	VALUE decoder_for_get_copy_data;

} t_pg_connection;

typedef struct pg_coder t_pg_coder;
typedef struct pg_typemap t_typemap;

/* The data behind each PG::Result object */
typedef struct {
	PGresult *pgresult;

	/* The connection object used to build this result */
	VALUE connection;

	/* The TypeMap used to type cast result values */
	VALUE typemap;

	/* Pointer to the typemap object data. This is assumed to be
	 * always valid.
	 */
	t_typemap *p_typemap;

	/* 0 = PGresult is cleared by PG::Result#clear or by the GC
	 * 1 = PGresult is cleared internally by libpq
	 */
	int autoclear;

	/* Number of fields in fnames[] .
	 * Set to -1 if fnames[] is not yet initialized.
	 */
	int nfields;

	/* Prefilled tuple Hash with fnames[] as keys. */
	VALUE tuple_hash;

	/* List of field names as frozen String objects.
	 * Only valid if nfields != -1
	 */
	VALUE fnames[0];
} t_pg_result;


typedef int (* t_pg_coder_enc_func)(t_pg_coder *, VALUE, char *, VALUE *, int);
typedef VALUE (* t_pg_coder_dec_func)(t_pg_coder *, char *, int, int, int, int);
typedef VALUE (* t_pg_fit_to_result)(VALUE, VALUE);
typedef VALUE (* t_pg_fit_to_query)(VALUE, VALUE);
typedef int (* t_pg_fit_to_copy_get)(VALUE);
typedef VALUE (* t_pg_typecast_result)(t_typemap *, VALUE, int, int);
typedef t_pg_coder *(* t_pg_typecast_query_param)(t_typemap *, VALUE, int);
typedef VALUE (* t_pg_typecast_copy_get)( t_typemap *, VALUE, int, int, int );

struct pg_coder {
	t_pg_coder_enc_func enc_func;
	t_pg_coder_dec_func dec_func;
	VALUE coder_obj;
	Oid oid;
	int format;
};

typedef struct {
	t_pg_coder comp;
	t_pg_coder *elem;
	int needs_quotation;
	char delimiter;
} t_pg_composite_coder;

struct pg_typemap {
	struct pg_typemap_funcs {
		t_pg_fit_to_result fit_to_result;
		t_pg_fit_to_query fit_to_query;
		t_pg_fit_to_copy_get fit_to_copy_get;
		t_pg_typecast_result typecast_result_value;
		t_pg_typecast_query_param typecast_query_param;
		t_pg_typecast_copy_get typecast_copy_get;
	} funcs;
	VALUE default_typemap;
};

typedef struct {
	t_typemap typemap;
	int nfields;
	struct pg_tmbc_converter {
		t_pg_coder *cconv;
	} convs[0];
} t_tmbc;


#include "gvl_wrappers.h"

/***************************************************************************
 * Globals
 **************************************************************************/

extern VALUE rb_mPG;
extern VALUE rb_ePGerror;
extern VALUE rb_eServerError;
extern VALUE rb_eUnableToSend;
extern VALUE rb_eConnectionBad;
extern VALUE rb_eInvalidResultStatus;
extern VALUE rb_eNoResultError;
extern VALUE rb_eInvalidChangeOfResultFields;
extern VALUE rb_mPGconstants;
extern VALUE rb_cPGconn;
extern VALUE rb_cPGresult;
extern VALUE rb_hErrors;
extern VALUE rb_cTypeMap;
extern VALUE rb_cTypeMapAllStrings;
extern VALUE rb_mDefaultTypeMappable;
extern VALUE rb_cPG_Coder;
extern VALUE rb_cPG_SimpleEncoder;
extern VALUE rb_cPG_SimpleDecoder;
extern VALUE rb_cPG_CompositeEncoder;
extern VALUE rb_cPG_CompositeDecoder;
extern VALUE rb_cPG_CopyCoder;
extern VALUE rb_cPG_CopyEncoder;
extern VALUE rb_cPG_CopyDecoder;
extern VALUE rb_mPG_TextEncoder;
extern VALUE rb_mPG_TextDecoder;
extern VALUE rb_mPG_BinaryEncoder;
extern VALUE rb_mPG_BinaryDecoder;
extern VALUE rb_mPG_BinaryFormatting;
extern const struct pg_typemap_funcs pg_tmbc_funcs;
extern const struct pg_typemap_funcs pg_typemap_funcs;

extern VALUE pg_typemap_all_strings;

/***************************************************************************
 * MACROS
 **************************************************************************/

#define UNUSED(x) ((void)(x))
#define SINGLETON_ALIAS(klass,new,old) rb_define_alias(rb_singleton_class((klass)),(new),(old))


/***************************************************************************
 * PROTOTYPES
 **************************************************************************/
void Init_pg_ext                                       _(( void ));

void init_pg_connection                                _(( void ));
void init_pg_result                                    _(( void ));
void init_pg_errors                                    _(( void ));
void init_pg_type_map                                  _(( void ));
void init_pg_type_map_all_strings                      _(( void ));
void init_pg_type_map_by_class                         _(( void ));
void init_pg_type_map_by_column                        _(( void ));
void init_pg_type_map_by_mri_type                      _(( void ));
void init_pg_type_map_by_oid                           _(( void ));
void init_pg_type_map_in_ruby                          _(( void ));
void init_pg_coder                                     _(( void ));
void init_pg_copycoder                                 _(( void ));
void init_pg_text_encoder                              _(( void ));
void init_pg_text_decoder                              _(( void ));
void init_pg_binary_encoder                            _(( void ));
void init_pg_binary_decoder                            _(( void ));
VALUE lookup_error_class                               _(( const char * ));
VALUE pg_bin_dec_bytea                                 _(( t_pg_coder*, char *, int, int, int, int ));
VALUE pg_text_dec_string                               _(( t_pg_coder*, char *, int, int, int, int ));
int pg_coder_enc_to_s                                  _(( t_pg_coder*, VALUE, char *, VALUE *, int));
int pg_text_enc_identifier                             _(( t_pg_coder*, VALUE, char *, VALUE *, int));
t_pg_coder_enc_func pg_coder_enc_func                  _(( t_pg_coder* ));
t_pg_coder_dec_func pg_coder_dec_func                  _(( t_pg_coder*, int ));
void pg_define_coder                                   _(( const char *, void *, VALUE, VALUE ));
VALUE pg_obj_to_i                                      _(( VALUE ));
VALUE pg_tmbc_allocate                                 _(( void ));
void pg_coder_init_encoder                             _(( VALUE ));
void pg_coder_init_decoder                             _(( VALUE ));
char *pg_rb_str_ensure_capa                            _(( VALUE, long, char *, char ** ));

#define PG_RB_STR_ENSURE_CAPA( str, expand_len, curr_ptr, end_ptr ) \
	do { \
		if( (curr_ptr) + (expand_len) >= (end_ptr) ) \
			(curr_ptr) = pg_rb_str_ensure_capa( (str), (expand_len), (curr_ptr), &(end_ptr) ); \
	} while(0);

#define PG_RB_STR_NEW( str, curr_ptr, end_ptr ) ( \
		(str) = rb_str_new( NULL, 0 ), \
		(curr_ptr) = (end_ptr) = RSTRING_PTR(str) \
	)

#define PG_RB_TAINTED_STR_NEW( str, curr_ptr, end_ptr ) ( \
		(str) = rb_tainted_str_new( NULL, 0 ), \
		(curr_ptr) = (end_ptr) = RSTRING_PTR(str) \
	)

VALUE pg_typemap_fit_to_result                         _(( VALUE, VALUE ));
VALUE pg_typemap_fit_to_query                          _(( VALUE, VALUE ));
int pg_typemap_fit_to_copy_get                         _(( VALUE ));
VALUE pg_typemap_result_value                          _(( t_typemap *, VALUE, int, int ));
t_pg_coder *pg_typemap_typecast_query_param            _(( t_typemap *, VALUE, int ));
VALUE pg_typemap_typecast_copy_get                     _(( t_typemap *, VALUE, int, int, int ));

PGconn *pg_get_pgconn                                  _(( VALUE ));
t_pg_connection *pg_get_connection                     _(( VALUE ));

VALUE pg_new_result                                    _(( PGresult *, VALUE ));
VALUE pg_new_result_autoclear                          _(( PGresult *, VALUE ));
PGresult* pgresult_get                                 _(( VALUE ));
VALUE pg_result_check                                  _(( VALUE ));
VALUE pg_result_clear                                  _(( VALUE ));

/*
 * Fetch the data pointer for the result object
 */
static inline t_pg_result *
pgresult_get_this( VALUE self )
{
	t_pg_result *this = DATA_PTR(self);

	if( this == NULL )
		rb_raise(rb_ePGerror, "result has been cleared");

	return this;
}


#ifdef M17N_SUPPORTED
rb_encoding * pg_get_pg_encoding_as_rb_encoding        _(( int ));
rb_encoding * pg_get_pg_encname_as_rb_encoding         _(( const char * ));
const char * pg_get_rb_encoding_as_pg_encoding         _(( rb_encoding * ));
rb_encoding *pg_conn_enc_get                           _(( PGconn * ));
#endif /* M17N_SUPPORTED */

void notice_receiver_proxy(void *arg, const PGresult *result);
void notice_processor_proxy(void *arg, const char *message);

#endif /* end __pg_h */
