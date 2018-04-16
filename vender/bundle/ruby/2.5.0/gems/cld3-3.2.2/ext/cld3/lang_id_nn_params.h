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

#ifndef LANG_ID_NN_PARAMS_H_
#define LANG_ID_NN_PARAMS_H_

#include "base.h"
#include "embedding_network_params.h"
#include "float16.h"

namespace chrome_lang_id {

class LangIdNNParams : public EmbeddingNetworkParams {
 public:
  ~LangIdNNParams() override {}

  // Access methods for embeddings:
  int embeddings_size() const override { return 6; }
  int embeddings_num_rows(int i) const override {
    return kEmbeddingsNumRows[i];
  }
  int embeddings_num_cols(int i) const override {
    return kEmbeddingsNumCols[i];
  }
  const void *embeddings_weights(int i) const override {
    return embeddings_weights_[i];
  }
  QuantizationType embeddings_quant_type(int i) const override {
    return QuantizationType::UINT8;
  }
  const float16 *embeddings_quant_scales(int i) const override {
    return embeddings_quant_scales_[i];
  }

  // Access methods for hidden:
  int hidden_size() const override { return 1; }
  int hidden_num_rows(int i) const override { return kHiddenNumRows[i]; }
  int hidden_num_cols(int i) const override { return kHiddenNumCols[i]; }
  const void *hidden_weights(int i) const override {
    return hidden_weights_[i];
  }

  // Access methods for hidden_bias:
  int hidden_bias_size() const override { return 1; }
  int hidden_bias_num_rows(int i) const override {
    return kHiddenBiasNumRows[i];
  }
  int hidden_bias_num_cols(int i) const override {
    return kHiddenBiasNumCols[i];
  }
  const void *hidden_bias_weights(int i) const override {
    return hidden_bias_weights_[i];
  }

  // Access methods for softmax:
  int softmax_size() const override { return 1; }
  int softmax_num_rows(int i) const override { return kSoftmaxNumRows[i]; }
  int softmax_num_cols(int i) const override { return kSoftmaxNumCols[i]; }
  const void *softmax_weights(int i) const override {
    return softmax_weights_[i];
  }

  // Access methods for softmax_bias:
  int softmax_bias_size() const override { return 1; }
  int softmax_bias_num_rows(int i) const override {
    return kSoftmaxBiasNumRows[i];
  }
  int softmax_bias_num_cols(int i) const override {
    return kSoftmaxBiasNumCols[i];
  }
  const void *softmax_bias_weights(int i) const override {
    return softmax_bias_weights_[i];
  }

  // Access methods for embedding_dim:
  int embedding_dim_size() const override { return 6; }
  int32 embedding_dim(int i) const override { return kEmbeddingDimValues[i]; }

  // Access methods for embedding_num_features:
  int embedding_num_features_size() const override { return 6; }
  int32 embedding_num_features(int i) const override {
    return kEmbeddingNumFeaturesValues[i];
  }

  // Access methods for embedding_features_domain_size:
  int embedding_features_domain_size_size() const override { return 6; }
  int32 embedding_features_domain_size(int i) const override {
    return kEmbeddingFeaturesDomainSizeValues[i];
  }

  // Access methods for concat_offset:
  int concat_offset_size() const override { return 6; }
  int32 concat_offset(int i) const override { return kConcatOffsetValues[i]; }

  // Access methods for concat_layer_size:
  bool has_concat_layer_size() const override { return true; }
  int32 concat_layer_size() const override { return 80; }

  // Access methods for is_precomputed:
  bool has_is_precomputed() const override { return false; }
  bool is_precomputed() const override { return false; }

 private:
  // Private fields for embeddings:
  static const int kEmbeddingsNumRows[];
  static const int kEmbeddingsNumCols[];
  static const uint8 kEmbeddingsWeights0[];
  static const uint8 kEmbeddingsWeights1[];
  static const uint8 kEmbeddingsWeights2[];
  static const uint8 kEmbeddingsWeights3[];
  static const uint8 kEmbeddingsWeights4[];
  static const uint8 kEmbeddingsWeights5[];
  const void *embeddings_weights_[6] = {
      kEmbeddingsWeights0, kEmbeddingsWeights1, kEmbeddingsWeights2,
      kEmbeddingsWeights3, kEmbeddingsWeights4, kEmbeddingsWeights5};
  static const float16 kEmbeddingsQuantScales0[];
  static const float16 kEmbeddingsQuantScales1[];
  static const float16 kEmbeddingsQuantScales2[];
  static const float16 kEmbeddingsQuantScales3[];
  static const float16 kEmbeddingsQuantScales4[];
  static const float16 kEmbeddingsQuantScales5[];
  const float16 *embeddings_quant_scales_[6] = {
      kEmbeddingsQuantScales0, kEmbeddingsQuantScales1,
      kEmbeddingsQuantScales2, kEmbeddingsQuantScales3,
      kEmbeddingsQuantScales4, kEmbeddingsQuantScales5};

  // Private fields for hidden:
  static const int kHiddenNumRows[];
  static const int kHiddenNumCols[];
  static const float kHiddenWeights0[];
  const void *hidden_weights_[1] = {kHiddenWeights0};

  // Private fields for hidden_bias:
  static const int kHiddenBiasNumRows[];
  static const int kHiddenBiasNumCols[];
  static const float kHiddenBiasWeights0[];
  const void *hidden_bias_weights_[1] = {kHiddenBiasWeights0};

  // Private fields for softmax:
  static const int kSoftmaxNumRows[];
  static const int kSoftmaxNumCols[];
  static const float kSoftmaxWeights0[];
  const void *softmax_weights_[1] = {kSoftmaxWeights0};

  // Private fields for softmax_bias:
  static const int kSoftmaxBiasNumRows[];
  static const int kSoftmaxBiasNumCols[];
  static const float kSoftmaxBiasWeights0[];
  const void *softmax_bias_weights_[1] = {kSoftmaxBiasWeights0};

  // Private fields for embedding_dim:
  static const int32 kEmbeddingDimValues[];

  // Private fields for embedding_num_features:
  static const int32 kEmbeddingNumFeaturesValues[];

  // Private fields for embedding_features_domain_size:
  static const int32 kEmbeddingFeaturesDomainSizeValues[];

  // Private fields for concat_offset:
  static const int32 kConcatOffsetValues[];
};  // class LangIdNNParams

}  // namespace chrome_lang_id

#endif  // LANG_ID_NN_PARAMS_H_
