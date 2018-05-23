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

#ifndef GUMBO_STRING_PIECE_H_
#define GUMBO_STRING_PIECE_H_

#include "gumbo.h"

#ifdef __cplusplus
extern "C" {
#endif

struct GumboInternalParser;

// Performs a deep-copy of an GumboStringPiece, allocating a fresh buffer in the
// destination and copying over the characters from source.  Dest should be
// empty, with no buffer allocated; otherwise, this leaks it.
void gumbo_string_copy(struct GumboInternalParser* parser,
    GumboStringPiece* dest, const GumboStringPiece* source);

#ifdef __cplusplus
}
#endif

#endif  // GUMBO_STRING_PIECE_H_
