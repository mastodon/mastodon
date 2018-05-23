/* odd.c
 * Copyright (c) 2011, Peter Ohler
 * All rights reserved.
 */

#include <string.h>

#include "odd.h"

static struct _Odd	_odds[4]; // bump up if new initial Odd classes are added
static struct _Odd	*odds = _odds;
static long		odd_cnt = 0;
static ID		sec_id;
static ID		sec_fraction_id;
static ID		to_f_id;
static ID		numerator_id;
static ID		denominator_id;
static ID		rational_id;
static VALUE		rational_class;

static void
set_class(Odd odd, const char *classname) {
    const char	**np;
    ID		*idp;

    odd->classname = classname;
    odd->clen = strlen(classname);
    odd->clas = rb_const_get(rb_cObject, rb_intern(classname));
    odd->create_obj = odd->clas;
    odd->create_op = rb_intern("new");
    odd->is_module = (T_MODULE == rb_type(odd->clas));
    odd->raw = 0;
    for (np = odd->attr_names, idp = odd->attrs; 0 != *np; np++, idp++) {
	*idp = rb_intern(*np);
    }
    *idp = 0;
}

static VALUE
get_datetime_secs(VALUE obj) {
    VALUE	rsecs = rb_funcall(obj, sec_id, 0);
    VALUE	rfrac = rb_funcall(obj, sec_fraction_id, 0);
    long	sec = NUM2LONG(rsecs);
    long long	num = rb_num2ll(rb_funcall(rfrac, numerator_id, 0));
    long long	den = rb_num2ll(rb_funcall(rfrac, denominator_id, 0));

    num += sec * den;

    return rb_funcall(rb_cObject, rational_id, 2, rb_ll2inum(num), rb_ll2inum(den));
}

void
oj_odd_init() {
    Odd		odd;
    const char	**np;

    sec_id = rb_intern("sec");
    sec_fraction_id = rb_intern("sec_fraction");
    to_f_id = rb_intern("to_f");
    numerator_id = rb_intern("numerator");
    denominator_id = rb_intern("denominator");
    rational_id = rb_intern("Rational");
    rational_class = rb_const_get(rb_cObject, rational_id);

    memset(_odds, 0, sizeof(_odds));
    odd = odds;
    // Rational
    np = odd->attr_names;
    *np++ = "numerator";
    *np++ = "denominator";
    *np = 0;
    set_class(odd, "Rational");
    odd->create_obj = rb_cObject;
    odd->create_op = rational_id;
    odd->attr_cnt = 2;
    // Date
    odd++;
    np = odd->attr_names;
    *np++ = "year";
    *np++ = "month";
    *np++ = "day";
    *np++ = "start";
    *np++ = 0;
    set_class(odd, "Date");
    odd->attr_cnt = 4;
    // DateTime
    odd++;
    np = odd->attr_names;
    *np++ = "year";
    *np++ = "month";
    *np++ = "day";
    *np++ = "hour";
    *np++ = "min";
    *np++ = "sec";
    *np++ = "offset";
    *np++ = "start";
    *np++ = 0;
    set_class(odd, "DateTime");
    odd->attr_cnt = 8;
    odd->attrFuncs[5] = get_datetime_secs;
    // Range
    odd++;
    np = odd->attr_names;
    *np++ = "begin";
    *np++ = "end";
    *np++ = "exclude_end?";
    *np++ = 0;
    set_class(odd, "Range");
    odd->attr_cnt = 3;

    odd_cnt = odd - odds + 1;
}

Odd
oj_get_odd(VALUE clas) {
    Odd		odd;
    const char	*classname = NULL;

    for (odd = odds + odd_cnt - 1; odds <= odd; odd--) {
	if (clas == odd->clas) {
	    return odd;
	}
	if (odd->is_module) {
	    if (NULL == classname) {
		classname = rb_class2name(clas);
	    }
	    if (0 == strncmp(odd->classname, classname, odd->clen) &&
		':' == classname[odd->clen]) {
		return odd;
	    }
	}
    }
    return NULL;
}

Odd
oj_get_oddc(const char *classname, size_t len) {
    Odd	odd;

    for (odd = odds + odd_cnt - 1; odds <= odd; odd--) {
	if (len == odd->clen && 0 == strncmp(classname, odd->classname, len)) {
	    return odd;
	}
	if (odd->is_module &&
	    0 == strncmp(odd->classname, classname, odd->clen) &&
	    ':' == classname[odd->clen]) {
	    return odd;
	}
    }
    return 0;
}

OddArgs
oj_odd_alloc_args(Odd odd) {
    OddArgs	oa = ALLOC_N(struct _OddArgs, 1);
    VALUE	*a;
    int		i;

    oa->odd = odd;
    for (i = odd->attr_cnt, a = oa->args; 0 < i; i--, a++) {
	*a = Qnil;
    }
    return oa;
}

void
oj_odd_free(OddArgs args) {
    xfree(args);
}

int
oj_odd_set_arg(OddArgs args, const char *key, size_t klen, VALUE value) {
    const char	**np;
    VALUE	*vp;
    int		i;

    for (i = args->odd->attr_cnt, np = args->odd->attr_names, vp = args->args; 0 < i; i--, np++, vp++) {
	if (0 == strncmp(key, *np, klen) && '\0' == *((*np) + klen)) {
	    *vp = value;
	    return 0;
	}
    }
    return -1;
}

void
oj_reg_odd(VALUE clas, VALUE create_object, VALUE create_method, int mcnt, VALUE *members, bool raw) {
    Odd		odd;
    const char	**np;
    ID		*ap;
    AttrGetFunc	*fp;

    if (_odds == odds) {
	odds = ALLOC_N(struct _Odd, odd_cnt + 1);

	memcpy(odds, _odds, sizeof(struct _Odd) * odd_cnt);
    } else {
	REALLOC_N(odds, struct _Odd, odd_cnt + 1);
    }
    odd = odds + odd_cnt;
    odd->clas = clas;
    odd->classname = strdup(rb_class2name(clas));
    odd->clen = strlen(odd->classname);
    odd->create_obj = create_object;
    odd->create_op = SYM2ID(create_method);
    odd->attr_cnt = mcnt;
    odd->is_module = (T_MODULE == rb_type(clas));
    odd->raw = raw;
    for (ap = odd->attrs, np = odd->attr_names, fp = odd->attrFuncs; 0 < mcnt; mcnt--, ap++, np++, members++, fp++) {
	*fp = 0;
	switch (rb_type(*members)) {
	case T_STRING:
	    *np = strdup(rb_string_value_ptr(members));
	    break;
	case T_SYMBOL:
	    *np = rb_id2name(SYM2ID(*members));
	    break;
	default:
	    rb_raise(rb_eArgError, "registered member identifiers must be Strings or Symbols.");
	    break;
	}
	*ap = rb_intern(*np);
    }
    *np = 0;
    *ap = 0;
    odd_cnt++;
}
