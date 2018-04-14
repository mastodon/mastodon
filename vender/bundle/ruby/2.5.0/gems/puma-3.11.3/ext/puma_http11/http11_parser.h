/**
 * Copyright (c) 2005 Zed A. Shaw
 * You can redistribute it and/or modify it under the same terms as Ruby.
 * License 3-clause BSD
 */

#ifndef http11_parser_h
#define http11_parser_h

#define RSTRING_NOT_MODIFIED 1
#include "ruby.h"

#include <sys/types.h>

#if defined(_WIN32)
#include <stddef.h>
#endif

#define BUFFER_LEN 1024

struct puma_parser;

typedef void (*element_cb)(struct puma_parser* hp,
                           const char *at, size_t length);

typedef void (*field_cb)(struct puma_parser* hp,
                         const char *field, size_t flen,
                         const char *value, size_t vlen);

typedef struct puma_parser {
  int cs;
  size_t body_start;
  int content_len;
  size_t nread;
  size_t mark;
  size_t field_start;
  size_t field_len;
  size_t query_start;

  VALUE request;
  VALUE body;

  field_cb http_field;
  element_cb request_method;
  element_cb request_uri;
  element_cb fragment;
  element_cb request_path;
  element_cb query_string;
  element_cb http_version;
  element_cb header_done;

  char buf[BUFFER_LEN];
  
} puma_parser;

int puma_parser_init(puma_parser *parser);
int puma_parser_finish(puma_parser *parser);
size_t puma_parser_execute(puma_parser *parser, const char *data,
                           size_t len, size_t off);
int puma_parser_has_error(puma_parser *parser);
int puma_parser_is_finished(puma_parser *parser);

#define puma_parser_nread(parser) (parser)->nread

#endif
