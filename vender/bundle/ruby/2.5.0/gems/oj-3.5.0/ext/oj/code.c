/* code.c
 * Copyright (c) 2017, Peter Ohler
 * All rights reserved.
 */

#include "code.h"
#include "dump.h"

inline static VALUE
resolve_classname(VALUE mod, const char *classname) {
    VALUE	clas = Qundef;
    ID		ci = rb_intern(classname);

    if (rb_const_defined_at(mod, ci)) {
	clas = rb_const_get_at(mod, ci);
    }
    return clas;
}

static VALUE
path2class(const char *name) {
    char	class_name[1024];
    VALUE	clas;
    char	*end = class_name + sizeof(class_name) - 1;
    char	*s;
    const char	*n = name;

    clas = rb_cObject;
    for (s = class_name; '\0' != *n; n++) {
	if (':' == *n) {
	    *s = '\0';
	    n++;
	    if (':' != *n) {
		return Qundef;
	    }
	    if (Qundef == (clas = resolve_classname(clas, class_name))) {
		return Qundef;
	    }
	    s = class_name;
	} else if (end <= s) {
	    return Qundef;
	} else {
	    *s++ = *n;
	}
    }
    *s = '\0';

    return resolve_classname(clas, class_name);
}

bool
oj_code_dump(Code codes, VALUE obj, int depth, Out out) {
    VALUE	clas = rb_obj_class(obj);
    Code	c = codes;

    for (; NULL != c->name; c++) {
	if (Qundef == c->clas) { // indicates not defined
	    continue;
	}
	if (Qnil == c->clas) {
	    c->clas = path2class(c->name);
	}
	if (clas == c->clas && c->active) {
	    c->encode(obj, depth, out);
	    return true;
	}
    }
    return false;
}

VALUE
oj_code_load(Code codes, VALUE clas, VALUE args) {
    Code	c = codes;

    for (; NULL != c->name; c++) {
	if (Qundef == c->clas) { // indicates not defined
	    continue;
	}
	if (Qnil == c->clas) {
	    c->clas = path2class(c->name);
	}
	if (clas == c->clas) {
	    if (NULL == c->decode) {
		break;
	    }
	    return c->decode(clas, args);
	}
    }
    return Qnil;
}

void
oj_code_set_active(Code codes, VALUE clas, bool active) {
    Code	c = codes;

    for (; NULL != c->name; c++) {
	if (Qundef == c->clas) { // indicates not defined
	    continue;
	}
	if (Qnil == c->clas) {
	    c->clas = path2class(c->name);
	}
	if (clas == c->clas || Qnil == clas) {
	    c->active = active;
	    if (Qnil != clas) {
		break;
	    }
	}
    }
}

bool
oj_code_has(Code codes, VALUE clas, bool encode) {
    Code	c = codes;

    for (; NULL != c->name; c++) {
	if (Qundef == c->clas) { // indicates not defined
	    continue;
	}
	if (Qnil == c->clas) {
	    c->clas = path2class(c->name);
	}
	if (clas == c->clas) {
	    if (encode) {
		return c->active && NULL != c->encode;
	    } else {
		return c->active && NULL != c->decode;
	    }
	}
    }
    return false;
}

void
oj_code_attrs(VALUE obj, Attr attrs, int depth, Out out, bool with_class) {
    int		d2 = depth + 1;
    int		d3 = d2 + 1;
    size_t	sep_len = out->opts->dump_opts.before_size + out->opts->dump_opts.after_size + 2;
    const char	*classname = rb_obj_classname(obj);
    size_t	len = strlen(classname);
    size_t	size = d2 * out->indent + 10 + len + out->opts->create_id_len + sep_len;
    bool	no_comma = true;
    
    assure_size(out, size);
    *out->cur++ = '{';

    if (with_class) {
	fill_indent(out, d2);
	*out->cur++ = '"';
	memcpy(out->cur, out->opts->create_id, out->opts->create_id_len);
	out->cur += out->opts->create_id_len;
	*out->cur++ = '"';
	if (0 < out->opts->dump_opts.before_size) {
	    strcpy(out->cur, out->opts->dump_opts.before_sep);
	    out->cur += out->opts->dump_opts.before_size;
	}
	*out->cur++ = ':';
	if (0 < out->opts->dump_opts.after_size) {
	    strcpy(out->cur, out->opts->dump_opts.after_sep);
	    out->cur += out->opts->dump_opts.after_size;
	}
	*out->cur++ = '"';
	memcpy(out->cur, classname, len);
	out->cur += len;
	*out->cur++ = '"';
	no_comma = false;
    }
    size = d3 * out->indent + 2;
    for (; NULL != attrs->name; attrs++) {
	assure_size(out, size + attrs->len + sep_len + 2);
	if (no_comma) {
	    no_comma = false;
	} else {
	    *out->cur++ = ',';
	}
	fill_indent(out, d2);
	*out->cur++ = '"';
	memcpy(out->cur, attrs->name, attrs->len);
	out->cur += attrs->len;
	*out->cur++ = '"';
	if (0 < out->opts->dump_opts.before_size) {
	    strcpy(out->cur, out->opts->dump_opts.before_sep);
	    out->cur += out->opts->dump_opts.before_size;
	}
	*out->cur++ = ':';
	if (0 < out->opts->dump_opts.after_size) {
	    strcpy(out->cur, out->opts->dump_opts.after_sep);
	    out->cur += out->opts->dump_opts.after_size;
	}
	if (Qundef == attrs->value) {
	    if (Qundef != attrs->time) {
		switch (out->opts->time_format) {
		case RubyTime:	oj_dump_ruby_time(attrs->time, out);	break;
		case XmlTime:	oj_dump_xml_time(attrs->time, out);	break;
		case UnixZTime:	oj_dump_time(attrs->time, out, true);	break;
		case UnixTime:
		default:	oj_dump_time(attrs->time, out, false);	break;
		}
	    } else {
		char	buf[32];
		char	*b = buf + sizeof(buf) - 1;
		int	neg = 0;
		long	num = attrs->num;
	    
		if (0 > num) {
		    neg = 1;
		    num = -num;
		}
		*b-- = '\0';
		if (0 < num) {
		    for (; 0 < num; num /= 10, b--) {
			*b = (num % 10) + '0';
		    }
		    if (neg) {
			*b = '-';
		    } else {
			b++;
		    }
		} else {
		    *b = '0';
		}
		assure_size(out, (sizeof(buf) - (b - buf)));
		for (; '\0' != *b; b++) {
		    *out->cur++ = *b;
		}
	    }
	} else {
	    oj_dump_compat_val(attrs->value, d3, out, true);
	}
    }
    assure_size(out, depth * out->indent + 2);
    fill_indent(out, depth);
    *out->cur++ = '}';
    *out->cur = '\0';
}
