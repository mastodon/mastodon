// Copyright 2011 Google Inc. All Rights Reserved.
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

#ifndef GUMBO_TOKEN_TYPE_H_
#define GUMBO_TOKEN_TYPE_H_

#ifdef __cplusplus
extern "C" {
#endif

// An enum representing the type of token.
typedef enum {
  GUMBO_TOKEN_DOCTYPE,
  GUMBO_TOKEN_START_TAG,
  GUMBO_TOKEN_END_TAG,
  GUMBO_TOKEN_COMMENT,
  GUMBO_TOKEN_WHITESPACE,
  GUMBO_TOKEN_CHARACTER,
  GUMBO_TOKEN_CDATA,
  GUMBO_TOKEN_NULL,
  GUMBO_TOKEN_EOF
} GumboTokenType;

#ifdef __cplusplus
}  // extern C
#endif

#endif  // GUMBO_TOKEN_TYPE_H_
