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

#ifndef LANGUAGE_IDENTIFIER_FEATURES_H_
#define LANGUAGE_IDENTIFIER_FEATURES_H_

#include <string>

#include "feature_extractor.h"
#include "feature_types.h"
#include "script_span/generated_ulscript.h"
#include "cld_3/protos/sentence.pb.h"
#include "sentence_features.h"
#include "task_context.h"
#include "workspace.h"

namespace chrome_lang_id {

// Feature type for numeric features.
class NumericFeatureType : public FeatureType {
 public:
  // Initializes numeric feature.
  NumericFeatureType(const string &name, FeatureValue size);

  // Returns numeric feature value.
  string GetFeatureValueName(FeatureValue value) const override;

  // Returns the number of feature values.
  FeatureValue GetDomainSize() const override;

 private:
  FeatureValue size_;
};

// Class for computing continuous char ngram features.
// Feature function descriptor parameters:
//   include_terminators(bool, false):
//     If 'true', then splits the text based on spaces to get tokens, adds "^"
//     to the beginning of each token, and adds "$" to the end of each token.
//   include_spaces(bool, false):
//     If 'true', then includes char ngrams containing spaces.
//   use_equal_weight(bool, false):
//     If 'true', then weighs each unique ngram by 1.0 / (number of unique
//     ngrams in the input). Otherwise, weighs each unique ngram by (ngram
//     count) / (total number of ngrams).
//   id_dim(int, 10000):
//     The integer id of each char ngram is computed as follows:
//     Hash32WithDefaultSeed(char ngram) % id_dim.
//   size(int, 3):
//     Only ngrams of this size will be extracted.
class ContinuousBagOfNgramsFunction : public WholeSentenceFeature {
 public:
  void Setup(TaskContext *context) override;
  void Init(TaskContext *context) override;

  // Appends the features computed from the focus to the feature vector.
  void Evaluate(const WorkspaceSet &workspaces, const Sentence &sentence,
                FeatureVector *result) const override;

 private:
  // If 'true', then splits the text based on spaces to get tokens, adds "^" to
  // the beginning of each token, and adds "$" to the end of each token.
  bool include_terminators_;

  // If 'true', then includes char ngrams containing spaces.
  bool include_spaces_;

  // If 'true', then weighs each unique ngram by 1.0 / (number of unique ngrams
  // in the input). Otherwise, weighs each unique ngram by (ngram count) /
  // (total number of ngrams).
  bool use_equal_ngram_weight_;

  // The integer id of each char ngram is computed as follows:
  // Hash32WithDefaultSeed(char_ngram) % ngram_id_dimension_.
  int ngram_id_dimension_;

  // Only ngrams of size ngram_size_ will be extracted.
  int ngram_size_;
};

// Class for detecting the script of a piece of text. The list of supported
// scripts is chrome_lang_id::CLD2::ULScript. This class uses the script
// recognition code ported from CLD2. ULScript_Hani is split into non-Korean
// script and Korean script (Hangul). In the former case, the function emits
// ULScript_Hani. In the latter case, the function emits NUM_ULSCRIPTS. The
// class assumes that the input is (1) interchange valid UTF8, and (2) contains
// only one chrome_lang_id::CLD2::ULScript.
class ScriptFeature : public WholeSentenceFeature {
 public:
  void Init(TaskContext *context) override {
    // The dimension is incremented by 1 because ULScript_Hani is split into two
    // as mentioned in the class description.
    set_feature_type(new NumericFeatureType(
        name(), chrome_lang_id::CLD2::NUM_ULSCRIPTS + 1));
  }

  // Computes the feature and saves it in the feature vector.
  FeatureValue Compute(const WorkspaceSet &workspaces, const Sentence &sentence,
                       const FeatureVector *result) const override;
};

}  // namespace chrome_lang_id

#endif  // LANGUAGE_IDENTIFIER_FEATURES_H_
