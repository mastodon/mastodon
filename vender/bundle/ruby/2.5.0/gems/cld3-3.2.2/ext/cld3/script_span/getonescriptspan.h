// Copyright 2013 Google Inc. All Rights Reserved.
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
// Author: dsites@google.com (Dick Sites)
//


#ifndef SCRIPT_SPAN_GETONESCRIPTSPAN_H_
#define SCRIPT_SPAN_GETONESCRIPTSPAN_H_

#include "generated_ulscript.h"
#include "integral_types.h"
#include "offsetmap.h"

namespace chrome_lang_id {
namespace CLD2 {

static const int kMaxScriptBuffer = 40960;
static const int kMaxScriptLowerBuffer = (kMaxScriptBuffer * 3) / 2;
static const int kMaxScriptBytes = kMaxScriptBuffer - 32;   // Leave some room
static const int kWithinScriptTail = 32;    // Stop at word space in last
                                            // N bytes of script buffer

typedef struct {
  char* text = nullptr;   // Pointer to the span, somewhere
  int text_bytes = 0;     // Number of bytes of text in the span
  int offset = 0;         // Offset of start of span in original input buffer
  ULScript ulscript = UNKNOWN_ULSCRIPT; // Unicode Letters Script of this span
  bool truncated = false; // true if buffer filled up before a
                          // different script or EOF was found
} LangSpan;

static inline bool IsContinuationByte(char c) {
  return static_cast<signed char>(c) < -64;
}

// Gets lscript number for letters; always returns
//   0 (common script) for non-letters
int GetUTF8LetterScriptNum(const char* src);

// Update src pointer to point to next quadgram, +2..+5
// Looks at src[0..4]
const char* AdvanceQuad(const char* src);

// Utility routine to search alphabetical tables
int BinarySearch(const char* key, int lo, int hi, const CharIntPair* cipair);

// Returns the length in bytes of the prefix of src that is all
//  interchange valid UTF-8
int SpanInterchangeValid(const char* src, int byte_length);

class ScriptScanner {
 public:
  ScriptScanner(const char* buffer, int buffer_length, bool is_plain_text);
  ScriptScanner(const char* buffer, int buffer_length, bool is_plain_text,
                bool any_text, bool any_script);
  ~ScriptScanner();

  // Copy next run of same-script non-tag letters to buffer [NUL terminated]
  bool GetOneScriptSpan(LangSpan* span);

  // Force Latin and Cyrillic scripts to be lowercase
  void LowerScriptSpan(LangSpan* span);

  // Copy next run of same-script non-tag letters to buffer [NUL terminated]
  // Force Latin and Cyrillic scripts to be lowercase
  bool GetOneScriptSpanLower(LangSpan* span);

  // Copy next run of non-tag characters to buffer [NUL terminated]
  // This just removes tags and removes entities
  // Buffer has leading space
  bool GetOneTextSpan(LangSpan* span);

  // Maps byte offset in most recent GetOneScriptSpan/Lower
  // span->text [0..text_bytes] into an additional byte offset from
  // span->offset, to get back to corresponding text in the original
  // input buffer.
  // text_offset must be the first byte
  // of a UTF-8 character, or just beyond the last character. Normally this
  // routine is called with the first byte of an interesting range and
  // again with the first byte of the following range.
  int MapBack(int text_offset);

  const char* GetBufferStart() {return start_byte_;};

 private:
  // Skip over tags and non-letters
  int SkipToFrontOfSpan(const char* src, int len, int* script);

  const char* start_byte_;        // Starting byte of buffer to scan
  const char* next_byte_;         // First unscanned byte
  int byte_length_;               // Bytes left

  bool is_plain_text_;            // true fo text, false for HTML
  char* script_buffer_;           // Holds text with expanded entities
  char* script_buffer_lower_;     // Holds lowercased text
  bool letters_marks_only_;       // To distinguish scriptspan of one
                                  // letters/marks vs. any mixture of text
  bool one_script_only_;          // To distinguish scriptspan of one
                                  // script vs. any mixture of scripts
  int exit_state_;                // For tag parser kTagParseTbl_0, based
                                  // on letters_marks_only_
 public :
  // Expose for debugging
  OffsetMap map2original_;    // map from script_buffer_ to buffer
  OffsetMap map2uplow_;       // map from script_buffer_lower_ to script_buffer_
};

}  // namespace CLD2
}  // namespace chrome_lang_id

#endif  // SCRIPT_SPAN_GETONESCRIPTSPAN_H_
