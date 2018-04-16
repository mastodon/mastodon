// Copyright (C) 2006 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Author: Jim Meehan

#include "unicodetext.h"

#include "base.h"
#include "utils.h"

namespace chrome_lang_id {

// *************** Data representation **********
// Note: the copy constructor is undefined.

void UnicodeText::Repr::PointTo(const char *data, int size) {
  if (ours_ && data_) delete[] data_;  // If we owned the old buffer, free it.
  data_ = const_cast<char *>(data);
  size_ = size;
  capacity_ = size;
  ours_ = false;
}

// *************** UnicodeText ******************

UnicodeText::UnicodeText() {}

UnicodeText &UnicodeText::PointToUTF8(const char *buffer, int byte_length) {
  repr_.PointTo(buffer, byte_length);
  return *this;
}

UnicodeText::~UnicodeText() {}

// ******************* UnicodeText::const_iterator *********************

// The implementation of const_iterator would be nicer if it
// inherited from boost::iterator_facade
// (http://boost.org/libs/iterator/doc/iterator_facade.html).

UnicodeText::const_iterator::const_iterator() : it_(0) {}

UnicodeText::const_iterator &UnicodeText::const_iterator::operator=(
    const const_iterator &other) {
  if (&other != this) it_ = other.it_;
  return *this;
}

UnicodeText::const_iterator UnicodeText::begin() const {
  return const_iterator(repr_.data_);
}

UnicodeText::const_iterator UnicodeText::end() const {
  return const_iterator(repr_.data_ + repr_.size_);
}

char32 UnicodeText::const_iterator::operator*() const {
  // (We could call chartorune here, but that does some
  // error-checking, and we're guaranteed that our data is valid
  // UTF-8. Also, we expect this routine to be called very often. So
  // for speed, we do the calculation ourselves.)

  // Convert from UTF-8
  unsigned char byte1 = static_cast<unsigned char>(it_[0]);
  if (byte1 < 0x80) return byte1;

  unsigned char byte2 = static_cast<unsigned char>(it_[1]);
  if (byte1 < 0xE0) return ((byte1 & 0x1F) << 6) | (byte2 & 0x3F);

  unsigned char byte3 = static_cast<unsigned char>(it_[2]);
  if (byte1 < 0xF0) {
    return ((byte1 & 0x0F) << 12) | ((byte2 & 0x3F) << 6) | (byte3 & 0x3F);
  }

  unsigned char byte4 = static_cast<unsigned char>(it_[3]);
  return ((byte1 & 0x07) << 18) | ((byte2 & 0x3F) << 12) |
         ((byte3 & 0x3F) << 6) | (byte4 & 0x3F);
}

UnicodeText::const_iterator &UnicodeText::const_iterator::operator++() {
  it_ += chrome_lang_id::utils::OneCharLen(it_);
  return *this;
}

}  // namespace chrome_lang_id
