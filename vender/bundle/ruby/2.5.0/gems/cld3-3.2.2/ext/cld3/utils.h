/* Copyright 2016 Google Inc. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#ifndef UTILS_H_
#define UTILS_H_

#include <stddef.h>
#include <functional>
#include <initializer_list>
#include <string>
#include <vector>

#include "base.h"
#include "script_span/stringpiece.h"

namespace chrome_lang_id {
namespace utils {

bool ParseInt32(const char *c_str, int *value);
bool ParseDouble(const char *c_str, double *value);

template <typename T>
T ParseUsing(const string &str, std::function<bool(const char *, T *)> func) {
  T value;
  func(str.c_str(), &value);
  return value;
}

template <typename T>
T ParseUsing(const string &str, T defval,
             std::function<bool(const char *, T *)> func) {
  return str.empty() ? defval : ParseUsing<T>(str, func);
}

string CEscape(const string &src);

std::vector<string> Split(const string &text, char delim);

int RemoveLeadingWhitespace(StringPiece *text);

int RemoveTrailingWhitespace(StringPiece *text);

int RemoveWhitespaceContext(StringPiece *text);

uint32 Hash32(const char *data, size_t n, uint32 seed);

uint32 Hash32WithDefaultSeed(const string &input);

// Deletes all the elements in an STL container and clears the container. This
// function is suitable for use with a vector, set, hash_set, or any other STL
// container which defines sensible begin(), end(), and clear() methods.
// If container is NULL, this function is a no-op.
template <typename T>
void STLDeleteElements(T *container) {
  if (!container) return;
  auto it = container->begin();
  while (it != container->end()) {
    auto temp = it;
    ++it;
    delete *temp;
  }
  container->clear();
}

class PunctuationUtil {
 public:
  // Unicode character ranges for punctuation characters according to CoNLL.
  struct CharacterRange {
    int first;
    int last;
  };
  static CharacterRange kPunctuation[];

  // Returns true if Unicode character is a punctuation character.
  static bool IsPunctuation(int u) {
    int i = 0;
    while (kPunctuation[i].first > 0) {
      if (u < kPunctuation[i].first) return false;
      if (u <= kPunctuation[i].last) return true;
      ++i;
    }
    return false;
  }

  // Determine if tag is a punctuation tag.
  static bool IsPunctuationTag(const string &tag) {
    for (size_t i = 0; i < tag.length(); ++i) {
      int c = tag[i];
      if (c != ',' && c != ':' && c != '.' && c != '\'' && c != '`') {
        return false;
      }
    }
    return true;
  }

  // Returns true if tag is non-empty and has only punctuation or parens
  // symbols.
  static bool IsPunctuationTagOrParens(const string &tag) {
    if (tag.empty()) return false;
    for (size_t i = 0; i < tag.length(); ++i) {
      int c = tag[i];
      if (c != '(' && c != ')' && c != ',' && c != ':' && c != '.' &&
          c != '\'' && c != '`') {
        return false;
      }
    }
    return true;
  }
};

void NormalizeDigits(string *form);

// Takes a text and convert it into a vector, where each element is a utf8
// character.
void GetUTF8Chars(const string &text, std::vector<string> *chars);

// Returns the number of bytes in the first UTF-8 char at the beginning
// of the string. It is assumed that the string is valid UTF-8.  If
// the first byte of the string is null, return 0 (for backwards
// compatibility only; this use is discouraged).
int UTF8FirstLetterNumBytes(const char *in_buf);

// Returns the length (number of bytes) of the Unicode code point starting at
// src, based on inspecting just that one byte.  Preconditions: src != NULL,
// *src can be read, and *src is not '\0', and src points to a well-formed UTF-8
// string.
int OneCharLen(const char *src);

}  // namespace utils
}  // namespace chrome_lang_id

#endif  // UTILS_H_
