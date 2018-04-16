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
// Routine that maps a Unicode code point to an interchange-valid one
//

#include "fixunicodevalue.h"
#include "integral_types.h"

namespace chrome_lang_id {
namespace CLD2 {

// Guarantees that the resulting output value is interchange valid
//  00-FF; map to spaces or MS CP1252
//  D800-DFFF; surrogates
//  FDD0-FDEF; non-characters
//  xxFFFE-xxFFFF; non-characters
char32 FixUnicodeValue(char32 uv) {
  uint32 uuv = static_cast<uint32>(uv);
  if (uuv < 0x0100) {
    return kMapFullMicrosoft1252OrSpace[uuv];
  }
  if (uuv < 0xD800) {
    return uv;
  }
  if ((uuv & ~0x0F) == 0xFDD0) {              // non-characters
    return 0xFFFD;
  }
  if ((uuv & ~0x0F) == 0xFDE0) {              // non-characters
    return 0xFFFD;
  }
  if ((uuv & 0x00FFFE) == 0xFFFE) {           // non-characters
    return 0xFFFD;
  }
  if ((0xE000 <= uuv) && (uuv <= 0x10FFFF))  {
    return uv;
  }
  // surrogates and negative and > 0x10FFFF all land here
  return 0xFFFD;
}

}       // End namespace CLD2
}       // End namespace chrome_lang_id
