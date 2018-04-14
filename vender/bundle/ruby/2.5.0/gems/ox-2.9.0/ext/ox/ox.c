/* ox.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <stdlib.h>
#include <errno.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "ruby.h"
#include "ox.h"
#include "sax.h"

/* maximum to allocate on the stack, arbitrary limit */
#define SMALL_XML		4096
#define WITH_CACHE_TESTS	0

typedef struct _YesNoOpt {
    VALUE	sym;
    char	*attr;
} *YesNoOpt;

void Init_ox();

VALUE	 Ox = Qnil;

ID	ox_abort_id;
ID	ox_at_column_id;
ID	ox_at_content_id;
ID	ox_at_id;
ID	ox_at_line_id;
ID	ox_at_pos_id;
ID	ox_at_value_id;
ID	ox_attr_id;
ID	ox_attr_value_id;
ID	ox_attributes_id;
ID	ox_attrs_done_id;
ID	ox_beg_id;
ID	ox_cdata_id;
ID	ox_comment_id;
ID	ox_den_id;
ID	ox_doctype_id;
ID	ox_end_element_id;
ID	ox_end_id;
ID	ox_end_instruct_id;
ID	ox_error_id;
ID	ox_excl_id;
ID	ox_external_encoding_id;
ID	ox_fileno_id;
ID	ox_force_encoding_id;
ID	ox_inspect_id;
ID	ox_instruct_id;
ID	ox_jd_id;
ID	ox_keys_id;
ID	ox_local_id;
ID	ox_mesg_id;
ID	ox_message_id;
ID	ox_new_id;
ID	ox_nodes_id;
ID	ox_num_id;
ID	ox_parse_id;
ID	ox_pos_id;
ID	ox_read_id;
ID	ox_readpartial_id;
ID	ox_start_element_id;
ID	ox_string_id;
ID	ox_text_id;
ID	ox_to_c_id;
ID	ox_to_s_id;
ID	ox_to_sym_id;
ID	ox_tv_nsec_id;
ID	ox_tv_sec_id;
ID	ox_tv_usec_id;
ID	ox_value_id;

VALUE	ox_encoding_sym;
VALUE	ox_version_sym;
VALUE	ox_standalone_sym;
VALUE	ox_indent_sym;
VALUE	ox_size_sym;

VALUE	ox_empty_string;
VALUE	ox_zero_fixnum;
VALUE	ox_sym_bank; // Array

VALUE	ox_arg_error_class;
VALUE	ox_bag_clas;
VALUE	ox_bigdecimal_class;
VALUE	ox_cdata_clas;
VALUE	ox_comment_clas;
VALUE	ox_raw_clas;
VALUE	ox_date_class;
VALUE	ox_doctype_clas;
VALUE	ox_document_clas;
VALUE	ox_element_clas;
VALUE	ox_instruct_clas;
VALUE	ox_parse_error_class;
VALUE	ox_stringio_class;
VALUE	ox_struct_class;
VALUE	ox_time_class;

Cache	ox_symbol_cache = 0;
Cache	ox_class_cache = 0;
Cache	ox_attr_cache = 0;

static VALUE	abort_sym;
static VALUE	active_sym;
static VALUE	auto_define_sym;
static VALUE	auto_sym;
static VALUE	block_sym;
static VALUE	circular_sym;
static VALUE	convert_special_sym;
static VALUE	effort_sym;
static VALUE	generic_sym;
static VALUE	hash_no_attrs_sym;
static VALUE	hash_sym;
static VALUE	inactive_sym;
static VALUE	invalid_replace_sym;
static VALUE	limited_sym;
static VALUE	margin_sym;
static VALUE	mode_sym;
static VALUE	nest_ok_sym;
static VALUE	object_sym;
static VALUE	off_sym;
static VALUE	opt_format_sym;
static VALUE	optimized_sym;
static VALUE	overlay_sym;
static VALUE	skip_none_sym;
static VALUE	skip_off_sym;
static VALUE	skip_return_sym;
static VALUE	skip_sym;
static VALUE	skip_white_sym;
static VALUE	smart_sym;
static VALUE	strict_sym;
static VALUE	strip_namespace_sym;
static VALUE	symbolize_keys_sym;
static VALUE	symbolize_sym;
static VALUE	tolerant_sym;
static VALUE	trace_sym;
static VALUE	with_dtd_sym;
static VALUE	with_instruct_sym;
static VALUE	with_xml_sym;
static VALUE	xsd_date_sym;

static ID	encoding_id;
static ID	has_key_id;

#if HAS_ENCODING_SUPPORT
rb_encoding	*ox_utf8_encoding = 0;
#elif HAS_PRIVATE_ENCODING
VALUE		ox_utf8_encoding = Qnil;
#else
void		*ox_utf8_encoding = 0;
#endif

struct _Options	 ox_default_options = {
    { '\0' },		/* encoding */
    { '\0' },		/* margin */
    2,			/* indent */
    0,			/* trace */
    0,			/* margin_len */
    No,			/* with_dtd */
    No,			/* with_xml */
    No,			/* with_instruct */
    No,			/* circular */
    No,			/* xsd_date */
    NoMode,		/* mode */
    StrictEffort,	/* effort */
    Yes,		/* sym_keys */
    SpcSkip,		/* skip */
    No,			/* smart */
    1,			/* convert_special */
    No,			/* allow_invalid */
    { '\0' },		/* inv_repl */
    { '\0' },		/* strip_ns */
    NULL,		/* html_hints */
#if HAS_PRIVATE_ENCODING
    Qnil		/* rb_enc */
#else
    0			/* rb_enc */
#endif
};

extern ParseCallbacks	ox_obj_callbacks;
extern ParseCallbacks	ox_gen_callbacks;
extern ParseCallbacks	ox_limited_callbacks;
extern ParseCallbacks	ox_nomode_callbacks;
extern ParseCallbacks	ox_hash_callbacks;
extern ParseCallbacks	ox_hash_no_attrs_callbacks;

static void	parse_dump_options(VALUE ropts, Options copts);

static char*
defuse_bom(char *xml, Options options) {
    switch ((uint8_t)*xml) {
    case 0xEF: /* UTF-8 */
	if (0xBB == (uint8_t)xml[1] && 0xBF == (uint8_t)xml[2]) {
	    options->rb_enc = ox_utf8_encoding;
	    xml += 3;
	} else {
	    rb_raise(ox_parse_error_class, "Invalid BOM in XML string.\n");
	}
	break;
#if 0
    case 0xFE: /* UTF-16BE */
	if (0xFF == (uint8_t)xml[1]) {
	    options->rb_enc = ox_utf16be_encoding;
	    xml += 2;
	} else {
	    rb_raise(ox_parse_error_class, "Invalid BOM in XML string.\n");
	}
	break;
    case 0xFF: /* UTF-16LE or UTF-32LE */
	if (0xFE == (uint8_t)xml[1]) {
	    if (0x00 == (uint8_t)xml[2] && 0x00 == (uint8_t)xml[3]) {
		options->rb_enc = ox_utf32le_encoding;
		xml += 4;
	    } else {
		options->rb_enc = ox_utf16le_encoding;
		xml += 2;
	    }
	} else {
	    rb_raise(ox_parse_error_class, "Invalid BOM in XML string.\n");
	}
	break;
    case 0x00: /* UTF-32BE */
	if (0x00 == (uint8_t)xml[1] && 0xFE == (uint8_t)xml[2] && 0xFF == (uint8_t)xml[3]) {
	    options->rb_enc = ox_utf32be_encoding;
	    xml += 4;
	} else {
	    rb_raise(ox_parse_error_class, "Invalid BOM in XML string.\n");
	}
	break;
#endif
    default:
	/* Let it fail if there is a BOM that is not UTF-8. Other BOM options are not ASCII compatible. */
	break;
    }
    return xml;
}

static VALUE
hints_to_overlay(Hints hints) {
    volatile VALUE	overlay = rb_hash_new();
    Hint		h;
    int			i;
    VALUE		ov;
    
    for (i = hints->size, h = hints->hints; 0 < i; i--, h++) {
	switch (h->overlay) {
	case InactiveOverlay:	ov = inactive_sym;	break;
	case BlockOverlay:	ov = block_sym;		break;
	case OffOverlay:	ov = off_sym;		break;
	case AbortOverlay:	ov = abort_sym;		break;
	case NestOverlay:	ov = nest_ok_sym;	break;
	case ActiveOverlay:
	default:		ov = active_sym;	break;
	}
	rb_hash_aset(overlay, rb_str_new2(h->name), ov);
    }    
    return overlay;
}

/* call-seq: default_options() => Hash
 *
 * Returns the default load and dump options as a Hash. The options are
 * - _:margin_ [String] left margin to inset when dumping
 * - _:indent_ [Fixnum] number of spaces to indent each element in an XML document
 * - _:trace_ [Fixnum] trace level where 0 is silent
 * - _:encoding_ [String] character encoding for the XML file
 * - _:with_dtd_ [true|false|nil] include DTD in the dump
 * - _:with_instruct_ [true|false|nil] include instructions in the dump
 * - _:with_xml_ [true|false|nil] include XML prolog in the dump
 * - _:circular_ [true|false|nil] support circular references while dumping
 * - _:xsd_date_ [true|false|nil] use XSD date format instead of decimal format
 * - _:mode_ [:object|:generic|:limited|:hash|:hash_no_attrs|nil] load method to use for XML
 * - _:effort_ [:strict|:tolerant|:auto_define] set the tolerance level for loading
 * - _:symbolize_keys_ [true|false|nil] symbolize element attribute keys or leave as Strings
 * - _:skip_ [:skip_none|:skip_return|:skip_white|:skip_off] determines how to handle white space in text
 * - _:smart_ [true|false|nil] flag indicating the SAX parser uses hints if available (use with html)
 * - _:convert_special_ [true|false|nil] flag indicating special characters like &lt; are converted with the SAX parser
 * - _:invalid_replace_ [nil|String] replacement string for invalid XML characters on dump. nil indicates include anyway as hex. A string, limited to 10 characters will replace the invalid character with the replace.
 * - _:strip_namespace_ [String|true|false] false or "" results in no namespace stripping. A string of "*" or true will strip all namespaces. Any other non-empty string indicates that matching namespaces will be stripped.
 * - _:overlay_ [Hash] a Hash of keys that match html element names and values that are one of
 *   - _:active_ - make the normal callback for the element
 *   - _:nest_ok_ - active but the nesting check is ignored
 *   - _:inactive_ - do not make the element start, end, or attribute callbacks for this element only
 *   - _:block_ - block this and all children callbacks
 *   - _:off_ - block this element and it's children unless the child element is active
 *   - _:abort_ - abort the html processing and return
 * 
 * *return* [Hash] all current option settings.
 *
 * Note that an indent of less than zero will result in a tight one line output
 * unless the text in the XML fields contain new line characters.
 */
static VALUE
get_def_opts(VALUE self) {
    VALUE	opts = rb_hash_new();
    int		elen = (int)strlen(ox_default_options.encoding);

    rb_hash_aset(opts, ox_encoding_sym, (0 == elen) ? Qnil : rb_str_new(ox_default_options.encoding, elen));
    rb_hash_aset(opts, margin_sym, rb_str_new(ox_default_options.margin, ox_default_options.margin_len));
    rb_hash_aset(opts, ox_indent_sym, INT2FIX(ox_default_options.indent));
    rb_hash_aset(opts, trace_sym, INT2FIX(ox_default_options.trace));
    rb_hash_aset(opts, with_dtd_sym, (Yes == ox_default_options.with_dtd) ? Qtrue : ((No == ox_default_options.with_dtd) ? Qfalse : Qnil));
    rb_hash_aset(opts, with_xml_sym, (Yes == ox_default_options.with_xml) ? Qtrue : ((No == ox_default_options.with_xml) ? Qfalse : Qnil));
    rb_hash_aset(opts, with_instruct_sym, (Yes == ox_default_options.with_instruct) ? Qtrue : ((No == ox_default_options.with_instruct) ? Qfalse : Qnil));
    rb_hash_aset(opts, circular_sym, (Yes == ox_default_options.circular) ? Qtrue : ((No == ox_default_options.circular) ? Qfalse : Qnil));
    rb_hash_aset(opts, xsd_date_sym, (Yes == ox_default_options.xsd_date) ? Qtrue : ((No == ox_default_options.xsd_date) ? Qfalse : Qnil));
    rb_hash_aset(opts, symbolize_keys_sym, (Yes == ox_default_options.sym_keys) ? Qtrue : ((No == ox_default_options.sym_keys) ? Qfalse : Qnil));
    rb_hash_aset(opts, smart_sym, (Yes == ox_default_options.smart) ? Qtrue : ((No == ox_default_options.smart) ? Qfalse : Qnil));
    rb_hash_aset(opts, convert_special_sym, (ox_default_options.convert_special) ? Qtrue : Qfalse);
    switch (ox_default_options.mode) {
    case ObjMode:		rb_hash_aset(opts, mode_sym, object_sym);		break;
    case GenMode:		rb_hash_aset(opts, mode_sym, generic_sym);		break;
    case LimMode:		rb_hash_aset(opts, mode_sym, limited_sym);		break;
    case HashMode:		rb_hash_aset(opts, mode_sym, hash_sym);			break;
    case HashNoAttrMode:	rb_hash_aset(opts, mode_sym, hash_no_attrs_sym);	break;
    case NoMode:
    default:			rb_hash_aset(opts, mode_sym, Qnil);			break;
    }
    switch (ox_default_options.effort) {
    case StrictEffort:		rb_hash_aset(opts, effort_sym, strict_sym);		break;
    case TolerantEffort:	rb_hash_aset(opts, effort_sym, tolerant_sym);		break;
    case AutoEffort:		rb_hash_aset(opts, effort_sym, auto_define_sym);	break;
    case NoEffort:
    default:			rb_hash_aset(opts, effort_sym, Qnil);			break;
    }
    switch (ox_default_options.skip) {
    case OffSkip:		rb_hash_aset(opts, skip_sym, skip_off_sym);		break;
    case NoSkip:		rb_hash_aset(opts, skip_sym, skip_none_sym);		break;
    case CrSkip:		rb_hash_aset(opts, skip_sym, skip_return_sym);		break;
    case SpcSkip:		rb_hash_aset(opts, skip_sym, skip_white_sym);		break;
    default:			rb_hash_aset(opts, skip_sym, Qnil);			break;
    }
    if (Yes == ox_default_options.allow_invalid) {
	rb_hash_aset(opts, invalid_replace_sym, Qnil);
    } else {
	rb_hash_aset(opts, invalid_replace_sym, rb_str_new(ox_default_options.inv_repl + 1, (int)*ox_default_options.inv_repl));
    }
    if ('\0' == *ox_default_options.strip_ns) {
	rb_hash_aset(opts, strip_namespace_sym, Qfalse);
    } else if ('*' == *ox_default_options.strip_ns && '\0' == ox_default_options.strip_ns[1]) {
	rb_hash_aset(opts, strip_namespace_sym, Qtrue);
    } else {
	rb_hash_aset(opts, strip_namespace_sym, rb_str_new(ox_default_options.strip_ns, strlen(ox_default_options.strip_ns)));
    }
    if (NULL == ox_default_options.html_hints) {
	//rb_hash_aset(opts, overlay_sym, hints_to_overlay(ox_hints_html()));
	rb_hash_aset(opts, overlay_sym, Qnil);
    } else {
	rb_hash_aset(opts, overlay_sym, hints_to_overlay(ox_default_options.html_hints));
    }
    return opts;
}

static int
set_overlay(VALUE key, VALUE value, VALUE ctx) {
    Hints	hints = (Hints)ctx;
    Hint	hint;
    
    if (NULL != (hint = ox_hint_find(hints, StringValuePtr(key)))) {
	if (active_sym == value) {
	    hint->overlay = ActiveOverlay;
	} else if (inactive_sym == value) {
	    hint->overlay = InactiveOverlay;
	} else if (block_sym == value) {
	    hint->overlay = BlockOverlay;
	} else if (nest_ok_sym == value) {
	    hint->overlay = NestOverlay;
	} else if (off_sym == value) {
	    hint->overlay = OffOverlay;
	} else if (abort_sym == value) {
	    hint->overlay = AbortOverlay;
	}
    }
    return ST_CONTINUE;
}

/* call-seq: sax_html_overlay() => Hash
 *
 * Returns an overlay hash that can be modified and used as an overlay in the
 * default options or in the sax_html() function call. Values for the keys are:
 *   - _:active_ - make the normal callback for the element
 *   - _:nest_ok_ - active but ignore nest check
 *   - _:inactive_ - do not make the element start, end, or attribute callbacks for this element only
 *   - _:block_ - block this and all children callbacks
 *   - _:off_ - block this element and it's children unless the child element is active
 *   - _:abort_ - abort the html processing and return
 *
 * *return* [Hash] default SAX HTML settings
 */
static VALUE
sax_html_overlay(VALUE self) {
    return hints_to_overlay(ox_hints_html());
}

/* call-seq: default_options=(opts)
 *
 * Sets the default options for load and dump.
 * - +opts+ [Hash] opts options to change
 *   - _:margin_ [String] left margin to inset when dumping
 *   - _:indent_ [Fixnum] number of spaces to indent each element in an XML document
 *   - _:trace_ [Fixnum] trace level where 0 is silent
 *   - _:encoding_ [String] character encoding for the XML file
 *   - _:with_dtd_ [true|false|nil] include DTD in the dump
 *   - _:with_instruct_ [true|false|nil] include instructions in the dump
 *   - _:with_xml_ [true|false|nil] include XML prolog in the dump
 *   - _:circular_ [true|false|nil] support circular references while dumping
 *   - _:xsd_date_ [true|false|nil] use XSD date format instead of decimal format
 *   - _:mode_ [:object|:generic|:limited|:hash|:hash_no_attrs|nil] load method to use for XML
 *   - _:effort_ [:strict|:tolerant|:auto_define] set the tolerance level for loading
 *   - _:symbolize_keys_ [true|false|nil] symbolize element attribute keys or leave as Strings
 *   - _:skip_ [:skip_none|:skip_return|:skip_white|:skip_off] determines how to handle white space in text
 *   - _:smart_ [true|false|nil] flag indicating the SAX parser uses hints if available (use with html)
 *   - _:invalid_replace_ [nil|String] replacement string for invalid XML characters on dump. nil indicates include anyway as hex. A string, limited to 10 characters will replace the invalid character with the replace.
 *   - _:strip_namespace_ [nil|String|true|false] "" or false result in no namespace stripping. A string of "*" or true will strip all namespaces. Any other non-empty string indicates that matching namespaces will be stripped.
 * - _:overlay_ [Hash] a Hash of keys that match html element names and values that are one of
 *   - _:active_ - make the normal callback for the element
 *   - _:nest_ok_ - active but ignore nest check
 *   - _:inactive_ - do not make the element start, end, or attribute callbacks for this element only
 *   - _:block_ - block this and all children callbacks
 *   - _:off_ - block this element and it's children unless the child element is active
 *   - _:abort_ - abort the html processing and return
 *
 * *return* [nil]
 */
static VALUE
set_def_opts(VALUE self, VALUE opts) {
    struct _YesNoOpt	ynos[] = {
	{ with_xml_sym, &ox_default_options.with_xml },
	{ with_dtd_sym, &ox_default_options.with_dtd },
	{ with_instruct_sym, &ox_default_options.with_instruct },
	{ xsd_date_sym, &ox_default_options.xsd_date },
	{ circular_sym, &ox_default_options.circular },
	{ symbolize_keys_sym, &ox_default_options.sym_keys },
	{ smart_sym, &ox_default_options.smart },
	{ Qnil, 0 }
    };
    YesNoOpt	o;
    VALUE	v;
    
    Check_Type(opts, T_HASH);

    v = rb_hash_aref(opts, ox_encoding_sym);
    if (Qnil == v) {
	*ox_default_options.encoding = '\0';
    } else {
	Check_Type(v, T_STRING);
	strncpy(ox_default_options.encoding, StringValuePtr(v), sizeof(ox_default_options.encoding) - 1);
#if HAS_ENCODING_SUPPORT
	ox_default_options.rb_enc = rb_enc_find(ox_default_options.encoding);
#elif HAS_PRIVATE_ENCODING
	ox_default_options.rb_enc = rb_str_new2(ox_default_options.encoding);
	rb_gc_register_address(&ox_default_options.rb_enc);
#endif
    }

    v = rb_hash_aref(opts, ox_indent_sym);
    if (Qnil != v) {
	Check_Type(v, T_FIXNUM);
	ox_default_options.indent = FIX2INT(v);
    }

    v = rb_hash_aref(opts, trace_sym);
    if (Qnil != v) {
	Check_Type(v, T_FIXNUM);
	ox_default_options.trace = FIX2INT(v);
    }

    v = rb_hash_aref(opts, mode_sym);
    if (Qnil == v) {
	ox_default_options.mode = NoMode;
    } else if (object_sym == v) {
	ox_default_options.mode = ObjMode;
    } else if (generic_sym == v) {
	ox_default_options.mode = GenMode;
    } else if (limited_sym == v) {
	ox_default_options.mode = LimMode;
    } else if (hash_sym == v) {
	ox_default_options.mode = HashMode;
    } else if (hash_no_attrs_sym == v) {
	ox_default_options.mode = HashNoAttrMode;
    } else {
	rb_raise(ox_parse_error_class, ":mode must be :object, :generic, :limited, :hash, :hash_no_attrs, or nil.\n");
    }

    v = rb_hash_aref(opts, effort_sym);
    if (Qnil == v) {
	ox_default_options.effort = NoEffort;
    } else if (strict_sym == v) {
	ox_default_options.effort = StrictEffort;
    } else if (tolerant_sym == v) {
	ox_default_options.effort = TolerantEffort;
    } else if (auto_define_sym == v) {
	ox_default_options.effort = AutoEffort;
    } else {
	rb_raise(ox_parse_error_class, ":effort must be :strict, :tolerant, :auto_define, or nil.\n");
    }

    v = rb_hash_aref(opts, skip_sym);
    if (Qnil == v) {
	ox_default_options.skip = NoSkip;
    } else if (skip_off_sym == v) {
	ox_default_options.skip = OffSkip;
    } else if (skip_none_sym == v) {
	ox_default_options.skip = NoSkip;
    } else if (skip_return_sym == v) {
	ox_default_options.skip = CrSkip;
    } else if (skip_white_sym == v) {
	ox_default_options.skip = SpcSkip;
    } else {
	rb_raise(ox_parse_error_class, ":skip must be :skip_none, :skip_return, :skip_white, :skip_off, or nil.\n");
    }

    v = rb_hash_lookup(opts, convert_special_sym);
    if (Qnil == v) {
	// no change
    } else if (Qtrue == v) {
	ox_default_options.convert_special = 1;
    } else if (Qfalse == v) {
	ox_default_options.convert_special = 0;
    } else {
	rb_raise(ox_parse_error_class, ":convert_special must be true or false.\n");
    }

    v = rb_hash_aref(opts, invalid_replace_sym);
    if (Qnil == v) {
	ox_default_options.allow_invalid = Yes;
    } else {
	long	slen;

	Check_Type(v, T_STRING);
	slen = RSTRING_LEN(v);
	if (sizeof(ox_default_options.inv_repl) - 2 < (size_t)slen) {
	    rb_raise(ox_parse_error_class, ":invalid_replace can be no longer than %d characters.",
		     (int)sizeof(ox_default_options.inv_repl) - 2);
	}
	strncpy(ox_default_options.inv_repl + 1, StringValuePtr(v), sizeof(ox_default_options.inv_repl) - 1);
	ox_default_options.inv_repl[sizeof(ox_default_options.inv_repl) - 1] = '\0';
	*ox_default_options.inv_repl = (char)slen;
	ox_default_options.allow_invalid = No;
    }

    v = rb_hash_aref(opts, strip_namespace_sym);
    if (Qfalse == v) {
	*ox_default_options.strip_ns = '\0';
    } else if (Qtrue == v) {
	*ox_default_options.strip_ns = '*';
	ox_default_options.strip_ns[1] = '\0';
    } else if (Qnil != v) {
	long	slen;

	Check_Type(v, T_STRING);
	slen = RSTRING_LEN(v);
	if (sizeof(ox_default_options.strip_ns) - 1 < (size_t)slen) {
	    rb_raise(ox_parse_error_class, ":strip_namespace can be no longer than %d characters.",
		     (int)sizeof(ox_default_options.strip_ns) - 1);
	}
	strncpy(ox_default_options.strip_ns, StringValuePtr(v), sizeof(ox_default_options.strip_ns) - 1);
	ox_default_options.strip_ns[sizeof(ox_default_options.strip_ns) - 1] = '\0';
    }

    v = rb_hash_aref(opts, margin_sym);
    if (Qnil != v) {
	long	slen;

	Check_Type(v, T_STRING);
	slen = RSTRING_LEN(v);
	if (sizeof(ox_default_options.margin) - 1 < (size_t)slen) {
	    rb_raise(ox_parse_error_class, ":margin can be no longer than %d characters.",
		     (int)sizeof(ox_default_options.margin) - 1);
	}
	strncpy(ox_default_options.margin, StringValuePtr(v), sizeof(ox_default_options.margin) - 1);
	ox_default_options.margin[sizeof(ox_default_options.margin) - 1] = '\0';
	ox_default_options.margin_len = strlen(ox_default_options.margin);
    }

    for (o = ynos; 0 != o->attr; o++) {
	v = rb_hash_lookup(opts, o->sym);
	if (Qnil == v) {
	    *o->attr = NotSet;
	} else if (Qtrue == v) {
	    *o->attr = Yes;
	} else if (Qfalse == v) {
	    *o->attr = No;
	} else {
	    rb_raise(ox_parse_error_class, "%s must be true or false.\n", rb_id2name(SYM2ID(o->sym)));
	}
    }
    v = rb_hash_aref(opts, overlay_sym);
    if (Qnil == v) {
	ox_hints_destroy(ox_default_options.html_hints);
	ox_default_options.html_hints = NULL;
    } else {
	int	cnt;

	Check_Type(v, T_HASH);
	cnt = (int)RHASH_SIZE(v);
	if (0 == cnt) {
	    ox_hints_destroy(ox_default_options.html_hints);
	    ox_default_options.html_hints = NULL;
	} else {
	    ox_hints_destroy(ox_default_options.html_hints);
	    ox_default_options.html_hints = ox_hints_dup(ox_hints_html());
	    rb_hash_foreach(v, set_overlay, (VALUE)ox_default_options.html_hints);
	}
    }
    return Qnil;
}

/* call-seq: parse_obj(xml) => Object
 *
 * Parses an XML document String that is in the object format and returns an
 * Object of the type represented by the XML. This function expects an
 * optimized XML formated String. For other formats use the more generic
 * Ox.load() method.  Raises an exception if the XML is malformed or the
 * classes specified in the file are not valid.
 * - +xml+ [String] XML String in optimized Object format.
 * *return* [Object] deserialized Object.
 */
static VALUE
to_obj(VALUE self, VALUE ruby_xml) {
    char		*xml, *x;
    size_t		len;
    VALUE		obj;
    struct _Options	options = ox_default_options;
    struct _Err		err;

    err_init(&err);
    Check_Type(ruby_xml, T_STRING);
    /* the xml string gets modified so make a copy of it */
    len = RSTRING_LEN(ruby_xml) + 1;
    x = defuse_bom(StringValuePtr(ruby_xml), &options);
    if (SMALL_XML < len) {
	xml = ALLOC_N(char, len);
    } else {
	xml = ALLOCA_N(char, len);
    }
    memcpy(xml, x, len);
#if HAS_GC_GUARD
    rb_gc_disable();
#endif
    obj = ox_parse(xml, ox_obj_callbacks, 0, &options, &err);
    if (SMALL_XML < len) {
	xfree(xml);
    }
#if HAS_GC_GUARD
    RB_GC_GUARD(obj);
    rb_gc_enable();
#endif
    if (err_has(&err)) {
	ox_err_raise(&err);
    }
    return obj;
}

/* call-seq: parse(xml) => Ox::Document or Ox::Element
 *
 * Parses and XML document String into an Ox::Document or Ox::Element.
 * - +xml+ [String] xml XML String
 * *return* [Ox::Document or Ox::Element] parsed XML document.
 *
 * _raise_ [Exception] if the XML is malformed.
 */
static VALUE
to_gen(VALUE self, VALUE ruby_xml) {
    char		*xml, *x;
    size_t		len;
    VALUE		obj;
    struct _Options	options = ox_default_options;
    struct _Err		err;

    err_init(&err);
    Check_Type(ruby_xml, T_STRING);
    /* the xml string gets modified so make a copy of it */
    len = RSTRING_LEN(ruby_xml) + 1;
    x = defuse_bom(StringValuePtr(ruby_xml), &options);
    if (SMALL_XML < len) {
	xml = ALLOC_N(char, len);
    } else {
	xml = ALLOCA_N(char, len);
    }
    memcpy(xml, x, len);
    obj = ox_parse(xml, ox_gen_callbacks, 0, &options, &err);
    if (SMALL_XML < len) {
	xfree(xml);
    }
    if (err_has(&err)) {
	ox_err_raise(&err);
    }
    return obj;
}

static VALUE
load(char *xml, int argc, VALUE *argv, VALUE self, VALUE encoding, Err err) {
    VALUE		obj;
    struct _Options	options = ox_default_options;

    if (1 == argc && rb_cHash == rb_obj_class(*argv)) {
	VALUE	h = *argv;
	VALUE	v;
	
	if (Qnil != (v = rb_hash_lookup(h, mode_sym))) {
	    if (object_sym == v) {
		options.mode = ObjMode;
	    } else if (optimized_sym == v) {
		options.mode = ObjMode;
	    } else if (generic_sym == v) {
		options.mode = GenMode;
	    } else if (limited_sym == v) {
		options.mode = LimMode;
	    } else if (hash_sym == v) {
		options.mode = HashMode;
	    } else if (hash_no_attrs_sym == v) {
		options.mode = HashNoAttrMode;
	    } else {
		rb_raise(ox_parse_error_class, ":mode must be :generic, :object, :limited, :hash, :hash_no_attrs.\n");
	    }
	}
	if (Qnil != (v = rb_hash_lookup(h, effort_sym))) {
	    if (auto_define_sym == v) {
		options.effort = AutoEffort;
	    } else if (tolerant_sym == v) {
		options.effort = TolerantEffort;
	    } else if (strict_sym == v) {
		options.effort = StrictEffort;
	    } else {
		rb_raise(ox_parse_error_class, ":effort must be :strict, :tolerant, or :auto_define.\n");
	    }
	}
	if (Qnil != (v = rb_hash_lookup(h, skip_sym))) {
	    if (skip_none_sym == v) {
		options.skip = NoSkip;
	    } else if (skip_off_sym == v) {
		options.skip = OffSkip;
	    } else if (skip_return_sym == v) {
		options.skip = CrSkip;
	    } else if (skip_white_sym == v) {
		options.skip = SpcSkip;
	    } else {
		rb_raise(ox_parse_error_class, ":skip must be :skip_none, :skip_return, :skip_white, or :skip_off.\n");
	    }
	}

	if (Qnil != (v = rb_hash_lookup(h, trace_sym))) {
	    Check_Type(v, T_FIXNUM);
	    options.trace = FIX2INT(v);
	}
	if (Qnil != (v = rb_hash_lookup(h, symbolize_keys_sym))) {
	    options.sym_keys = (Qfalse == v) ? No : Yes;
	}
	if (Qnil != (v = rb_hash_lookup(h, convert_special_sym))) {
	    options.convert_special = (Qfalse != v);
	}

	v = rb_hash_lookup(h, invalid_replace_sym);
	if (Qnil == v) {
	    if (Qtrue == rb_funcall(h, has_key_id, 1, invalid_replace_sym)) {
		options.allow_invalid = Yes;
	    }
	} else {
	    long	slen;

	    Check_Type(v, T_STRING);
	    slen = RSTRING_LEN(v);
	    if (sizeof(options.inv_repl) - 2 < (size_t)slen) {
		rb_raise(ox_parse_error_class, ":invalid_replace can be no longer than %d characters.",
			 (int)sizeof(options.inv_repl) - 2);
	    }
	    strncpy(options.inv_repl + 1, StringValuePtr(v), sizeof(options.inv_repl) - 1);
	    options.inv_repl[sizeof(options.inv_repl) - 1] = '\0';
	    *options.inv_repl = (char)slen;
	    options.allow_invalid = No;
	}
	v = rb_hash_lookup(h, strip_namespace_sym);
	if (Qfalse == v) {
	    *options.strip_ns = '\0';
	} else if (Qtrue == v) {
	    *options.strip_ns = '*';
	    options.strip_ns[1] = '\0';
	} else if (Qnil != v) {
	    long	slen;

	    Check_Type(v, T_STRING);
	    slen = RSTRING_LEN(v);
	    if (sizeof(options.strip_ns) - 1 < (size_t)slen) {
		rb_raise(ox_parse_error_class, ":strip_namespace can be no longer than %d characters.",
			 (int)sizeof(options.strip_ns) - 1);
	    }
	    strncpy(options.strip_ns, StringValuePtr(v), sizeof(options.strip_ns) - 1);
	    options.strip_ns[sizeof(options.strip_ns) - 1] = '\0';
	}
	v = rb_hash_lookup(h, margin_sym);
	if (Qnil != v) {
	    long	slen;

	    Check_Type(v, T_STRING);
	    slen = RSTRING_LEN(v);
	    if (sizeof(options.margin) - 1 < (size_t)slen) {
		rb_raise(ox_parse_error_class, ":margin can be no longer than %d characters.",
			 (int)sizeof(options.margin) - 1);
	    }
	    strncpy(options.margin, StringValuePtr(v), sizeof(options.margin) - 1);
	    options.margin[sizeof(options.margin) - 1] = '\0';
	    options.margin_len = strlen(options.margin);
	}
    }
#if HAS_ENCODING_SUPPORT
    if ('\0' == *options.encoding) {
	if (Qnil != encoding) {
	    options.rb_enc = rb_enc_from_index(rb_enc_get_index(encoding));
	} else {
	    options.rb_enc = 0;
	}
    } else if (0 == options.rb_enc) {
	options.rb_enc = rb_enc_find(options.encoding);
    }
#elif HAS_PRIVATE_ENCODING
    if ('\0' == *options.encoding) {
	if (Qnil != encoding) {
	    options.rb_enc = encoding;
	} else {
	    options.rb_enc = Qnil;
	}
    } else if (0 == options.rb_enc) {
	options.rb_enc = rb_str_new2(options.encoding);
	rb_gc_register_address(&options.rb_enc);
    }
#endif
    xml = defuse_bom(xml, &options);
    switch (options.mode) {
    case ObjMode:
#if HAS_GC_GUARD
	rb_gc_disable();
#endif
	obj = ox_parse(xml, ox_obj_callbacks, 0, &options, err);
#if HAS_GC_GUARD
	RB_GC_GUARD(obj);
	rb_gc_enable();
#endif
	break;
    case GenMode:
	obj = ox_parse(xml, ox_gen_callbacks, 0, &options, err);
	break;
    case LimMode:
	obj = ox_parse(xml, ox_limited_callbacks, 0, &options, err);
	break;
    case HashMode:
	obj = ox_parse(xml, ox_hash_callbacks, 0, &options, err);
	break;
    case HashNoAttrMode:
	obj = ox_parse(xml, ox_hash_no_attrs_callbacks, 0, &options, err);
	break;
    case NoMode:
	obj = ox_parse(xml, ox_nomode_callbacks, 0, &options, err);
	break;
    default:
	obj = ox_parse(xml, ox_gen_callbacks, 0, &options, err);
	break;
    }
    return obj;
}

/* call-seq: load(xml, options) => Ox::Document or Ox::Element or Object
 *
 * Parses and XML document String into an Ox::Document, or Ox::Element, or
 * Object depending on the options.  Raises an exception if the XML is malformed
 * or the classes specified are not valid. If a block is given it will be called
 * on the completion of each complete top level entity with that entity as it's
 * only argument.
 *
 * - +xml+ [String] XML String
 * - +options+ [Hash] load options
 *   - *:mode* [:object|:generic|:limited] format expected
 *     - _:object_ - object format
 *     - _:generic_ - read as a generic XML file
 *     - _:limited_ - read as a generic XML file but with callbacks on text and elements events only
 *     - _:hash_ - read and convert to a Hash and core class objects only
 *     - _:hash_no_attrs_ - read and convert to a Hash and core class objects only without capturing attributes
 *   - *:effort* [:strict|:tolerant|:auto_define] effort to use when an undefined class is encountered, default: :strict
 *     - _:strict_ - raise an NameError for missing classes and modules
 *     - _:tolerant_ - return nil for missing classes and modules
 *     - _:auto_define_ - auto define missing classes and modules
 *   - *:trace* [Fixnum] trace level as a Fixnum, default: 0 (silent)
 *   - *:symbolize_keys* [true|false|nil] symbolize element attribute keys or leave as Strings
 *   - *:invalid_replace* [nil|String] replacement string for invalid XML characters on dump. nil indicates include anyway as hex. A string, limited to 10 characters will replace the invalid character with the replace.
 *   - *:strip_namespace* [String|true|false] "" or false result in no namespace stripping. A string of "*" or true will strip all namespaces. Any other non-empty string indicates that matching namespaces will be stripped.
 */
static VALUE
load_str(int argc, VALUE *argv, VALUE self) {
    char	*xml;
    size_t	len;
    VALUE	obj;
    VALUE	encoding;
    struct _Err	err;

    err_init(&err);
    Check_Type(*argv, T_STRING);
    /* the xml string gets modified so make a copy of it */
    len = RSTRING_LEN(*argv) + 1;
    if (SMALL_XML < len) {
	xml = ALLOC_N(char, len);
    } else {
	xml = ALLOCA_N(char, len);
    }
#if HAS_ENCODING_SUPPORT
#ifdef MACRUBY_RUBY
    encoding = rb_funcall(*argv, encoding_id, 0);
#else
    encoding = rb_obj_encoding(*argv);
#endif
#elif HAS_PRIVATE_ENCODING
    encoding = rb_funcall(*argv, encoding_id, 0);
#else
    encoding = Qnil;
#endif
    memcpy(xml, StringValuePtr(*argv), len);
    obj = load(xml, argc - 1, argv + 1, self, encoding, &err);
    if (SMALL_XML < len) {
	xfree(xml);
    }
    if (err_has(&err)) {
	ox_err_raise(&err);
    }
    return obj;
}

/* call-seq: load_file(file_path, options) => Ox::Document or Ox::Element or Object
 *
 * Parses and XML document from a file into an Ox::Document, or Ox::Element,
 * or Object depending on the options.	Raises an exception if the XML is
 * malformed or the classes specified are not valid.
 * - +file_path+ [String] file path to read the XML document from
 * - +options+ [Hash] load options
 *   - *:mode* [:object|:generic|:limited] format expected
 *     - _:object_ - object format
 *     - _:generic_ - read as a generic XML file
 *     - _:limited_ - read as a generic XML file but with callbacks on text and elements events only
 *     - _:hash_ - read and convert to a Hash and core class objects only
 *     - _:hash_no_attrs_ - read and convert to a Hash and core class objects only without capturing attributes
 *   - *:effort* [:strict|:tolerant|:auto_define] effort to use when an undefined class is encountered, default: :strict
 *     - _:strict_ - raise an NameError for missing classes and modules
 *     - _:tolerant_ - return nil for missing classes and modules
 *     - _:auto_define_ - auto define missing classes and modules
 *   - *:trace* [Fixnum] trace level as a Fixnum, default: 0 (silent)
 *   - *:symbolize_keys* [true|false|nil] symbolize element attribute keys or leave as Strings
 *   - *:invalid_replace* [nil|String] replacement string for invalid XML characters on dump. nil indicates include anyway as hex. A string, limited to 10 characters will replace the invalid character with the replace.
 *   - *:strip_namespace* [String|true|false] "" or false result in no namespace stripping. A string of "*" or true will strip all namespaces. Any other non-empty string indicates that matching namespaces will be stripped.
 */
static VALUE
load_file(int argc, VALUE *argv, VALUE self) {
    char	*path;
    char	*xml;
    FILE	*f;
    size_t	len;
    VALUE	obj;
    struct _Err	err;

    err_init(&err);
    Check_Type(*argv, T_STRING);
    path = StringValuePtr(*argv);
    if (0 == (f = fopen(path, "r"))) {
	rb_raise(rb_eIOError, "%s\n", strerror(errno));
    }
    fseek(f, 0, SEEK_END);
    len = ftell(f);
    if (SMALL_XML < len) {
	xml = ALLOC_N(char, len + 1);
    } else {
	xml = ALLOCA_N(char, len + 1);
    }
    fseek(f, 0, SEEK_SET);
    if (len != fread(xml, 1, len, f)) {
	ox_err_set(&err, rb_eLoadError, "Failed to read %ld bytes from %s.\n", (long)len, path);
	obj = Qnil;
    } else {
	xml[len] = '\0';
	obj = load(xml, argc - 1, argv + 1, self, Qnil, &err);
    }
    fclose(f);
    if (SMALL_XML < len) {
	xfree(xml);
    }
    if (err_has(&err)) {
	ox_err_raise(&err);
    }
    return obj;
}

/* call-seq: sax_parse(handler, io, options)
 *
 * Parses an IO stream or file containing an XML document. Raises an exception
 * if the XML is malformed or the classes specified are not valid.
 * - +handler+ [Ox::Sax] SAX (responds to OX::Sax methods) like handler
 * - +io+ [IO|String] IO Object to read from
 * - +options+ [Hash] options parse options
 *   - *:convert_special* [true|false] flag indicating special characters like &lt; are converted
 *   - *:symbolize* [true|false] flag indicating the parser symbolize element and attribute names
 *   - *:smart* [true|false] flag indicating the parser uses hints if available (use with html)
 *   - *:skip* [:skip_none|:skip_return|:skip_white|:skip_off] flag indicating the parser skips \\r or collpase white space into a single space. Default (skip space)
 *   - *:strip_namespace* [nil|String|true|false] "" or false result in no namespace stripping. A string of "*" or true will strip all namespaces. Any other non-empty string indicates that matching namespaces will be stripped.
 */
static VALUE
sax_parse(int argc, VALUE *argv, VALUE self) {
    struct _SaxOptions	options;

    options.symbolize = (No != ox_default_options.sym_keys);
    options.convert_special = ox_default_options.convert_special;
    options.smart = (Yes == ox_default_options.smart);
    options.skip = ox_default_options.skip;
    options.hints = NULL;
    strcpy(options.strip_ns, ox_default_options.strip_ns);
    
    if (argc < 2) {
	rb_raise(ox_parse_error_class, "Wrong number of arguments to sax_parse.\n");
    }
    if (3 <= argc && rb_cHash == rb_obj_class(argv[2])) {
	VALUE	h = argv[2];
	VALUE	v;
	
	if (Qnil != (v = rb_hash_lookup(h, convert_special_sym))) {
	    options.convert_special = (Qtrue == v);
	}
	if (Qnil != (v = rb_hash_lookup(h, smart_sym))) {
	    options.smart = (Qtrue == v);
	}
	if (Qnil != (v = rb_hash_lookup(h, symbolize_sym))) {
	    options.symbolize = (Qtrue == v);
	}
	if (Qnil != (v = rb_hash_lookup(h, skip_sym))) {
	    if (skip_return_sym == v) {
		options.skip = CrSkip;
	    } else if (skip_white_sym == v) {
		options.skip = SpcSkip;
	    } else if (skip_none_sym == v) {
		options.skip = NoSkip;
	    } else if (skip_off_sym == v) {
		options.skip = OffSkip;
	    }
	}
	if (Qnil != (v = rb_hash_lookup(h, strip_namespace_sym))) {
	    if (Qfalse == v) {
		*options.strip_ns = '\0';
	    } else if (Qtrue == v) {
		*options.strip_ns = '*';
		options.strip_ns[1] = '\0';
	    } else {
		long	slen;

		Check_Type(v, T_STRING);
		slen = RSTRING_LEN(v);
		if (sizeof(options.strip_ns) - 1 <  (size_t)slen) {
		    rb_raise(ox_parse_error_class, ":strip_namespace can be no longer than %d characters.",
			     (int)sizeof(options.strip_ns) - 1);
		}
		strncpy(options.strip_ns, StringValuePtr(v), sizeof(options.strip_ns) - 1);
		options.strip_ns[sizeof(options.strip_ns) - 1] = '\0';
	    }
	}
    }
    ox_sax_parse(argv[0], argv[1], &options);

    return Qnil;
}

/* call-seq: sax_html(handler, io, options)
 *
 * Parses an IO stream or file containing an XML document. Raises an exception
 * if the XML is malformed or the classes specified are not valid.
 * - +handler+ [Ox::Sax] SAX (responds to OX::Sax methods) like handler
 * - +io+ [IO|String] IO Object to read from
 * - +options+ [Hash] options parse options
 *   - *:convert_special* [true|false] flag indicating special characters like &lt; are converted
 *   - *:symbolize* [true|false] flag indicating the parser symbolize element and attribute names
 *   - *:skip* [:skip_none|:skip_return|:skip_white|:skip_off] flag indicating the parser skips \\r or collapse white space into a single space. Default (skip space)
 *   - *:overlay* [Hash] a Hash of keys that match html element names and values that are one of
 *     - _:active_ - make the normal callback for the element
 *     - _:nest_ok_ - active but ignore nest check
 *     - _:inactive_ - do not make the element start, end, or attribute callbacks for this element only
 *     - _:block_ - block this and all children callbacks
 *     - _:off_ - block this element and it's children unless the child element is active
 *     - _:abort_ - abort the html processing and return
 */
static VALUE
sax_html(int argc, VALUE *argv, VALUE self) {
    struct _SaxOptions	options;
    bool		free_hints = false;
    
    options.symbolize = (No != ox_default_options.sym_keys);
    options.convert_special = ox_default_options.convert_special;
    options.smart = true;
    options.skip = ox_default_options.skip;
    options.hints = ox_default_options.html_hints;
    if (NULL == options.hints) {
	options.hints = ox_hints_html();
    }
    *options.strip_ns = '\0';
    
    if (argc < 2) {
	rb_raise(ox_parse_error_class, "Wrong number of arguments to sax_html.\n");
    }
    if (3 <= argc && rb_cHash == rb_obj_class(argv[2])) {
	volatile VALUE	h = argv[2];
	volatile VALUE	v;
	
	if (Qnil != (v = rb_hash_lookup(h, convert_special_sym))) {
	    options.convert_special = (Qtrue == v);
	}
	if (Qnil != (v = rb_hash_lookup(h, symbolize_sym))) {
	    options.symbolize = (Qtrue == v);
	}
	if (Qnil != (v = rb_hash_lookup(h, skip_sym))) {
	    if (skip_return_sym == v) {
		options.skip = CrSkip;
	    } else if (skip_white_sym == v) {
		options.skip = SpcSkip;
	    } else if (skip_none_sym == v) {
		options.skip = NoSkip;
	    } else if (skip_off_sym == v) {
		options.skip = OffSkip;
	    }
	}
	if (Qnil != (v = rb_hash_lookup(h, overlay_sym))) {
	    int	cnt;
	    
	    Check_Type(v, T_HASH);
	    cnt = (int)RHASH_SIZE(v);
	    if (0 == cnt) {
		options.hints = ox_hints_html();
	    } else {
		options.hints = ox_hints_dup(options.hints);
		free_hints = true;
		rb_hash_foreach(v, set_overlay, (VALUE)options.hints);
	    }
	}
    }
    ox_sax_parse(argv[0], argv[1], &options);
    if (free_hints) {
	ox_hints_destroy(options.hints);
    }
    return Qnil;
}

static void
parse_dump_options(VALUE ropts, Options copts) {
    struct _YesNoOpt	ynos[] = {
	{ with_xml_sym, &copts->with_xml },
	{ with_dtd_sym, &copts->with_dtd },
	{ with_instruct_sym, &copts->with_instruct },
	{ xsd_date_sym, &copts->xsd_date },
	{ circular_sym, &copts->circular },
	{ Qnil, 0 }
    };
    YesNoOpt	o;
    
    if (rb_cHash == rb_obj_class(ropts)) {
	VALUE	v;
	
	if (Qnil != (v = rb_hash_lookup(ropts, ox_indent_sym))) {
#ifdef RUBY_INTEGER_UNIFICATION
	    if (rb_cInteger != rb_obj_class(v) && T_FIXNUM != rb_type(v)) {
#else
	    if (rb_cFixnum != rb_obj_class(v)) {
#endif
		rb_raise(ox_parse_error_class, ":indent must be a Fixnum.\n");
	    }
	    copts->indent = NUM2INT(v);
	}
	if (Qnil != (v = rb_hash_lookup(ropts, trace_sym))) {
#ifdef RUBY_INTEGER_UNIFICATION
	    if (rb_cInteger != rb_obj_class(v) && T_FIXNUM != rb_type(v)) {
#else
	    if (rb_cFixnum != rb_obj_class(v)) {
#endif
		rb_raise(ox_parse_error_class, ":trace must be a Fixnum.\n");
	    }
	    copts->trace = NUM2INT(v);
	}
	if (Qnil != (v = rb_hash_lookup(ropts, ox_encoding_sym))) {
	    if (rb_cString != rb_obj_class(v)) {
		rb_raise(ox_parse_error_class, ":encoding must be a String.\n");
	    }
	    strncpy(copts->encoding, StringValuePtr(v), sizeof(copts->encoding) - 1);
	}
	if (Qnil != (v = rb_hash_lookup(ropts, effort_sym))) {
	    if (auto_define_sym == v) {
		copts->effort = AutoEffort;
	    } else if (tolerant_sym == v) {
		copts->effort = TolerantEffort;
	    } else if (strict_sym == v) {
		copts->effort = StrictEffort;
	    } else {
		rb_raise(ox_parse_error_class, ":effort must be :strict, :tolerant, or :auto_define.\n");
	    }
	}
	v = rb_hash_lookup(ropts, invalid_replace_sym);
	if (Qnil == v) {
	    if (Qtrue == rb_funcall(ropts, has_key_id, 1, invalid_replace_sym)) {
		copts->allow_invalid = Yes;
	    }
	} else {
	    long	slen;

	    Check_Type(v, T_STRING);
	    slen = RSTRING_LEN(v);
	    if (sizeof(copts->inv_repl) - 2 <  (size_t)slen) {
		rb_raise(ox_parse_error_class, ":invalid_replace can be no longer than %d characters.",
			 (int)sizeof(copts->inv_repl) - 2);
	    }
	    strncpy(copts->inv_repl + 1, StringValuePtr(v), sizeof(copts->inv_repl) - 1);
	    copts->inv_repl[sizeof(copts->inv_repl) - 1] = '\0';
	    *copts->inv_repl = (char)slen;
	    copts->allow_invalid = No;
	}
	v = rb_hash_lookup(ropts, margin_sym);
	if (Qnil != v) {
	    long	slen;

	    Check_Type(v, T_STRING);
	    slen = RSTRING_LEN(v);
	    if (sizeof(copts->margin) - 2 <  (size_t)slen) {
		rb_raise(ox_parse_error_class, ":margin can be no longer than %d characters.",
			 (int)sizeof(copts->margin) - 2);
	    }
	    strncpy(copts->margin, StringValuePtr(v), sizeof(copts->margin) - 1);
	    copts->margin[sizeof(copts->margin) - 1] = '\0';
	    copts->margin_len = (char)slen;
	}
	
	for (o = ynos; 0 != o->attr; o++) {
	    if (Qnil != (v = rb_hash_lookup(ropts, o->sym))) {
		VALUE	    c = rb_obj_class(v);

		if (rb_cTrueClass == c) {
		    *o->attr = Yes;
		} else if (rb_cFalseClass == c) {
		    *o->attr = No;
		} else {
		    rb_raise(ox_parse_error_class, "%s must be true or false.\n", rb_id2name(SYM2ID(o->sym)));
		}
	    }
	}
    }
}

/* call-seq: dump(obj, options) => xml-string
 *
 * Dumps an Object (obj) to a string.
 * - +obj+ [Object] Object to serialize as an XML document String
 * - +options+ [Hash] formating options
 *   - *:indent* [Fixnum] format expected
 *   - *:xsd_date* [true|false] use XSD date format if true, default: false
 *   - *:circular* [true|false] allow circular references, default: false
 *   - *:strict|:tolerant]* [ :effort effort to use when an undumpable object (e.g., IO) is encountered, default: :strict
 *     - _:strict_ - raise an NotImplementedError if an undumpable object is encountered
 *     - _:tolerant_ - replaces undumplable objects with nil
 *
 * Note that an indent of less than zero will result in a tight one line output
 * unless the text in the XML fields contain new line characters.
 */
static VALUE
dump(int argc, VALUE *argv, VALUE self) {
    char		*xml;
    struct _Options	copts = ox_default_options;
    VALUE		rstr;
    
    if (2 == argc) {
	parse_dump_options(argv[1], &copts);
    }
    if (0 == (xml = ox_write_obj_to_str(*argv, &copts))) {
	rb_raise(rb_eNoMemError, "Not enough memory.\n");
    }
    rstr = rb_str_new2(xml);
#if HAS_ENCODING_SUPPORT
    if ('\0' != *copts.encoding) {
	rb_enc_associate(rstr, rb_enc_find(copts.encoding));
    }
#elif HAS_PRIVATE_ENCODING
    if ('\0' != *copts.encoding) {
	rb_funcall(rstr, ox_force_encoding_id, 1, rb_str_new2(copts.encoding));
    }
#endif
    xfree(xml);

    return rstr;
}

/* call-seq: to_file(file_path, obj, options)
 *
 * Dumps an Object to the specified file.
 * - +file_path+ [String] file path to write the XML document to
 * - +obj+ [Object] Object to serialize as an XML document String
 * - +options+ [Hash] formating options
 *   - *:indent* [Fixnum] format expected
 *   - *:xsd_date* [true|false] use XSD date format if true, default: false
 *   - *:circular* [true|false] allow circular references, default: false
 *   - *:strict|:tolerant]* [ :effort effort to use when an undumpable object (e.g., IO) is encountered, default: :strict
 *     - _:strict_ - raise an NotImplementedError if an undumpable object is encountered
 *     - _:tolerant_ - replaces undumplable objects with nil
 *
 * Note that an indent of less than zero will result in a tight one line output
 * unless the text in the XML fields contain new line characters.
 */
static VALUE
to_file(int argc, VALUE *argv, VALUE self) {
    struct _Options	copts = ox_default_options;
    
    if (3 == argc) {
	parse_dump_options(argv[2], &copts);
    }
    Check_Type(*argv, T_STRING);
    ox_write_obj_to_file(argv[1], StringValuePtr(*argv), &copts);

    return Qnil;
}

#if WITH_CACHE_TESTS
extern void	ox_cache_test(void);

static VALUE
cache_test(VALUE self) {
    ox_cache_test();
    return Qnil;
}

extern void	ox_cache8_test(void);

static VALUE
cache8_test(VALUE self) {
    ox_cache8_test();
    return Qnil;
}
#endif

void Init_ox() {
    Ox = rb_define_module("Ox");

    rb_define_module_function(Ox, "default_options", get_def_opts, 0);
    rb_define_module_function(Ox, "default_options=", set_def_opts, 1);

    rb_define_module_function(Ox, "parse_obj", to_obj, 1);
    rb_define_module_function(Ox, "parse", to_gen, 1);
    rb_define_module_function(Ox, "load", load_str, -1);
    rb_define_module_function(Ox, "sax_parse", sax_parse, -1);
    rb_define_module_function(Ox, "sax_html", sax_html, -1);

    rb_define_module_function(Ox, "to_xml", dump, -1);
    rb_define_module_function(Ox, "dump", dump, -1);

    rb_define_module_function(Ox, "load_file", load_file, -1);
    rb_define_module_function(Ox, "to_file", to_file, -1);

    rb_define_module_function(Ox, "sax_html_overlay", sax_html_overlay, 0);
    
    ox_init_builder(Ox);
    
    rb_require("time");
    rb_require("date");
    rb_require("bigdecimal");
    rb_require("stringio");

    ox_abort_id = rb_intern("abort");
    ox_at_column_id = rb_intern("@column");
    ox_at_content_id = rb_intern("@content");
    ox_at_id = rb_intern("at");
    ox_at_line_id = rb_intern("@line");
    ox_at_pos_id = rb_intern("@pos");
    ox_at_value_id = rb_intern("@value");
    ox_attr_id = rb_intern("attr");
    ox_attr_value_id = rb_intern("attr_value");
    ox_attributes_id = rb_intern("@attributes");
    ox_attrs_done_id = rb_intern("attrs_done");
    ox_beg_id = rb_intern("@beg");
    ox_cdata_id = rb_intern("cdata");
    ox_comment_id = rb_intern("comment");
    ox_den_id = rb_intern("@den");
    ox_doctype_id = rb_intern("doctype");
    ox_end_element_id = rb_intern("end_element");
    ox_end_id = rb_intern("@end");
    ox_end_instruct_id = rb_intern("end_instruct");
    ox_error_id = rb_intern("error");
    ox_excl_id = rb_intern("@excl");
    ox_external_encoding_id = rb_intern("external_encoding");
    ox_fileno_id = rb_intern("fileno");
    ox_force_encoding_id = rb_intern("force_encoding");
    ox_inspect_id = rb_intern("inspect");
    ox_instruct_id = rb_intern("instruct");
    ox_jd_id = rb_intern("jd");
    ox_keys_id = rb_intern("keys");
    ox_local_id = rb_intern("local");
    ox_mesg_id = rb_intern("mesg");
    ox_message_id = rb_intern("message");
    ox_nodes_id = rb_intern("@nodes");
    ox_new_id = rb_intern("new");
    ox_num_id = rb_intern("@num");
    ox_parse_id = rb_intern("parse");
    ox_pos_id = rb_intern("pos");
    ox_read_id = rb_intern("read");
    ox_readpartial_id = rb_intern("readpartial");
    ox_start_element_id = rb_intern("start_element");
    ox_string_id = rb_intern("string");
    ox_text_id = rb_intern("text");
    ox_to_c_id = rb_intern("to_c");
    ox_to_s_id = rb_intern("to_s");
    ox_to_sym_id = rb_intern("to_sym");
    ox_tv_nsec_id = rb_intern("tv_nsec");
    ox_tv_sec_id = rb_intern("tv_sec");
    ox_tv_usec_id = rb_intern("tv_usec");
    ox_value_id = rb_intern("value");

    encoding_id = rb_intern("encoding");
    has_key_id = rb_intern("has_key?");

    rb_require("ox/version");
    rb_require("ox/error");
    rb_require("ox/hasattrs");
    rb_require("ox/node");
    rb_require("ox/comment");
    rb_require("ox/instruct");
    rb_require("ox/cdata");
    rb_require("ox/doctype");
    rb_require("ox/element");
    rb_require("ox/document");
    rb_require("ox/bag");
    rb_require("ox/sax");

    ox_time_class = rb_const_get(rb_cObject, rb_intern("Time"));
    ox_date_class = rb_const_get(rb_cObject, rb_intern("Date"));
    ox_parse_error_class = rb_const_get_at(Ox, rb_intern("ParseError"));
    ox_arg_error_class = rb_const_get_at(Ox, rb_intern("ArgError"));
    ox_struct_class = rb_const_get(rb_cObject, rb_intern("Struct"));
    ox_stringio_class = rb_const_get(rb_cObject, rb_intern("StringIO"));
    ox_bigdecimal_class = rb_const_get(rb_cObject, rb_intern("BigDecimal"));

    abort_sym = ID2SYM(rb_intern("abort"));			rb_gc_register_address(&abort_sym);
    active_sym = ID2SYM(rb_intern("active"));			rb_gc_register_address(&active_sym);
    auto_define_sym = ID2SYM(rb_intern("auto_define"));		rb_gc_register_address(&auto_define_sym);
    auto_sym = ID2SYM(rb_intern("auto"));			rb_gc_register_address(&auto_sym);
    block_sym = ID2SYM(rb_intern("block"));			rb_gc_register_address(&block_sym);
    circular_sym = ID2SYM(rb_intern("circular"));		rb_gc_register_address(&circular_sym);
    convert_special_sym = ID2SYM(rb_intern("convert_special")); rb_gc_register_address(&convert_special_sym);
    effort_sym = ID2SYM(rb_intern("effort"));			rb_gc_register_address(&effort_sym);
    generic_sym = ID2SYM(rb_intern("generic"));			rb_gc_register_address(&generic_sym);
    hash_no_attrs_sym = ID2SYM(rb_intern("hash_no_attrs"));	rb_gc_register_address(&hash_no_attrs_sym);
    hash_sym = ID2SYM(rb_intern("hash"));			rb_gc_register_address(&hash_sym);
    inactive_sym = ID2SYM(rb_intern("inactive"));		rb_gc_register_address(&inactive_sym);
    invalid_replace_sym = ID2SYM(rb_intern("invalid_replace"));	rb_gc_register_address(&invalid_replace_sym);
    limited_sym = ID2SYM(rb_intern("limited"));			rb_gc_register_address(&limited_sym);
    margin_sym = ID2SYM(rb_intern("margin"));			rb_gc_register_address(&margin_sym);
    mode_sym = ID2SYM(rb_intern("mode"));			rb_gc_register_address(&mode_sym);
    nest_ok_sym = ID2SYM(rb_intern("nest_ok"));			rb_gc_register_address(&nest_ok_sym);
    object_sym = ID2SYM(rb_intern("object"));			rb_gc_register_address(&object_sym);
    off_sym = ID2SYM(rb_intern("off"));				rb_gc_register_address(&off_sym);
    opt_format_sym = ID2SYM(rb_intern("opt_format"));		rb_gc_register_address(&opt_format_sym);
    optimized_sym = ID2SYM(rb_intern("optimized"));		rb_gc_register_address(&optimized_sym);
    overlay_sym = ID2SYM(rb_intern("overlay"));			rb_gc_register_address(&overlay_sym);
    ox_encoding_sym = ID2SYM(rb_intern("encoding"));		rb_gc_register_address(&ox_encoding_sym);
    ox_indent_sym = ID2SYM(rb_intern("indent"));		rb_gc_register_address(&ox_indent_sym);
    ox_size_sym = ID2SYM(rb_intern("size"));			rb_gc_register_address(&ox_size_sym);
    ox_standalone_sym = ID2SYM(rb_intern("standalone"));	rb_gc_register_address(&ox_standalone_sym);
    ox_version_sym = ID2SYM(rb_intern("version"));		rb_gc_register_address(&ox_version_sym);
    skip_none_sym = ID2SYM(rb_intern("skip_none"));		rb_gc_register_address(&skip_none_sym);
    skip_off_sym = ID2SYM(rb_intern("skip_off"));		rb_gc_register_address(&skip_off_sym);
    skip_return_sym = ID2SYM(rb_intern("skip_return"));		rb_gc_register_address(&skip_return_sym);
    skip_sym = ID2SYM(rb_intern("skip"));			rb_gc_register_address(&skip_sym);
    skip_white_sym = ID2SYM(rb_intern("skip_white"));		rb_gc_register_address(&skip_white_sym);
    smart_sym = ID2SYM(rb_intern("smart"));			rb_gc_register_address(&smart_sym);
    strict_sym = ID2SYM(rb_intern("strict"));			rb_gc_register_address(&strict_sym);
    strip_namespace_sym = ID2SYM(rb_intern("strip_namespace"));	rb_gc_register_address(&strip_namespace_sym);
    symbolize_keys_sym = ID2SYM(rb_intern("symbolize_keys"));	rb_gc_register_address(&symbolize_keys_sym);
    symbolize_sym = ID2SYM(rb_intern("symbolize"));		rb_gc_register_address(&symbolize_sym);
    tolerant_sym = ID2SYM(rb_intern("tolerant"));		rb_gc_register_address(&tolerant_sym);
    trace_sym = ID2SYM(rb_intern("trace"));			rb_gc_register_address(&trace_sym);
    with_dtd_sym = ID2SYM(rb_intern("with_dtd"));		rb_gc_register_address(&with_dtd_sym);
    with_instruct_sym = ID2SYM(rb_intern("with_instructions")); rb_gc_register_address(&with_instruct_sym);
    with_xml_sym = ID2SYM(rb_intern("with_xml"));		rb_gc_register_address(&with_xml_sym);
    xsd_date_sym = ID2SYM(rb_intern("xsd_date"));		rb_gc_register_address(&xsd_date_sym);

    ox_empty_string = rb_str_new2("");				rb_gc_register_address(&ox_empty_string);
    ox_zero_fixnum = INT2NUM(0);				rb_gc_register_address(&ox_zero_fixnum);
    ox_sym_bank = rb_ary_new();					rb_gc_register_address(&ox_sym_bank);

    ox_document_clas = rb_const_get_at(Ox, rb_intern("Document"));
    ox_element_clas = rb_const_get_at(Ox, rb_intern("Element"));
    ox_instruct_clas = rb_const_get_at(Ox, rb_intern("Instruct"));
    ox_comment_clas = rb_const_get_at(Ox, rb_intern("Comment"));
    ox_raw_clas = rb_const_get_at(Ox, rb_intern("Raw"));
    ox_doctype_clas = rb_const_get_at(Ox, rb_intern("DocType"));
    ox_cdata_clas = rb_const_get_at(Ox, rb_intern("CData"));
    ox_bag_clas = rb_const_get_at(Ox, rb_intern("Bag"));

    ox_cache_new(&ox_symbol_cache);
    ox_cache_new(&ox_class_cache);
    ox_cache_new(&ox_attr_cache);

    ox_sax_define();

#if WITH_CACHE_TESTS
    // space added to stop yardoc from trying to document
    rb_define _module_function(Ox, "cache_test", cache_test, 0);
    rb_define _module_function(Ox, "cache8_test", cache8_test, 0);
#endif
    
#if HAS_ENCODING_SUPPORT
    ox_utf8_encoding = rb_enc_find("UTF-8");
#elif HAS_PRIVATE_ENCODING
    ox_utf8_encoding = rb_str_new2("UTF-8");
    rb_gc_register_address(&ox_utf8_encoding);
#endif
}

#if __GNUC__ > 4
_Noreturn void
#else
void
#endif
_ox_raise_error(const char *msg, const char *xml, const char *current, const char* file, int line) {
    int	xline = 1;
    int	col = 1;

    for (; xml < current && '\n' != *current; current--) {
	col++;
    }
    for (; xml < current; current--) {
	if ('\n' == *current) {
	    xline++;
	}
    }
#if HAS_GC_GUARD
    rb_gc_enable();
#endif
    rb_raise(ox_parse_error_class, "%s at line %d, column %d [%s:%d]\n", msg, xline, col, file, line);
}
