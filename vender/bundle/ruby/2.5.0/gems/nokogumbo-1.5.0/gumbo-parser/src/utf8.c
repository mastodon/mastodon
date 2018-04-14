// Copyright 2010 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Author: jdtang@google.com (Jonathan Tang)

#include "utf8.h"

#include <assert.h>
#include <stdint.h>
#include <string.h>
#include <strings.h>  // For strncasecmp.

#include "error.h"
#include "gumbo.h"
#include "parser.h"
#include "util.h"
#include "vector.h"

const int kUtf8ReplacementChar = 0xFFFD;

// Reference material:
// Wikipedia: http://en.wikipedia.org/wiki/UTF-8#Description
// RFC 3629: http://tools.ietf.org/html/rfc3629
// HTML5 Unicode handling:
// http://www.whatwg.org/specs/web-apps/current-work/multipage/syntax.html#preprocessing-the-input-stream
//
// This implementation is based on a DFA-based decoder by Bjoern Hoehrmann
// <bjoern@hoehrmann.de>.  We wrap the inner table-based decoder routine in our
// own handling for newlines, tabs, invalid continuation bytes, and other
// conditions that the HTML5 spec fully specifies but normal UTF8 decoders do
// not handle.
// See http://bjoern.hoehrmann.de/utf-8/decoder/dfa/ for details.  Full text of
// the license agreement and code follows.

// Copyright (c) 2008-2009 Bjoern Hoehrmann <bjoern@hoehrmann.de>

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
// of the Software, and to permit persons to whom the Software is furnished to
// do
// so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

#define UTF8_ACCEPT 0
#define UTF8_REJECT 12

static const uint8_t utf8d[] = {
    // The first part of the table maps bytes to character classes that
    // to reduce the size of the transition table and create bitmasks.
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 9, 9, 9, 9, 9, 9,
    9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8, 8, 2, 2, 2, 2, 2, 2,
    2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 10,
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 4, 3, 3, 11, 6, 6, 6, 5, 8, 8, 8, 8, 8,
    8, 8, 8, 8, 8, 8,

    // The second part is a transition table that maps a combination
    // of a state of the automaton and a character class to a state.
    0, 12, 24, 36, 60, 96, 84, 12, 12, 12, 48, 72, 12, 12, 12, 12, 12, 12, 12,
    12, 12, 12, 12, 12, 12, 0, 12, 12, 12, 12, 12, 0, 12, 0, 12, 12, 12, 24, 12,
    12, 12, 12, 12, 24, 12, 24, 12, 12, 12, 12, 12, 12, 12, 12, 12, 24, 12, 12,
    12, 12, 12, 24, 12, 12, 12, 12, 12, 12, 12, 24, 12, 12, 12, 12, 12, 12, 12,
    12, 12, 36, 12, 36, 12, 12, 12, 36, 12, 12, 12, 12, 12, 36, 12, 36, 12, 12,
    12, 36, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
};

uint32_t static inline decode(uint32_t* state, uint32_t* codep, uint32_t byte) {
  uint32_t type = utf8d[byte];

  *codep = (*state != UTF8_ACCEPT) ? (byte & 0x3fu) | (*codep << 6)
                                   : (0xff >> type) & (byte);

  *state = utf8d[256 + *state + type];
  return *state;
}

// END COPIED CODE.

// Adds a decoding error to the parser's error list, based on the current state
// of the Utf8Iterator.
static void add_error(Utf8Iterator* iter, GumboErrorType type) {
  GumboParser* parser = iter->_parser;

  GumboError* error = gumbo_add_error(parser);
  if (!error) {
    return;
  }
  error->type = type;
  error->position = iter->_pos;
  error->original_text = iter->_start;

  // At the point the error is recorded, the code point hasn't been computed
  // yet (and can't be, because it's invalid), so we need to build up the raw
  // hex value from the bytes under the cursor.
  uint64_t code_point = 0;
  for (int i = 0; i < iter->_width; ++i) {
    code_point = (code_point << 8) | (unsigned char) iter->_start[i];
  }
  error->v.codepoint = code_point;
}

// Reads the next UTF-8 character in the iter.
// This assumes that iter->_start points to the beginning of the character.
// When this method returns, iter->_width and iter->_current will be set
// appropriately, as well as any error flags.
static void read_char(Utf8Iterator* iter) {
  if (iter->_start >= iter->_end) {
    // No input left to consume; emit an EOF and set width = 0.
    iter->_current = -1;
    iter->_width = 0;
    return;
  }

  uint32_t code_point = 0;
  uint32_t state = UTF8_ACCEPT;
  for (const char* c = iter->_start; c < iter->_end; ++c) {
    decode(&state, &code_point, (uint32_t)(unsigned char) (*c));
    if (state == UTF8_ACCEPT) {
      iter->_width = c - iter->_start + 1;
      // This is the special handling for carriage returns that is mandated by
      // the HTML5 spec.  Since we're looking for particular 7-bit literal
      // characters, we operate in terms of chars and only need a check for iter
      // overrun, instead of having to read in a full next code point.
      // http://www.whatwg.org/specs/web-apps/current-work/multipage/parsing.html#preprocessing-the-input-stream
      if (code_point == '\r') {
        assert(iter->_width == 1);
        const char* next = c + 1;
        if (next < iter->_end && *next == '\n') {
          // Advance the iter, as if the carriage return didn't exist.
          ++iter->_start;
          // Preserve the true offset, since other tools that look at it may be
          // unaware of HTML5's rules for converting \r into \n.
          ++iter->_pos.offset;
        }
        code_point = '\n';
      }
      if (utf8_is_invalid_code_point(code_point)) {
        add_error(iter, GUMBO_ERR_UTF8_INVALID);
        code_point = kUtf8ReplacementChar;
      }
      iter->_current = code_point;
      return;
    } else if (state == UTF8_REJECT) {
      // We don't want to consume the invalid continuation byte of a multi-byte
      // run, but we do want to skip past an invalid first byte.
      iter->_width = c - iter->_start + (c == iter->_start);
      iter->_current = kUtf8ReplacementChar;
      add_error(iter, GUMBO_ERR_UTF8_INVALID);
      return;
    }
  }
  // If we got here without exiting early, then we've reached the end of the
  // iterator.  Add an error for truncated input, set the width to consume the
  // rest of the iterator, and emit a replacement character.  The next time we
  // enter this method, it will detect that there's no input to consume and
  // output an EOF.
  iter->_current = kUtf8ReplacementChar;
  iter->_width = iter->_end - iter->_start;
  add_error(iter, GUMBO_ERR_UTF8_TRUNCATED);
}

static void update_position(Utf8Iterator* iter) {
  iter->_pos.offset += iter->_width;
  if (iter->_current == '\n') {
    ++iter->_pos.line;
    iter->_pos.column = 1;
  } else if (iter->_current == '\t') {
    int tab_stop = iter->_parser->_options->tab_stop;
    iter->_pos.column = ((iter->_pos.column / tab_stop) + 1) * tab_stop;
  } else if (iter->_current != -1) {
    ++iter->_pos.column;
  }
}

// Returns true if this Unicode code point is in the list of characters
// forbidden by the HTML5 spec, such as undefined control chars.
bool utf8_is_invalid_code_point(int c) {
  return (c >= 0x1 && c <= 0x8) || c == 0xB || (c >= 0xE && c <= 0x1F) ||
         (c >= 0x7F && c <= 0x9F) || (c >= 0xFDD0 && c <= 0xFDEF) ||
         ((c & 0xFFFF) == 0xFFFE) || ((c & 0xFFFF) == 0xFFFF);
}

void utf8iterator_init(GumboParser* parser, const char* source,
    size_t source_length, Utf8Iterator* iter) {
  iter->_start = source;
  iter->_end = source + source_length;
  iter->_pos.line = 1;
  iter->_pos.column = 1;
  iter->_pos.offset = 0;
  iter->_parser = parser;
  read_char(iter);
}

void utf8iterator_next(Utf8Iterator* iter) {
  // We update positions based on the *last* character read, so that the first
  // character following a newline is at column 1 in the next line.
  update_position(iter);
  iter->_start += iter->_width;
  read_char(iter);
}

int utf8iterator_current(const Utf8Iterator* iter) { return iter->_current; }

void utf8iterator_get_position(
    const Utf8Iterator* iter, GumboSourcePosition* output) {
  *output = iter->_pos;
}

const char* utf8iterator_get_char_pointer(const Utf8Iterator* iter) {
  return iter->_start;
}

const char* utf8iterator_get_end_pointer(const Utf8Iterator* iter) {
  return iter->_end;
}

bool utf8iterator_maybe_consume_match(Utf8Iterator* iter, const char* prefix,
    size_t length, bool case_sensitive) {
  bool matched = (iter->_start + length <= iter->_end) &&
                 (case_sensitive ? !strncmp(iter->_start, prefix, length)
                                 : !strncasecmp(iter->_start, prefix, length));
  if (matched) {
    for (unsigned int i = 0; i < length; ++i) {
      utf8iterator_next(iter);
    }
    return true;
  } else {
    return false;
  }
}

void utf8iterator_mark(Utf8Iterator* iter) {
  iter->_mark = iter->_start;
  iter->_mark_pos = iter->_pos;
}

// Returns the current input stream position to the mark.
void utf8iterator_reset(Utf8Iterator* iter) {
  iter->_start = iter->_mark;
  iter->_pos = iter->_mark_pos;
  read_char(iter);
}

// Sets the position and original text fields of an error to the value at the
// mark.
void utf8iterator_fill_error_at_mark(Utf8Iterator* iter, GumboError* error) {
  error->position = iter->_mark_pos;
  error->original_text = iter->_mark;
}
