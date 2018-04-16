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

#ifndef GUMBO_INSERTION_MODE_H_
#define GUMBO_INSERTION_MODE_H_

#ifdef __cplusplus
extern "C" {
#endif

// http://www.whatwg.org/specs/web-apps/current-work/complete/parsing.html#insertion-mode
// If new enum values are added, be sure to update the kTokenHandlers dispatch
// table in parser.c.
typedef enum {
  GUMBO_INSERTION_MODE_INITIAL,
  GUMBO_INSERTION_MODE_BEFORE_HTML,
  GUMBO_INSERTION_MODE_BEFORE_HEAD,
  GUMBO_INSERTION_MODE_IN_HEAD,
  GUMBO_INSERTION_MODE_IN_HEAD_NOSCRIPT,
  GUMBO_INSERTION_MODE_AFTER_HEAD,
  GUMBO_INSERTION_MODE_IN_BODY,
  GUMBO_INSERTION_MODE_TEXT,
  GUMBO_INSERTION_MODE_IN_TABLE,
  GUMBO_INSERTION_MODE_IN_TABLE_TEXT,
  GUMBO_INSERTION_MODE_IN_CAPTION,
  GUMBO_INSERTION_MODE_IN_COLUMN_GROUP,
  GUMBO_INSERTION_MODE_IN_TABLE_BODY,
  GUMBO_INSERTION_MODE_IN_ROW,
  GUMBO_INSERTION_MODE_IN_CELL,
  GUMBO_INSERTION_MODE_IN_SELECT,
  GUMBO_INSERTION_MODE_IN_SELECT_IN_TABLE,
  GUMBO_INSERTION_MODE_IN_TEMPLATE,
  GUMBO_INSERTION_MODE_AFTER_BODY,
  GUMBO_INSERTION_MODE_IN_FRAMESET,
  GUMBO_INSERTION_MODE_AFTER_FRAMESET,
  GUMBO_INSERTION_MODE_AFTER_AFTER_BODY,
  GUMBO_INSERTION_MODE_AFTER_AFTER_FRAMESET
} GumboInsertionMode;

#ifdef __cplusplus
}  // extern C
#endif

#endif  // GUMBO_INSERTION_MODE_H_
