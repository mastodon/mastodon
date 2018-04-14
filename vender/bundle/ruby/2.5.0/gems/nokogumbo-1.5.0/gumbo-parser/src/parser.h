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
// Contains the definition of the top-level GumboParser structure that's
// threaded through basically every internal function in the library.

#ifndef GUMBO_PARSER_H_
#define GUMBO_PARSER_H_

#ifdef __cplusplus
extern "C" {
#endif

struct GumboInternalParserState;
struct GumboInternalOutput;
struct GumboInternalOptions;
struct GumboInternalTokenizerState;

// An overarching struct that's threaded through (nearly) all functions in the
// library, OOP-style.  This gives each function access to the options and
// output, along with any internal state needed for the parse.
typedef struct GumboInternalParser {
  // Settings for this parse run.
  const struct GumboInternalOptions* _options;

  // Output for the parse.
  struct GumboInternalOutput* _output;

  // The internal tokenizer state, defined as a pointer to avoid a cyclic
  // dependency on html5tokenizer.h.  The main parse routine is responsible for
  // initializing this on parse start, and destroying it on parse end.
  // End-users will never see a non-garbage value in this pointer.
  struct GumboInternalTokenizerState* _tokenizer_state;

  // The internal parser state.  Initialized on parse start and destroyed on
  // parse end; end-users will never see a non-garbage value in this pointer.
  struct GumboInternalParserState* _parser_state;
} GumboParser;

#ifdef __cplusplus
}
#endif

#endif  // GUMBO_PARSER_H_
