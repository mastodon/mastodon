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

#include "error.h"

#include <assert.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>

#include "gumbo.h"
#include "parser.h"
#include "string_buffer.h"
#include "util.h"
#include "vector.h"

// Prints a formatted message to a StringBuffer.  This automatically resizes the
// StringBuffer as necessary to fit the message.  Returns the number of bytes
// written.
static int print_message(
    GumboParser* parser, GumboStringBuffer* output, const char* format, ...) {
  va_list args;
  int remaining_capacity = output->capacity - output->length;
  va_start(args, format);
  int bytes_written = vsnprintf(
      output->data + output->length, remaining_capacity, format, args);
  va_end(args);
#ifdef _MSC_VER
  if (bytes_written == -1) {
    // vsnprintf returns -1 on MSVC++ if there's not enough capacity, instead of
    // returning the number of bytes that would've been written had there been
    // enough.  In this case, we'll double the buffer size and hope it fits when
    // we retry (letting it fail and returning 0 if it doesn't), since there's
    // no way to smartly resize the buffer.
    gumbo_string_buffer_reserve(parser, output->capacity * 2, output);
    va_start(args, format);
    int result = vsnprintf(
        output->data + output->length, remaining_capacity, format, args);
    va_end(args);
    return result == -1 ? 0 : result;
  }
#else
  // -1 in standard C99 indicates an encoding error.  Return 0 and do nothing.
  if (bytes_written == -1) {
    return 0;
  }
#endif

  if (bytes_written > remaining_capacity) {
    gumbo_string_buffer_reserve(
        parser, output->capacity + bytes_written, output);
    remaining_capacity = output->capacity - output->length;
    va_start(args, format);
    bytes_written = vsnprintf(
        output->data + output->length, remaining_capacity, format, args);
    va_end(args);
  }
  output->length += bytes_written;
  return bytes_written;
}

static void print_tag_stack(GumboParser* parser, const GumboParserError* error,
    GumboStringBuffer* output) {
  print_message(parser, output, "  Currently open tags: ");
  for (unsigned int i = 0; i < error->tag_stack.length; ++i) {
    if (i) {
      print_message(parser, output, ", ");
    }
    GumboTag tag = (GumboTag) error->tag_stack.data[i];
    print_message(parser, output, gumbo_normalized_tagname(tag));
  }
  gumbo_string_buffer_append_codepoint(parser, '.', output);
}

static void handle_parser_error(GumboParser* parser,
    const GumboParserError* error, GumboStringBuffer* output) {
  if (error->parser_state == GUMBO_INSERTION_MODE_INITIAL &&
      error->input_type != GUMBO_TOKEN_DOCTYPE) {
    print_message(
        parser, output, "The doctype must be the first token in the document");
    return;
  }

  switch (error->input_type) {
    case GUMBO_TOKEN_DOCTYPE:
      print_message(parser, output, "This is not a legal doctype");
      return;
    case GUMBO_TOKEN_COMMENT:
      // Should never happen; comments are always legal.
      assert(0);
      // But just in case...
      print_message(parser, output, "Comments aren't legal here");
      return;
    case GUMBO_TOKEN_CDATA:
    case GUMBO_TOKEN_WHITESPACE:
    case GUMBO_TOKEN_CHARACTER:
      print_message(parser, output, "Character tokens aren't legal here");
      return;
    case GUMBO_TOKEN_NULL:
      print_message(parser, output, "Null bytes are not allowed in HTML5");
      return;
    case GUMBO_TOKEN_EOF:
      if (error->parser_state == GUMBO_INSERTION_MODE_INITIAL) {
        print_message(parser, output, "You must provide a doctype");
      } else {
        print_message(parser, output, "Premature end of file");
        print_tag_stack(parser, error, output);
      }
      return;
    case GUMBO_TOKEN_START_TAG:
    case GUMBO_TOKEN_END_TAG:
      print_message(parser, output, "That tag isn't allowed here");
      print_tag_stack(parser, error, output);
      // TODO(jdtang): Give more specific messaging.
      return;
  }
}

// Finds the preceding newline in an original source buffer from a given byte
// location.  Returns a character pointer to the character after that, or a
// pointer to the beginning of the string if this is the first line.
static const char* find_last_newline(
    const char* original_text, const char* error_location) {
  assert(error_location >= original_text);
  const char* c = error_location;
  for (; c != original_text && *c != '\n'; --c) {
    // There may be an error at EOF, which would be a nul byte.
    assert(*c || c == error_location);
  }
  return c == original_text ? c : c + 1;
}

// Finds the next newline in the original source buffer from a given byte
// location.  Returns a character pointer to that newline, or a pointer to the
// terminating null byte if this is the last line.
static const char* find_next_newline(
    const char* original_text, const char* error_location) {
  const char* c = error_location;
  for (; *c && *c != '\n'; ++c)
    ;
  return c;
}

GumboError* gumbo_add_error(GumboParser* parser) {
  int max_errors = parser->_options->max_errors;
  if (max_errors >= 0 && parser->_output->errors.length >= (unsigned int) max_errors) {
    return NULL;
  }
  GumboError* error = gumbo_parser_allocate(parser, sizeof(GumboError));
  gumbo_vector_add(parser, error, &parser->_output->errors);
  return error;
}

void gumbo_error_to_string(
    GumboParser* parser, const GumboError* error, GumboStringBuffer* output) {
  print_message(
      parser, output, "@%d:%d: ", error->position.line, error->position.column);
  switch (error->type) {
    case GUMBO_ERR_UTF8_INVALID:
      print_message(
          parser, output, "Invalid UTF8 character 0x%x", error->v.codepoint);
      break;
    case GUMBO_ERR_UTF8_TRUNCATED:
      print_message(parser, output,
          "Input stream ends with a truncated UTF8 character 0x%x",
          error->v.codepoint);
      break;
    case GUMBO_ERR_NUMERIC_CHAR_REF_NO_DIGITS:
      print_message(
          parser, output, "No digits after &# in numeric character reference");
      break;
    case GUMBO_ERR_NUMERIC_CHAR_REF_WITHOUT_SEMICOLON:
      print_message(parser, output,
          "The numeric character reference &#%d should be followed "
          "by a semicolon",
          error->v.codepoint);
      break;
    case GUMBO_ERR_NUMERIC_CHAR_REF_INVALID:
      print_message(parser, output,
          "The numeric character reference &#%d; encodes an invalid "
          "unicode codepoint",
          error->v.codepoint);
      break;
    case GUMBO_ERR_NAMED_CHAR_REF_WITHOUT_SEMICOLON:
      // The textual data came from one of the literal strings in the table, and
      // so it'll be null-terminated.
      print_message(parser, output,
          "The named character reference &%.*s should be followed by a "
          "semicolon",
          (int) error->v.text.length, error->v.text.data);
      break;
    case GUMBO_ERR_NAMED_CHAR_REF_INVALID:
      print_message(parser, output,
          "The named character reference &%.*s; is not a valid entity name",
          (int) error->v.text.length, error->v.text.data);
      break;
    case GUMBO_ERR_DUPLICATE_ATTR:
      print_message(parser, output,
          "Attribute %s occurs multiple times, at positions %d and %d",
          error->v.duplicate_attr.name, error->v.duplicate_attr.original_index,
          error->v.duplicate_attr.new_index);
      break;
    case GUMBO_ERR_PARSER:
    case GUMBO_ERR_UNACKNOWLEDGED_SELF_CLOSING_TAG:
      handle_parser_error(parser, &error->v.parser, output);
      break;
    default:
      print_message(parser, output,
          "Tokenizer error with an unimplemented error message");
      break;
  }
  gumbo_string_buffer_append_codepoint(parser, '.', output);
}

void gumbo_caret_diagnostic_to_string(GumboParser* parser,
    const GumboError* error, const char* source_text,
    GumboStringBuffer* output) {
  gumbo_error_to_string(parser, error, output);

  const char* line_start = find_last_newline(source_text, error->original_text);
  const char* line_end = find_next_newline(source_text, error->original_text);
  GumboStringPiece original_line;
  original_line.data = line_start;
  original_line.length = line_end - line_start;

  gumbo_string_buffer_append_codepoint(parser, '\n', output);
  gumbo_string_buffer_append_string(parser, &original_line, output);
  gumbo_string_buffer_append_codepoint(parser, '\n', output);
  gumbo_string_buffer_reserve(
      parser, output->length + error->position.column, output);
  int num_spaces = error->position.column - 1;
  memset(output->data + output->length, ' ', num_spaces);
  output->length += num_spaces;
  gumbo_string_buffer_append_codepoint(parser, '^', output);
  gumbo_string_buffer_append_codepoint(parser, '\n', output);
}

void gumbo_print_caret_diagnostic(
    GumboParser* parser, const GumboError* error, const char* source_text) {
  GumboStringBuffer text;
  gumbo_string_buffer_init(parser, &text);
  gumbo_caret_diagnostic_to_string(parser, error, source_text, &text);
  printf("%.*s", (int) text.length, text.data);
  gumbo_string_buffer_destroy(parser, &text);
}

void gumbo_error_destroy(GumboParser* parser, GumboError* error) {
  if (error->type == GUMBO_ERR_PARSER ||
      error->type == GUMBO_ERR_UNACKNOWLEDGED_SELF_CLOSING_TAG) {
    gumbo_vector_destroy(parser, &error->v.parser.tag_stack);
  } else if (error->type == GUMBO_ERR_DUPLICATE_ATTR) {
    gumbo_parser_deallocate(parser, (void*) error->v.duplicate_attr.name);
  }
  gumbo_parser_deallocate(parser, error);
}

void gumbo_init_errors(GumboParser* parser) {
  gumbo_vector_init(parser, 5, &parser->_output->errors);
}

void gumbo_destroy_errors(GumboParser* parser) {
  for (unsigned int i = 0; i < parser->_output->errors.length; ++i) {
    gumbo_error_destroy(parser, parser->_output->errors.data[i]);
  }
  gumbo_vector_destroy(parser, &parser->_output->errors);
}
