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

#include "embedding_feature_extractor.h"

#include <stddef.h>
#include <vector>

#include "feature_extractor.h"
#include "feature_types.h"
#include "task_context.h"
#include "utils.h"

namespace chrome_lang_id {

GenericEmbeddingFeatureExtractor::GenericEmbeddingFeatureExtractor() {}

GenericEmbeddingFeatureExtractor::~GenericEmbeddingFeatureExtractor() {}

void GenericEmbeddingFeatureExtractor::Setup(TaskContext *context) {
  // Don't use version to determine how to get feature FML.
  string features_param = ArgPrefix();
  features_param += "_features";
  const string features = context->Get(features_param, "");
  const string embedding_names =
      context->Get(GetParamName("embedding_names"), "");
  const string embedding_dims =
      context->Get(GetParamName("embedding_dims"), "");
  embedding_fml_ = utils::Split(features, ';');
  add_strings_ = context->Get(GetParamName("add_varlen_strings"), false);
  embedding_names_ = utils::Split(embedding_names, ';');
  for (const string &dim : utils::Split(embedding_dims, ';')) {
    embedding_dims_.push_back(utils::ParseUsing<int>(dim, utils::ParseInt32));
  }
}

void GenericEmbeddingFeatureExtractor::Init(TaskContext *context) {}

}  // namespace chrome_lang_id
