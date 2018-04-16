#include "ruby.h"
#include "ext_help.h"
#include "ryah_http_parser.h"

#define GET_WRAPPER(N, from)  ParserWrapper *N = (ParserWrapper *)(from)->data;
#define HASH_CAT(h, k, ptr, len)                \
  do {                                          \
    VALUE __v = rb_hash_aref(h, k);             \
    if (__v != Qnil) {                          \
      rb_str_cat(__v, ptr, len);                \
    } else {                                    \
      rb_hash_aset(h, k, rb_str_new(ptr, len)); \
    }                                           \
  } while(0)

typedef struct ParserWrapper {
  ryah_http_parser parser;

  VALUE request_url;

  VALUE headers;

  VALUE upgrade_data;

  VALUE on_message_begin;
  VALUE on_headers_complete;
  VALUE on_body;
  VALUE on_message_complete;

  VALUE callback_object;
  VALUE stopped;
  VALUE completed;

  VALUE header_value_type;

  VALUE last_field_name;
  VALUE curr_field_name;

  enum ryah_http_parser_type type;
} ParserWrapper;

void ParserWrapper_init(ParserWrapper *wrapper) {
  ryah_http_parser_init(&wrapper->parser, wrapper->type);
  wrapper->parser.status_code = 0;
  wrapper->parser.http_major = 0;
  wrapper->parser.http_minor = 0;

  wrapper->request_url = Qnil;

  wrapper->upgrade_data = Qnil;

  wrapper->headers = Qnil;
  wrapper->completed = Qfalse;

  wrapper->last_field_name = Qnil;
  wrapper->curr_field_name = Qnil;
}

void ParserWrapper_mark(void *data) {
  if(data) {
    ParserWrapper *wrapper = (ParserWrapper *) data;
    rb_gc_mark_maybe(wrapper->request_url);
    rb_gc_mark_maybe(wrapper->upgrade_data);
    rb_gc_mark_maybe(wrapper->headers);
    rb_gc_mark_maybe(wrapper->on_message_begin);
    rb_gc_mark_maybe(wrapper->on_headers_complete);
    rb_gc_mark_maybe(wrapper->on_body);
    rb_gc_mark_maybe(wrapper->on_message_complete);
    rb_gc_mark_maybe(wrapper->callback_object);
    rb_gc_mark_maybe(wrapper->last_field_name);
    rb_gc_mark_maybe(wrapper->curr_field_name);
  }
}

void ParserWrapper_free(void *data) {
  if(data) {
    free(data);
  }
}

static VALUE cParser;
static VALUE cRequestParser;
static VALUE cResponseParser;

static VALUE eParserError;

static ID Icall;
static ID Ion_message_begin;
static ID Ion_headers_complete;
static ID Ion_body;
static ID Ion_message_complete;

static VALUE Sstop;
static VALUE Sreset;
static VALUE Sarrays;
static VALUE Sstrings;
static VALUE Smixed;

/** Callbacks **/

int on_message_begin(ryah_http_parser *parser) {
  GET_WRAPPER(wrapper, parser);

  wrapper->request_url = rb_str_new2("");
  wrapper->headers = rb_hash_new();
  wrapper->upgrade_data = rb_str_new2("");

  VALUE ret = Qnil;

  if (wrapper->callback_object != Qnil && rb_respond_to(wrapper->callback_object, Ion_message_begin)) {
    ret = rb_funcall(wrapper->callback_object, Ion_message_begin, 0);
  } else if (wrapper->on_message_begin != Qnil) {
    ret = rb_funcall(wrapper->on_message_begin, Icall, 0);
  }

  if (ret == Sstop) {
    wrapper->stopped = Qtrue;
    return -1;
  } else {
    return 0;
  }
}

int on_url(ryah_http_parser *parser, const char *at, size_t length) {
  GET_WRAPPER(wrapper, parser);
  rb_str_cat(wrapper->request_url, at, length);
  return 0;
}

int on_header_field(ryah_http_parser *parser, const char *at, size_t length) {
  GET_WRAPPER(wrapper, parser);

  if (wrapper->curr_field_name == Qnil) {
    wrapper->last_field_name = Qnil;
    wrapper->curr_field_name = rb_str_new(at, length);
  } else {
    rb_str_cat(wrapper->curr_field_name, at, length);
  }

  return 0;
}

int on_header_value(ryah_http_parser *parser, const char *at, size_t length) {
  GET_WRAPPER(wrapper, parser);

  int new_field = 0;
  VALUE current_value;

  if (wrapper->last_field_name == Qnil) {
    new_field = 1;
    wrapper->last_field_name = wrapper->curr_field_name;
    wrapper->curr_field_name = Qnil;
  }

  current_value = rb_hash_aref(wrapper->headers, wrapper->last_field_name);

  if (new_field == 1) {
    if (current_value == Qnil) {
      if (wrapper->header_value_type == Sarrays) {
        rb_hash_aset(wrapper->headers, wrapper->last_field_name, rb_ary_new3(1, rb_str_new2("")));
      } else {
        rb_hash_aset(wrapper->headers, wrapper->last_field_name, rb_str_new2(""));
      }
    } else {
      if (wrapper->header_value_type == Smixed) {
        if (TYPE(current_value) == T_STRING) {
          rb_hash_aset(wrapper->headers, wrapper->last_field_name, rb_ary_new3(2, current_value, rb_str_new2("")));
        } else {
          rb_ary_push(current_value, rb_str_new2(""));
        }
      } else if (wrapper->header_value_type == Sarrays) {
        rb_ary_push(current_value, rb_str_new2(""));
      } else {
        rb_str_cat(current_value, ", ", 2);
      }
    }
    current_value = rb_hash_aref(wrapper->headers, wrapper->last_field_name);
  }

  if (TYPE(current_value) == T_ARRAY) {
    current_value = rb_ary_entry(current_value, -1);
  }

  rb_str_cat(current_value, at, length);

  return 0;
}

int on_headers_complete(ryah_http_parser *parser) {
  GET_WRAPPER(wrapper, parser);

  VALUE ret = Qnil;

  if (wrapper->callback_object != Qnil && rb_respond_to(wrapper->callback_object, Ion_headers_complete)) {
    ret = rb_funcall(wrapper->callback_object, Ion_headers_complete, 1, wrapper->headers);
  } else if (wrapper->on_headers_complete != Qnil) {
    ret = rb_funcall(wrapper->on_headers_complete, Icall, 1, wrapper->headers);
  }

  if (ret == Sstop) {
    wrapper->stopped = Qtrue;
    return -1;
  } else if (ret == Sreset){
    return 1;
  } else {
    return 0;
  }
}

int on_body(ryah_http_parser *parser, const char *at, size_t length) {
  GET_WRAPPER(wrapper, parser);

  VALUE ret = Qnil;

  if (wrapper->callback_object != Qnil && rb_respond_to(wrapper->callback_object, Ion_body)) {
    ret = rb_funcall(wrapper->callback_object, Ion_body, 1, rb_str_new(at, length));
  } else if (wrapper->on_body != Qnil) {
    ret = rb_funcall(wrapper->on_body, Icall, 1, rb_str_new(at, length));
  }

  if (ret == Sstop) {
    wrapper->stopped = Qtrue;
    return -1;
  } else {
    return 0;
  }
}

int on_message_complete(ryah_http_parser *parser) {
  GET_WRAPPER(wrapper, parser);

  VALUE ret = Qnil;
  wrapper->completed = Qtrue;

  if (wrapper->callback_object != Qnil && rb_respond_to(wrapper->callback_object, Ion_message_complete)) {
    ret = rb_funcall(wrapper->callback_object, Ion_message_complete, 0);
  } else if (wrapper->on_message_complete != Qnil) {
    ret = rb_funcall(wrapper->on_message_complete, Icall, 0);
  }

  if (ret == Sstop) {
    wrapper->stopped = Qtrue;
    return -1;
  } else {
    return 0;
  }
}

static ryah_http_parser_settings settings = {
  .on_message_begin = on_message_begin,
  .on_url = on_url,
  .on_header_field = on_header_field,
  .on_header_value = on_header_value,
  .on_headers_complete = on_headers_complete,
  .on_body = on_body,
  .on_message_complete = on_message_complete
};

VALUE Parser_alloc_by_type(VALUE klass, enum ryah_http_parser_type type) {
  ParserWrapper *wrapper = ALLOC_N(ParserWrapper, 1);
  wrapper->type = type;
  wrapper->parser.data = wrapper;

  wrapper->on_message_begin = Qnil;
  wrapper->on_headers_complete = Qnil;
  wrapper->on_body = Qnil;
  wrapper->on_message_complete = Qnil;

  wrapper->callback_object = Qnil;

  ParserWrapper_init(wrapper);

  return Data_Wrap_Struct(klass, ParserWrapper_mark, ParserWrapper_free, wrapper);
}

VALUE Parser_alloc(VALUE klass) {
  return Parser_alloc_by_type(klass, HTTP_BOTH);
}

VALUE RequestParser_alloc(VALUE klass) {
  return Parser_alloc_by_type(klass, HTTP_REQUEST);
}

VALUE ResponseParser_alloc(VALUE klass) {
  return Parser_alloc_by_type(klass, HTTP_RESPONSE);
}

VALUE Parser_strict_p(VALUE klass) {
  return HTTP_PARSER_STRICT == 1 ? Qtrue : Qfalse;
}

VALUE Parser_initialize(int argc, VALUE *argv, VALUE self) {
  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);

  wrapper->header_value_type = rb_iv_get(CLASS_OF(self), "@default_header_value_type");

  if (argc == 1) {
    wrapper->callback_object = argv[0];
  }

  if (argc == 2) {
    wrapper->callback_object = argv[0];
    wrapper->header_value_type = argv[1];
  }

  return self;
}

VALUE Parser_execute(VALUE self, VALUE data) {
  ParserWrapper *wrapper = NULL;

  Check_Type(data, T_STRING);
  char *ptr = RSTRING_PTR(data);
  long len = RSTRING_LEN(data);

  DATA_GET(self, ParserWrapper, wrapper);

  wrapper->stopped = Qfalse;
  size_t nparsed = ryah_http_parser_execute(&wrapper->parser, &settings, ptr, len);

  if (wrapper->parser.upgrade) {
    if (RTEST(wrapper->stopped))
      nparsed += 1;

    rb_str_cat(wrapper->upgrade_data, ptr + nparsed, len - nparsed);

  } else if (nparsed != (size_t)len) {
    if (!RTEST(wrapper->stopped) && !RTEST(wrapper->completed))
      rb_raise(eParserError, "Could not parse data entirely (%zu != %zu)", nparsed, len);
    else
      nparsed += 1; // error states fail on the current character
  }

  return INT2FIX(nparsed);
}

VALUE Parser_set_on_message_begin(VALUE self, VALUE callback) {
  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);

  wrapper->on_message_begin = callback;
  return callback;
}

VALUE Parser_set_on_headers_complete(VALUE self, VALUE callback) {
  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);

  wrapper->on_headers_complete = callback;
  return callback;
}

VALUE Parser_set_on_body(VALUE self, VALUE callback) {
  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);

  wrapper->on_body = callback;
  return callback;
}

VALUE Parser_set_on_message_complete(VALUE self, VALUE callback) {
  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);

  wrapper->on_message_complete = callback;
  return callback;
}

VALUE Parser_keep_alive_p(VALUE self) {
  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);

  return http_should_keep_alive(&wrapper->parser) == 1 ? Qtrue : Qfalse;
}

VALUE Parser_upgrade_p(VALUE self) {
  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);

  return wrapper->parser.upgrade ? Qtrue : Qfalse;
}

VALUE Parser_http_version(VALUE self) {
  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);

  if (wrapper->parser.http_major == 0 && wrapper->parser.http_minor == 0)
    return Qnil;
  else
    return rb_ary_new3(2, INT2FIX(wrapper->parser.http_major), INT2FIX(wrapper->parser.http_minor));
}

VALUE Parser_http_major(VALUE self) {
  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);

  if (wrapper->parser.http_major == 0 && wrapper->parser.http_minor == 0)
    return Qnil;
  else
    return INT2FIX(wrapper->parser.http_major);
}

VALUE Parser_http_minor(VALUE self) {
  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);

  if (wrapper->parser.http_major == 0 && wrapper->parser.http_minor == 0)
    return Qnil;
  else
    return INT2FIX(wrapper->parser.http_minor);
}

VALUE Parser_http_method(VALUE self) {
  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);

  if (wrapper->parser.type == HTTP_REQUEST)
    return rb_str_new2(http_method_str(wrapper->parser.method));
  else
    return Qnil;
}

VALUE Parser_status_code(VALUE self) {
  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);

  if (wrapper->parser.status_code)
    return INT2FIX(wrapper->parser.status_code);
  else
    return Qnil;
}

#define DEFINE_GETTER(name)                  \
  VALUE Parser_##name(VALUE self) {          \
    ParserWrapper *wrapper = NULL;           \
    DATA_GET(self, ParserWrapper, wrapper);  \
    return wrapper->name;                    \
  }

DEFINE_GETTER(request_url);
DEFINE_GETTER(headers);
DEFINE_GETTER(upgrade_data);
DEFINE_GETTER(header_value_type);

VALUE Parser_set_header_value_type(VALUE self, VALUE val) {
  if (val != Sarrays && val != Sstrings && val != Smixed) {
    rb_raise(rb_eArgError, "Invalid header value type");
  }

  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);
  wrapper->header_value_type = val;
  return wrapper->header_value_type;
}

VALUE Parser_reset(VALUE self) {
  ParserWrapper *wrapper = NULL;
  DATA_GET(self, ParserWrapper, wrapper);

  ParserWrapper_init(wrapper);

  return Qtrue;
}

void Init_ruby_http_parser() {
  VALUE mHTTP = rb_define_module("HTTP");
  cParser = rb_define_class_under(mHTTP, "Parser", rb_cObject);
  cRequestParser = rb_define_class_under(mHTTP, "RequestParser", cParser);
  cResponseParser = rb_define_class_under(mHTTP, "ResponseParser", cParser);

  eParserError = rb_define_class_under(cParser, "Error", rb_eIOError);
  Icall = rb_intern("call");
  Ion_message_begin = rb_intern("on_message_begin");
  Ion_headers_complete = rb_intern("on_headers_complete");
  Ion_body = rb_intern("on_body");
  Ion_message_complete = rb_intern("on_message_complete");
  Sstop = ID2SYM(rb_intern("stop"));
  Sreset = ID2SYM(rb_intern("reset"));

  Sarrays = ID2SYM(rb_intern("arrays"));
  Sstrings = ID2SYM(rb_intern("strings"));
  Smixed = ID2SYM(rb_intern("mixed"));

  rb_define_alloc_func(cParser, Parser_alloc);
  rb_define_alloc_func(cRequestParser, RequestParser_alloc);
  rb_define_alloc_func(cResponseParser, ResponseParser_alloc);

  rb_define_singleton_method(cParser, "strict?", Parser_strict_p, 0);
  rb_define_method(cParser, "initialize", Parser_initialize, -1);

  rb_define_method(cParser, "on_message_begin=", Parser_set_on_message_begin, 1);
  rb_define_method(cParser, "on_headers_complete=", Parser_set_on_headers_complete, 1);
  rb_define_method(cParser, "on_body=", Parser_set_on_body, 1);
  rb_define_method(cParser, "on_message_complete=", Parser_set_on_message_complete, 1);
  rb_define_method(cParser, "<<", Parser_execute, 1);

  rb_define_method(cParser, "keep_alive?", Parser_keep_alive_p, 0);
  rb_define_method(cParser, "upgrade?", Parser_upgrade_p, 0);

  rb_define_method(cParser, "http_version", Parser_http_version, 0);
  rb_define_method(cParser, "http_major", Parser_http_major, 0);
  rb_define_method(cParser, "http_minor", Parser_http_minor, 0);

  rb_define_method(cParser, "http_method", Parser_http_method, 0);
  rb_define_method(cParser, "status_code", Parser_status_code, 0);

  rb_define_method(cParser, "request_url", Parser_request_url, 0);
  rb_define_method(cParser, "headers", Parser_headers, 0);
  rb_define_method(cParser, "upgrade_data", Parser_upgrade_data, 0);
  rb_define_method(cParser, "header_value_type", Parser_header_value_type, 0);
  rb_define_method(cParser, "header_value_type=", Parser_set_header_value_type, 1);

  rb_define_method(cParser, "reset!", Parser_reset, 0);
}
