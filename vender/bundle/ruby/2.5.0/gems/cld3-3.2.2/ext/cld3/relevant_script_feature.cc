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

#include "relevant_script_feature.h"

#include <ctype.h>

#include <string>

#include "feature_extractor.h"
#include "feature_types.h"
#include "language_identifier_features.h"
#include "script_detector.h"
#include "cld_3/protos/sentence.pb.h"
#include "sentence_features.h"
#include "task_context.h"
#include "utils.h"
#include "workspace.h"

namespace chrome_lang_id {
void RelevantScriptFeature::Setup(TaskContext *context) {
  // Nothing.
}

void RelevantScriptFeature::Init(TaskContext *context) {
  set_feature_type(new NumericFeatureType(name(), kNumRelevantScripts));
}

void RelevantScriptFeature::Evaluate(const WorkspaceSet &workspaces,
                                     const Sentence &sentence,
                                     FeatureVector *result) const {
  const string &text = sentence.text();

  // We expect kNumRelevantScripts to be small, so we stack-allocate the array
  // of counts.  Still, if that changes, we want to find out.
  static_assert(
      kNumRelevantScripts < 25,
      "switch counts to vector<int>: too big for stack-allocated int[]");

  // counts[s] is the number of characters with script s.
  // Note: {} "value-initializes" the array to zero.
  int counts[kNumRelevantScripts]{};
  int total_count = 0;
  const char *const text_end = text.data() + text.size();
  for (const char *curr = text.data(); curr < text_end;
       curr += utils::OneCharLen(curr)) {
    const int num_bytes = utils::OneCharLen(curr);

    // If a partial UTF-8 character is encountered, break out of the loop.
    if (curr + num_bytes > text_end) {
      break;
    }

    // Skip spaces, numbers, punctuation, and all other non-alpha ASCII
    // characters: these characters are used in so many languages, they do not
    // communicate language-related information.
    if ((num_bytes == 1) && !isalpha(*curr)) {
      continue;
    }
    Script script = GetScript(curr, num_bytes);
    CLD3_DCHECK(script >= 0);
    CLD3_DCHECK(script < kNumRelevantScripts);
    counts[static_cast<int>(script)]++;
    total_count++;
  }

  for (int script_id = 0; script_id < kNumRelevantScripts; ++script_id) {
    int count = counts[script_id];
    if (count > 0) {
      const float weight = static_cast<float>(count) / total_count;
      FloatFeatureValue value(script_id, weight);
      result->add(feature_type(), value.discrete_value);
    }
  }
}

}  // namespace chrome_lang_id
