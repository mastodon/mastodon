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

#include "string_piece.h"

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>

#include "util.h"

struct GumboInternalParser;

const GumboStringPiece kGumboEmptyString = {NULL, 0};

bool gumbo_string_equals(
    const GumboStringPiece* str1, const GumboStringPiece* str2) {
  return str1->length == str2->length &&
         !memcmp(str1->data, str2->data, str1->length);
}

bool gumbo_string_equals_ignore_case(
    const GumboStringPiece* str1, const GumboStringPiece* str2) {
  return str1->length == str2->length &&
         !strncasecmp(str1->data, str2->data, str1->length);
}

void gumbo_string_copy(struct GumboInternalParser* parser,
    GumboStringPiece* dest, const GumboStringPiece* source) {
  dest->length = source->length;
  char* buffer = gumbo_parser_allocate(parser, source->length);
  memcpy(buffer, source->data, source->length);
  dest->data = buffer;
}
