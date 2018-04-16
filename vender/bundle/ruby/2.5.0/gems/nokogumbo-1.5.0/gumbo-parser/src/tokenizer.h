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
//
// This contains an implementation of a tokenizer for HTML5.  It consumes a
// buffer of UTF-8 characters, and then emits a stream of tokens.

#ifndef GUMBO_TOKENIZER_H_
#define GUMBO_TOKENIZER_H_

#include <stdbool.h>
#include <stddef.h>

#include "gumbo.h"
#include "token_type.h"
#include "tokenizer_states.h"

#ifdef __cplusplus
extern "C" {
#endif

struct GumboInternalParser;

// Struct containing all information pertaining to doctype tokens.
typedef struct GumboInternalTokenDocType {
  const char* name;
  const char* public_identifier;
  const char* system_identifier;
  bool force_quirks;
  // There's no way to tell a 0-length public or system ID apart from the
  // absence of a public or system ID, but they're handled different by the
  // spec, so we need bool flags for them.
  bool has_public_identifier;
  bool has_system_identifier;
} GumboTokenDocType;

// Struct containing all information pertaining to start tag tokens.
typedef struct GumboInternalTokenStartTag {
  GumboTag tag;
  GumboVector /* GumboAttribute */ attributes;
  bool is_self_closing;
} GumboTokenStartTag;

// A data structure representing a single token in the input stream.  This
// contains an enum for the type, the source position, a GumboStringPiece
// pointing to the original text, and then a union for any parsed data.
typedef struct GumboInternalToken {
  GumboTokenType type;
  GumboSourcePosition position;
  GumboStringPiece original_text;
  union {
    GumboTokenDocType doc_type;
    GumboTokenStartTag start_tag;
    GumboTag end_tag;
    const char* text;  // For comments.
    int character;     // For character, whitespace, null, and EOF tokens.
  } v;
} GumboToken;

// Initializes the tokenizer state within the GumboParser object, setting up a
// parse of the specified text.
void gumbo_tokenizer_state_init(
    struct GumboInternalParser* parser, const char* text, size_t text_length);

// Destroys the tokenizer state within the GumboParser object, freeing any
// dynamically-allocated structures within it.
void gumbo_tokenizer_state_destroy(struct GumboInternalParser* parser);

// Sets the tokenizer state to the specified value.  This is needed by some
// parser states, which alter the state of the tokenizer in response to tags
// seen.
void gumbo_tokenizer_set_state(
    struct GumboInternalParser* parser, GumboTokenizerEnum state);

// Flags whether the current node is a foreign content element.  This is
// necessary for the markup declaration open state, where the tokenizer must be
// aware of the state of the parser to properly tokenize bad comment tags.
// http://www.whatwg.org/specs/web-apps/current-work/multipage/tokenization.html#markup-declaration-open-state
void gumbo_tokenizer_set_is_current_node_foreign(
    struct GumboInternalParser* parser, bool is_foreign);

// Lexes a single token from the specified buffer, filling the output with the
// parsed GumboToken data structure.  Returns true for a successful
// tokenization, false if a parse error occurs.
//
// Example:
//   struct GumboInternalParser parser;
//   GumboToken output;
//   gumbo_tokenizer_state_init(&parser, text, strlen(text));
//   while (gumbo_lex(&parser, &output)) {
//     ...do stuff with output.
//     gumbo_token_destroy(&parser, &token);
//   }
//   gumbo_tokenizer_state_destroy(&parser);
bool gumbo_lex(struct GumboInternalParser* parser, GumboToken* output);

// Frees the internally-allocated pointers within an GumboToken.  Note that this
// doesn't free the token itself, since oftentimes it will be allocated on the
// stack.  A simple call to free() (or GumboParser->deallocator, if
// appropriate) can handle that.
//
// Note that if you are handing over ownership of the internal strings to some
// other data structure - for example, a parse tree - these do not need to be
// freed.
void gumbo_token_destroy(struct GumboInternalParser* parser, GumboToken* token);

#ifdef __cplusplus
}
#endif

#endif  // GUMBO_TOKENIZER_H_
