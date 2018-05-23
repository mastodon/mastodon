/* gen_load.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include "ruby.h"
#include "ox.h"

static void     instruct(PInfo pi, const char *target, Attr attrs, const char *content);
static void	create_doc(PInfo pi);
static void     create_prolog_doc(PInfo pi, const char *target, Attr attrs);
static void     nomode_instruct(PInfo pi, const char *target, Attr attrs, const char *content);
static void     add_doctype(PInfo pi, const char *docType);
static void     add_comment(PInfo pi, const char *comment);
static void     add_cdata(PInfo pi, const char *cdata, size_t len);
static void     add_text(PInfo pi, char *text, int closed);
static void     add_element(PInfo pi, const char *ename, Attr attrs, int hasChildren);
static void     end_element(PInfo pi, const char *ename);
static void	add_instruct(PInfo pi, const char *name, Attr attrs, const char *content);

extern ParseCallbacks   ox_obj_callbacks;

struct _ParseCallbacks   _ox_gen_callbacks = {
    instruct, /* instruct, */
    add_doctype,
    add_comment,
    add_cdata,
    add_text,
    add_element,
    end_element,
    NULL,
};

ParseCallbacks   ox_gen_callbacks = &_ox_gen_callbacks;

struct _ParseCallbacks   _ox_limited_callbacks = {
    0,
    0,
    0,
    0,
    add_text,
    add_element,
    end_element,
    NULL,
};

ParseCallbacks   ox_limited_callbacks = &_ox_limited_callbacks;

struct _ParseCallbacks   _ox_nomode_callbacks = {
    nomode_instruct,
    add_doctype,
    add_comment,
    add_cdata,
    add_text,
    add_element,
    end_element,
    NULL,
};

ParseCallbacks   ox_nomode_callbacks = &_ox_nomode_callbacks;

static void
create_doc(PInfo pi) {
    VALUE       doc;
    VALUE       nodes;

    helper_stack_init(&pi->helpers);
    doc = rb_obj_alloc(ox_document_clas);
#if HAS_GC_GUARD
    RB_GC_GUARD(doc);
#endif
    nodes = rb_ary_new();
    rb_ivar_set(doc, ox_attributes_id, rb_hash_new());
    rb_ivar_set(doc, ox_nodes_id, nodes);
    helper_stack_push(&pi->helpers, 0, nodes, NoCode);
    pi->obj = doc;
}

static void
create_prolog_doc(PInfo pi, const char *target, Attr attrs) {
    VALUE       doc;
    VALUE       ah;
    VALUE       nodes;
    VALUE	sym;

    if (!helper_stack_empty(&pi->helpers)) { /* top level object */
        ox_err_set(&pi->err, rb_eSyntaxError, "Prolog must be the first element in an XML document.\n");
	return;
    }
    doc = rb_obj_alloc(ox_document_clas);
    ah = rb_hash_new();
    for (; 0 != attrs->name; attrs++) {
	if (Yes == pi->options->sym_keys) {
#if HAS_ENCODING_SUPPORT
	    if (0 != pi->options->rb_enc) {
		VALUE	rstr = rb_str_new2(attrs->name);

		rb_enc_associate(rstr, pi->options->rb_enc);
		sym = rb_funcall(rstr, ox_to_sym_id, 0);
	    } else {
		sym = ID2SYM(rb_intern(attrs->name));
	    }
#elif HAS_PRIVATE_ENCODING
	    if (Qnil != pi->options->rb_enc) {
		VALUE	rstr = rb_str_new2(attrs->name);

		rb_funcall(rstr, ox_force_encoding_id, 1, pi->options->rb_enc);
		sym = rb_funcall(rstr, ox_to_sym_id, 0);
	    } else {
		sym = ID2SYM(rb_intern(attrs->name));
	    }
#else
	    sym = ID2SYM(rb_intern(attrs->name));
#endif
	    rb_hash_aset(ah, sym, rb_str_new2(attrs->value));
	} else {
	    VALUE	rstr = rb_str_new2(attrs->name);

#if HAS_ENCODING_SUPPORT
	    if (0 != pi->options->rb_enc) {
		rb_enc_associate(rstr, pi->options->rb_enc);
	    }
#elif HAS_PRIVATE_ENCODING
	    if (Qnil != pi->options->rb_enc) {
		rb_funcall(rstr, ox_force_encoding_id, 1, pi->options->rb_enc);
	    }
#endif
	    rb_hash_aset(ah, rstr, rb_str_new2(attrs->value));
	}
#if HAS_ENCODING_SUPPORT
	if (0 == strcmp("encoding", attrs->name)) {
	    pi->options->rb_enc = rb_enc_find(attrs->value);
	}
#elif HAS_PRIVATE_ENCODING
	if (0 == strcmp("encoding", attrs->name)) {
	    pi->options->rb_enc = rb_str_new2(attrs->value);
	}
#endif
    }
    nodes = rb_ary_new();
    rb_ivar_set(doc, ox_attributes_id, ah);
    rb_ivar_set(doc, ox_nodes_id, nodes);
    helper_stack_push(&pi->helpers, 0, nodes, ArrayCode);
    pi->obj = doc;
}

static void
instruct(PInfo pi, const char *target, Attr attrs, const char *content) {
    if (0 == strcmp("xml", target)) {
        create_prolog_doc(pi, target, attrs);
    } else if (0 == strcmp("ox", target)) {
        for (; 0 != attrs->name; attrs++) {
            if (0 == strcmp("version", attrs->name)) {
                if (0 != strcmp("1.0", attrs->value)) {
                    ox_err_set(&pi->err, rb_eSyntaxError, "Only Ox XML Object version 1.0 supported, not %s.\n", attrs->value);
		    return;
                }
            }
            /* ignore other instructions */
        }
    } else {
	add_instruct(pi, target, attrs, content);
    }
}

static void
nomode_instruct(PInfo pi, const char *target, Attr attrs, const char *content) {
    if (0 == strcmp("xml", target)) {
        create_prolog_doc(pi, target, attrs);
    } else if (0 == strcmp("ox", target)) {
        for (; 0 != attrs->name; attrs++) {
            if (0 == strcmp("version", attrs->name)) {
                if (0 != strcmp("1.0", attrs->value)) {
                    ox_err_set(&pi->err, rb_eSyntaxError, "Only Ox XML Object version 1.0 supported, not %s.\n", attrs->value);
		    return;
                }
            } else if (0 == strcmp("mode", attrs->name)) {
                if (0 == strcmp("object", attrs->value)) {
                    pi->pcb = ox_obj_callbacks;
                    pi->obj = Qnil;
		    helper_stack_init(&pi->helpers);
                } else if (0 == strcmp("generic", attrs->value)) {
                    pi->pcb = ox_gen_callbacks;
                } else if (0 == strcmp("limited", attrs->value)) {
                    pi->pcb = ox_limited_callbacks;
                    pi->obj = Qnil;
		    helper_stack_init(&pi->helpers);
                } else {
                    ox_err_set(&pi->err, rb_eSyntaxError, "%s is not a valid processing instruction mode.\n", attrs->value);
		    return;
                }
            }
        }
    } else {
        if (TRACE <= pi->options->trace) {
            printf("Processing instruction %s ignored.\n", target);
        }
    }
}

static void
add_doctype(PInfo pi, const char *docType) {
    VALUE       n = rb_obj_alloc(ox_doctype_clas);
    VALUE       s = rb_str_new2(docType);

#if HAS_ENCODING_SUPPORT
    if (0 != pi->options->rb_enc) {
        rb_enc_associate(s, pi->options->rb_enc);
    }
#elif HAS_PRIVATE_ENCODING
    if (Qnil != pi->options->rb_enc) {
	rb_funcall(s, ox_force_encoding_id, 1, pi->options->rb_enc);
    }
#endif
    rb_ivar_set(n, ox_at_value_id, s);
    if (helper_stack_empty(&pi->helpers)) { /* top level object */
	create_doc(pi);
    }
    rb_ary_push(helper_stack_peek(&pi->helpers)->obj, n);
}

static void
add_comment(PInfo pi, const char *comment) {
    VALUE       n = rb_obj_alloc(ox_comment_clas);
    VALUE       s = rb_str_new2(comment);

#if HAS_ENCODING_SUPPORT
    if (0 != pi->options->rb_enc) {
        rb_enc_associate(s, pi->options->rb_enc);
    }
#elif HAS_PRIVATE_ENCODING
    if (Qnil != pi->options->rb_enc) {
	rb_funcall(s, ox_force_encoding_id, 1, pi->options->rb_enc);
    }
#endif
    rb_ivar_set(n, ox_at_value_id, s);
    if (helper_stack_empty(&pi->helpers)) { /* top level object */
	create_doc(pi);
    }
    rb_ary_push(helper_stack_peek(&pi->helpers)->obj, n);
}

static void
add_cdata(PInfo pi, const char *cdata, size_t len) {
    VALUE       n = rb_obj_alloc(ox_cdata_clas);
    VALUE       s = rb_str_new2(cdata);

#if HAS_ENCODING_SUPPORT
    if (0 != pi->options->rb_enc) {
        rb_enc_associate(s, pi->options->rb_enc);
    }
#elif HAS_PRIVATE_ENCODING
    if (Qnil != pi->options->rb_enc) {
	rb_funcall(s, ox_force_encoding_id, 1, pi->options->rb_enc);
    }
#endif
    rb_ivar_set(n, ox_at_value_id, s);
    if (helper_stack_empty(&pi->helpers)) { /* top level object */
	create_doc(pi);
    }
    rb_ary_push(helper_stack_peek(&pi->helpers)->obj, n);
}

static void
add_text(PInfo pi, char *text, int closed) {
    VALUE       s = rb_str_new2(text);

#if HAS_ENCODING_SUPPORT
    if (0 != pi->options->rb_enc) {
        rb_enc_associate(s, pi->options->rb_enc);
    }
#elif HAS_PRIVATE_ENCODING
    if (Qnil != pi->options->rb_enc) {
	rb_funcall(s, ox_force_encoding_id, 1, pi->options->rb_enc);
    }
#endif
    if (helper_stack_empty(&pi->helpers)) { /* top level object */
	create_doc(pi);
    }
    rb_ary_push(helper_stack_peek(&pi->helpers)->obj, s);
}

static void
add_element(PInfo pi, const char *ename, Attr attrs, int hasChildren) {
    VALUE       e;
    VALUE       s = rb_str_new2(ename);

#if HAS_ENCODING_SUPPORT
    if (0 != pi->options->rb_enc) {
        rb_enc_associate(s, pi->options->rb_enc);
    }
#elif HAS_PRIVATE_ENCODING
    if (Qnil != pi->options->rb_enc) {
	rb_funcall(s, ox_force_encoding_id, 1, pi->options->rb_enc);
    }
#endif
    e = rb_obj_alloc(ox_element_clas);
    rb_ivar_set(e, ox_at_value_id, s);
    if (0 != attrs->name) {
        volatile VALUE	ah = rb_hash_new();
        
        for (; 0 != attrs->name; attrs++) {
            volatile VALUE	sym;

	    if (Yes == pi->options->sym_keys) {
		VALUE	*slot;

		if (Qundef == (sym = ox_cache_get(ox_symbol_cache, attrs->name, &slot, 0))) {
#if HAS_ENCODING_SUPPORT
		    if (0 != pi->options->rb_enc) {
			VALUE	rstr = rb_str_new2(attrs->name);

			rb_enc_associate(rstr, pi->options->rb_enc);
			sym = rb_funcall(rstr, ox_to_sym_id, 0);
		    } else {
			sym = ID2SYM(rb_intern(attrs->name));
		    }
#elif HAS_PRIVATE_ENCODING
		    if (Qnil != pi->options->rb_enc) {
			VALUE	rstr = rb_str_new2(attrs->name);

			rb_funcall(rstr, ox_force_encoding_id, 1, pi->options->rb_enc);
			sym = rb_funcall(rstr, ox_to_sym_id, 0);
		    } else {
			sym = ID2SYM(rb_intern(attrs->name));
		    }
#else
		    sym = ID2SYM(rb_intern(attrs->name));
#endif
		    // Needed for Ruby 2.2 to get around the GC of symbols
		    // created with to_sym which is needed for encoded symbols.
		    rb_ary_push(ox_sym_bank, sym);
		    *slot = sym;
		}
	    } else {
		sym = rb_str_new2(attrs->name);
#if HAS_ENCODING_SUPPORT
		if (0 != pi->options->rb_enc) {
		    rb_enc_associate(sym, pi->options->rb_enc);
		}
#elif HAS_PRIVATE_ENCODING
		if (Qnil != pi->options->rb_enc) {
		    rb_funcall(sym, ox_force_encoding_id, 1, pi->options->rb_enc);
		}
#endif
	    }
            s = rb_str_new2(attrs->value);
#if HAS_ENCODING_SUPPORT
            if (0 != pi->options->rb_enc) {
                rb_enc_associate(s, pi->options->rb_enc);
            }
#elif HAS_PRIVATE_ENCODING
            if (Qnil != pi->options->rb_enc) {
		rb_funcall(s, ox_force_encoding_id, 1, pi->options->rb_enc);
            }
#endif
            rb_hash_aset(ah, sym, s);
        }
        rb_ivar_set(e, ox_attributes_id, ah);
    }
    if (helper_stack_empty(&pi->helpers)) { /* top level object */
	pi->obj = e;
    } else {
	rb_ary_push(helper_stack_peek(&pi->helpers)->obj, e);
    }
    if (hasChildren) {
        VALUE   nodes = rb_ary_new();

        rb_ivar_set(e, ox_nodes_id, nodes);
	helper_stack_push(&pi->helpers, 0, nodes, NoCode);
    } else {
	helper_stack_push(&pi->helpers, 0, Qnil, NoCode); // will be popped in end_element
    }
}

static void
end_element(PInfo pi, const char *ename) {
    if (!helper_stack_empty(&pi->helpers)) {
	helper_stack_pop(&pi->helpers);
    }
}

static void
add_instruct(PInfo pi, const char *name, Attr attrs, const char *content) {
    VALUE       inst;
    VALUE       s = rb_str_new2(name);
    VALUE       c = Qnil;

    if (0 != content) {
	c = rb_str_new2(content);
    }
#if HAS_ENCODING_SUPPORT
    if (0 != pi->options->rb_enc) {
        rb_enc_associate(s, pi->options->rb_enc);
	if (0 != content) {
	    rb_enc_associate(c, pi->options->rb_enc);
	}
    }
#elif HAS_PRIVATE_ENCODING
    if (Qnil != pi->options->rb_enc) {
	rb_funcall(s, ox_force_encoding_id, 1, pi->options->rb_enc);
	if (0 != content) {
	    rb_funcall(c, ox_force_encoding_id, 1, pi->options->rb_enc);
	}
    }
#endif
    inst = rb_obj_alloc(ox_instruct_clas);
    rb_ivar_set(inst, ox_at_value_id, s);
    if (0 != content) {
	rb_ivar_set(inst, ox_at_content_id, c);
    } else if (0 != attrs->name) {
        VALUE   ah = rb_hash_new();
        
        for (; 0 != attrs->name; attrs++) {
            VALUE   sym;
            VALUE   *slot;

	    if (Yes == pi->options->sym_keys) {
		if (Qundef == (sym = ox_cache_get(ox_symbol_cache, attrs->name, &slot, 0))) {
#if HAS_ENCODING_SUPPORT
		    if (0 != pi->options->rb_enc) {
			VALUE	rstr = rb_str_new2(attrs->name);

			rb_enc_associate(rstr, pi->options->rb_enc);
			sym = rb_funcall(rstr, ox_to_sym_id, 0);
		    } else {
			sym = ID2SYM(rb_intern(attrs->name));
		    }
#elif HAS_PRIVATE_ENCODING
		    if (Qnil != pi->options->rb_enc) {
			VALUE	rstr = rb_str_new2(attrs->name);

			rb_funcall(rstr, ox_force_encoding_id, 1, pi->options->rb_enc);
			sym = rb_funcall(rstr, ox_to_sym_id, 0);
		    } else {
			sym = ID2SYM(rb_intern(attrs->name));
		    }
#else
		    sym = ID2SYM(rb_intern(attrs->name));
#endif
		    // Needed for Ruby 2.2 to get around the GC of symbols
		    // created with to_sym which is needed for encoded symbols.
		    rb_ary_push(ox_sym_bank, sym);
		    *slot = sym;
		}
	    } else {
		sym = rb_str_new2(attrs->name);
#if HAS_ENCODING_SUPPORT
		if (0 != pi->options->rb_enc) {
		    rb_enc_associate(sym, pi->options->rb_enc);
		}
#elif HAS_PRIVATE_ENCODING
		if (Qnil != pi->options->rb_enc) {
		    rb_funcall(sym, ox_force_encoding_id, 1, pi->options->rb_enc);
		}
#endif
	    }
            s = rb_str_new2(attrs->value);
#if HAS_ENCODING_SUPPORT
            if (0 != pi->options->rb_enc) {
                rb_enc_associate(s, pi->options->rb_enc);
            }
#elif HAS_PRIVATE_ENCODING
	    if (Qnil != pi->options->rb_enc) {
		rb_funcall(s, ox_force_encoding_id, 1, pi->options->rb_enc);
	    }
#endif
            rb_hash_aset(ah, sym, s);
        }
        rb_ivar_set(inst, ox_attributes_id, ah);
    }
    if (helper_stack_empty(&pi->helpers)) { /* top level object */
	create_doc(pi);
    }
    rb_ary_push(helper_stack_peek(&pi->helpers)->obj, inst);
}
