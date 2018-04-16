/* mimic_json.c
 * Copyright (c) 2012, 2017, Peter Ohler
 * All rights reserved.
 */

#include "oj.h"
#include "encode.h"
#include "dump.h"
#include "parse.h"

static VALUE	symbolize_names_sym;

extern const char	oj_json_class[];

VALUE	oj_array_nl_sym;
VALUE	oj_ascii_only_sym;
VALUE	oj_json_generator_error_class;
VALUE	oj_json_parser_error_class;
VALUE	oj_max_nesting_sym;
VALUE	oj_object_nl_sym;
VALUE	oj_space_before_sym;
VALUE	oj_space_sym;

static VALUE	state_class;

// mimic JSON documentation

/* Document-module: JSON::Ext
 * 
 * The Ext module is a placeholder in the mimic JSON module used for
 * compatibility only.
 */
/* Document-class: JSON::Ext::Parser
 * 
 * The JSON::Ext::Parser is a placeholder in the mimic JSON module used for
 * compatibility only.
 */
/* Document-class: JSON::Ext::Generator
 * 
 * The JSON::Ext::Generator is a placeholder in the mimic JSON module used for
 * compatibility only.
 */

/* Document-method: parser=
 * call-seq: parser=(parser)
 * 
 * Does nothing other than provide compatibility.
 * - *parser* [_Object_] ignored
 */
/* Document-method: generator=
 * call-seq: generator=(generator)
 * 
 * Does nothing other than provide compatibility.
 * - *generator* [_Object_] ignored
 */

VALUE
oj_get_json_err_class(const char *err_classname) {
    volatile VALUE	json_module;
    volatile VALUE	clas;
    volatile VALUE	json_error_class;

    if (rb_const_defined_at(rb_cObject, rb_intern("JSON"))) {
	json_module = rb_const_get_at(rb_cObject, rb_intern("JSON"));
    } else {
	json_module = rb_define_module("JSON");
    }
    if (rb_const_defined_at(json_module, rb_intern("JSONError"))) {
        json_error_class = rb_const_get(json_module, rb_intern("JSONError"));
    } else {
        json_error_class = rb_define_class_under(json_module, "JSONError", rb_eStandardError);
    }
    if (0 == strcmp(err_classname, "JSONError")) {
	clas = json_error_class;
    } else {
	if (rb_const_defined_at(json_module, rb_intern(err_classname))) {
	    clas = rb_const_get(json_module, rb_intern(err_classname));
	} else {
	    clas = rb_define_class_under(json_module, err_classname, json_error_class);
	}
    }
    return clas;
}

void
oj_parse_mimic_dump_options(VALUE ropts, Options copts) {
    VALUE	v;
    size_t	len;

    if (T_HASH != rb_type(ropts)) {
	if (rb_respond_to(ropts, oj_to_hash_id)) {
	    ropts = rb_funcall(ropts, oj_to_hash_id, 0);
	} else if (rb_respond_to(ropts, oj_to_h_id)) {
	    ropts = rb_funcall(ropts, oj_to_h_id, 0);
	} else if (Qnil == ropts) {
	    return;
	} else {
	    rb_raise(rb_eArgError, "options must be a hash.");
	}
    }
    v = rb_hash_lookup(ropts, oj_max_nesting_sym);
    if (Qtrue == v) {
	copts->dump_opts.max_depth = 100;
    } else if (Qfalse == v || Qnil == v) {
	copts->dump_opts.max_depth = MAX_DEPTH;
    } else if (T_FIXNUM == rb_type(v)) {
	copts->dump_opts.max_depth = NUM2INT(v);
	if (0 >= copts->dump_opts.max_depth) {
	    copts->dump_opts.max_depth = MAX_DEPTH;
	}
    }
    if (Qnil != (v = rb_hash_lookup(ropts, oj_allow_nan_sym))) {
	if (Qtrue == v) {
	    copts->dump_opts.nan_dump = WordNan;
	} else {
	    copts->dump_opts.nan_dump = RaiseNan;
	}
    }
    if (Qnil != (v = rb_hash_lookup(ropts, oj_indent_sym))) {
	rb_check_type(v, T_STRING);
	if (sizeof(copts->dump_opts.indent_str) <= (len = RSTRING_LEN(v))) {
	    rb_raise(rb_eArgError, "indent string is limited to %lu characters.", (unsigned long)sizeof(copts->dump_opts.indent_str));
	}
	strcpy(copts->dump_opts.indent_str, StringValuePtr(v));
	copts->dump_opts.indent_size = (uint8_t)len;
	copts->dump_opts.use = true;
    }
    if (Qnil != (v = rb_hash_lookup(ropts, oj_space_sym))) {
	rb_check_type(v, T_STRING);
	if (sizeof(copts->dump_opts.after_sep) <= (len = RSTRING_LEN(v))) {
	    rb_raise(rb_eArgError, "space string is limited to %lu characters.", (unsigned long)sizeof(copts->dump_opts.after_sep));
	}
	strcpy(copts->dump_opts.after_sep, StringValuePtr(v));
	copts->dump_opts.after_size = (uint8_t)len;
	copts->dump_opts.use = true;
    }
    if (Qnil != (v = rb_hash_lookup(ropts, oj_space_before_sym))) {
	rb_check_type(v, T_STRING);
	if (sizeof(copts->dump_opts.before_sep) <= (len = RSTRING_LEN(v))) {
	    rb_raise(rb_eArgError, "space_before string is limited to %lu characters.", (unsigned long)sizeof(copts->dump_opts.before_sep));
	}
	strcpy(copts->dump_opts.before_sep, StringValuePtr(v));
	copts->dump_opts.before_size = (uint8_t)len;
	copts->dump_opts.use = true;
    }
    if (Qnil != (v = rb_hash_lookup(ropts, oj_object_nl_sym))) {
	rb_check_type(v, T_STRING);
	if (sizeof(copts->dump_opts.hash_nl) <= (len = RSTRING_LEN(v))) {
	    rb_raise(rb_eArgError, "object_nl string is limited to %lu characters.", (unsigned long)sizeof(copts->dump_opts.hash_nl));
	}
	strcpy(copts->dump_opts.hash_nl, StringValuePtr(v));
	copts->dump_opts.hash_size = (uint8_t)len;
	copts->dump_opts.use = true;
    }
    if (Qnil != (v = rb_hash_lookup(ropts, oj_array_nl_sym))) {
	rb_check_type(v, T_STRING);
	if (sizeof(copts->dump_opts.array_nl) <= (len = RSTRING_LEN(v))) {
	    rb_raise(rb_eArgError, "array_nl string is limited to %lu characters.", (unsigned long)sizeof(copts->dump_opts.array_nl));
	}
	strcpy(copts->dump_opts.array_nl, StringValuePtr(v));
	copts->dump_opts.array_size = (uint8_t)len;
	copts->dump_opts.use = true;
    }
    if (Qnil != (v = rb_hash_lookup(ropts, oj_quirks_mode_sym))) {
	copts->quirks_mode = (Qtrue == v) ? Yes : No;
    }
    if (Qnil != (v = rb_hash_lookup(ropts, oj_ascii_only_sym))) {
	// generate seems to assume anything except nil and false are true.
	if (Qfalse == v) {
	    copts->escape_mode = JXEsc; // JSONEsc;
	} else {
	    copts->escape_mode = ASCIIEsc;
	}
    }
}

static int
mimic_limit_arg(VALUE a) {
    if (Qnil == a || T_FIXNUM != rb_type(a)) {
	return -1;
    }
    return NUM2INT(a);
}

/* Document-method: dump
 * call-seq: dump(obj, anIO=nil, limit=nil)
 * 
 * Encodes an object as a JSON String.
 * 
 * - *obj* [_Object_] object to convert to encode as JSON
 * - *anIO* [_IO_] an IO that allows writing
 * - *limit* [_Fixnum_] ignored
 *
 * Returns [_String_] a JSON string.
 */
static VALUE
mimic_dump(int argc, VALUE *argv, VALUE self) {
    char		buf[4096];
    struct _Out		out;
    struct _Options	copts = oj_default_options;
    VALUE		rstr;

    copts.str_rx.head = NULL;
    copts.str_rx.tail = NULL;
    out.buf = buf;
    out.end = buf + sizeof(buf) - 10;
    out.allocated = false;
    out.caller = CALLER_DUMP;
    copts.escape_mode = JXEsc;
    copts.mode = CompatMode;

    /* seems like this is not correct
    if (No == copts.nilnil && Qnil == *argv) {
	rb_raise(rb_eTypeError, "nil not allowed.");
    }
    */
    copts.dump_opts.max_depth = MAX_DEPTH; // when using dump there is no limit
    out.omit_nil = copts.dump_opts.omit_nil;
    if (2 <= argc) {
	int	limit;
	
	// The json gem take a more liberal approach to optional
	// arguments. Expected are (obj, anIO=nil, limit=nil) yet the io
	// argument can be left off completely and the 2nd argument is then
	// the limit.
	if (0 <= (limit = mimic_limit_arg(argv[1]))) {
	    copts.dump_opts.max_depth = limit;
	}
	if (3 <= argc && 0 <= (limit = mimic_limit_arg(argv[2]))) {
	    copts.dump_opts.max_depth = limit;
	}
    }
    oj_dump_obj_to_json(*argv, &copts, &out);
    if (0 == out.buf) {
	rb_raise(rb_eNoMemError, "Not enough memory.");
    }
    rstr = rb_str_new2(out.buf);
    rstr = oj_encode(rstr);
    if (2 <= argc && Qnil != argv[1] && rb_respond_to(argv[1], oj_write_id)) {
	VALUE	io = argv[1];
	VALUE	args[1];

	*args = rstr;
	rb_funcall2(io, oj_write_id, 1, args);
	rstr = io;
    }
    if (out.allocated) {
	xfree(out.buf);
    }
    return rstr;
}

// This is the signature for the hash_foreach callback also.
static int
mimic_walk(VALUE key, VALUE obj, VALUE proc) {
    switch (rb_type(obj)) {
    case T_HASH:
	rb_hash_foreach(obj, mimic_walk, proc);
	break;
    case T_ARRAY:
	{
	    size_t	cnt = RARRAY_LEN(obj);
	    size_t	i;

	    for (i = 0; i < cnt; i++) {
		mimic_walk(Qnil, rb_ary_entry(obj, i), proc);
	    }
	    break;
	}
    default:
	break;
    }
    if (Qnil == proc) {
	if (rb_block_given_p()) {
	    rb_yield(obj);
	}
    } else {
#if HAS_PROC_WITH_BLOCK
	VALUE	args[1];

	*args = obj;
	rb_proc_call_with_block(proc, 1, args, Qnil);
#else
	rb_raise(rb_eNotImpError, "Calling a Proc with a block not supported in this version. Use func() {|x| } syntax instead.");
#endif
    }
    return ST_CONTINUE;
}

/* Document-method: restore
 * call-seq: restore(source, proc=nil)
 * 
 * Loads a Ruby Object from a JSON source that can be either a String or an
 * IO. If Proc is given or a block is providedit is called with each nested
 * element of the loaded Object.
 * 
 * - *source* [_String_|IO] JSON source
 * - *proc* [_Proc_] to yield to on each element or nil
 *
 * Returns [_Object_] the decoded Object.
 */

/* Document-method: load
 * call-seq: load(source, proc=nil)
 * 
 * Loads a Ruby Object from a JSON source that can be either a String or an
 * IO. If Proc is given or a block is providedit is called with each nested
 * element of the loaded Object.
 * 
 * - *source* [_String_|IO] JSON source
 * - *proc* [_Proc_] to yield to on each element or nil
 *
 * Returns [_Object_] the decode Object.
 */
static VALUE
mimic_load(int argc, VALUE *argv, VALUE self) {
    VALUE	obj;
    VALUE	p = Qnil;

    obj = oj_compat_load(argc, argv, self);
    if (2 <= argc) {
	if (rb_cProc == rb_obj_class(argv[1])) {
	    p = argv[1];
	} else if (3 <= argc) {
	    if (rb_cProc == rb_obj_class(argv[2])) {
		p = argv[2];
	    }
	}
    }
    mimic_walk(Qnil, obj, p);

    return obj;
}

/* Document-method: []
 * call-seq: [](obj, opts={})
 * 
 * If the obj argument is a String then it is assumed to be a JSON String and
 * parsed otherwise the obj is encoded as a JSON String.
 * 
 * - *obj* [_String_|Hash|Array] object to convert
 * - *opts* [_Hash_] same options as either generate or parse
 *
 * Returns [_Object_]
 */
static VALUE
mimic_dump_load(int argc, VALUE *argv, VALUE self) {
    if (1 > argc) {
	rb_raise(rb_eArgError, "wrong number of arguments (0 for 1)");
    } else if (T_STRING == rb_type(*argv)) {
	return mimic_load(argc, argv, self);
    } else {
	return mimic_dump(argc, argv, self);
    }
    return Qnil;
}

static VALUE
mimic_generate_core(int argc, VALUE *argv, Options copts) {
    char	buf[4096];
    struct _Out	out;
    VALUE	rstr;

    out.buf = buf;
    out.end = buf + sizeof(buf) - 10;
    out.allocated = false;
    out.omit_nil = copts->dump_opts.omit_nil;
    out.caller = CALLER_GENERATE;
    // For obj.to_json or generate nan is not allowed but if called from dump
    // it is.
    copts->dump_opts.nan_dump = RaiseNan;
    copts->mode = CompatMode;
    if (2 == argc && Qnil != argv[1]) {
	oj_parse_mimic_dump_options(argv[1], copts);
    }
    /* seems like this is not correct
    if (No == copts->nilnil && Qnil == *argv) {
	rb_raise(rb_eTypeError, "nil not allowed.");
    }
    */
    oj_dump_obj_to_json_using_params(*argv, copts, &out, argc - 1, argv + 1);

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

/* Document-method: fast_generate
 * call-seq: fast_generate(obj, opts=nil)
 * Same as generate().
 * @see generate
 */

/* Document-method: generate
 * call-seq: generate(obj, opts=nil)
 * 
 * Encode obj as a JSON String. The obj argument must be a Hash, Array, or
 * respond to to_h or to_json. Options other than those listed such as
 * +:allow_nan+ or +:max_nesting+ are ignored.
 * 
 * - *obj* [_Object_|Hash|Array] object to convert to a JSON String
 * - *opts* [_Hash_] options
 * - - *:indent* [_String_] String to use for indentation.
 *   - *:space* [_String_] String placed after a , or : delimiter
 *   - *:space_before*  [_String_] String placed before a : delimiter
 *   - *:object_nl* [_String_] String placed after a JSON object
 *   - *:array_nl* [_String_] String placed after a JSON array
 *   - *:ascii_only* [_Boolean_] if not nil or false then use only ascii characters in the output. Note JSON.generate does support this even if it is not documented.
 *
 * Returns [_String_] generated JSON.
 */
VALUE
oj_mimic_generate(int argc, VALUE *argv, VALUE self) {
    struct _Options	copts = oj_default_options;

    copts.str_rx.head = NULL;
    copts.str_rx.tail = NULL;

    return mimic_generate_core(argc, argv, &copts);
}

/* Document-method: pretty_generate
 *	call-seq: pretty_generate(obj, opts=nil)
 *
 * Same as generate() but with different defaults for the spacing options.
 * @see generate
 *
 * Return [_String_] the generated JSON.
 */
VALUE
oj_mimic_pretty_generate(int argc, VALUE *argv, VALUE self) {
    struct _Options	copts = oj_default_options;
    VALUE		rargs[2];
    volatile VALUE	h;

    // Some (all?) json gem to_json methods need a State instance and not just
    // a Hash. I haven't dug deep enough to find out why but using a State
    // instance and not a Hash gives the desired behavior.
    *rargs = *argv;
    if (1 == argc) {
	h = rb_hash_new();
    } else {
	h = argv[1];
    }
    if (Qfalse == rb_funcall(h, oj_has_key_id, 1, oj_indent_sym)) {
	rb_hash_aset(h, oj_indent_sym, rb_str_new2("  "));
    }
    if (Qfalse == rb_funcall(h, oj_has_key_id, 1, oj_space_before_sym)) {
	rb_hash_aset(h, oj_space_before_sym, rb_str_new2(""));
    }
    if (Qfalse == rb_funcall(h, oj_has_key_id, 1, oj_space_sym)) {
	rb_hash_aset(h, oj_space_sym, rb_str_new2(" "));
    }
    if (Qfalse == rb_funcall(h, oj_has_key_id, 1, oj_object_nl_sym)) {
	rb_hash_aset(h, oj_object_nl_sym, rb_str_new2("\n"));
    }
    if (Qfalse == rb_funcall(h, oj_has_key_id, 1, oj_array_nl_sym)) {
	rb_hash_aset(h, oj_array_nl_sym, rb_str_new2("\n"));
    }
    rargs[1] = rb_funcall(state_class, oj_new_id, 1, h);
    
    copts.str_rx.head = NULL;
    copts.str_rx.tail = NULL;
    strcpy(copts.dump_opts.indent_str, "  ");
    copts.dump_opts.indent_size = (uint8_t)strlen(copts.dump_opts.indent_str);
    strcpy(copts.dump_opts.before_sep, "");
    copts.dump_opts.before_size = (uint8_t)strlen(copts.dump_opts.before_sep);
    strcpy(copts.dump_opts.after_sep, " ");
    copts.dump_opts.after_size = (uint8_t)strlen(copts.dump_opts.after_sep);
    strcpy(copts.dump_opts.hash_nl, "\n");
    copts.dump_opts.hash_size = (uint8_t)strlen(copts.dump_opts.hash_nl);
    strcpy(copts.dump_opts.array_nl, "\n");
    copts.dump_opts.array_size = (uint8_t)strlen(copts.dump_opts.array_nl);
    copts.dump_opts.use = true;

    return mimic_generate_core(2, rargs, &copts);
}

static VALUE
mimic_parse_core(int argc, VALUE *argv, VALUE self, bool bang) {
    struct _ParseInfo	pi;
    VALUE		ropts;
    VALUE		args[1];

    rb_scan_args(argc, argv, "11", NULL, &ropts);
    parse_info_init(&pi);
    oj_set_compat_callbacks(&pi);

    pi.err_class = oj_json_parser_error_class;
    //pi.err_class = Qnil;

    pi.options = oj_default_options;
    pi.options.auto_define = No;
    pi.options.quirks_mode = Yes;
    pi.options.allow_invalid = No;
    pi.options.empty_string = No;
    pi.options.create_ok = No;
    pi.options.allow_nan = (bang ? Yes : No);
    pi.options.nilnil = No;
    pi.options.bigdec_load = FloatDec;
    pi.options.mode = CompatMode;
    pi.max_depth = 100;

    if (Qnil != ropts) {
	VALUE	v;

	if (T_HASH != rb_type(ropts)) {
	    rb_raise(rb_eArgError, "options must be a hash.");
	}
	if (Qnil != (v = rb_hash_lookup(ropts, symbolize_names_sym))) {
	    pi.options.sym_key = (Qtrue == v) ? Yes : No;
	}
	if (Qnil != (v = rb_hash_lookup(ropts, oj_quirks_mode_sym))) {
	    pi.options.quirks_mode = (Qtrue == v) ? Yes : No;
	}
	if (Qnil != (v = rb_hash_lookup(ropts, oj_create_additions_sym))) {
	    pi.options.create_ok = (Qtrue == v) ? Yes : No;
	}
	if (Qnil != (v = rb_hash_lookup(ropts, oj_allow_nan_sym))) {
	    pi.options.allow_nan = (Qtrue == v) ? Yes : No;
	}

	if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, oj_hash_class_sym)) {
	    if (Qnil == (v = rb_hash_lookup(ropts, oj_hash_class_sym))) {
		pi.options.hash_class = Qnil;
	    } else {
		rb_check_type(v, T_CLASS);
		pi.options.hash_class = v;
	    }
	}
	if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, oj_object_class_sym)) {
	    if (Qnil == (v = rb_hash_lookup(ropts, oj_object_class_sym))) {
		pi.options.hash_class = Qnil;
	    } else {
		rb_check_type(v, T_CLASS);
		pi.options.hash_class = v;
	    }
	}
	if (Qtrue == rb_funcall(ropts, oj_has_key_id, 1, oj_array_class_sym)) {
	    if (Qnil == (v = rb_hash_lookup(ropts, oj_array_class_sym))) {
		pi.options.array_class = Qnil;
	    } else {
		rb_check_type(v, T_CLASS);
		pi.options.array_class = v;
	    }
	}
	v = rb_hash_lookup(ropts, oj_max_nesting_sym);
	if (Qtrue == v) {
	    pi.max_depth = 100;
	} else if (Qfalse == v || Qnil == v) {
	    pi.max_depth = 0;
	} else if (T_FIXNUM == rb_type(v)) {
	    pi.max_depth = NUM2INT(v);
	}
	oj_parse_opt_match_string(&pi.options.str_rx, ropts);
	if (Yes == pi.options.create_ok && Yes == pi.options.sym_key) {
	    rb_raise(rb_eArgError, ":symbolize_names and :create_additions can not both be true.");
	}
    }
    *args = *argv;

    if (T_STRING == rb_type(*args)) {
	return oj_pi_parse(1, args, &pi, 0, 0, false);
    } else {
	return oj_pi_sparse(1, args, &pi, 0);
    }
}

/* Document-method: parse
 * call-seq: parse(source, opts=nil)
 *
 * Parses a JSON String or IO into a Ruby Object.  Options other than those
 * listed such as +:allow_nan+ or +:max_nesting+ are ignored. +:object_class+ and
 * +:array_object+ are not supported.
 *
 * - *source* [_String_|IO] source to parse
 * - *opts* [_Hash_] options
 *   - *:symbolize* [Boolean] _names flag indicating JSON object keys should be Symbols instead of Strings
 *   - *:create_additions* [Boolean] flag indicating a key matching +create_id+ in a JSON object should trigger the creation of Ruby Object
 *
 * Returns [Object]
 * @see create_id=
 */
VALUE
oj_mimic_parse(int argc, VALUE *argv, VALUE self) {
    return mimic_parse_core(argc, argv, self, false);
}

/* Document-method: parse!
 * call-seq: parse!(source, opts=nil)
 *
 * Same as parse().
 * @see parse
 */
static VALUE
mimic_parse_bang(int argc, VALUE *argv, VALUE self) {
    return mimic_parse_core(argc, argv, self, true);
}

/* Document-method: recurse_proc
 * call-seq: recurse_proc(obj, &proc)
 * 
 * Yields to the proc for every element in the obj recursively.
 * 
 * - *obj* [_Hash_|Array] object to walk
 * - *proc* [_Proc_] to yield to on each element
 */
static VALUE
mimic_recurse_proc(VALUE self, VALUE obj) {
    rb_need_block();
    mimic_walk(Qnil, obj, Qnil);

    return Qnil;
}

/* Document-method: create_id=
 * call-seq: create_id=(id)
 *
 * Sets the create_id tag to look for in JSON document. That key triggers the
 * creation of a class with the same name.
 *
 * - *id* [_nil_|String] new create_id
 *
 * Returns [_String_] the id.
 */
static VALUE
mimic_set_create_id(VALUE self, VALUE id) {
    Check_Type(id, T_STRING);

    if (NULL != oj_default_options.create_id) {
	if (oj_json_class != oj_default_options.create_id && NULL != oj_default_options.create_id) {
	    xfree((char*)oj_default_options.create_id);
	}
	oj_default_options.create_id = NULL;
	oj_default_options.create_id_len = 0;
    }
    if (Qnil != id) {
	size_t	len = RSTRING_LEN(id) + 1;

	oj_default_options.create_id = ALLOC_N(char, len);
	strcpy((char*)oj_default_options.create_id, StringValuePtr(id));
	oj_default_options.create_id_len = len - 1;
    }
    return id;
}

/* Document-method: create_id
 * call-seq: create_id()
 *
 * Returns [_String_] the create_id.
 */
static VALUE
mimic_create_id(VALUE self) {
    if (NULL != oj_default_options.create_id) {
	return oj_encode(rb_str_new_cstr(oj_default_options.create_id));
    }
    return rb_str_new_cstr(oj_json_class);
}

static struct _Options	mimic_object_to_json_options = {
    0,		// indent
    No,		// circular
    No,		// auto_define
    No,		// sym_key
    JXEsc,	// escape_mode
    CompatMode,	// mode
    No,		// class_cache
    RubyTime,	// time_format
    No,		// bigdec_as_num
    FloatDec,	// bigdec_load
    No,		// to_hash
    No,		// to_json
    No,		// as_json
    No,		// nilnil
    No,		// empty_string
    Yes,	// allow_gc
    Yes,	// quirks_mode
    No,		// allow_invalid
    No,		// create_ok
    No,		// allow_nan
    No,		// trace
    oj_json_class,// create_id
    10,		// create_id_len
    3,		// sec_prec
    16,		// float_prec
    "%0.16g",	// float_fmt
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
	RaiseNan,// nan_dump
	false,	// omit_nil
	100, // max_depth
    },
    {		// str_rx
	NULL,	// head
	NULL,	// tail
	{ '\0' }, // err
    }
};

static VALUE
mimic_object_to_json(int argc, VALUE *argv, VALUE self) {
    char		buf[4096];
    struct _Out		out;
    VALUE		rstr;
    struct _Options	copts = oj_default_options;

    copts.str_rx.head = NULL;
    copts.str_rx.tail = NULL;
    out.buf = buf;
    out.end = buf + sizeof(buf) - 10;
    out.allocated = false;
    out.omit_nil = copts.dump_opts.omit_nil;
    copts.mode = CompatMode;
    copts.to_json = No;
    if (1 <= argc && Qnil != argv[0]) {
	oj_parse_mimic_dump_options(argv[0], &copts);
    }
    // To be strict the mimic_object_to_json_options should be used but people
    // seem to prefer the option of changing that.
    //oj_dump_obj_to_json(self, &mimic_object_to_json_options, &out);
    oj_dump_obj_to_json_using_params(self, &copts, &out, argc, argv);
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

/* Document-method: state
 *	call-seq: state()
 *
 * Returns [_JSON::State_] the JSON::State class.
 */
static VALUE
mimic_state(VALUE self) {
    return state_class;
}

void
oj_mimic_json_methods(VALUE json) {
    VALUE	json_error;
    VALUE	generator;
    VALUE	ext;

    rb_define_module_function(json, "create_id=", mimic_set_create_id, 1);
    rb_define_module_function(json, "create_id", mimic_create_id, 0);

    rb_define_module_function(json, "dump", mimic_dump, -1);
    rb_define_module_function(json, "load", mimic_load, -1);
    rb_define_module_function(json, "restore", mimic_load, -1);
    rb_define_module_function(json, "recurse_proc", mimic_recurse_proc, 1);
    rb_define_module_function(json, "[]", mimic_dump_load, -1);

    rb_define_module_function(json, "generate", oj_mimic_generate, -1);
    rb_define_module_function(json, "fast_generate", oj_mimic_generate, -1);
    rb_define_module_function(json, "pretty_generate", oj_mimic_pretty_generate, -1);
    // For older versions of JSON, the deprecated unparse methods.
    rb_define_module_function(json, "unparse", oj_mimic_generate, -1);
    rb_define_module_function(json, "fast_unparse", oj_mimic_generate, -1);
    rb_define_module_function(json, "pretty_unparse", oj_mimic_pretty_generate, -1);

    rb_define_module_function(json, "parse", oj_mimic_parse, -1);
    rb_define_module_function(json, "parse!", mimic_parse_bang, -1);

    rb_define_module_function(json, "state", mimic_state, 0);

    if (rb_const_defined_at(json, rb_intern("JSONError"))) {
        json_error = rb_const_get(json, rb_intern("JSONError"));
    } else {
        json_error = rb_define_class_under(json, "JSONError", rb_eStandardError);
    }
    if (rb_const_defined_at(json, rb_intern("ParserError"))) {
        oj_json_parser_error_class = rb_const_get(json, rb_intern("ParserError"));
    } else {
    	oj_json_parser_error_class = rb_define_class_under(json, "ParserError", json_error);
    }
    if (rb_const_defined_at(json, rb_intern("GeneratorError"))) {
        oj_json_generator_error_class = rb_const_get(json, rb_intern("GeneratorError"));
    } else {
    	oj_json_generator_error_class = rb_define_class_under(json, "GeneratorError", json_error);
    }
    if (rb_const_defined_at(json, rb_intern("NestingError"))) {
        rb_const_get(json, rb_intern("NestingError"));
    } else {
    	rb_define_class_under(json, "NestingError", json_error);
    }

    if (rb_const_defined_at(json, rb_intern("Ext"))) {
	ext = rb_const_get_at(json, rb_intern("Ext"));
     } else {
	ext = rb_define_module_under(json, "Ext");
    }
    if (rb_const_defined_at(ext, rb_intern("Generator"))) {
	generator = rb_const_get_at(ext, rb_intern("Generator"));
     } else {
	generator = rb_define_module_under(ext, "Generator");
    }
    if (!rb_const_defined_at(generator, rb_intern("State"))) {
	rb_require("oj/state");
    }
    // Pull in the JSON::State mimic file.
    state_class = rb_const_get_at(generator, rb_intern("State"));

    symbolize_names_sym = ID2SYM(rb_intern("symbolize_names"));	rb_gc_register_address(&symbolize_names_sym);
}

/* Document-module: JSON
 *
 * A mimic of the json gem module.
 */
VALUE
oj_define_mimic_json(int argc, VALUE *argv, VALUE self) {
    VALUE	dummy;
    VALUE	verbose;
    VALUE	json;
    
    // Either set the paths to indicate JSON has been loaded or replaces the
    // methods if it has been loaded.
    if (rb_const_defined_at(rb_cObject, rb_intern("JSON"))) {
	json = rb_const_get_at(rb_cObject, rb_intern("JSON"));
    } else {
	json = rb_define_module("JSON");
    }
    verbose = rb_gv_get("$VERBOSE");
    rb_gv_set("$VERBOSE", Qfalse);
    rb_define_module_function(rb_cObject, "JSON", mimic_dump_load, -1);
    dummy = rb_gv_get("$LOADED_FEATURES");
    if (rb_type(dummy) == T_ARRAY) {
	rb_ary_push(dummy, rb_str_new2("json"));
	if (0 < argc) {
	    VALUE	mimic_args[1];

	    *mimic_args = *argv;
	    rb_funcall2(Oj, rb_intern("mimic_loaded"), 1, mimic_args);
	} else {
	    rb_funcall2(Oj, rb_intern("mimic_loaded"), 0, 0);
	}
    }

    // TBD create all modules in mimic_loaded

    oj_mimic_json_methods(json);

    rb_define_method(rb_cObject, "to_json", mimic_object_to_json, -1);

    rb_gv_set("$VERBOSE", verbose);

    oj_default_options = mimic_object_to_json_options;
    oj_default_options.to_json = Yes;

    return json;
}
