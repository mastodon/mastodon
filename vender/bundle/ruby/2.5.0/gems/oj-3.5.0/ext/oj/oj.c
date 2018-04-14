/* oj.c
 * Copyright (c) 2012, Peter Ohler
 * All rights reserved.
 */

#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <fcntl.h>

#include "oj.h"
#include "parse.h"
#include "hash.h"
#include "odd.h"
#include "dump.h"
#include "rails.h"
#include "encode.h"

#if !HAS_ENCODING_SUPPORT || defined(RUBINIUS_RUBY)
#define rb_eEncodingError	rb_eException
#endif

typedef struct _YesNoOpt {
    VALUE	sym;
    char	*attr;
} *YesNoOpt;

void Init_oj();

VALUE	 Oj = Qnil;

ID	oj_add_value_id;
ID	oj_array_append_id;
ID	oj_array_end_id;
ID	oj_array_start_id;
ID	oj_as_json_id;
ID	oj_begin_id;
ID	oj_bigdecimal_id;
ID	oj_end_id;
ID	oj_exclude_end_id;
ID	oj_error_id;
ID	oj_file_id;
ID	oj_fileno_id;
ID	oj_ftype_id;
ID	oj_has_key_id;
ID	oj_hash_end_id;
ID	oj_hash_key_id;
ID	oj_hash_set_id;
ID	oj_hash_start_id;
ID	oj_iconv_id;
ID	oj_instance_variables_id;
ID	oj_json_create_id;
ID	oj_length_id;
ID	oj_new_id;
ID	oj_parse_id;
ID	oj_pos_id;
ID	oj_read_id;
ID	oj_readpartial_id;
ID	oj_replace_id;
ID	oj_stat_id;
ID	oj_string_id;
ID	oj_to_h_id;
ID	oj_to_hash_id;
ID	oj_to_json_id;
ID	oj_to_s_id;
ID	oj_to_sym_id;
ID	oj_to_time_id;
ID	oj_tv_nsec_id;
ID	oj_tv_sec_id;
ID	oj_tv_usec_id;
ID	oj_utc_id;
ID	oj_utc_offset_id;
ID	oj_utcq_id;
ID	oj_write_id;


VALUE	oj_bag_class;
VALUE	oj_bigdecimal_class;
VALUE	oj_cstack_class;
VALUE	oj_date_class;
VALUE	oj_datetime_class;
VALUE	oj_enumerable_class;
VALUE	oj_parse_error_class;
VALUE	oj_stream_writer_class;
VALUE	oj_string_writer_class;
VALUE	oj_stringio_class;
VALUE	oj_struct_class;

VALUE	oj_slash_string;

VALUE	oj_allow_nan_sym;
VALUE	oj_array_class_sym;
VALUE	oj_create_additions_sym;
VALUE	oj_hash_class_sym;
VALUE	oj_indent_sym;
VALUE	oj_object_class_sym;
VALUE	oj_quirks_mode_sym;
VALUE	oj_trace_sym;

static VALUE	allow_blank_sym;
static VALUE	allow_gc_sym;
static VALUE	allow_invalid_unicode_sym;
static VALUE	ascii_sym;
static VALUE	auto_define_sym;
static VALUE	auto_sym;
static VALUE	bigdecimal_as_decimal_sym;
static VALUE	bigdecimal_load_sym;
static VALUE	bigdecimal_sym;
static VALUE	circular_sym;
static VALUE	class_cache_sym;
static VALUE	compat_sym;
static VALUE	create_id_sym;
static VALUE	custom_sym;
static VALUE	empty_string_sym;
static VALUE	escape_mode_sym;
static VALUE	float_prec_sym;
static VALUE	float_sym;
static VALUE	huge_sym;
static VALUE	ignore_sym;
static VALUE	json_sym;
static VALUE	match_string_sym;
static VALUE	mode_sym;
static VALUE	nan_sym;
static VALUE	newline_sym;
static VALUE	nilnil_sym;
static VALUE	null_sym;
static VALUE	object_sym;
static VALUE	omit_nil_sym;
static VALUE	rails_sym;
static VALUE	raise_sym;
static VALUE	ruby_sym;
static VALUE	sec_prec_sym;
static VALUE	strict_sym;
static VALUE	symbol_keys_sym;
static VALUE	time_format_sym;
static VALUE	unicode_xss_sym;
static VALUE	unix_sym;
static VALUE	unix_zone_sym;
static VALUE	use_as_json_sym;
static VALUE	use_to_hash_sym;
static VALUE	use_to_json_sym;
static VALUE	wab_sym;
static VALUE	word_sym;
static VALUE	xmlschema_sym;
static VALUE	xss_safe_sym;

#if HAS_ENCODING_SUPPORT
rb_encoding	*oj_utf8_encoding = 0;
#else
VALUE		oj_utf8_encoding = Qnil;
#endif

#if USE_PTHREAD_MUTEX
pthread_mutex_t	oj_cache_mutex;
#elif USE_RB_MUTEX
VALUE oj_cache_mutex = Qnil;
#endif

const char	oj_json_class[] = "json_class";

struct _Options	oj_default_options = {
    0,		// indent
    No,		// circular
    No,		// auto_define
    No,		// sym_key
    JSONEsc,	// escape_mode
    ObjectMode,	// mode
    Yes,	// class_cache
    UnixTime,	// time_format
    NotSet,	// bigdec_as_num
    AutoDec,	// bigdec_load
    No,		// to_hash
    No,		// to_json
    No,		// as_json
    No,		// nilnil
    Yes,	// empty_string
    Yes,	// allow_gc
    Yes,	// quirks_mode
    No,		// allow_invalid
    No,		// create_ok
    Yes,	// allow_nan
    No,		// trace
    oj_json_class,	// create_id
    10,		// create_id_len
    9,		// sec_prec
    16,		// float_prec
    "%0.15g",	// float_fmt
    Qnil,	// hash_class
    Qnil,	// array_class
    {		// dump_opts
	false,	//use
	"",	// indent
	"",	// before_sep
	"",	// after_sep
	"",	// hash_nl
	"",	// array_nl
	0,	// indent_size
	0,	// before_size
	0,	// after_size
	0,	// hash_size
	0,	// array_size
	AutoNan,// nan_dump
	false,	// omit_nil
	MAX_DEPTH, // max_depth
    },
    {		// str_rx
	NULL,	// head
	NULL,	// tail
	{ '\0' }, // err
    },
    NULL,	// ignore
};

/* Document-method: default_options()
 *	call-seq: default_options()
 *
 * Returns the default load and dump options as a Hash. The options are
 * - *:indent* [_Fixnum_|_String_|_nil_] number of spaces to indent each element in an JSON document, zero or nil is no newline between JSON elements, negative indicates no newline between top level JSON elements in a stream, a String indicates the string should be used for indentation
 * - *:circular* [_Boolean_|_nil_] support circular references while dumping
 * - *:auto_define* [_Boolean_|_nil_] automatically define classes if they do not exist
 * - *:symbol_keys* [_Boolean_|_nil_] use symbols instead of strings for hash keys
 * - *:escape_mode* [_:newline_|_:json_|_:xss_safe_|_:ascii_|_unicode_xss_|_nil_] determines the characters to escape
 * - *:class_cache* [_Boolean_|_nil_] cache classes for faster parsing (if dynamically modifying classes or reloading classes then don't use this)
 * - *:mode* [_:object_|_:strict_|_:compat_|_:null_|_:custom_|_:rails_|_:wab_] load and dump modes to use for JSON
 * - *:time_format* [_:unix_|_:unix_zone_|_:xmlschema_|_:ruby_] time format when dumping
 * - *:bigdecimal_as_decimal* [_Boolean_|_nil_] dump BigDecimal as a decimal number or as a String
 * - *:bigdecimal_load* [_:bigdecimal_|_:float_|_:auto_] load decimals as BigDecimal instead of as a Float. :auto pick the most precise for the number of digits.
 * - *:create_id* [_String_|_nil_] create id for json compatible object encoding, default is 'json_class'
 * - *:second_precision* [_Fixnum_|_nil_] number of digits after the decimal when dumping the seconds portion of time
 * - *:float_precision* [_Fixnum_|_nil_] number of digits of precision when dumping floats, 0 indicates use Ruby
 * - *:use_to_json* [_Boolean_|_nil_] call to_json() methods on dump, default is false
 * - *:use_as_json* [_Boolean_|_nil_] call as_json() methods on dump, default is false
 * - *:nilnil* [_Boolean_|_nil_] if true a nil input to load will return nil and not raise an Exception
 * - *:empty_string* [_Boolean_|_nil_] if true an empty input will not raise an Exception
 * - *:allow_gc* [_Boolean_|_nil_] allow or prohibit GC during parsing, default is true (allow)
 * - *:quirks_mode* [_true,_|_false_|_nil_] Allow single JSON values instead of documents, default is true (allow)
 * - *:allow_invalid_unicode* [_true,_|_false_|_nil_] Allow invalid unicode, default is false (don't allow)
 * - *:allow_nan* [_true,_|_false_|_nil_] Allow Nan, Infinity, and -Infinity to be parsed, default is true (allow)
 * - *:indent_str* [_String_|_nil_] String to use for indentation, overriding the indent option is not nil
 * - *:space* [_String_|_nil_] String to use for the space after the colon in JSON object fields
 * - *:space_before* [_String_|_nil_] String to use before the colon separator in JSON object fields
 * - *:object_nl* [_String_|_nil_] String to use after a JSON object field value
 * - *:array_nl* [_String_|_nil_] String to use after a JSON array value
 * - *:nan* [_:null_|_:huge_|_:word_|_:raise_|_:auto_] how to dump Infinity and NaN. :null places a null, :huge places a huge number, :word places Infinity or NaN, :raise raises and exception, :auto uses default for each mode.
 * - *:hash_class* [_Class_|_nil_] Class to use instead of Hash on load, :object_class can also be used
 * - *:array_class* [_Class_|_nil_] Class to use instead of Array on load
 * - *:omit_nil* [_true_|_false_] if true Hash and Object attributes with nil values are omitted
 * - *:ignore* [_nil_|Array] either nil or an Array of classes to ignore when dumping
 * - *:trace* [_true,_|_false_] Trace all load and dump calls, default is false (trace is off)
 *
 * Return [_Hash_] all current option settings.
 */
static VALUE
get_def_opts(VALUE self) {
    VALUE	opts = rb_hash_new();

    if (0 == oj_default_options.dump_opts.indent_size) {
	rb_hash_aset(opts, oj_indent_sym, INT2FIX(oj_default_options.indent));
    } else {
	rb_hash_aset(opts, oj_indent_sym, rb_str_new2(oj_default_options.dump_opts.indent_str));
    }
    rb_hash_aset(opts, sec_prec_sym, INT2FIX(oj_default_options.sec_prec));
    rb_hash_aset(opts, circular_sym, (Yes == oj_default_options.circular) ? Qtrue : ((No == oj_default_options.circular) ? Qfalse : Qnil));
    rb_hash_aset(opts, class_cache_sym, (Yes == oj_default_options.class_cache) ? Qtrue : ((No == oj_default_options.class_cache) ? Qfalse : Qnil));
    rb_hash_aset(opts, auto_define_sym, (Yes == oj_default_options.auto_define) ? Qtrue : ((No == oj_default_options.auto_define) ? Qfalse : Qnil));
    rb_hash_aset(opts, symbol_keys_sym, (Yes == oj_default_options.sym_key) ? Qtrue : ((No == oj_default_options.sym_key) ? Qfalse : Qnil));
    rb_hash_aset(opts, bigdecimal_as_decimal_sym, (Yes == oj_default_options.bigdec_as_num) ? Qtrue : ((No == oj_default_options.bigdec_as_num) ? Qfalse : Qnil));
    rb_hash_aset(opts, use_to_json_sym, (Yes == oj_default_options.to_json) ? Qtrue : ((No == oj_default_options.to_json) ? Qfalse : Qnil));
    rb_hash_aset(opts, use_to_hash_sym, (Yes == oj_default_options.to_hash) ? Qtrue : ((No == oj_default_options.to_hash) ? Qfalse : Qnil));
    rb_hash_aset(opts, use_as_json_sym, (Yes == oj_default_options.as_json) ? Qtrue : ((No == oj_default_options.as_json) ? Qfalse : Qnil));
    rb_hash_aset(opts, nilnil_sym, (Yes == oj_default_options.nilnil) ? Qtrue : ((No == oj_default_options.nilnil) ? Qfalse : Qnil));
    rb_hash_aset(opts, empty_string_sym, (Yes == oj_default_options.empty_string) ? Qtrue : ((No == oj_default_options.empty_string) ? Qfalse : Qnil));
    rb_hash_aset(opts, allow_gc_sym, (Yes == oj_default_options.allow_gc) ? Qtrue : ((No == oj_default_options.allow_gc) ? Qfalse : Qnil));
    rb_hash_aset(opts, oj_quirks_mode_sym, (Yes == oj_default_options.quirks_mode) ? Qtrue : ((No == oj_default_options.quirks_mode) ? Qfalse : Qnil));
    rb_hash_aset(opts, allow_invalid_unicode_sym, (Yes == oj_default_options.allow_invalid) ? Qtrue : ((No == oj_default_options.allow_invalid) ? Qfalse : Qnil));
    rb_hash_aset(opts, oj_allow_nan_sym, (Yes == oj_default_options.allow_nan) ? Qtrue : ((No == oj_default_options.allow_nan) ? Qfalse : Qnil));
    rb_hash_aset(opts, oj_trace_sym, (Yes == oj_default_options.trace) ? Qtrue : ((No == oj_default_options.trace) ? Qfalse : Qnil));
    rb_hash_aset(opts, float_prec_sym, INT2FIX(oj_default_options.float_prec));
    switch (oj_default_options.mode) {
    case StrictMode:	rb_hash_aset(opts, mode_sym, strict_sym);	break;
    case CompatMode:	rb_hash_aset(opts, mode_sym, compat_sym);	break;
    case NullMode:	rb_hash_aset(opts, mode_sym, null_sym);		break;
    case ObjectMode:	rb_hash_aset(opts, mode_sym, object_sym);	break;
    case CustomMode:	rb_hash_aset(opts, mode_sym, custom_sym);	break;
    case RailsMode:	rb_hash_aset(opts, mode_sym, rails_sym);	break;
    case WabMode:	rb_hash_aset(opts, mode_sym, wab_sym);		break;
    default:		rb_hash_aset(opts, mode_sym, object_sym);	break;
    }
    switch (oj_default_options.escape_mode) {
    case NLEsc:		rb_hash_aset(opts, escape_mode_sym, newline_sym);	break;
    case JSONEsc:	rb_hash_aset(opts, escape_mode_sym, json_sym);		break;
    case XSSEsc:	rb_hash_aset(opts, escape_mode_sym, xss_safe_sym);	break;
    case ASCIIEsc:	rb_hash_aset(opts, escape_mode_sym, ascii_sym);		break;
    case JXEsc:		rb_hash_aset(opts, escape_mode_sym, unicode_xss_sym);	break;
    default:		rb_hash_aset(opts, escape_mode_sym, json_sym);		break;
    }
    switch (oj_default_options.time_format) {
    case XmlTime:	rb_hash_aset(opts, time_format_sym, xmlschema_sym);	break;
    case RubyTime:	rb_hash_aset(opts, time_format_sym, ruby_sym);		break;
    case UnixZTime:	rb_hash_aset(opts, time_format_sym, unix_zone_sym);	break;
    case UnixTime:
    default:		rb_hash_aset(opts, time_format_sym, unix_sym);		break;
    }
    switch (oj_default_options.bigdec_load) {
    case BigDec:	rb_hash_aset(opts, bigdecimal_load_sym, bigdecimal_sym);break;
    case FloatDec:	rb_hash_aset(opts, bigdecimal_load_sym, float_sym);	break;
    case AutoDec:
    default:		rb_hash_aset(opts, bigdecimal_load_sym, auto_sym);	break;
    }
    rb_hash_aset(opts, create_id_sym, (0 == oj_default_options.create_id) ? Qnil : rb_str_new2(oj_default_options.create_id));
    rb_hash_aset(opts, oj_space_sym, (0 == oj_default_options.dump_opts.after_size) ? Qnil : rb_str_new2(oj_default_options.dump_opts.after_sep));
    rb_hash_aset(opts, oj_space_before_sym, (0 == oj_default_options.dump_opts.before_size) ? Qnil : rb_str_new2(oj_default_options.dump_opts.before_sep));
    rb_hash_aset(opts, oj_object_nl_sym, (0 == oj_default_options.dump_opts.hash_size) ? Qnil : rb_str_new2(oj_default_options.dump_opts.hash_nl));
    rb_hash_aset(opts, oj_array_nl_sym, (0 == oj_default_options.dump_opts.array_size) ? Qnil : rb_str_new2(oj_default_options.dump_opts.array_nl));

    switch (oj_default_options.dump_opts.nan_dump) {
    case NullNan:	rb_hash_aset(opts, nan_sym, null_sym);	break;
    case RaiseNan:	rb_hash_aset(opts, nan_sym, raise_sym);	break;
    case WordNan:	rb_hash_aset(opts, nan_sym, word_sym);	break;
    case HugeNan:	rb_hash_aset(opts, nan_sym, huge_sym);	break;
    case AutoNan:
    default:		rb_hash_aset(opts, nan_sym, auto_sym);	break;
    }
    rb_hash_aset(opts, omit_nil_sym, oj_default_options.dump_opts.omit_nil ? Qtrue : Qfalse);
    rb_hash_aset(opts, oj_hash_class_sym, oj_default_options.hash_class);
    rb_hash_aset(opts, oj_array_class_sym, oj_default_options.array_class);

    if (NULL == oj_default_options.ignore) {
	rb_hash_aset(opts, ignore_sym, Qnil);
    } else {
	VALUE		*vp;
	volatile VALUE	a = rb_ary_new();
	
	for (vp = oj_default_options.ignore; Qnil != *vp; vp++) {
	    rb_ary_push(a, *vp);
	}
	rb_hash_aset(opts, ignore_sym, a);
    }
    return opts;
}

/* Document-method: default_options=
 *	call-seq: default_options=(opts)
 *
 * Sets the default options for load and dump.
 * - *opts* [_Hash_] options to change
 *   - *:indent* [_Fixnum_|_String_|_nil_] number of spaces to indent each element in a JSON document or the String to use for identation.
 *   - :circular [_Boolean_|_nil_] support circular references while dumping.
 *   - *:auto_define* [_Boolean_|_nil_] automatically define classes if they do not exist.
 *   - *:symbol_keys* [_Boolean_|_nil_] convert hash keys to symbols.
 *   - *:class_cache* [_Boolean_|_nil_] cache classes for faster parsing.
 *   - *:escape* [_:newline_|_:json_|_:xss_safe_|_:ascii_|_unicode_xss_|_nil_] mode encodes all high-bit characters as escaped sequences if :ascii, :json is standand UTF-8 JSON encoding, :newline is the same as :json but newlines are not escaped, :unicode_xss allows unicode but escapes &, <, and >, and any \u20xx characters along with some others, and :xss_safe escapes &, <, and >, and some others.
 *   - *:bigdecimal_as_decimal* [_Boolean_|_nil_] dump BigDecimal as a decimal number or as a String.
 *   - *:bigdecimal_load* [_:bigdecimal_|_:float_|_:auto_|_nil_] load decimals as BigDecimal instead of as a Float. :auto pick the most precise for the number of digits.
 *   - *:mode* [_:object_|_:strict_|_:compat_|_:null_|_:custom_|_:rails_|_:wab_] load and dump mode to use for JSON :strict raises an exception when a non-supported Object is encountered. :compat attempts to extract variable values from an Object using to_json() or to_hash() then it walks the Object's variables if neither is found. The :object mode ignores to_hash() and to_json() methods and encodes variables using code internal to the Oj gem. The :null mode ignores non-supported Objects and replaces them with a null. The :custom mode honors all dump options. The :rails more mimics rails and Active behavior.
 *   - *:time_format* [_:unix_|_:xmlschema_|_:ruby_] time format when dumping in :compat mode :unix decimal number denoting the number of seconds since 1/1/1970, :unix_zone decimal number denoting the number of seconds since 1/1/1970 plus the utc_offset in the exponent, :xmlschema date-time format taken from XML Schema as a String, :ruby Time.to_s formatted String.
 *   - *:create_id* [_String_|_nil_] create id for json compatible object encoding
 *   - *:second_precision* [_Fixnum_|_nil_] number of digits after the decimal when dumping the seconds portion of time.
 *   - *:float_precision* [_Fixnum_|_nil_] number of digits of precision when dumping floats, 0 indicates use Ruby.
 *   - *:use_to_json* [_Boolean_|_nil_] call to_json() methods on dump, default is false.
 *   - *:use_as_json* [_Boolean_|_nil_] call as_json() methods on dump, default is false.
 *   - *:use_to_hash* [_Boolean_|_nil_] call to_hash() methods on dump, default is false.
 *   - *:nilnil* [_Boolean_|_nil_] if true a nil input to load will return nil and not raise an Exception.
 *   - *:allow_gc* [_Boolean_|_nil_] allow or prohibit GC during parsing, default is true (allow).
 *   - *:quirks_mode* [_Boolean_|_nil_] allow single JSON values instead of documents, default is true (allow).
 *   - *:allow_invalid_unicode* [_Boolean_|_nil_] allow invalid unicode, default is false (don't allow).
 *   - *:allow_nan* [_Boolean_|_nil_] allow Nan, Infinity, and -Infinity, default is true (allow).
 *   - *:space* [_String_|_nil_] String to use for the space after the colon in JSON object fields.
 *   - *:space_before* [_String_|_nil_] String to use before the colon separator in JSON object fields.
 *   - *:object_nl* [_String_|_nil_] String to use after a JSON object field value.
 *   - *:array_nl* [_String_|_nil_] String to use after a JSON array value
 *   - *:nan* [_:null_|_:huge_|_:word_|_:raise_] how to dump Infinity and NaN in null, strict, and compat mode. :null places a null, :huge places a huge number, :word places Infinity or NaN, :raise raises and exception, :auto uses default for each mode.
 *   - *:hash_class* [_Class_|_nil_] Class to use instead of Hash on load, :object_class can also be used.
 *   - *:array_class* [_Class_|_nil_] Class to use instead of Array on load.
 *   - *:omit_nil* [_true_|_false_] if true Hash and Object attributes with nil values are omitted.
 *   - *:ignore* [_nil_|Array] either nil or an Array of classes to ignore when dumping
 *   - *:trace* [_Boolean_] turn trace on or off.
 */
static VALUE
set_def_opts(VALUE self, VALUE opts) {
    Check_Type(opts, T_HASH);
    oj_parse_options(opts, &oj_default_options);

    return Qnil;
}

void
oj_parse_options(VALUE ropts, Options copts) {
    struct _YesNoOpt	ynos[] = {
	{ circular_sym, &copts->circular },
	{ auto_define_sym, &copts->auto_define },
	{ symbol_keys_sym, &copts->sym_key },
	{ class_cache_sym, &copts->class_cache },
	{ bigdecimal_as_decimal_sym, &copts->bigdec_as_num },
	{ use_to_hash_sym, &copts->to_hash },
	{ use_to_json_sym, &copts->to_json },
	{ use_as_json_sym, &copts->as_json },
	{ nilnil_sym, &copts->nilnil },
	{ allow_blank_sym, &copts->nilnil }, // same as nilnil
	{ empty_string_sym, &copts->empty_string },
	{ allow_gc_sym, &copts->allow_gc },
	{ oj_quirks_mode_sym, &copts->quirks_mode },
	{ allow_invalid_unicode_sym, &copts->allow_invalid },
	{ oj_allow_nan_sym, &copts->allow_nan },
	{ oj_trace_sym, &copts->trace },
	{ oj_create_additions_sym, &copts->create_ok },
	{ Qnil, 0 }
    };
    YesNoOpt		o;
    volatile VALUE	v;
    size_t		len;
    
    if (T_HASH != rb_type(ropts)) {
	return;
    }
    if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, oj_indent_sym)) {
	v = rb_hash_lookup(ropts, oj_indent_sym);
	switch (rb_type(v)) {
	case T_NIL:
	    copts->dump_opts.indent_size = 0;
	    *copts->dump_opts.indent_str = '\0';
	    copts->indent = 0;
	    break;
	case T_FIXNUM:
	    copts->dump_opts.indent_size = 0;
	    *copts->dump_opts.indent_str = '\0';
	    copts->indent = FIX2INT(v);
	    break;
	case T_STRING:
	    if (sizeof(copts->dump_opts.indent_str) <= (len = RSTRING_LEN(v))) {
		rb_raise(rb_eArgError, "indent string is limited to %lu characters.", (unsigned long)sizeof(copts->dump_opts.indent_str));
	    }
	    strcpy(copts->dump_opts.indent_str, StringValuePtr(v));
	    copts->dump_opts.indent_size = (uint8_t)len;
	    copts->indent = 0;
	    break;
	default:
	    rb_raise(rb_eTypeError, "indent must be a Fixnum, String, or nil.");
	    break;
	}
    }
    if (Qnil != (v = rb_hash_lookup(ropts, float_prec_sym))) {
	int	n;

#ifdef RUBY_INTEGER_UNIFICATION
	if (rb_cInteger != rb_obj_class(v)) {
	    rb_raise(rb_eArgError, ":float_precision must be a Integer.");
	}
#else
	if (T_FIXNUM != rb_type(v)) {
	    rb_raise(rb_eArgError, ":float_precision must be a Fixnum.");
	}
#endif
	n = FIX2INT(v);
	if (0 >= n) {
	    *copts->float_fmt = '\0';
	    copts->float_prec = 0;
	} else {
	    if (20 < n) {
		n = 20;
	    }
	    sprintf(copts->float_fmt, "%%0.%dg", n);
	    copts->float_prec = n;
	}
    }
    if (Qnil != (v = rb_hash_lookup(ropts, sec_prec_sym))) {
	int	n;

#ifdef RUBY_INTEGER_UNIFICATION
	if (rb_cInteger != rb_obj_class(v)) {
	    rb_raise(rb_eArgError, ":second_precision must be a Integer.");
	}
#else
	if (T_FIXNUM != rb_type(v)) {
	    rb_raise(rb_eArgError, ":second_precision must be a Fixnum.");
	}
#endif
	n = NUM2INT(v);
	if (0 > n) {
	    n = 0;
	} else if (9 < n) {
	    n = 9;
	}
	copts->sec_prec = n;
    }
    if (Qnil != (v = rb_hash_lookup(ropts, mode_sym))) {
	if (wab_sym == v) {
	    copts->mode = WabMode;
	} else if (object_sym == v) {
	    copts->mode = ObjectMode;
	} else if (strict_sym == v) {
	    copts->mode = StrictMode;
	} else if (compat_sym == v || json_sym == v) {
	    copts->mode = CompatMode;
	} else if (null_sym == v) {
	    copts->mode = NullMode;
	} else if (custom_sym == v) {
	    copts->mode = CustomMode;
	} else if (rails_sym == v) {
	    copts->mode = RailsMode;
	} else {
	    rb_raise(rb_eArgError, ":mode must be :object, :strict, :compat, :null, :custom, :rails, or :wab.");
	}
    }
    if (Qnil != (v = rb_hash_lookup(ropts, time_format_sym))) {
	if (unix_sym == v) {
	    copts->time_format = UnixTime;
	} else if (unix_zone_sym == v) {
	    copts->time_format = UnixZTime;
	} else if (xmlschema_sym == v) {
	    copts->time_format = XmlTime;
	} else if (ruby_sym == v) {
	    copts->time_format = RubyTime;
	} else {
	    rb_raise(rb_eArgError, ":time_format must be :unix, :unix_zone, :xmlschema, or :ruby.");
	}
    }
    if (Qnil != (v = rb_hash_lookup(ropts, escape_mode_sym))) {
	if (newline_sym == v) {
	    copts->escape_mode = NLEsc;
	} else if (json_sym == v) {
	    copts->escape_mode = JSONEsc;
	} else if (xss_safe_sym == v) {
	    copts->escape_mode = XSSEsc;
	} else if (ascii_sym == v) {
	    copts->escape_mode = ASCIIEsc;
	} else if (unicode_xss_sym == v) {
	    copts->escape_mode = JXEsc;
	} else {
	    rb_raise(rb_eArgError, ":encoding must be :newline, :json, :xss_safe, :unicode_xss, or :ascii.");
	}
    }
    if (Qnil != (v = rb_hash_lookup(ropts, bigdecimal_load_sym))) {
	if (bigdecimal_sym == v || Qtrue == v) {
	    copts->bigdec_load = BigDec;
	} else if (float_sym == v) {
	    copts->bigdec_load = FloatDec;
	} else if (auto_sym == v || Qfalse == v) {
	    copts->bigdec_load = AutoDec;
	} else {
	    rb_raise(rb_eArgError, ":bigdecimal_load must be :bigdecimal, :float, or :auto.");
	}
    }
    if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, create_id_sym)) {
	v = rb_hash_lookup(ropts, create_id_sym);
	if (Qnil == v) {
	    if (oj_json_class != oj_default_options.create_id && NULL != copts->create_id) {
		xfree((char*)oj_default_options.create_id);
	    }
	    copts->create_id = NULL;
	    copts->create_id_len = 0;
	} else if (T_STRING == rb_type(v)) {
	    const char	*str = StringValuePtr(v);

	    len = RSTRING_LEN(v);
	    if (len != copts->create_id_len ||
		0 != strcmp(copts->create_id, str)) {
		copts->create_id = ALLOC_N(char, len + 1);
		strcpy((char*)copts->create_id, str);
		copts->create_id_len = len;
	    }
	} else {
	    rb_raise(rb_eArgError, ":create_id must be string.");
	}
    }
    for (o = ynos; 0 != o->attr; o++) {
	if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, o->sym)) {
	    v = rb_hash_lookup(ropts, o->sym);
	    if (Qnil == v) {
		*o->attr = NotSet;
	    } else if (Qtrue == v) {
		*o->attr = Yes;
	    } else if (Qfalse == v) {
		*o->attr = No;
	    } else {
		rb_raise(rb_eArgError, "%s must be true, false, or nil.", rb_id2name(SYM2ID(o->sym)));
	    }
	}
    }
    if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, oj_space_sym)) {
	if (Qnil == (v = rb_hash_lookup(ropts, oj_space_sym))) {
	    copts->dump_opts.after_size = 0;
	    *copts->dump_opts.after_sep = '\0';
	} else {
	    rb_check_type(v, T_STRING);
	    if (sizeof(copts->dump_opts.after_sep) <= (len = RSTRING_LEN(v))) {
		rb_raise(rb_eArgError, "space string is limited to %lu characters.", (unsigned long)sizeof(copts->dump_opts.after_sep));
	    }
	    strcpy(copts->dump_opts.after_sep, StringValuePtr(v));
	    copts->dump_opts.after_size = (uint8_t)len;
	}
    }
    if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, oj_space_before_sym)) {
	if (Qnil == (v = rb_hash_lookup(ropts, oj_space_before_sym))) {
	    copts->dump_opts.before_size = 0;
	    *copts->dump_opts.before_sep = '\0';
	} else {
	    rb_check_type(v, T_STRING);
	    if (sizeof(copts->dump_opts.before_sep) <= (len = RSTRING_LEN(v))) {
		rb_raise(rb_eArgError, "sapce_before string is limited to %lu characters.", (unsigned long)sizeof(copts->dump_opts.before_sep));
	    }
	    strcpy(copts->dump_opts.before_sep, StringValuePtr(v));
	    copts->dump_opts.before_size = (uint8_t)len;
	}
    }
    if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, oj_object_nl_sym)) {
	if (Qnil == (v = rb_hash_lookup(ropts, oj_object_nl_sym))) {
	    copts->dump_opts.hash_size = 0;
	    *copts->dump_opts.hash_nl = '\0';
	} else {
	    rb_check_type(v, T_STRING);
	    if (sizeof(copts->dump_opts.hash_nl) <= (len = RSTRING_LEN(v))) {
		rb_raise(rb_eArgError, "object_nl string is limited to %lu characters.", (unsigned long)sizeof(copts->dump_opts.hash_nl));
	    }
	    strcpy(copts->dump_opts.hash_nl, StringValuePtr(v));
	    copts->dump_opts.hash_size = (uint8_t)len;
	}
    }
    if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, oj_array_nl_sym)) {
	if (Qnil == (v = rb_hash_lookup(ropts, oj_array_nl_sym))) {
	    copts->dump_opts.array_size = 0;
	    *copts->dump_opts.array_nl = '\0';
	} else {
	    rb_check_type(v, T_STRING);
	    if (sizeof(copts->dump_opts.array_nl) <= (len = RSTRING_LEN(v))) {
		rb_raise(rb_eArgError, "array_nl string is limited to %lu characters.", (unsigned long)sizeof(copts->dump_opts.array_nl));
	    }
	    strcpy(copts->dump_opts.array_nl, StringValuePtr(v));
	    copts->dump_opts.array_size = (uint8_t)len;
	}
    }
    if (Qnil != (v = rb_hash_lookup(ropts, nan_sym))) {
	if (null_sym == v) {
	    copts->dump_opts.nan_dump = NullNan;
	} else if (huge_sym == v) {
	    copts->dump_opts.nan_dump = HugeNan;
	} else if (word_sym == v) {
	    copts->dump_opts.nan_dump = WordNan;
	} else if (raise_sym == v) {
	    copts->dump_opts.nan_dump = RaiseNan;
	} else if (auto_sym == v) {
	    copts->dump_opts.nan_dump = AutoNan;
	} else {
	    rb_raise(rb_eArgError, ":nan must be :null, :huge, :word, :raise, or :auto.");
	}
    }
    copts->dump_opts.use = (0 < copts->dump_opts.indent_size ||
			    0 < copts->dump_opts.after_size ||
			    0 < copts->dump_opts.before_size ||
			    0 < copts->dump_opts.hash_size ||
			    0 < copts->dump_opts.array_size);
    if (Qnil != (v = rb_hash_lookup(ropts, omit_nil_sym))) {
	if (Qtrue == v) {
	    copts->dump_opts.omit_nil = true;
	} else if (Qfalse == v) {
	    copts->dump_opts.omit_nil = false;
	} else {
	    rb_raise(rb_eArgError, ":omit_nil must be true or false.");
	}
    }
    // This is here only for backwards compatibility with the original Oj.
    v = rb_hash_lookup(ropts, oj_ascii_only_sym);
    if (Qtrue == v) {
	copts->escape_mode = ASCIIEsc;
    } else if (Qfalse == v) {
	copts->escape_mode = JSONEsc;
    }
    if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, oj_hash_class_sym)) {
	if (Qnil == (v = rb_hash_lookup(ropts, oj_hash_class_sym))) {
	    copts->hash_class = Qnil;
	} else {
	    rb_check_type(v, T_CLASS);
	    copts->hash_class = v;
	}
    }
    if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, oj_object_class_sym)) {
	if (Qnil == (v = rb_hash_lookup(ropts, oj_object_class_sym))) {
	    copts->hash_class = Qnil;
	} else {
	    rb_check_type(v, T_CLASS);
	    copts->hash_class = v;
	}
    }
    if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, oj_array_class_sym)) {
	if (Qnil == (v = rb_hash_lookup(ropts, oj_array_class_sym))) {
	    copts->array_class = Qnil;
	} else {
	    rb_check_type(v, T_CLASS);
	    copts->array_class = v;
	}
    }
    oj_parse_opt_match_string(&copts->str_rx, ropts);
    if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, ignore_sym)) {
	xfree(copts->ignore);
	copts->ignore = NULL;
	if (Qnil != (v = rb_hash_lookup(ropts, ignore_sym))) {
	    int	cnt;

	    rb_check_type(v, T_ARRAY);
	    cnt = (int)RARRAY_LEN(v);
	    if (0 < cnt) {
		int	i;
		
		copts->ignore = ALLOC_N(VALUE, cnt + 1);
		for (i = 0; i < cnt; i++) {
		    copts->ignore[i] = rb_ary_entry(v, i);
		}
		copts->ignore[i] = Qnil;
	    }
	}
    }
}

static int
match_string_cb(VALUE key, VALUE value, RxClass rc) {
    if (T_CLASS != rb_type(value)) {
	rb_raise(rb_eArgError, "for :match_string, the hash values must be a Class.");
    }
    switch (rb_type(key)) {
    case T_REGEXP:
	oj_rxclass_rappend(rc, key, value);
	break;
    case T_STRING:
	if (0 != oj_rxclass_append(rc, StringValuePtr(key), value)) {
	    rb_raise(rb_eArgError, "%s", rc->err);
	}
	break;
    default:
	rb_raise(rb_eArgError, "for :match_string, keys must either a String or RegExp.");
	break;
    }
    return ST_CONTINUE;
}

void
oj_parse_opt_match_string(RxClass rc, VALUE ropts) {
    VALUE	v;

    if (Qnil != (v = rb_hash_lookup(ropts, match_string_sym))) {
	rb_check_type(v, T_HASH);
	// Zero out rc. Pattern are not appended but override.
	rc->head = NULL;
	rc->tail = NULL;
	*rc->err = '\0';
	rb_hash_foreach(v, match_string_cb, (VALUE)rc);
    }
}

/* Document-method: load
 * call-seq: load(json, options) { _|_obj, start, len_|_ }
 *
 * Parses a JSON document String into a Object, Hash, Array, String, Fixnum,
 * Float, true, false, or nil according to the default mode or the mode
 * specified. Raises an exception if the JSON is malformed or the classes
 * specified are not valid. If the string input is not a valid JSON document (an
 * empty string is not a valid JSON document) an exception is raised.
 *
 * When used with a document that has multiple JSON elements the block, if
 * any, will be yielded to. If no block then the last element read will be
 * returned.
 *
 * This parser operates on string and will attempt to load files into memory if
 * a file object is passed as the first argument. A stream input will be parsed
 * using a stream parser but others use the slightly faster string parser.
 *
 * A block can be provided with a single argument. That argument will be the
 * parsed JSON document. This is useful when parsing a string that includes
 * multiple JSON documents. The block can take up to 3 arguments, the parsed
 * object, the position in the string or stream of the start of the JSON for
 * that object, and the length of the JSON for that object plus trailing
 * whitespace.
 *
 * - *json* [_String_|_IO_] JSON String or an Object that responds to read()
 * - *options* [_Hash_] load options (same as default_options)
 *   - -
 * - *obj* [_Hash_|_Array_|_String_|_Fixnum_|_Float_|_Boolean_|_nil_] parsed object.
 * - *start* [_optional, _Integer_] start position of parsed JSON for obj.
 * - *len* [_optional, _Integer_] length of parsed JSON for obj.
 * 
 * Returns [_Hash_|_Array_|_String_|_Fixnum_|_Float_|_Boolean_|_nil_]
 */
static VALUE
load(int argc, VALUE *argv, VALUE self) {
    Mode	mode = oj_default_options.mode;

    if (1 > argc) {
	rb_raise(rb_eArgError, "Wrong number of arguments to load().");
    }
    if (2 <= argc) {
	VALUE	ropts = argv[1];
	VALUE	v;

	if (Qnil != ropts || CompatMode != mode) {
	    Check_Type(ropts, T_HASH);
	    if (Qnil != (v = rb_hash_lookup(ropts, mode_sym))) {
		if (object_sym == v) {
		    mode = ObjectMode;
		} else if (strict_sym == v) {
		    mode = StrictMode;
		} else if (compat_sym == v || json_sym == v) {
		    mode = CompatMode;
		} else if (null_sym == v) {
		    mode = NullMode;
		} else if (custom_sym == v) {
		    mode = CustomMode;
		} else if (rails_sym == v) {
		    mode = RailsMode;
		} else if (wab_sym == v) {
		    mode = WabMode;
		} else {
		    rb_raise(rb_eArgError, ":mode must be :object, :strict, :compat, :null, :custom, :rails, or :wab.");
		}
	    }
	}
    }
    switch (mode) {
    case StrictMode:
    case NullMode:
	return oj_strict_parse(argc, argv, self);
    case CompatMode:
    case RailsMode:
	return oj_compat_parse(argc, argv, self);
    case CustomMode:
	return oj_custom_parse(argc, argv, self);
    case WabMode:
	return oj_wab_parse(argc, argv, self);
    case ObjectMode:
    default:
	break;
    }
    return oj_object_parse(argc, argv, self);
}

/* Document-method: load_file
 * call-seq: load_file(path, options) { _|_obj, start, len_|_ }
 *
 * Parses a JSON document String into a Object, Hash, Array, String, Fixnum,
 * Float, true, false, or nil according to the default mode or the mode
 * specified. Raises an exception if the JSON is malformed or the classes
 * specified are not valid. If the string input is not a valid JSON document (an
 * empty string is not a valid JSON document) an exception is raised.
 *
 * When used with a document that has multiple JSON elements the block, if
 * any, will be yielded to. If no block then the last element read will be
 * returned.
 *
 * If the input file is not a valid JSON document (an empty file is not a valid
 * JSON document) an exception is raised.
 *
 * This is a stream based parser which allows a large or huge file to be loaded
 * without pulling the whole file into memory.
 *
 * A block can be provided with a single argument. That argument will be the
 * parsed JSON document. This is useful when parsing a string that includes
 * multiple JSON documents. The block can take up to 3 arguments, the parsed
 * object, the position in the string or stream of the start of the JSON for
 * that object, and the length of the JSON for that object plus trailing
 * whitespace.
 *
 * - *path* [_String_] to a file containing a JSON document
 * - *options* [_Hash_] load options (same as default_options)
 *   - -
 * - *obj* [_Hash_|_Array_|_String_|_Fixnum_|_Float_|_Boolean_|_nil_] parsed object.
 * - *start* [_optional, _Integer_] start position of parsed JSON for obj.
 * - *len* [_optional, _Integer_] length of parsed JSON for obj.
 *
 * Returns [_Object_|_Hash_|_Array_|_String_|_Fixnum_|_Float_|_Boolean_|_nil_]
 */
static VALUE
load_file(int argc, VALUE *argv, VALUE self) {
    char		*path;
    int			fd;
    Mode		mode = oj_default_options.mode;
    struct _ParseInfo	pi;

    if (1 > argc) {
	rb_raise(rb_eArgError, "Wrong number of arguments to load().");
    }
    Check_Type(*argv, T_STRING);
    parse_info_init(&pi);
    pi.options = oj_default_options;
    pi.handler = Qnil;
    pi.err_class = Qnil;
    pi.max_depth = 0;
    if (2 <= argc) {
	VALUE	ropts = argv[1];
	VALUE	v;

	Check_Type(ropts, T_HASH);
	if (Qnil != (v = rb_hash_lookup(ropts, mode_sym))) {
	    if (object_sym == v) {
		mode = ObjectMode;
	    } else if (strict_sym == v) {
		mode = StrictMode;
	    } else if (compat_sym == v || json_sym == v) {
		mode = CompatMode;
	    } else if (null_sym == v) {
		mode = NullMode;
	    } else if (custom_sym == v) {
		mode = CustomMode;
	    } else if (rails_sym == v) {
		mode = RailsMode;
	    } else if (wab_sym == v) {
		mode = WabMode;
	    } else {
		rb_raise(rb_eArgError, ":mode must be :object, :strict, :compat, :null, :custom, :rails, or :wab.");
	    }
	}
    }
    path = StringValuePtr(*argv);
    if (0 == (fd = open(path, O_RDONLY))) {
	rb_raise(rb_eIOError, "%s", strerror(errno));
    }
    switch (mode) {
    case StrictMode:
	oj_set_strict_callbacks(&pi);
	return oj_pi_sparse(argc, argv, &pi, fd);
    case NullMode:
    case CompatMode:
    case CustomMode:
    case RailsMode:
	oj_set_compat_callbacks(&pi);
	return oj_pi_sparse(argc, argv, &pi, fd);
    case WabMode:
	oj_set_wab_callbacks(&pi);
	return oj_pi_sparse(argc, argv, &pi, fd);
    case ObjectMode:
    default:
	break;
    }
    oj_set_object_callbacks(&pi);

    return oj_pi_sparse(argc, argv, &pi, fd);
}

/* Document-method: safe_load
 * call-seq: safe_load(doc)
 *
 * Loads a JSON document in strict mode with :auto_define and :symbol_keys
 * turned off. This function should be safe to use with JSON received on an
 * unprotected public interface.
 *
 * - *doc* [_String__|_IO_] JSON String or IO to load.
 *
 * Returns [_Hash_|_Array_|_String_|_Fixnum_|_Bignum_|_BigDecimal_|_nil_|_True_|_False_]
 */
static VALUE
safe_load(VALUE self, VALUE doc) {
    struct _ParseInfo	pi;
    VALUE		args[1];

    parse_info_init(&pi);
    pi.err_class = Qnil;
    pi.max_depth = 0;
    pi.options = oj_default_options;
    pi.options.auto_define = No;
    pi.options.sym_key = No;
    pi.options.mode = StrictMode;
    oj_set_strict_callbacks(&pi);
    *args = doc;

    return oj_pi_parse(1, args, &pi, 0, 0, 1);
}

/* Document-method: saj_parse
 * call-seq: saj_parse(handler, io)
 *
 * Parses an IO stream or file containing a JSON document. Raises an exception
 * if the JSON is malformed. This is a callback parser that calls the methods in
 * the handler if they exist. A sample is the Oj::Saj class which can be used as
 * a base class for the handler.
 *
 * - *handler* [_Oj::Saj_] responds to Oj::Saj methods
 * - *io* [_IO_|_String_] IO Object to read from
 */

/* Document-method: sc_parse
 * call-seq: sc_parse(handler, io)
 *
 * Parses an IO stream or file containing a JSON document. Raises an exception
 * if the JSON is malformed. This is a callback parser (Simple Callback Parser)
 * that calls the methods in the handler if they exist. A sample is the
 * Oj::ScHandler class which can be used as a base class for the handler. This
 * callback parser is slightly more efficient than the Saj callback parser and
 * requires less argument checking.
 *
 * - *handler* [_Oj_::ScHandler_] responds to Oj::ScHandler methods
 * - *io* [_IO__|_String_] IO Object to read from
 */

/* Document-method: dump
 * call-seq: dump(obj, options)
 *
 * Dumps an Object (obj) to a string.
 * - *obj* [_Object_] Object to serialize as an JSON document String
 * - *options* [_Hash_] same as default_options
 */
static VALUE
dump(int argc, VALUE *argv, VALUE self) {
    char		buf[4096];
    struct _Out		out;
    struct _Options	copts = oj_default_options;
    VALUE		rstr;

    if (1 > argc) {
	rb_raise(rb_eArgError, "wrong number of arguments (0 for 1).");
    }
    if (CompatMode == copts.mode) {
	copts.dump_opts.nan_dump = WordNan;
    }
    if (2 == argc) {
	oj_parse_options(argv[1], &copts);
    }
    out.buf = buf;
    out.end = buf + sizeof(buf) - 10;
    out.allocated = false;
    out.omit_nil = copts.dump_opts.omit_nil;
    out.caller = CALLER_DUMP;
    oj_dump_obj_to_json_using_params(*argv, &copts, &out, argc - 1,argv + 1);
    if (0 == out.buf) {
	rb_raise(rb_eNoMemError, "Not enough memory.");
    }
    rstr = rb_str_new2(out.buf);
    rstr = oj_encode(rstr);
    if (out.allocated) {
	xfree(out.buf);
    }
    return rstr;
}

/* Document-method: to_json
 * call-seq: to_json(obj, options)
 *
 * Dumps an Object (obj) to a string. If the object has a to_json method that
 * will be called. The mode is set to :compat.
 * - *obj* [_Object_] Object to serialize as an JSON document String
 * - *options* [_Hash_] 
 *   - *:max_nesting* [_boolean_] It true nesting is limited to 100. The option to detect circular references is available but is not compatible with the json gem., default is false
 *   - *:allow_nan* [_boolean_] If true non JSON compliant words such as Nan and Infinity will be used as appropriate, default is true.
 *   - *:quirks_mode* [_boolean_] Allow single JSON values instead of documents, default is true (allow).
 *   - *:indent* [_String_|_nil_] String to use for indentation, overriding the indent option if not nil.
 *   - *:space* [_String_|_nil_] String to use for the space after the colon in JSON object fields.
 *   - *:space_before* [_String_|_nil_] String to use before the colon separator in JSON object fields.
 *   - *:object_nl* [_String_|_nil_] String to use after a JSON object field value.
 *   - *:array_nl* [_String_|_nil_] String to use after a JSON array value.
 *   - *:trace* [_Boolean_] If true trace is turned on.
 *
 * Returns [_String_] the encoded JSON.
 */
static VALUE
to_json(int argc, VALUE *argv, VALUE self) {
    char		buf[4096];
    struct _Out		out;
    struct _Options	copts = oj_default_options;
    VALUE		rstr;

    if (1 > argc) {
	rb_raise(rb_eArgError, "wrong number of arguments (0 for 1).");
    }
    copts.escape_mode = JXEsc;
    copts.dump_opts.nan_dump = RaiseNan;
    if (2 == argc) {
	oj_parse_mimic_dump_options(argv[1], &copts);
    }
    copts.mode = CompatMode;
    copts.to_json = Yes;
    out.buf = buf;
    out.end = buf + sizeof(buf) - 10;
    out.allocated = false;
    out.omit_nil = copts.dump_opts.omit_nil;
    // For obj.to_json or generate nan is not allowed but if called from dump
    // it is.
    oj_dump_obj_to_json_using_params(*argv, &copts, &out, argc - 1, argv + 1);

    if (0 == out.buf) {
	rb_raise(rb_eNoMemError, "Not enough memory.");
    }
    rstr = rb_str_new2(out.buf);
    rstr = oj_encode(rstr);
    if (out.allocated) {
	xfree(out.buf);
    }
    return rstr;
}

/* Document-method: to_file
 * call-seq: to_file(file_path, obj, options)
 *
 * Dumps an Object to the specified file.
 * - *file* [_String_] _path file path to write the JSON document to
 * - *obj* [_Object_] Object to serialize as an JSON document String
 * - *options* [_Hash_] formating options
 *   - *:indent* [_Fixnum_] format expected
 *   - *:circular* [_Boolean_] allow circular references, default: false
 */
static VALUE
to_file(int argc, VALUE *argv, VALUE self) {
    struct _Options	copts = oj_default_options;
    
    if (3 == argc) {
	oj_parse_options(argv[2], &copts);
    }
    Check_Type(*argv, T_STRING);
    oj_write_obj_to_file(argv[1], StringValuePtr(*argv), &copts);

    return Qnil;
}

/* Document-method: to_stream
 * call-seq: to_stream(io, obj, options)
 *
 * Dumps an Object to the specified IO stream.
 * - *io* [_IO_] IO stream to write the JSON document to
 * - *obj* [_Object_] Object to serialize as an JSON document String
 * - *options* [_Hash_] formating options
 *   - *:indent* [_Fixnum_] format expected
 *   - *:circular* [_Boolean_] allow circular references, default: false
 */
static VALUE
to_stream(int argc, VALUE *argv, VALUE self) {
    struct _Options	copts = oj_default_options;
    
    if (3 == argc) {
	oj_parse_options(argv[2], &copts);
    }
    oj_write_obj_to_stream(argv[1], *argv, &copts);

    return Qnil;
}

/* Document-method: register_odd
 * call-seq: register_odd(clas, create_object, create_method, *members)
 *
 * Registers a class as special. This is useful for working around subclasses of
 * primitive types as is done with ActiveSupport classes. The use of this
 * function should be limited to just classes that can not be handled in the
 * normal way. It is not intended as a hook for changing the output of all
 * classes as it is not optimized for large numbers of classes.
 *
 * - *clas* [_Class__|_Module_] Class or Module to be made special
 * - *create_object* [_Object_]  object to call the create method on
 * - *create_method* [_Symbol_] method on the clas that will create a new instance of the clas when given all the member values in the order specified.
 * - *members* [_Symbol__|_String_] methods used to get the member values from instances of the clas.
 */
static VALUE
register_odd(int argc, VALUE *argv, VALUE self) {
    if (3 > argc) {
	rb_raise(rb_eArgError, "incorrect number of arguments.");
    }
    switch (rb_type(*argv)) {
    case T_CLASS:
    case T_MODULE:
	break;
    default:
	rb_raise(rb_eTypeError, "expected a class or module.");
	break;
    }
    Check_Type(argv[2], T_SYMBOL);
    if (MAX_ODD_ARGS < argc - 2) {
	rb_raise(rb_eArgError, "too many members.");
    }
    oj_reg_odd(argv[0], argv[1], argv[2], argc - 3, argv + 3, false);

    return Qnil;
}

/* Document-method: register_odd_raw
 *	call-seq: register_odd_raw(clas, create_object, create_method, dump_method)
 *
 * Registers a class as special and expect the output to be a string that can be
 * included in the dumped JSON directly. This is useful for working around
 * subclasses of primitive types as is done with ActiveSupport classes. The use
 * of this function should be limited to just classes that can not be handled in
 * the normal way. It is not intended as a hook for changing the output of all
 * classes as it is not optimized for large numbers of classes. Be careful with
 * this option as the JSON may be incorrect if invalid JSON is returned.
 *
 * - *clas* [_Class_|_Module_] Class or Module to be made special
 * - *create_object* [_Object_] object to call the create method on
 * - *create_method* [_Symbol_] method on the clas that will create a new instance of the clas when given all the member values in the order specified.
 * - *dump_method* [_Symbol_|_String_] method to call on the object being serialized to generate the raw JSON.
 */
static VALUE
register_odd_raw(int argc, VALUE *argv, VALUE self) {
    if (3 > argc) {
	rb_raise(rb_eArgError, "incorrect number of arguments.");
    }
    switch (rb_type(*argv)) {
    case T_CLASS:
    case T_MODULE:
	break;
    default:
	rb_raise(rb_eTypeError, "expected a class or module.");
	break;
    }
    Check_Type(argv[2], T_SYMBOL);
    if (MAX_ODD_ARGS < argc - 2) {
	rb_raise(rb_eArgError, "too many members.");
    }
    oj_reg_odd(argv[0], argv[1], argv[2], 1, argv + 3, true);

    return Qnil;
}

////////////////////////////////////////////////////////////////////////////////
// RDoc entries must be in the same file as the rb_define_method and must be
// directly above the C method function. The extern declaration is enough to
// get it to work.
////////////////////////////////////////////////////////////////////////////////

/* Document-method: strict_load
 * call-seq: strict_load(json, options) { _|_obj, start, len_|_ }
 *
 * Parses a JSON document String into an Hash, Array, String, Fixnum, Float,
 * true, false, or nil. It parses using a mode that is strict in that it maps
 * each primitive JSON type to a similar Ruby type. The :create_id is not
 * honored in this mode. Note that a Ruby Hash is used to represent the JSON
 * Object type. These two are not the same since the JSON Object type can have
 * repeating entries with the same key and Ruby Hash can not.
 *
 * When used with a document that has multiple JSON elements the block, if
 * any, will be yielded to. If no block then the last element read will be
 * returned.
 *
 * Raises an exception if the JSON is malformed or the classes specified are not
 * valid. If the input is not a valid JSON document (an empty string is not a
 * valid JSON document) an exception is raised.
 *
 * A block can be provided with a single argument. That argument will be the
 * parsed JSON document. This is useful when parsing a string that includes
 * multiple JSON documents. The block can take up to 3 arguments, the parsed
 * object, the position in the string or stream of the start of the JSON for
 * that object, and the length of the JSON for that object plus trailing
 * whitespace.
 *
 * - *json* [_String_|_IO_] JSON String or an Object that responds to read().
 * - *options* [_Hash_] load options (same as default_options).
 *   - -
 * - *obj* [_Hash_|_Array_|_String_|_Fixnum_|_Float_|_Boolean_|_nil_] parsed object.
 * - *start* [_optional, _Integer_] start position of parsed JSON for obj.
 * - *len* [_optional, _Integer_] length of parsed JSON for obj.
 *
 * Returns [_Hash_|_Array_|_String_|_Fixnum_|_Float_|_Boolean_|_nil_]
 */
extern VALUE	oj_strict_parse(int argc, VALUE *argv, VALUE self);

/* Document-method: compat_load
 * call-seq: compat_load(json, options) { _|_obj, start, len_|_ }
 *
 * Parses a JSON document String into an Object, Hash, Array, String, Fixnum,
 * Float, true, false, or nil. It parses using a mode that is generally
 * compatible with other Ruby JSON parsers in that it will create objects based
 * on the :create_id value. It is not compatible in every way to every other
 * parser though as each parser has it's own variations.
 *
 * When used with a document that has multiple JSON elements the block, if
 * any, will be yielded to. If no block then the last element read will be
 * returned.
 *
 * Raises an exception if the JSON is malformed or the classes specified are not
 * valid. If the input is not a valid JSON document (an empty string is not a
 * valid JSON document) an exception is raised.
 *
 * A block can be provided with a single argument. That argument will be the
 * parsed JSON document. This is useful when parsing a string that includes
 * multiple JSON documents. The block can take up to 3 arguments, the parsed
 * object, the position in the string or stream of the start of the JSON for
 * that object, and the length of the JSON for that object plus trailing
 * whitespace.
 *
 * - *json* [_String_|_IO_] JSON String or an Object that responds to read().
 * - *options* [_Hash_] load options (same as default_options).
 *   - -
 * - *obj* [_Hash_|_Array_|_String_|_Fixnum_|_Float_|_Boolean_|_nil_] parsed object.
 * - *start* [_optional, _Integer_] start position of parsed JSON for obj.
 * - *len* [_optional, _Integer_] length of parsed JSON for obj.
 *
 * Returns [_Hash_|_Array_|_String_|_Fixnum_|_Float_|_Boolean_|_nil_]
 */
extern VALUE	oj_compat_parse(int argc, VALUE *argv, VALUE self);

/* Document-method: object_load
 * call-seq: object_load(json, options) { _|_obj, start, len_|_ }
 *
 * Parses a JSON document String into an Object, Hash, Array, String, Fixnum,
 * Float, true, false, or nil. In the :object mode the JSON should have been
 * generated by Oj.dump(). The parser will reconstitute the original marshalled
 * or dumped Object. The :auto_define and :circular options have meaning with
 * this parsing mode.
 *
 * Raises an exception if the JSON is malformed or the classes specified are not
 * valid. If the input is not a valid JSON document (an empty string is not a
 * valid JSON document) an exception is raised.
 *
 * Note: Oj is not able to automatically deserialize all classes that are a
 * subclass of a Ruby Exception. Only exception that take one required string
 * argument in the initialize() method are supported. This is an example of how
 * to write an Exception subclass that supports both a single string intializer
 * and an Exception as an argument. Additional optional arguments can be added
 * as well.
 *
 * The reason for this restriction has to do with a design decision on the part
 * of the Ruby developers. Exceptions are special Objects. They do not follow the
 * rules of other Objects. Exceptions have 'mesg' and a 'bt' attribute. Note that
 * these are not '@mesg' and '@bt'. They can not be set using the normal C or
 * Ruby calls. The only way I have found to set the 'mesg' attribute is through
 * the initializer. Unfortunately that means any subclass that provides a
 * different initializer can not be automatically decoded. A way around this is
 * to use a create function but this example shows an alternative.
 *
 * A block can be provided with a single argument. That argument will be the
 * parsed JSON document. This is useful when parsing a string that includes
 * multiple JSON documents. The block can take up to 3 arguments, the parsed
 * object, the position in the string or stream of the start of the JSON for
 * that object, and the length of the JSON for that object plus trailing
 * whitespace.
 *
 * - *json* [_String_|_IO_] JSON String or an Object that responds to read().
 * - *options* [_Hash_] load options (same as default_options).
 *   - -
 * - *obj* [_Hash_|_Array_|_String_|_Fixnum_|_Float_|_Boolean_|_nil_] parsed object.
 * - *start* [_optional, _Integer_] start position of parsed JSON for obj.
 * - *len* [_optional, _Integer_] length of parsed JSON for obj.
 *
 * Returns [_Hash_|_Array_|_String_|_Fixnum_|_Float_|_Boolean_|_nil_]
 */
extern VALUE	oj_object_parse(int argc, VALUE *argv, VALUE self);

/* Document-method: wab_load
 * call-seq: wab_load(json, options) { _|_obj, start, len_|_ }
 *
 * Parses a JSON document String into an Hash, Array, String, Fixnum, Float,
 * true, false, or nil. It parses using a mode that is :wab in that it maps
 * each primitive JSON type to a similar Ruby type. The :create_id is not
 * honored in this mode. Note that a Ruby Hash is used to represent the JSON
 * Object type. These two are not the same since the JSON Object type can have
 * repeating entries with the same key and Ruby Hash can not.
 *
 * When used with a document that has multiple JSON elements the block, if
 * any, will be yielded to. If no block then the last element read will be
 * returned.
 *
 * Raises an exception if the JSON is malformed or the classes specified are not
 * valid. If the input is not a valid JSON document (an empty string is not a
 * valid JSON document) an exception is raised.
 *
 * A block can be provided with a single argument. That argument will be the
 * parsed JSON document. This is useful when parsing a string that includes
 * multiple JSON documents. The block can take up to 3 arguments, the parsed
 * object, the position in the string or stream of the start of the JSON for
 * that object, and the length of the JSON for that object plus trailing
 * whitespace.
 *
 * - *json* [_String_|_IO_] JSON String or an Object that responds to read().
 * - *options* [_Hash_] load options (same as default_options).
 *   - -
 * - *obj* [_Hash_|_Array_|_String_|_Fixnum_|_Float_|_Boolean_|_nil_] parsed object.
 * - *start* [_optional, _Integer_] start position of parsed JSON for obj.
 * - *len* [_optional, _Integer_] length of parsed JSON for obj.
 *
 * Returns [_Hash_|_Array_|_String_|_Fixnum_|_Float_|_Boolean_|_nil_]
 */
extern VALUE	oj_wab_parse(int argc, VALUE *argv, VALUE self);

/* Document-method: add_to_json
 * call-seq: add_to_json(*args)
 *
 * Override simple to_s dump behavior in :compat mode to instead use an
 * optimized dump that includes the classname and attributes so that the
 * object can be re-created on load. The format is the same as the json gem
 * but does not use the ruby methods for encoding.
 *
 * The classes supported for optimization are: Array, BigDecimal, Complex,
 * Date, DateTime, Exception, Hash, Integer, OpenStruct, Range, Rational,
 * Regexp, Struct, and Time. Providing no classes will result in all those
 * classes being optimized.q
 *
 * - *args( [_Class_] zero or more classes to optimize.
 */
extern VALUE	oj_add_to_json(int argc, VALUE *argv, VALUE self);

/* @!method remove_to_json(*args)
 *
 * Reverts back to the to_s dump behavior in :compat mode to instead use an
 * optimized dump that includes the classname and attributes so that the
 * object can be re-created on load. The format is the same as the json gem
 * but does not use the ruby methods for encoding.
 *
 * The classes supported for optimization are: Array, BigDecimal, Complex,
 * Date, DateTime, Exception, Hash, Integer, OpenStruct, Range, Rational,
 * Regexp, Struct, and Time. Providing no classes will result in all those
 * classes being reverted from the optimized mode.
 *
 * - *args* [_Class_] zero or more classes to optimize.
 */
extern VALUE	oj_remove_to_json(int argc, VALUE *argv, VALUE self);

/* Document-method: mimic_JSON
 * call-seq: mimic_JSON()
 *
 * Creates the JSON module with methods and classes to mimic the JSON gem. After
 * this method is invoked calls that expect the JSON module will use Oj instead
 * and be faster than the original JSON. Most options that could be passed to
 * the JSON methods are supported. The calls to set parser or generator will not
 * raise an Exception but will not have any effect. The method can also be
 * called after the json gem is loaded. The necessary methods on the json gem
 * will be replaced with Oj methods.
 *
 * Note that this also sets the default options of :mode to :compat and
 * :encoding to :unicode_xss.
 *
 * Returns [_Module_] the JSON module.
 */
extern VALUE	oj_define_mimic_json(int argc, VALUE *argv, VALUE self);

/* Document-method: generate
 * call-seq: generate(obj, opts=nil)
 * 
 * Encode obj as a JSON String. The obj argument must be a Hash, Array, or
 * respond to to_h or to_json. Options other than those listed such as
 * +:allow_nan+ or +:max_nesting+ are ignored.
 * 
 * - *obj* [_Object__|_Hash_|_Array_] object to convert to a JSON String
 * - *opts* [_Hash_] options
 * - - *:indent* [_String_] String to use for indentation.
 *   - *:space* [_String_] String placed after a , or : delimiter
 *   - *:space * _before [_String_] String placed before a : delimiter
 *   - *:object_nl* [_String_] String placed after a JSON object
 *   - *:array_nl* [_String_] String placed after a JSON array
 *   - *:ascii_only* [_Boolean_] if not nil or false then use only ascii characters in the output. Note JSON.generate does support this even if it is not documented.
 *
 * Returns [_String_]generated JSON.
 */
extern VALUE	oj_mimic_generate(int argc, VALUE *argv, VALUE self);

/* Document-module: Oj.optimize_rails()
 *
 * Sets the Oj as the Rails encoder and decoder. Oj::Rails.optimize is also
 * called.
 */
extern VALUE	oj_optimize_rails(VALUE self);

/*
extern void	oj_hash_test();

static VALUE
hash_test(VALUE self) {
    oj_hash_test();
    return Qnil;
}
*/

#if !HAS_ENCODING_SUPPORT
static VALUE
iconv_encoder(VALUE x) {
    VALUE	iconv;

    rb_require("iconv");
    iconv = rb_const_get(rb_cObject, rb_intern("Iconv"));

    return rb_funcall(iconv, rb_intern("new"), 2, rb_str_new2("ASCII//TRANSLIT"), rb_str_new2("UTF-8"));
}

static VALUE
iconv_rescue(VALUE x) {
    return Qnil;
}
#endif

static VALUE
protect_require(VALUE x) {
    rb_require("time");
    rb_require("bigdecimal");
    return Qnil;
}

/* Document-module: Oj
 *
 * Optimized JSON (Oj), as the name implies was written to provide speed
 * optimized JSON handling.
 *
 * Oj uses modes to control how object are encoded and decoded. In addition
 * global and options to methods allow additional behavior modifications. The
 * modes are:
 *
 * - *:strict* mode will only allow the 7 basic JSON types to be serialized. Any other Object
 *   will raise an Exception. 
 * 
 * - *:null* mode is similar to the :strict mode except any Object that is not
 *   one of the JSON base types is replaced by a JSON null.
 * 
 * - *:object* mode will dump any Object as a JSON Object with keys that match
 *   the Ruby Object's variable names without the '@' character. This is the
 *   highest performance mode.
 * 
 * - *:compat* or *:json* mode is the compatible mode for the json gem. It mimics
 *   the json gem including the options, defaults, and restrictions.
 *
 * - *:rails* is the compatibility mode for Rails or Active support.
 *
 * - *:custom* is the most configurable mode.
 *
 * - *:wab* specifically for WAB data exchange.
 */
void
Init_oj() {
    int	err = 0;

    Oj = rb_define_module("Oj");

    oj_cstack_class = rb_define_class_under(Oj, "CStack", rb_cObject);

    oj_string_writer_init();
    oj_stream_writer_init();

    rb_require("date");
    // On Rubinius the require fails but can be done from a ruby file.
    rb_protect(protect_require, Qnil, &err);
#if NEEDS_RATIONAL
    rb_require("rational");
#endif
    rb_require("stringio");
#if HAS_ENCODING_SUPPORT
    oj_utf8_encoding = rb_enc_find("UTF-8");
#else
    // need an option to turn this on
    oj_utf8_encoding = rb_rescue(iconv_encoder, Qnil, iconv_rescue, Qnil);
    oj_utf8_encoding = Qnil;
#endif

    //rb_define_module_function(Oj, "hash_test", hash_test, 0);

    rb_define_module_function(Oj, "default_options", get_def_opts, 0);
    rb_define_module_function(Oj, "default_options=", set_def_opts, 1);

    rb_define_module_function(Oj, "mimic_JSON", oj_define_mimic_json, -1);
    rb_define_module_function(Oj, "load", load, -1);
    rb_define_module_function(Oj, "load_file", load_file, -1);
    rb_define_module_function(Oj, "safe_load", safe_load, 1);
    rb_define_module_function(Oj, "strict_load", oj_strict_parse, -1);
    rb_define_module_function(Oj, "compat_load", oj_compat_parse, -1);
    rb_define_module_function(Oj, "object_load", oj_object_parse, -1);
    rb_define_module_function(Oj, "wab_load", oj_wab_parse, -1);

    rb_define_module_function(Oj, "dump", dump, -1);

    rb_define_module_function(Oj, "to_file", to_file, -1);
    rb_define_module_function(Oj, "to_stream", to_stream, -1);
    // JSON gem compatibility
    rb_define_module_function(Oj, "to_json", to_json, -1);
    rb_define_module_function(Oj, "generate", oj_mimic_generate, -1);
    rb_define_module_function(Oj, "fast_generate", oj_mimic_generate, -1);

    rb_define_module_function(Oj, "add_to_json", oj_add_to_json, -1);
    rb_define_module_function(Oj, "remove_to_json", oj_remove_to_json, -1);

    rb_define_module_function(Oj, "register_odd", register_odd, -1);
    rb_define_module_function(Oj, "register_odd_raw", register_odd_raw, -1);

    rb_define_module_function(Oj, "saj_parse", oj_saj_parse, -1);
    rb_define_module_function(Oj, "sc_parse", oj_sc_parse, -1);

    rb_define_module_function(Oj, "optimize_rails", oj_optimize_rails, 0);

    oj_add_value_id = rb_intern("add_value");
    oj_array_append_id = rb_intern("array_append");
    oj_array_end_id = rb_intern("array_end");
    oj_array_start_id = rb_intern("array_start");
    oj_as_json_id = rb_intern("as_json");
    oj_begin_id = rb_intern("begin");
    oj_bigdecimal_id = rb_intern("BigDecimal");
    oj_end_id = rb_intern("end");
    oj_error_id = rb_intern("error");
    oj_exclude_end_id = rb_intern("exclude_end?");
    oj_file_id = rb_intern("file?");
    oj_fileno_id = rb_intern("fileno");
    oj_ftype_id = rb_intern("ftype");
    oj_has_key_id = rb_intern("has_key?");
    oj_hash_end_id = rb_intern("hash_end");
    oj_hash_key_id = rb_intern("hash_key");
    oj_hash_set_id = rb_intern("hash_set");
    oj_hash_start_id = rb_intern("hash_start");
    oj_iconv_id = rb_intern("iconv");
    oj_instance_variables_id = rb_intern("instance_variables");
    oj_json_create_id = rb_intern("json_create");
    oj_length_id = rb_intern("length");
    oj_new_id = rb_intern("new");
    oj_parse_id = rb_intern("parse");
    oj_pos_id = rb_intern("pos");
    oj_read_id = rb_intern("read");
    oj_readpartial_id = rb_intern("readpartial");
    oj_replace_id = rb_intern("replace");
    oj_stat_id = rb_intern("stat");
    oj_string_id = rb_intern("string");
    oj_to_h_id = rb_intern("to_h");
    oj_to_hash_id = rb_intern("to_hash");
    oj_to_json_id = rb_intern("to_json");
    oj_to_s_id = rb_intern("to_s");
    oj_to_sym_id = rb_intern("to_sym");
    oj_to_time_id = rb_intern("to_time");
    oj_tv_nsec_id = rb_intern("tv_nsec");
    oj_tv_sec_id = rb_intern("tv_sec");
    oj_tv_usec_id = rb_intern("tv_usec");
    oj_utc_id = rb_intern("utc");
    oj_utc_offset_id = rb_intern("utc_offset");
    oj_utcq_id = rb_intern("utc?");
    oj_write_id = rb_intern("write");

    rb_require("oj/bag");
    rb_require("oj/error");
    rb_require("oj/mimic");
    rb_require("oj/saj");
    rb_require("oj/schandler");

    oj_bag_class = rb_const_get_at(Oj, rb_intern("Bag"));
    oj_bigdecimal_class = rb_const_get(rb_cObject, rb_intern("BigDecimal"));
    oj_date_class = rb_const_get(rb_cObject, rb_intern("Date"));
    oj_datetime_class = rb_const_get(rb_cObject, rb_intern("DateTime"));
    oj_enumerable_class = rb_const_get(rb_cObject, rb_intern("Enumerable"));
    oj_parse_error_class = rb_const_get_at(Oj, rb_intern("ParseError"));
    oj_stringio_class = rb_const_get(rb_cObject, rb_intern("StringIO"));
    oj_struct_class = rb_const_get(rb_cObject, rb_intern("Struct"));
    oj_json_parser_error_class = rb_eEncodingError;    // replaced if mimic is called
    oj_json_generator_error_class = rb_eEncodingError; // replaced if mimic is called

    allow_blank_sym = ID2SYM(rb_intern("allow_blank"));		rb_gc_register_address(&allow_blank_sym);
    allow_gc_sym = ID2SYM(rb_intern("allow_gc"));		rb_gc_register_address(&allow_gc_sym);
    allow_invalid_unicode_sym = ID2SYM(rb_intern("allow_invalid_unicode"));rb_gc_register_address(&allow_invalid_unicode_sym);
    ascii_sym = ID2SYM(rb_intern("ascii"));			rb_gc_register_address(&ascii_sym);
    auto_define_sym = ID2SYM(rb_intern("auto_define"));		rb_gc_register_address(&auto_define_sym);
    auto_sym = ID2SYM(rb_intern("auto"));			rb_gc_register_address(&auto_sym);
    bigdecimal_as_decimal_sym = ID2SYM(rb_intern("bigdecimal_as_decimal"));rb_gc_register_address(&bigdecimal_as_decimal_sym);
    bigdecimal_load_sym = ID2SYM(rb_intern("bigdecimal_load"));	rb_gc_register_address(&bigdecimal_load_sym);
    bigdecimal_sym = ID2SYM(rb_intern("bigdecimal"));		rb_gc_register_address(&bigdecimal_sym);
    circular_sym = ID2SYM(rb_intern("circular"));		rb_gc_register_address(&circular_sym);
    class_cache_sym = ID2SYM(rb_intern("class_cache"));		rb_gc_register_address(&class_cache_sym);
    compat_sym = ID2SYM(rb_intern("compat"));			rb_gc_register_address(&compat_sym);
    create_id_sym = ID2SYM(rb_intern("create_id"));		rb_gc_register_address(&create_id_sym);
    custom_sym = ID2SYM(rb_intern("custom"));			rb_gc_register_address(&custom_sym);
    empty_string_sym = ID2SYM(rb_intern("empty_string"));	rb_gc_register_address(&empty_string_sym);
    escape_mode_sym = ID2SYM(rb_intern("escape_mode"));		rb_gc_register_address(&escape_mode_sym);
    float_prec_sym = ID2SYM(rb_intern("float_precision"));	rb_gc_register_address(&float_prec_sym);
    float_sym = ID2SYM(rb_intern("float"));			rb_gc_register_address(&float_sym);
    huge_sym = ID2SYM(rb_intern("huge"));			rb_gc_register_address(&huge_sym);
    ignore_sym = ID2SYM(rb_intern("ignore"));			rb_gc_register_address(&ignore_sym);
    json_sym = ID2SYM(rb_intern("json"));			rb_gc_register_address(&json_sym);
    match_string_sym = ID2SYM(rb_intern("match_string"));	rb_gc_register_address(&match_string_sym);
    mode_sym = ID2SYM(rb_intern("mode"));			rb_gc_register_address(&mode_sym);
    nan_sym = ID2SYM(rb_intern("nan"));				rb_gc_register_address(&nan_sym);
    newline_sym = ID2SYM(rb_intern("newline"));			rb_gc_register_address(&newline_sym);
    nilnil_sym = ID2SYM(rb_intern("nilnil"));			rb_gc_register_address(&nilnil_sym);
    null_sym = ID2SYM(rb_intern("null"));			rb_gc_register_address(&null_sym);
    object_sym = ID2SYM(rb_intern("object"));			rb_gc_register_address(&object_sym);
    oj_allow_nan_sym = ID2SYM(rb_intern("allow_nan"));		rb_gc_register_address(&oj_allow_nan_sym);
    oj_array_class_sym = ID2SYM(rb_intern("array_class"));	rb_gc_register_address(&oj_array_class_sym);
    oj_array_nl_sym = ID2SYM(rb_intern("array_nl"));		rb_gc_register_address(&oj_array_nl_sym);
    oj_ascii_only_sym = ID2SYM(rb_intern("ascii_only"));	rb_gc_register_address(&oj_ascii_only_sym);
    oj_create_additions_sym = ID2SYM(rb_intern("create_additions"));rb_gc_register_address(&oj_create_additions_sym);
    oj_hash_class_sym = ID2SYM(rb_intern("hash_class"));	rb_gc_register_address(&oj_hash_class_sym);
    oj_indent_sym = ID2SYM(rb_intern("indent"));		rb_gc_register_address(&oj_indent_sym);
    oj_max_nesting_sym = ID2SYM(rb_intern("max_nesting"));	rb_gc_register_address(&oj_max_nesting_sym);
    oj_object_class_sym = ID2SYM(rb_intern("object_class"));	rb_gc_register_address(&oj_object_class_sym);
    oj_object_nl_sym = ID2SYM(rb_intern("object_nl"));		rb_gc_register_address(&oj_object_nl_sym);
    oj_quirks_mode_sym = ID2SYM(rb_intern("quirks_mode"));	rb_gc_register_address(&oj_quirks_mode_sym);
    oj_space_before_sym = ID2SYM(rb_intern("space_before"));	rb_gc_register_address(&oj_space_before_sym);
    oj_space_sym = ID2SYM(rb_intern("space"));			rb_gc_register_address(&oj_space_sym);
    oj_trace_sym = ID2SYM(rb_intern("trace"));			rb_gc_register_address(&oj_trace_sym);
    omit_nil_sym = ID2SYM(rb_intern("omit_nil"));		rb_gc_register_address(&omit_nil_sym);
    rails_sym = ID2SYM(rb_intern("rails"));			rb_gc_register_address(&rails_sym);
    raise_sym = ID2SYM(rb_intern("raise"));			rb_gc_register_address(&raise_sym);
    ruby_sym = ID2SYM(rb_intern("ruby"));			rb_gc_register_address(&ruby_sym);
    sec_prec_sym = ID2SYM(rb_intern("second_precision"));	rb_gc_register_address(&sec_prec_sym);
    strict_sym = ID2SYM(rb_intern("strict"));			rb_gc_register_address(&strict_sym);
    symbol_keys_sym = ID2SYM(rb_intern("symbol_keys"));		rb_gc_register_address(&symbol_keys_sym);
    time_format_sym = ID2SYM(rb_intern("time_format"));		rb_gc_register_address(&time_format_sym);
    unicode_xss_sym = ID2SYM(rb_intern("unicode_xss"));		rb_gc_register_address(&unicode_xss_sym);
    unix_sym = ID2SYM(rb_intern("unix"));			rb_gc_register_address(&unix_sym);
    unix_zone_sym = ID2SYM(rb_intern("unix_zone"));		rb_gc_register_address(&unix_zone_sym);
    use_as_json_sym = ID2SYM(rb_intern("use_as_json"));		rb_gc_register_address(&use_as_json_sym);
    use_to_hash_sym = ID2SYM(rb_intern("use_to_hash"));		rb_gc_register_address(&use_to_hash_sym);
    use_to_json_sym = ID2SYM(rb_intern("use_to_json"));		rb_gc_register_address(&use_to_json_sym);
    wab_sym = ID2SYM(rb_intern("wab"));				rb_gc_register_address(&wab_sym);
    word_sym = ID2SYM(rb_intern("word"));			rb_gc_register_address(&word_sym);
    xmlschema_sym = ID2SYM(rb_intern("xmlschema"));		rb_gc_register_address(&xmlschema_sym);
    xss_safe_sym = ID2SYM(rb_intern("xss_safe"));		rb_gc_register_address(&xss_safe_sym);

    oj_slash_string = rb_str_new2("/");				rb_gc_register_address(&oj_slash_string);

    oj_default_options.mode = ObjectMode;

    oj_hash_init();
    oj_odd_init();
    oj_mimic_rails_init();

#if USE_PTHREAD_MUTEX
    pthread_mutex_init(&oj_cache_mutex, 0);
#elif USE_RB_MUTEX
    oj_cache_mutex = rb_mutex_new();
    rb_gc_register_address(&oj_cache_mutex);
#endif
    oj_init_doc();
}
