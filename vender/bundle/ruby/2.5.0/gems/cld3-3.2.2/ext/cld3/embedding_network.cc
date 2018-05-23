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

#include "embedding_network.h"

#include "base.h"
#include "embedding_network_params.h"
#include "float16.h"
#include "simple_adder.h"

namespace chrome_lang_id {
namespace {

using VectorWrapper = EmbeddingNetwork::VectorWrapper;

void CheckNoQuantization(const EmbeddingNetworkParams::Matrix matrix) {
  // Quantization not allowed here.
  CLD3_DCHECK(static_cast<int>(QuantizationType::NONE) ==
              static_cast<int>(matrix.quant_type));
}

// Fills a Matrix object with the parameters in the given MatrixParams.  This
// function is used to initialize weight matrices that are *not* embedding
// matrices.
void FillMatrixParams(const EmbeddingNetworkParams::Matrix source_matrix,
                      EmbeddingNetwork::Matrix *mat) {
  mat->resize(source_matrix.rows);
  CheckNoQuantization(source_matrix);
  const float *weights =
      reinterpret_cast<const float *>(source_matrix.elements);
  for (int r = 0; r < source_matrix.rows; ++r) {
    (*mat)[r] = EmbeddingNetwork::VectorWrapper(weights, source_matrix.cols);
    weights += source_matrix.cols;
  }
}

// Computes y = weights * Relu(x) + b where Relu is optionally applied.
template <typename ScaleAdderClass>
void SparseReluProductPlusBias(bool apply_relu,
                               const EmbeddingNetwork::Matrix &weights,
                               const EmbeddingNetwork::VectorWrapper &b,
                               const EmbeddingNetwork::Vector &x,
                               EmbeddingNetwork::Vector *y) {
  y->assign(b.data(), b.data() + b.size());
  ScaleAdderClass adder(y->data(), y->size());

  const int x_size = x.size();
  for (int i = 0; i < x_size; ++i) {
    const float &scale = x[i];
    if (apply_relu) {
      if (scale > 0) {
        adder.LazyScaleAdd(weights[i].data(), scale);
      }
    } else {
      adder.LazyScaleAdd(weights[i].data(), scale);
    }
  }
  adder.Finalize();
}
}  // namespace

void EmbeddingNetwork::ConcatEmbeddings(
    const std::vector<FeatureVector> &feature_vectors, Vector *concat) const {
  concat->resize(model_->concat_layer_size());

  // "es_index" stands for "embedding space index".
  for (size_t es_index = 0; es_index < feature_vectors.size(); ++es_index) {
    const int concat_offset = model_->concat_offset(es_index);
    const int embedding_dim = model_->embedding_dim(es_index);

    const EmbeddingMatrix &embedding_matrix = embedding_matrices_[es_index];
    CLD3_DCHECK(embedding_matrix.dim() == embedding_dim);

    const bool is_quantized =
        embedding_matrix.quant_type() != QuantizationType::NONE;

    const FeatureVector &feature_vector = feature_vectors[es_index];
    const int num_features = feature_vector.size();
    for (int fi = 0; fi < num_features; ++fi) {
      const FeatureType *feature_type = feature_vector.type(fi);
      int feature_offset = concat_offset + feature_type->base() * embedding_dim;
      CLD3_DCHECK(feature_offset + embedding_dim <=
                  static_cast<int>(concat->size()));

      // Weighted embeddings will be added starting from this address.
      float *concat_ptr = concat->data() + feature_offset;

      // Pointer to float / uint8 weights for relevant embedding.
      const void *embedding_data;

      // Multiplier for each embedding weight.
      float multiplier;
      const FeatureValue feature_value = feature_vector.value(fi);
      if (feature_type->is_continuous()) {
        // Continuous features (encoded as FloatFeatureValue).
        FloatFeatureValue float_feature_value(feature_value);
        const int id = float_feature_value.value.id;
        embedding_matrix.get_embedding(id, &embedding_data, &multiplier);
        multiplier *= float_feature_value.value.weight;
      } else {
        // Discrete features: every present feature has implicit value 1.0.
        embedding_matrix.get_embedding(feature_value, &embedding_data,
                                       &multiplier);
      }

      if (is_quantized) {
        const uint8 *quant_weights =
            reinterpret_cast<const uint8 *>(embedding_data);
        for (int i = 0; i < embedding_dim; ++i, ++quant_weights, ++concat_ptr) {
          // 128 is bias for UINT8 quantization, only one we currently support.
          *concat_ptr += (static_cast<int>(*quant_weights) - 128) * multiplier;
        }
      } else {
        const float *weights = reinterpret_cast<const float *>(embedding_data);
        for (int i = 0; i < embedding_dim; ++i, ++weights, ++concat_ptr) {
          *concat_ptr += *weights * multiplier;
        }
      }
    }
  }
}

template <typename ScaleAdderClass>
void EmbeddingNetwork::FinishComputeFinalScores(const Vector &concat,
                                                Vector *scores) const {
  Vector h0(hidden_bias_[0].size());
  SparseReluProductPlusBias<ScaleAdderClass>(false, hidden_weights_[0],
                                             hidden_bias_[0], concat, &h0);

  CLD3_DCHECK((hidden_weights_.size() == 1) || (hidden_weights_.size() == 2));
  if (hidden_weights_.size() == 1) {  // 1 hidden layer
    SparseReluProductPlusBias<ScaleAdderClass>(true, softmax_weights_,
                                               softmax_bias_, h0, scores);
  } else if (hidden_weights_.size() == 2) {  // 2 hidden layers
    Vector h1(hidden_bias_[1].size());
    SparseReluProductPlusBias<ScaleAdderClass>(true, hidden_weights_[1],
                                               hidden_bias_[1], h0, &h1);
    SparseReluProductPlusBias<ScaleAdderClass>(true, softmax_weights_,
                                               softmax_bias_, h1, scores);
  }
}

void EmbeddingNetwork::ComputeFinalScores(
    const std::vector<FeatureVector> &features, Vector *scores) const {
  Vector concat;
  ConcatEmbeddings(features, &concat);

  scores->resize(softmax_bias_.size());
  FinishComputeFinalScores<SimpleAdder>(concat, scores);
}

EmbeddingNetwork::EmbeddingNetwork(const EmbeddingNetworkParams *model)
    : model_(model) {
  int offset_sum = 0;
  for (int i = 0; i < model_->embedding_dim_size(); ++i) {
    CLD3_DCHECK(offset_sum == model_->concat_offset(i));
    offset_sum += model_->embedding_dim(i) * model_->embedding_num_features(i);
    embedding_matrices_.emplace_back(model_->GetEmbeddingMatrix(i));
  }

  CLD3_DCHECK(model_->hidden_size() == model_->hidden_bias_size());
  hidden_weights_.resize(model_->hidden_size());
  hidden_bias_.resize(model_->hidden_size());
  for (int i = 0; i < model_->hidden_size(); ++i) {
    FillMatrixParams(model_->GetHiddenLayerMatrix(i), &hidden_weights_[i]);
    EmbeddingNetworkParams::Matrix bias = model_->GetHiddenLayerBias(i);
    CLD3_DCHECK(1 == bias.cols);
    CheckNoQuantization(bias);
    hidden_bias_[i] = VectorWrapper(
        reinterpret_cast<const float *>(bias.elements), bias.rows);
  }

  CLD3_DCHECK(model_->HasSoftmax());
  FillMatrixParams(model_->GetSoftmaxMatrix(), &softmax_weights_);

  EmbeddingNetworkParams::Matrix softmax_bias = model_->GetSoftmaxBias();
  CLD3_DCHECK(1 == softmax_bias.cols);
  CheckNoQuantization(softmax_bias);
  softmax_bias_ =
      VectorWrapper(reinterpret_cast<const float *>(softmax_bias.elements),
                    softmax_bias.rows);
}

}  // namespace chrome_lang_id
