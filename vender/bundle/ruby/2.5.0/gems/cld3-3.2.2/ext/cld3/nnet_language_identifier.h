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

#ifndef NNET_LANGUAGE_IDENTIFIER_H_
#define NNET_LANGUAGE_IDENTIFIER_H_

#include <string>

#include "base.h"
#include "embedding_feature_extractor.h"
#include "embedding_network.h"
#include "lang_id_nn_params.h"
#include "language_identifier_features.h"
#include "script_span/getonescriptspan.h"
#include "cld_3/protos/sentence.pb.h"
#include "sentence_features.h"
#include "task_context.h"
#include "task_context_params.h"
#include "cld_3/protos/task_spec.pb.h"
#include "workspace.h"

namespace chrome_lang_id {

// Specialization of the EmbeddingFeatureExtractor for extracting from
// (Sentence, int).
class LanguageIdEmbeddingFeatureExtractor
    : public EmbeddingFeatureExtractor<WholeSentenceExtractor, Sentence> {
 public:
  const string ArgPrefix() const override;
};

// Class for detecting the language of a document.
class NNetLanguageIdentifier {
 public:
  // Information about a predicted language.
  struct Result {
    string language = kUnknown;
    float probability = 0.0;   // Language probability.
    bool is_reliable = false;  // Whether the prediction is reliable.

    // Proportion of bytes associated with the language. If FindLanguage is
    // called, this variable is set to 1.
    float proportion = 0.0;
  };

  NNetLanguageIdentifier();
  NNetLanguageIdentifier(int min_num_bytes, int max_num_bytes);
  ~NNetLanguageIdentifier();

  // Finds the most likely language for the given text, along with additional
  // information (e.g., probability). The prediction is based on the first N
  // bytes where N is the minumum between the number of interchange valid UTF8
  // bytes and max_num_bytes_. If N is less than min_num_bytes_ long, then this
  // function returns kUnknown.
  Result FindLanguage(const string &text);

  // Splits the input text (up to the first byte, if any, that is not
  // interchange valid UTF8) into spans based on the script, predicts a language
  // for each span, and returns a vector storing the top num_langs most frequent
  // languages along with additional information (e.g., proportions). The number
  // of bytes considered for each span is the minimum between the size of the
  // span and max_num_bytes_. If more languages are requested than what is
  // available in the input, then for those cases kUnknown is returned. Also, if
  // the size of the span is less than min_num_bytes_ long, then the span is
  // skipped. If the input text is too long, only the first
  // kMaxNumInputBytesToConsider bytes are processed.
  std::vector<Result> FindTopNMostFreqLangs(const string &text, int num_langs);

  // String returned when a language is unknown or prediction cannot be made.
  static const char kUnknown[];

  // Min number of bytes needed to make a prediction if the default constructor
  // is called.
  static const int kMinNumBytesToConsider;

  // Max number of bytes to consider to make a prediction if the default
  // constructor is called.
  static const int kMaxNumBytesToConsider;

  // Max number of input bytes to process.
  static const int kMaxNumInputBytesToConsider;

  // Predictions with probability greater than or equal to this threshold are
  // marked as reliable. This threshold was optimized on a set of text segments
  // extracted from wikipedia, and results in an overall precision, recall,
  // and f1 equal to 0.9760, 0.9624, and 0.9692, respectively.
  static const float kReliabilityThreshold;

  // Reliability threshold for the languages hr and bs.
  static const float kReliabilityHrBsThreshold;

 private:
  // Sets up and initializes the model.
  void Setup(TaskContext *context);
  void Init(TaskContext *context);

  // Extract features from sentence.  On return, FeatureVector features[i]
  // contains the features for the embedding space #i.
  void GetFeatures(Sentence *sentence,
                   std::vector<FeatureVector> *features) const;

  // Finds the most likely language for the given text. Assumes that the text is
  // interchange valid UTF8.
  Result FindLanguageOfValidUTF8(const string &text);

  // Returns the language name corresponding to the given id.
  string GetLanguageName(int language_id) const;

  // Concatenates snippets of text equally spread out throughout the input if
  // the size of the input is greater than the maximum number of bytes needed to
  // make a prediction. The resulting string is used for language
  // identification.
  string SelectTextGivenScriptSpan(const CLD2::LangSpan &script_span);
  string SelectTextGivenBeginAndSize(const char *text_begin, int text_size);

  // Number of languages.
  const int num_languages_;

  // Typed feature extractor for embeddings.
  LanguageIdEmbeddingFeatureExtractor feature_extractor_;

  // The registry of shared workspaces in the feature extractor.
  WorkspaceRegistry workspace_registry_;

  // Parameters for the neural networks.
  LangIdNNParams nn_params_;

  // Neural network to use for scoring.
  EmbeddingNetwork network_;

  // This feature function is not relevant to this class. Adding this variable
  // ensures that the features are linked.
  ContinuousBagOfNgramsFunction ngram_function_;

  // Minimum number of bytes needed to make a prediction. If the default
  // constructor is called, this variable is equal to kMinNumBytesToConsider.
  int min_num_bytes_;

  // Maximum number of bytes to use to make a prediction. If the default
  // constructor is called, this variable is equal to kMaxNumBytesToConsider.
  int max_num_bytes_;

  // Number of snippets to concatenate to produce the string used for language
  // identification. If max_num_bytes_ <= kNumSnippets (i.e., the maximum number
  // of bytes needed to make a prediction is smaller or equal to the number of
  // default snippets), then this variable is equal to 1. Otherwise, it is set
  // to kNumSnippets.
  int num_snippets_;

  // The string used to make a prediction is created by concatenating
  // num_snippets_ snippets of size snippet_size_ = (max_num_bytes_ /
  // num_snippets_) that are equaly spread out throughout the input.
  int snippet_size_;

  // Default number of snippets to concatenate to produce the string used for
  // language identification. For the actual number of snippets, see
  // num_snippets_.
  static const int kNumSnippets;
};

}  // namespace chrome_lang_id

#endif  // NNET_LANGUAGE_IDENTIFIER_H_
