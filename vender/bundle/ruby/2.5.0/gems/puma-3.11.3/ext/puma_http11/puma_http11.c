/**
 * Copyright (c) 2005 Zed A. Shaw
 * You can redistribute it and/or modify it under the same terms as Ruby.
 * License 3-clause BSD
 */

#define RSTRING_NOT_MODIFIED 1

#include "ruby.h"
#include "ext_help.h"
#include <assert.h>
#include <string.h>
#include "http11_parser.h"

#ifndef MANAGED_STRINGS

#ifndef RSTRING_PTR
#define RSTRING_PTR(s) (RSTRING(s)->ptr)
#endif
#ifndef RSTRING_LEN
#define RSTRING_LEN(s) (RSTRING(s)->len)
#endif

#define rb_extract_chars(e, sz) (*sz = RSTRING_LEN(e), RSTRING_PTR(e))
#define rb_free_chars(e) /* nothing */

#endif

static VALUE eHttpParserError;

#define HTTP_PREFIX "HTTP_"
#define HTTP_PREFIX_LEN (sizeof(HTTP_PREFIX) - 1)

static VALUE global_request_method;
static VALUE global_request_uri;
static VALUE global_fragment;
static VALUE global_query_string;
static VALUE global_http_version;
static VALUE global_request_path;

/** Defines common length and error messages for input length validation. */
#define DEF_MAX_LENGTH(N,length) const size_t MAX_##N##_LENGTH = length; const char *MAX_##N##_LENGTH_ERR = "HTTP element " # N  " is longer than the " # length " allowed length (was %d)"

/** Validates the max length of given input and throws an HttpParserError exception if over. */
#define VALIDATE_MAX_LENGTH(len, N) if(len > MAX_##N##_LENGTH) { rb_raise(eHttpParserError, MAX_##N##_LENGTH_ERR, len); }

/** Defines global strings in the init method. */
#define DEF_GLOBAL(N, val)   global_##N = rb_str_new2(val); rb_global_variable(&global_##N)


/* Defines the maximum allowed lengths for various input elements.*/
DEF_MAX_LENGTH(FIELD_NAME, 256);
DEF_MAX_LENGTH(FIELD_VALUE, 80 * 1024);
DEF_MAX_LENGTH(REQUEST_URI, 1024 * 12);
DEF_MAX_LENGTH(FRAGMENT, 1024); /* Don't know if this length is specified somewhere or not */
DEF_MAX_LENGTH(REQUEST_PATH, 2048);
DEF_MAX_LENGTH(QUERY_STRING, (1024 * 10));
DEF_MAX_LENGTH(HEADER, (1024 * (80 + 32)));

struct common_field {
	const size_t len;
	const char *name;
  int raw;
	VALUE value;
};

/*
 * A list of common HTTP headers we expect to receive.
 * This allows us to avoid repeatedly creating identical string
 * objects to be used with rb_hash_aset().
 */
static struct common_field common_http_fields[] = {
# define f(N) { (sizeof(N) - 1), N, 0, Qnil }
# define fr(N) { (sizeof(N) - 1), N, 1, Qnil }
	f("ACCEPT"),
	f("ACCEPT_CHARSET"),
	f("ACCEPT_ENCODING"),
	f("ACCEPT_LANGUAGE"),
	f("ALLOW"),
	f("AUTHORIZATION"),
	f("CACHE_CONTROL"),
	f("CONNECTION"),
	f("CONTENT_ENCODING"),
	fr("CONTENT_LENGTH"),
	fr("CONTENT_TYPE"),
	f("COOKIE"),
	f("DATE"),
	f("EXPECT"),
	f("FROM"),
	f("HOST"),
	f("IF_MATCH"),
	f("IF_MODIFIED_SINCE"),
	f("IF_NONE_MATCH"),
	f("IF_RANGE"),
	f("IF_UNMODIFIED_SINCE"),
	f("KEEP_ALIVE"), /* Firefox sends this */
	f("MAX_FORWARDS"),
	f("PRAGMA"),
	f("PROXY_AUTHORIZATION"),
	f("RANGE"),
	f("REFERER"),
	f("TE"),
	f("TRAILER"),
	f("TRANSFER_ENCODING"),
	f("UPGRADE"),
	f("USER_AGENT"),
	f("VIA"),
	f("X_FORWARDED_FOR"), /* common for proxies */
	f("X_REAL_IP"), /* common for proxies */
	f("WARNING")
# undef f
};

/*
 * qsort(3) and bsearch(3) improve average performance slightly, but may
 * not be worth it for lack of portability to certain platforms...
 */
#if defined(HAVE_QSORT_BSEARCH)
/* sort by length, then by name if there's a tie */
static int common_field_cmp(const void *a, const void *b)
{
  struct common_field *cfa = (struct common_field *)a;
  struct common_field *cfb = (struct common_field *)b;
  signed long diff = cfa->len - cfb->len;
  return diff ? diff : memcmp(cfa->name, cfb->name, cfa->len);
}
#endif /* HAVE_QSORT_BSEARCH */

static void init_common_fields(void)
{
  unsigned i;
  struct common_field *cf = common_http_fields;
  char tmp[256]; /* MAX_FIELD_NAME_LENGTH */
  memcpy(tmp, HTTP_PREFIX, HTTP_PREFIX_LEN);

  for(i = 0; i < ARRAY_SIZE(common_http_fields); cf++, i++) {
    if(cf->raw) {
      cf->value = rb_str_new(cf->name, cf->len);
    } else {
      memcpy(tmp + HTTP_PREFIX_LEN, cf->name, cf->len + 1);
      cf->value = rb_str_new(tmp, HTTP_PREFIX_LEN + cf->len);
    }
    rb_global_variable(&cf->value);
  }

#if defined(HAVE_QSORT_BSEARCH)
  qsort(common_http_fields,
        ARRAY_SIZE(common_http_fields),
        sizeof(struct common_field),
        common_field_cmp);
#endif /* HAVE_QSORT_BSEARCH */
}

static VALUE find_common_field_value(const char *field, size_t flen)
{
#if defined(HAVE_QSORT_BSEARCH)
  struct common_field key;
  struct common_field *found;
  key.name = field;
  key.len = (signed long)flen;
  found = (struct common_field *)bsearch(&key, common_http_fields,
                                         ARRAY_SIZE(common_http_fields),
                                         sizeof(struct common_field),
                                         common_field_cmp);
  return found ? found->value : Qnil;
#else /* !HAVE_QSORT_BSEARCH */
  unsigned i;
  struct common_field *cf = common_http_fields;
  for(i = 0; i < ARRAY_SIZE(common_http_fields); i++, cf++) {
    if (cf->len == flen && !memcmp(cf->name, field, flen))
      return cf->value;
  }
  return Qnil;
#endif /* !HAVE_QSORT_BSEARCH */
}

void http_field(puma_parser* hp, const char *field, size_t flen,
                                 const char *value, size_t vlen)
{
  VALUE f = Qnil;
  VALUE v;

  VALIDATE_MAX_LENGTH(flen, FIELD_NAME);
  VALIDATE_MAX_LENGTH(vlen, FIELD_VALUE);

  f = find_common_field_value(field, flen);

  if (f == Qnil) {
    /*
     * We got a strange header that we don't have a memoized value for.
     * Fallback to creating a new string to use as a hash key.
     */

    size_t new_size = HTTP_PREFIX_LEN + flen;
    assert(new_size < BUFFER_LEN);

    memcpy(hp->buf, HTTP_PREFIX, HTTP_PREFIX_LEN);
    memcpy(hp->buf + HTTP_PREFIX_LEN, field, flen);

    f = rb_str_new(hp->buf, new_size);
  }

  /* check for duplicate header */
  v = rb_hash_aref(hp->request, f);

  if (v == Qnil) {
      v = rb_str_new(value, vlen);
      rb_hash_aset(hp->request, f, v);
  } else {
      /* if duplicate header, normalize to comma-separated values */
      rb_str_cat2(v, ", ");
      rb_str_cat(v, value, vlen);
  }
}

void request_method(puma_parser* hp, const char *at, size_t length)
{
  VALUE val = Qnil;

  val = rb_str_new(at, length);
  rb_hash_aset(hp->request, global_request_method, val);
}

void request_uri(puma_parser* hp, const char *at, size_t length)
{
  VALUE val = Qnil;

  VALIDATE_MAX_LENGTH(length, REQUEST_URI);

  val = rb_str_new(at, length);
  rb_hash_aset(hp->request, global_request_uri, val);
}

void fragment(puma_parser* hp, const char *at, size_t length)
{
  VALUE val = Qnil;

  VALIDATE_MAX_LENGTH(length, FRAGMENT);

  val = rb_str_new(at, length);
  rb_hash_aset(hp->request, global_fragment, val);
}

void request_path(puma_parser* hp, const char *at, size_t length)
{
  VALUE val = Qnil;

  VALIDATE_MAX_LENGTH(length, REQUEST_PATH);

  val = rb_str_new(at, length);
  rb_hash_aset(hp->request, global_request_path, val);
}

void query_string(puma_parser* hp, const char *at, size_t length)
{
  VALUE val = Qnil;

  VALIDATE_MAX_LENGTH(length, QUERY_STRING);

  val = rb_str_new(at, length);
  rb_hash_aset(hp->request, global_query_string, val);
}

void http_version(puma_parser* hp, const char *at, size_t length)
{
  VALUE val = rb_str_new(at, length);
  rb_hash_aset(hp->request, global_http_version, val);
}

/** Finalizes the request header to have a bunch of stuff that's
  needed. */

void header_done(puma_parser* hp, const char *at, size_t length)
{
  hp->body = rb_str_new(at, length);
}


void HttpParser_free(void *data) {
  TRACE();

  if(data) {
    xfree(data);
  }
}

void HttpParser_mark(puma_parser* hp) {
  if(hp->request) rb_gc_mark(hp->request);
  if(hp->body) rb_gc_mark(hp->body);
}

VALUE HttpParser_alloc(VALUE klass)
{
  puma_parser *hp = ALLOC_N(puma_parser, 1);
  TRACE();
  hp->http_field = http_field;
  hp->request_method = request_method;
  hp->request_uri = request_uri;
  hp->fragment = fragment;
  hp->request_path = request_path;
  hp->query_string = query_string;
  hp->http_version = http_version;
  hp->header_done = header_done;
  hp->request = Qnil;

  puma_parser_init(hp);

  return Data_Wrap_Struct(klass, HttpParser_mark, HttpParser_free, hp);
}

/**
 * call-seq:
 *    parser.new -> parser
 *
 * Creates a new parser.
 */
VALUE HttpParser_init(VALUE self)
{
  puma_parser *http = NULL;
  DATA_GET(self, puma_parser, http);
  puma_parser_init(http);

  return self;
}


/**
 * call-seq:
 *    parser.reset -> nil
 *
 * Resets the parser to it's initial state so that you can reuse it
 * rather than making new ones.
 */
VALUE HttpParser_reset(VALUE self)
{
  puma_parser *http = NULL;
  DATA_GET(self, puma_parser, http);
  puma_parser_init(http);

  return Qnil;
}


/**
 * call-seq:
 *    parser.finish -> true/false
 *
 * Finishes a parser early which could put in a "good" or bad state.
 * You should call reset after finish it or bad things will happen.
 */
VALUE HttpParser_finish(VALUE self)
{
  puma_parser *http = NULL;
  DATA_GET(self, puma_parser, http);
  puma_parser_finish(http);

  return puma_parser_is_finished(http) ? Qtrue : Qfalse;
}


/**
 * call-seq:
 *    parser.execute(req_hash, data, start) -> Integer
 *
 * Takes a Hash and a String of data, parses the String of data filling in the Hash
 * returning an Integer to indicate how much of the data has been read.  No matter
 * what the return value, you should call HttpParser#finished? and HttpParser#error?
 * to figure out if it's done parsing or there was an error.
 *
 * This function now throws an exception when there is a parsing error.  This makes
 * the logic for working with the parser much easier.  You can still test for an
 * error, but now you need to wrap the parser with an exception handling block.
 *
 * The third argument allows for parsing a partial request and then continuing
 * the parsing from that position.  It needs all of the original data as well
 * so you have to append to the data buffer as you read.
 */
VALUE HttpParser_execute(VALUE self, VALUE req_hash, VALUE data, VALUE start)
{
  puma_parser *http = NULL;
  int from = 0;
  char *dptr = NULL;
  long dlen = 0;

  DATA_GET(self, puma_parser, http);

  from = FIX2INT(start);
  dptr = rb_extract_chars(data, &dlen);

  if(from >= dlen) {
    rb_free_chars(dptr);
    rb_raise(eHttpParserError, "%s", "Requested start is after data buffer end.");
  } else {
    http->request = req_hash;
    puma_parser_execute(http, dptr, dlen, from);

    rb_free_chars(dptr);
    VALIDATE_MAX_LENGTH(puma_parser_nread(http), HEADER);

    if(puma_parser_has_error(http)) {
      rb_raise(eHttpParserError, "%s", "Invalid HTTP format, parsing fails.");
    } else {
      return INT2FIX(puma_parser_nread(http));
    }
  }
}



/**
 * call-seq:
 *    parser.error? -> true/false
 *
 * Tells you whether the parser is in an error state.
 */
VALUE HttpParser_has_error(VALUE self)
{
  puma_parser *http = NULL;
  DATA_GET(self, puma_parser, http);

  return puma_parser_has_error(http) ? Qtrue : Qfalse;
}


/**
 * call-seq:
 *    parser.finished? -> true/false
 *
 * Tells you whether the parser is finished or not and in a good state.
 */
VALUE HttpParser_is_finished(VALUE self)
{
  puma_parser *http = NULL;
  DATA_GET(self, puma_parser, http);

  return puma_parser_is_finished(http) ? Qtrue : Qfalse;
}


/**
 * call-seq:
 *    parser.nread -> Integer
 *
 * Returns the amount of data processed so far during this processing cycle.  It is
 * set to 0 on initialize or reset calls and is incremented each time execute is called.
 */
VALUE HttpParser_nread(VALUE self)
{
  puma_parser *http = NULL;
  DATA_GET(self, puma_parser, http);

  return INT2FIX(http->nread);
}

/**
 * call-seq:
 *    parser.body -> nil or String
 *
 * If the request included a body, returns it.
 */
VALUE HttpParser_body(VALUE self) {
  puma_parser *http = NULL;
  DATA_GET(self, puma_parser, http);

  return http->body;
}

void Init_io_buffer(VALUE puma);
void Init_mini_ssl(VALUE mod);

void Init_puma_http11()
{

  VALUE mPuma = rb_define_module("Puma");
  VALUE cHttpParser = rb_define_class_under(mPuma, "HttpParser", rb_cObject);

  DEF_GLOBAL(request_method, "REQUEST_METHOD");
  DEF_GLOBAL(request_uri, "REQUEST_URI");
  DEF_GLOBAL(fragment, "FRAGMENT");
  DEF_GLOBAL(query_string, "QUERY_STRING");
  DEF_GLOBAL(http_version, "HTTP_VERSION");
  DEF_GLOBAL(request_path, "REQUEST_PATH");

  eHttpParserError = rb_define_class_under(mPuma, "HttpParserError", rb_eIOError);
  rb_global_variable(&eHttpParserError);

  rb_define_alloc_func(cHttpParser, HttpParser_alloc);
  rb_define_method(cHttpParser, "initialize", HttpParser_init, 0);
  rb_define_method(cHttpParser, "reset", HttpParser_reset, 0);
  rb_define_method(cHttpParser, "finish", HttpParser_finish, 0);
  rb_define_method(cHttpParser, "execute", HttpParser_execute, 3);
  rb_define_method(cHttpParser, "error?", HttpParser_has_error, 0);
  rb_define_method(cHttpParser, "finished?", HttpParser_is_finished, 0);
  rb_define_method(cHttpParser, "nread", HttpParser_nread, 0);
  rb_define_method(cHttpParser, "body", HttpParser_body, 0);
  init_common_fields();

  Init_io_buffer(mPuma);
  Init_mini_ssl(mPuma);
}
