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

#include "util.h"

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <stdarg.h>
#include <stdio.h>

#include "gumbo.h"
#include "parser.h"

// TODO(jdtang): This should be elsewhere, but there's no .c file for
// SourcePositions and yet the constant needs some linkage, so this is as good
// as any.
const GumboSourcePosition kGumboEmptySourcePosition = {0, 0, 0};

void* gumbo_parser_allocate(GumboParser* parser, size_t num_bytes) {
  return parser->_options->allocator(parser->_options->userdata, num_bytes);
}

void gumbo_parser_deallocate(GumboParser* parser, void* ptr) {
  parser->_options->deallocator(parser->_options->userdata, ptr);
}

char* gumbo_copy_stringz(GumboParser* parser, const char* str) {
  char* buffer = gumbo_parser_allocate(parser, strlen(str) + 1);
  strcpy(buffer, str);
  return buffer;
}

// Debug function to trace operation of the parser.  Pass --copts=-DGUMBO_DEBUG
// to use.
void gumbo_debug(const char* format, ...) {
#ifdef GUMBO_DEBUG
  va_list args;
  va_start(args, format);
  vprintf(format, args);
  va_end(args);
  fflush(stdout);
#endif
}
