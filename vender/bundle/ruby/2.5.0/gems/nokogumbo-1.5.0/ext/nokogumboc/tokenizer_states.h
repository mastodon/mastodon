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
//
// This contains the list of states used in the tokenizer.  Although at first
// glance it seems like these could be kept internal to the tokenizer, several
// of the actions in the parser require that it reach into the tokenizer and
// reset the tokenizer state.  For that to work, it needs to have the
// definitions of individual states available.
//
// This may also be useful for providing more detailed error messages for parse
// errors, as we can match up states and inputs in a table without having to
// clutter the tokenizer code with lots of precise error messages.

#ifndef GUMBO_TOKENIZER_STATES_H_
#define GUMBO_TOKENIZER_STATES_H_

// The ordering of this enum is also used to build the dispatch table for the
// tokenizer state machine, so if it is changed, be sure to update that too.
typedef enum {
  GUMBO_LEX_DATA,
  GUMBO_LEX_CHAR_REF_IN_DATA,
  GUMBO_LEX_RCDATA,
  GUMBO_LEX_CHAR_REF_IN_RCDATA,
  GUMBO_LEX_RAWTEXT,
  GUMBO_LEX_SCRIPT,
  GUMBO_LEX_PLAINTEXT,
  GUMBO_LEX_TAG_OPEN,
  GUMBO_LEX_END_TAG_OPEN,
  GUMBO_LEX_TAG_NAME,
  GUMBO_LEX_RCDATA_LT,
  GUMBO_LEX_RCDATA_END_TAG_OPEN,
  GUMBO_LEX_RCDATA_END_TAG_NAME,
  GUMBO_LEX_RAWTEXT_LT,
  GUMBO_LEX_RAWTEXT_END_TAG_OPEN,
  GUMBO_LEX_RAWTEXT_END_TAG_NAME,
  GUMBO_LEX_SCRIPT_LT,
  GUMBO_LEX_SCRIPT_END_TAG_OPEN,
  GUMBO_LEX_SCRIPT_END_TAG_NAME,
  GUMBO_LEX_SCRIPT_ESCAPED_START,
  GUMBO_LEX_SCRIPT_ESCAPED_START_DASH,
  GUMBO_LEX_SCRIPT_ESCAPED,
  GUMBO_LEX_SCRIPT_ESCAPED_DASH,
  GUMBO_LEX_SCRIPT_ESCAPED_DASH_DASH,
  GUMBO_LEX_SCRIPT_ESCAPED_LT,
  GUMBO_LEX_SCRIPT_ESCAPED_END_TAG_OPEN,
  GUMBO_LEX_SCRIPT_ESCAPED_END_TAG_NAME,
  GUMBO_LEX_SCRIPT_DOUBLE_ESCAPED_START,
  GUMBO_LEX_SCRIPT_DOUBLE_ESCAPED,
  GUMBO_LEX_SCRIPT_DOUBLE_ESCAPED_DASH,
  GUMBO_LEX_SCRIPT_DOUBLE_ESCAPED_DASH_DASH,
  GUMBO_LEX_SCRIPT_DOUBLE_ESCAPED_LT,
  GUMBO_LEX_SCRIPT_DOUBLE_ESCAPED_END,
  GUMBO_LEX_BEFORE_ATTR_NAME,
  GUMBO_LEX_ATTR_NAME,
  GUMBO_LEX_AFTER_ATTR_NAME,
  GUMBO_LEX_BEFORE_ATTR_VALUE,
  GUMBO_LEX_ATTR_VALUE_DOUBLE_QUOTED,
  GUMBO_LEX_ATTR_VALUE_SINGLE_QUOTED,
  GUMBO_LEX_ATTR_VALUE_UNQUOTED,
  GUMBO_LEX_CHAR_REF_IN_ATTR_VALUE,
  GUMBO_LEX_AFTER_ATTR_VALUE_QUOTED,
  GUMBO_LEX_SELF_CLOSING_START_TAG,
  GUMBO_LEX_BOGUS_COMMENT,
  GUMBO_LEX_MARKUP_DECLARATION,
  GUMBO_LEX_COMMENT_START,
  GUMBO_LEX_COMMENT_START_DASH,
  GUMBO_LEX_COMMENT,
  GUMBO_LEX_COMMENT_END_DASH,
  GUMBO_LEX_COMMENT_END,
  GUMBO_LEX_COMMENT_END_BANG,
  GUMBO_LEX_DOCTYPE,
  GUMBO_LEX_BEFORE_DOCTYPE_NAME,
  GUMBO_LEX_DOCTYPE_NAME,
  GUMBO_LEX_AFTER_DOCTYPE_NAME,
  GUMBO_LEX_AFTER_DOCTYPE_PUBLIC_KEYWORD,
  GUMBO_LEX_BEFORE_DOCTYPE_PUBLIC_ID,
  GUMBO_LEX_DOCTYPE_PUBLIC_ID_DOUBLE_QUOTED,
  GUMBO_LEX_DOCTYPE_PUBLIC_ID_SINGLE_QUOTED,
  GUMBO_LEX_AFTER_DOCTYPE_PUBLIC_ID,
  GUMBO_LEX_BETWEEN_DOCTYPE_PUBLIC_SYSTEM_ID,
  GUMBO_LEX_AFTER_DOCTYPE_SYSTEM_KEYWORD,
  GUMBO_LEX_BEFORE_DOCTYPE_SYSTEM_ID,
  GUMBO_LEX_DOCTYPE_SYSTEM_ID_DOUBLE_QUOTED,
  GUMBO_LEX_DOCTYPE_SYSTEM_ID_SINGLE_QUOTED,
  GUMBO_LEX_AFTER_DOCTYPE_SYSTEM_ID,
  GUMBO_LEX_BOGUS_DOCTYPE,
  GUMBO_LEX_CDATA
} GumboTokenizerEnum;

#endif  // GUMBO_TOKENIZER_STATES_H_
