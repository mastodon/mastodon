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

#include "base.h"

#include <string>
#if defined(COMPILER_MSVC) || defined(_WIN32)
#include <sstream>
#endif  // defined(COMPILER_MSVC) || defined(_WIN32)

namespace chrome_lang_id {

// TODO(abakalov): Pick the most efficient approach.
#if defined(COMPILER_MSVC) || defined(_WIN32)
std::string Int64ToString(int64 input) {
  std::stringstream stream;
  stream << input;
  return stream.str();
}
#else
std::string Int64ToString(int64 input) { return std::to_string(input); }
#endif  // defined(COMPILER_MSVC) || defined(_WIN32)

}  // namespace chrome_lang_id
