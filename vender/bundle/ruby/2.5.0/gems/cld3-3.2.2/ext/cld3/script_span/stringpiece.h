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
// A StringPiece points to part or all of a string, double-quoted string
// literal, or other string-like object.  A StringPiece does *not* own the
// string to which it points.  A StringPiece is not null-terminated. [subset]
//

#ifndef SCRIPT_SPAN_STRINGPIECE_H_
#define SCRIPT_SPAN_STRINGPIECE_H_

#include <string.h>
#include <string>

namespace chrome_lang_id {

typedef int stringpiece_ssize_type;

class StringPiece {
 private:
  const char* ptr_;
  stringpiece_ssize_type length_;

 public:
  // We provide non-explicit singleton constructors so users can pass
  // in a "const char*" or a "string" wherever a "StringPiece" is
  // expected.
  StringPiece() : ptr_(NULL), length_(0) {}

  StringPiece(const char* str)  // NOLINT(runtime/explicit)
      : ptr_(str), length_(0) {
    if (str != NULL) {
      length_ = static_cast<stringpiece_ssize_type>(strlen(str));
    }
  }

  StringPiece(const std::string& str)  // NOLINT(runtime/explicit)
      : ptr_(str.data()), length_(0) {
    length_ = static_cast<stringpiece_ssize_type>(str.size());
  }

  StringPiece(const char* offset, stringpiece_ssize_type len)
      : ptr_(offset), length_(len) {
  }

  void remove_prefix(stringpiece_ssize_type n) {
    ptr_ += n;
    length_ -= n;
  }

  void remove_suffix(stringpiece_ssize_type n) {
    length_ -= n;
  }

  // data() may return a pointer to a buffer with embedded NULs, and the
  // returned buffer may or may not be null terminated.  Therefore it is
  // typically a mistake to pass data() to a routine that expects a NUL
  // terminated string.
  const char* data() const { return ptr_; }
  stringpiece_ssize_type size() const { return length_; }
  stringpiece_ssize_type length() const { return length_; }
  bool empty() const { return length_ == 0; }
};

class StringPiece;

}  // namespace chrome_lang_id

#endif  // SCRIPT_SPAN_STRINGPIECE_H__
