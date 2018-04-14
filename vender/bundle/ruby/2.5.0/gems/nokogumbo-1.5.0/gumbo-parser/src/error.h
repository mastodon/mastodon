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
// Error types, enums, and handling functions.

#ifndef GUMBO_ERROR_H_
#define GUMBO_ERROR_H_
#ifdef _MSC_VER
#define _CRT_SECURE_NO_WARNINGS
#endif
#include <stdint.h>

#include "gumbo.h"
#include "insertion_mode.h"
#include "string_buffer.h"
#include "token_type.h"

#ifdef __cplusplus
extern "C" {
#endif

struct GumboInternalParser;

typedef enum {
  GUMBO_ERR_UTF8_INVALID,
  GUMBO_ERR_UTF8_TRUNCATED,
  GUMBO_ERR_UTF8_NULL,
  GUMBO_ERR_NUMERIC_CHAR_REF_NO_DIGITS,
  GUMBO_ERR_NUMERIC_CHAR_REF_WITHOUT_SEMICOLON,
  GUMBO_ERR_NUMERIC_CHAR_REF_INVALID,
  GUMBO_ERR_NAMED_CHAR_REF_WITHOUT_SEMICOLON,
  GUMBO_ERR_NAMED_CHAR_REF_INVALID,
  GUMBO_ERR_TAG_STARTS_WITH_QUESTION,
  GUMBO_ERR_TAG_EOF,
  GUMBO_ERR_TAG_INVALID,
  GUMBO_ERR_CLOSE_TAG_EMPTY,
  GUMBO_ERR_CLOSE_TAG_EOF,
  GUMBO_ERR_CLOSE_TAG_INVALID,
  GUMBO_ERR_SCRIPT_EOF,
  GUMBO_ERR_ATTR_NAME_EOF,
  GUMBO_ERR_ATTR_NAME_INVALID,
  GUMBO_ERR_ATTR_DOUBLE_QUOTE_EOF,
  GUMBO_ERR_ATTR_SINGLE_QUOTE_EOF,
  GUMBO_ERR_ATTR_UNQUOTED_EOF,
  GUMBO_ERR_ATTR_UNQUOTED_RIGHT_BRACKET,
  GUMBO_ERR_ATTR_UNQUOTED_EQUALS,
  GUMBO_ERR_ATTR_AFTER_EOF,
  GUMBO_ERR_ATTR_AFTER_INVALID,
  GUMBO_ERR_DUPLICATE_ATTR,
  GUMBO_ERR_SOLIDUS_EOF,
  GUMBO_ERR_SOLIDUS_INVALID,
  GUMBO_ERR_DASHES_OR_DOCTYPE,
  GUMBO_ERR_COMMENT_EOF,
  GUMBO_ERR_COMMENT_INVALID,
  GUMBO_ERR_COMMENT_BANG_AFTER_DOUBLE_DASH,
  GUMBO_ERR_COMMENT_DASH_AFTER_DOUBLE_DASH,
  GUMBO_ERR_COMMENT_SPACE_AFTER_DOUBLE_DASH,
  GUMBO_ERR_COMMENT_END_BANG_EOF,
  GUMBO_ERR_DOCTYPE_EOF,
  GUMBO_ERR_DOCTYPE_INVALID,
  GUMBO_ERR_DOCTYPE_SPACE,
  GUMBO_ERR_DOCTYPE_RIGHT_BRACKET,
  GUMBO_ERR_DOCTYPE_SPACE_OR_RIGHT_BRACKET,
  GUMBO_ERR_DOCTYPE_END,
  GUMBO_ERR_PARSER,
  GUMBO_ERR_UNACKNOWLEDGED_SELF_CLOSING_TAG,
} GumboErrorType;

// Additional data for duplicated attributes.
typedef struct GumboInternalDuplicateAttrError {
  // The name of the attribute.  Owned by this struct.
  const char* name;

  // The (0-based) index within the attributes vector of the original
  // occurrence.
  unsigned int original_index;

  // The (0-based) index where the new occurrence would be.
  unsigned int new_index;
} GumboDuplicateAttrError;

// A simplified representation of the tokenizer state, designed to be more
// useful to clients of this library than the internal representation.  This
// condenses the actual states used in the tokenizer state machine into a few
// values that will be familiar to users of HTML.
typedef enum {
  GUMBO_ERR_TOKENIZER_DATA,
  GUMBO_ERR_TOKENIZER_CHAR_REF,
  GUMBO_ERR_TOKENIZER_RCDATA,
  GUMBO_ERR_TOKENIZER_RAWTEXT,
  GUMBO_ERR_TOKENIZER_PLAINTEXT,
  GUMBO_ERR_TOKENIZER_SCRIPT,
  GUMBO_ERR_TOKENIZER_TAG,
  GUMBO_ERR_TOKENIZER_SELF_CLOSING_TAG,
  GUMBO_ERR_TOKENIZER_ATTR_NAME,
  GUMBO_ERR_TOKENIZER_ATTR_VALUE,
  GUMBO_ERR_TOKENIZER_MARKUP_DECLARATION,
  GUMBO_ERR_TOKENIZER_COMMENT,
  GUMBO_ERR_TOKENIZER_DOCTYPE,
  GUMBO_ERR_TOKENIZER_CDATA,
} GumboTokenizerErrorState;

// Additional data for tokenizer errors.
// This records the current state and codepoint encountered - this is usually
// enough to reconstruct what went wrong and provide a friendly error message.
typedef struct GumboInternalTokenizerError {
  // The bad codepoint encountered.
  int codepoint;

  // The state that the tokenizer was in at the time.
  GumboTokenizerErrorState state;
} GumboTokenizerError;

// Additional data for parse errors.
typedef struct GumboInternalParserError {
  // The type of input token that resulted in this error.
  GumboTokenType input_type;

  // The HTML tag of the input token.  TAG_UNKNOWN if this was not a tag token.
  GumboTag input_tag;

  // The insertion mode that the parser was in at the time.
  GumboInsertionMode parser_state;

  // The tag stack at the point of the error.  Note that this is an GumboVector
  // of GumboTag's *stored by value* - cast the void* to an GumboTag directly to
  // get at the tag.
  GumboVector /* GumboTag */ tag_stack;
} GumboParserError;

// The overall error struct representing an error in decoding/tokenizing/parsing
// the HTML.  This contains an enumerated type flag, a source position, and then
// a union of fields containing data specific to the error.
typedef struct GumboInternalError {
  // The type of error.
  GumboErrorType type;

  // The position within the source file where the error occurred.
  GumboSourcePosition position;

  // A pointer to the byte within the original source file text where the error
  // occurred (note that this is not the same as position.offset, as that gives
  // character-based instead of byte-based offsets).
  const char* original_text;

  // Type-specific error information.
  union {
    // The code point we encountered, for:
    // * GUMBO_ERR_UTF8_INVALID
    // * GUMBO_ERR_UTF8_TRUNCATED
    // * GUMBO_ERR_NUMERIC_CHAR_REF_WITHOUT_SEMICOLON
    // * GUMBO_ERR_NUMERIC_CHAR_REF_INVALID
    uint64_t codepoint;

    // Tokenizer errors.
    GumboTokenizerError tokenizer;

    // Short textual data, for:
    // * GUMBO_ERR_NAMED_CHAR_REF_WITHOUT_SEMICOLON
    // * GUMBO_ERR_NAMED_CHAR_REF_INVALID
    GumboStringPiece text;

    // Duplicate attribute data, for GUMBO_ERR_DUPLICATE_ATTR.
    GumboDuplicateAttrError duplicate_attr;

    // Parser state, for GUMBO_ERR_PARSER and
    // GUMBO_ERR_UNACKNOWLEDGE_SELF_CLOSING_TAG.
    struct GumboInternalParserError parser;
  } v;
} GumboError;

// Adds a new error to the parser's error list, and returns a pointer to it so
// that clients can fill out the rest of its fields.  May return NULL if we're
// already over the max_errors field specified in GumboOptions.
GumboError* gumbo_add_error(struct GumboInternalParser* parser);

// Initializes the errors vector in the parser.
void gumbo_init_errors(struct GumboInternalParser* errors);

// Frees all the errors in the 'errors_' field of the parser.
void gumbo_destroy_errors(struct GumboInternalParser* errors);

// Frees the memory used for a single GumboError.
void gumbo_error_destroy(struct GumboInternalParser* parser, GumboError* error);

// Prints an error to a string.  This fills an empty GumboStringBuffer with a
// freshly-allocated buffer containing the error message text.  The caller is
// responsible for deleting the buffer.  (Note that the buffer is allocated with
// the allocator specified in the GumboParser config and hence should be freed
// by gumbo_parser_deallocate().)
void gumbo_error_to_string(struct GumboInternalParser* parser,
    const GumboError* error, GumboStringBuffer* output);

// Prints a caret diagnostic to a string.  This fills an empty GumboStringBuffer
// with a freshly-allocated buffer containing the error message text.  The
// caller is responsible for deleting the buffer.  (Note that the buffer is
// allocated with the allocator specified in the GumboParser config and hence
// should be freed by gumbo_parser_deallocate().)
void gumbo_caret_diagnostic_to_string(struct GumboInternalParser* parser,
    const GumboError* error, const char* source_text,
    GumboStringBuffer* output);

// Like gumbo_caret_diagnostic_to_string, but prints the text to stdout instead
// of writing to a string.
void gumbo_print_caret_diagnostic(struct GumboInternalParser* parser,
    const GumboError* error, const char* source_text);

#ifdef __cplusplus
}
#endif

#endif  // GUMBO_ERROR_H_
