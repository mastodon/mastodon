/**
 * Copyright (c) 2005 Zed A. Shaw
 * You can redistribute it and/or modify it under the same terms as Ruby.
 * License 3-clause BSD
 */
#include "http11_parser.h"
#include <stdio.h>
#include <assert.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

/*
 * capitalizes all lower-case ASCII characters,
 * converts dashes to underscores.
 */
static void snake_upcase_char(char *c)
{
    if (*c >= 'a' && *c <= 'z')
      *c &= ~0x20;
    else if (*c == '-')
      *c = '_';
}

#define LEN(AT, FPC) (FPC - buffer - parser->AT)
#define MARK(M,FPC) (parser->M = (FPC) - buffer)
#define PTR_TO(F) (buffer + parser->F)

/** Machine **/

%%{

  machine puma_parser;

  action mark { MARK(mark, fpc); }


  action start_field { MARK(field_start, fpc); }
  action snake_upcase_field { snake_upcase_char((char *)fpc); }
  action write_field {
    parser->field_len = LEN(field_start, fpc);
  }

  action start_value { MARK(mark, fpc); }
  action write_value {
    parser->http_field(parser, PTR_TO(field_start), parser->field_len, PTR_TO(mark), LEN(mark, fpc));
  }
  action request_method {
    parser->request_method(parser, PTR_TO(mark), LEN(mark, fpc));
  }
  action request_uri {
    parser->request_uri(parser, PTR_TO(mark), LEN(mark, fpc));
  }
  action fragment {
    parser->fragment(parser, PTR_TO(mark), LEN(mark, fpc));
  }

  action start_query { MARK(query_start, fpc); }
  action query_string {
    parser->query_string(parser, PTR_TO(query_start), LEN(query_start, fpc));
  }

  action http_version {
    parser->http_version(parser, PTR_TO(mark), LEN(mark, fpc));
  }

  action request_path {
    parser->request_path(parser, PTR_TO(mark), LEN(mark,fpc));
  }

  action done {
    parser->body_start = fpc - buffer + 1;
    parser->header_done(parser, fpc + 1, pe - fpc - 1);
    fbreak;
  }

  include puma_parser_common "http11_parser_common.rl";

}%%

/** Data **/
%% write data;

int puma_parser_init(puma_parser *parser)  {
  int cs = 0;
  %% write init;
  parser->cs = cs;
  parser->body_start = 0;
  parser->content_len = 0;
  parser->mark = 0;
  parser->nread = 0;
  parser->field_len = 0;
  parser->field_start = 0;
  parser->request = Qnil;
  parser->body = Qnil;

  return 1;
}


/** exec **/
size_t puma_parser_execute(puma_parser *parser, const char *buffer, size_t len, size_t off)  {
  const char *p, *pe;
  int cs = parser->cs;

  assert(off <= len && "offset past end of buffer");

  p = buffer+off;
  pe = buffer+len;

  /* assert(*pe == '\0' && "pointer does not end on NUL"); */
  assert((size_t) (pe - p) == len - off && "pointers aren't same distance");

  %% write exec;

  if (!puma_parser_has_error(parser))
    parser->cs = cs;
  parser->nread += p - (buffer + off);

  assert(p <= pe && "buffer overflow after parsing execute");
  assert(parser->nread <= len && "nread longer than length");
  assert(parser->body_start <= len && "body starts after buffer end");
  assert(parser->mark < len && "mark is after buffer end");
  assert(parser->field_len <= len && "field has length longer than whole buffer");
  assert(parser->field_start < len && "field starts after buffer end");

  return(parser->nread);
}

int puma_parser_finish(puma_parser *parser)
{
  if (puma_parser_has_error(parser) ) {
    return -1;
  } else if (puma_parser_is_finished(parser) ) {
    return 1;
  } else {
    return 0;
  }
}

int puma_parser_has_error(puma_parser *parser) {
  return parser->cs == puma_parser_error;
}

int puma_parser_is_finished(puma_parser *parser) {
  return parser->cs >= puma_parser_first_final;
}
