/* oj.h
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#ifndef __OJ_H__
#define __OJ_H__

#if defined(__cplusplus)
extern "C" {
#if 0
} /* satisfy cc-mode */
#endif
#endif

#define RSTRING_NOT_MODIFIED

#include "ruby.h"
#if HAS_ENCODING_SUPPORT
#include "ruby/encoding.h"
#endif

#include <stdint.h>
#include <stdbool.h>

#if USE_PTHREAD_MUTEX
#include <pthread.h>
#endif
#include "cache8.h"

#ifdef RUBINIUS_RUBY
#undef T_RATIONAL
#undef T_COMPLEX
enum st_retval {ST_CONTINUE = 0, ST_STOP = 1, ST_DELETE = 2, ST_CHECK};
#else
#if HAS_TOP_LEVEL_ST_H
// Only on travis, local is where it is for all others. Seems to vary depending on the travis machine picked up.
#include "st.h"
#else
#include "ruby/st.h"
#endif
#endif

#include "rxclass.h"
#include "err.h"

#define INF_VAL		"3.0e14159265358979323846"
#define NINF_VAL	"-3.0e14159265358979323846"
#define NAN_VAL		"3.3e14159265358979323846"

typedef enum {
    Yes	   = 'y',
    No	   = 'n',
    NotSet = 0
} YesNo;

typedef enum {
    StrictMode	= 's',
    ObjectMode	= 'o',
    NullMode	= 'n',
    CompatMode	= 'c',
    RailsMode	= 'r',
    CustomMode	= 'C',
    WabMode	= 'w',
} Mode;

typedef enum {
    UnixTime	= 'u',
    UnixZTime	= 'z',
    XmlTime	= 'x',
    RubyTime	= 'r'
} TimeFormat;

typedef enum {
    NLEsc	= 'n',
    JSONEsc	= 'j',
    XSSEsc	= 'x',
    ASCIIEsc	= 'a',
    JXEsc	= 'r', // json
    RailsEsc	= 'R', // rails non escape
} Encoding;

typedef enum {
    BigDec	= 'b',
    FloatDec	= 'f',
    AutoDec	= 'a'
} BigLoad;

typedef enum {
    ArrayNew	= 'A',
    ArrayType	= 'a',
    ObjectNew	= 'O',
    ObjectType	= 'o',
} DumpType;

typedef enum {
    AutoNan	= 'a',
    NullNan	= 'n',
    HugeNan	= 'h',
    WordNan	= 'w',
    RaiseNan	= 'r',
} NanDump;

typedef enum {
    STRING_IO	= 'c',
    STREAM_IO	= 's',
    FILE_IO	= 'f',
} StreamWriterType;

typedef enum {
    CALLER_DUMP		= 'd',
    CALLER_TO_JSON	= 't',
    CALLER_GENERATE	= 'g',
    // Add the fast versions if necessary. Maybe unparse as well if needed.
} DumpCaller;

typedef struct _DumpOpts {
    bool	use;
    char	indent_str[16];
    char	before_sep[16];
    char	after_sep[16];
    char	hash_nl[16];
    char	array_nl[16];
    uint8_t	indent_size;
    uint8_t	before_size;
    uint8_t	after_size;
    uint8_t	hash_size;
    uint8_t	array_size;
    char	nan_dump;	// NanDump
    bool	omit_nil;
    int		max_depth;
} *DumpOpts;

typedef struct _Options {
    int			indent;		// indention for dump, default 2
    char		circular;	// YesNo
    char		auto_define;	// YesNo
    char		sym_key;	// YesNo
    char		escape_mode;	// Escape_Mode
    char		mode;		// Mode
    char		class_cache;	// YesNo
    char		time_format;	// TimeFormat
    char		bigdec_as_num;	// YesNo
    char		bigdec_load;	// BigLoad
    char		to_hash;	// YesNo
    char		to_json;	// YesNo
    char		as_json;	// YesNo
    char		nilnil;		// YesNo
    char		empty_string;	// YesNo
    char		allow_gc;	// allow GC during parse
    char		quirks_mode;	// allow single JSON values instead of documents
    char		allow_invalid;	// YesNo - allow invalid unicode
    char		create_ok;	// YesNo allow create_id
    char		allow_nan;	// YEsyNo for parsing only
    char		trace;		// YesNo
    const char		*create_id;	// 0 or string
    size_t		create_id_len;	// length of create_id
    int			sec_prec;	// second precision when dumping time
    char		float_prec;	// float precision, linked to float_fmt
    char		float_fmt[7];	// float format for dumping, if empty use Ruby
    VALUE		hash_class;	// class to use in place of Hash on load
    VALUE		array_class;	// class to use in place of Array on load
    struct _DumpOpts	dump_opts;
    struct _RxClass	str_rx;
    VALUE		*ignore;	// Qnil terminated array of classes or NULL
} *Options;

struct _Out;
typedef void	(*DumpFunc)(VALUE obj, int depth, struct _Out *out, bool as_ok);

// rails optimize
typedef struct _ROpt {
    VALUE	clas;
    bool	on;
    DumpFunc	dump;
} *ROpt;

typedef struct _ROptTable {
    int			len;
    int			alen;
    ROpt		table;
} *ROptTable;

typedef struct _Out {
    char		*buf;
    char		*end;
    char		*cur;
    Cache8		circ_cache;
    slot_t		circ_cnt;
    int			indent;
    int			depth; // used by dump_hash
    Options		opts;
    uint32_t		hash_cnt;
    bool		allocated;
    bool		omit_nil;
    int			argc;
    VALUE		*argv;
    DumpCaller		caller; // used for the mimic json only
    ROptTable		ropts;
} *Out;

typedef struct _StrWriter {
    struct _Out		out;
    struct _Options	opts;
    int			depth;
    char		*types;	// DumpType
    char		*types_end;
    int			keyWritten;
    
} *StrWriter;

typedef struct _StreamWriter {
    struct _StrWriter	sw;
    StreamWriterType	type;
    VALUE		stream;
    int			fd;
    int			flush_limit; // indicator of when to flush
} *StreamWriter;

enum {
    NO_VAL   = 0x00,
    STR_VAL  = 0x01,
    COL_VAL  = 0x02,
    RUBY_VAL = 0x03
};
    
typedef struct _Leaf {
    struct _Leaf	*next;
    union {
	const char	*key;	   // hash key
	size_t		index;	   // array index, 0 is not set
    };
    union {
	char		*str;	   // pointer to location in json string or allocated
	struct _Leaf	*elements; // array and hash elements
	VALUE		value;
    };
    uint8_t		rtype;
    uint8_t		parent_type;
    uint8_t		value_type;
} *Leaf;

extern VALUE	oj_saj_parse(int argc, VALUE *argv, VALUE self);
extern VALUE	oj_sc_parse(int argc, VALUE *argv, VALUE self);

extern VALUE	oj_strict_parse(int argc, VALUE *argv, VALUE self);
extern VALUE	oj_strict_sparse(int argc, VALUE *argv, VALUE self);
extern VALUE	oj_compat_parse(int argc, VALUE *argv, VALUE self);
extern VALUE	oj_compat_load(int argc, VALUE *argv, VALUE self);
extern VALUE	oj_object_parse(int argc, VALUE *argv, VALUE self);
extern VALUE	oj_custom_parse(int argc, VALUE *argv, VALUE self);
extern VALUE	oj_wab_parse(int argc, VALUE *argv, VALUE self);

extern VALUE	oj_strict_parse_cstr(int argc, VALUE *argv, char *json, size_t len);
extern VALUE	oj_compat_parse_cstr(int argc, VALUE *argv, char *json, size_t len);
extern VALUE	oj_object_parse_cstr(int argc, VALUE *argv, char *json, size_t len);
extern VALUE	oj_custom_parse_cstr(int argc, VALUE *argv, char *json, size_t len);

extern void	oj_parse_options(VALUE ropts, Options copts);

extern void	oj_dump_obj_to_json(VALUE obj, Options copts, Out out);
extern void	oj_dump_obj_to_json_using_params(VALUE obj, Options copts, Out out, int argc, VALUE *argv);
extern void	oj_write_obj_to_file(VALUE obj, const char *path, Options copts);
extern void	oj_write_obj_to_stream(VALUE obj, VALUE stream, Options copts);
extern void	oj_dump_leaf_to_json(Leaf leaf, Options copts, Out out);
extern void	oj_write_leaf_to_file(Leaf leaf, const char *path, Options copts);

extern void	oj_str_writer_push_key(StrWriter sw, const char *key);
extern void	oj_str_writer_push_object(StrWriter sw, const char *key);
extern void	oj_str_writer_push_array(StrWriter sw, const char *key);
extern void	oj_str_writer_push_value(StrWriter sw, VALUE val, const char *key);
extern void	oj_str_writer_push_json(StrWriter sw, const char *json, const char *key);
extern void	oj_str_writer_pop(StrWriter sw);
extern void	oj_str_writer_pop_all(StrWriter sw);

extern void	oj_init_doc(void);
extern void	oj_string_writer_init();
extern void	oj_stream_writer_init();
extern void	oj_str_writer_init(StrWriter sw, int buf_size);
extern VALUE	oj_define_mimic_json(int argc, VALUE *argv, VALUE self);
extern VALUE	oj_mimic_generate(int argc, VALUE *argv, VALUE self);
extern VALUE	oj_mimic_pretty_generate(int argc, VALUE *argv, VALUE self);
extern void	oj_parse_mimic_dump_options(VALUE ropts, Options copts);

extern VALUE	oj_mimic_parse(int argc, VALUE *argv, VALUE self);
extern VALUE	oj_get_json_err_class(const char *err_classname);
extern void	oj_parse_opt_match_string(RxClass rc, VALUE ropts);

extern VALUE	oj_rails_encode(int argc, VALUE *argv, VALUE self);

extern VALUE	Oj;
extern struct _Options	oj_default_options;
#if HAS_ENCODING_SUPPORT
extern rb_encoding	*oj_utf8_encoding;
#else
extern VALUE		oj_utf8_encoding;
#endif

extern VALUE	oj_bag_class;
extern VALUE	oj_bigdecimal_class;
extern VALUE	oj_cstack_class;
extern VALUE	oj_date_class;
extern VALUE	oj_datetime_class;
extern VALUE	oj_doc_class;
extern VALUE	oj_enumerable_class;
extern VALUE	oj_json_generator_error_class;
extern VALUE	oj_json_parser_error_class;
extern VALUE	oj_stream_writer_class;
extern VALUE	oj_string_writer_class;
extern VALUE	oj_stringio_class;
extern VALUE	oj_struct_class;

extern VALUE	oj_allow_nan_sym;
extern VALUE	oj_array_class_sym;
extern VALUE	oj_array_nl_sym;
extern VALUE	oj_ascii_only_sym;
extern VALUE	oj_create_additions_sym;
extern VALUE	oj_hash_class_sym;
extern VALUE	oj_indent_sym;
extern VALUE	oj_max_nesting_sym;
extern VALUE	oj_object_class_sym;
extern VALUE	oj_object_nl_sym;
extern VALUE	oj_quirks_mode_sym;
extern VALUE	oj_space_before_sym;
extern VALUE	oj_space_sym;
extern VALUE	oj_trace_sym;

extern VALUE	oj_slash_string;

extern ID	oj_add_value_id;
extern ID	oj_array_append_id;
extern ID	oj_array_end_id;
extern ID	oj_array_start_id;
extern ID	oj_as_json_id;
extern ID	oj_begin_id;
extern ID	oj_bigdecimal_id;
extern ID	oj_end_id;
extern ID	oj_error_id;
extern ID	oj_exclude_end_id;
extern ID	oj_file_id;
extern ID	oj_fileno_id;
extern ID	oj_ftype_id;
extern ID	oj_has_key_id;
extern ID	oj_hash_end_id;
extern ID	oj_hash_key_id;
extern ID	oj_hash_set_id;
extern ID	oj_hash_start_id;
extern ID	oj_iconv_id;
extern ID	oj_instance_variables_id;
extern ID	oj_json_create_id;
extern ID	oj_length_id;
extern ID	oj_new_id;
extern ID	oj_parse_id;
extern ID	oj_pos_id;
extern ID	oj_read_id;
extern ID	oj_readpartial_id;
extern ID	oj_replace_id;
extern ID	oj_stat_id;
extern ID	oj_string_id;
extern ID	oj_to_h_id;
extern ID	oj_to_hash_id;
extern ID	oj_to_json_id;
extern ID	oj_to_s_id;
extern ID	oj_to_sym_id;
extern ID	oj_to_time_id;
extern ID	oj_tv_nsec_id;
extern ID	oj_tv_sec_id;
extern ID	oj_tv_usec_id;
extern ID	oj_utc_id;
extern ID	oj_utc_offset_id;
extern ID	oj_utcq_id;
extern ID	oj_write_id;

extern bool	oj_use_hash_alt;
extern bool	oj_use_array_alt;

#if USE_PTHREAD_MUTEX
extern pthread_mutex_t	oj_cache_mutex;
#elif USE_RB_MUTEX
extern VALUE	oj_cache_mutex;
#endif

#if defined(__cplusplus)
#if 0
{ /* satisfy cc-mode */
#endif
}  /* extern "C" { */
#endif
#endif /* __OJ_H__ */
