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

#ifndef EMBEDDING_NETWORK_H_
#define EMBEDDING_NETWORK_H_

#include <vector>

#include "embedding_network_params.h"
#include "feature_extractor.h"
#include "float16.h"

namespace chrome_lang_id {

// Classifier using a hand-coded feed-forward neural network.
//
// No gradient computation, just inference.
//
// Based on the more general nlp_saft::EmbeddingNetwork.
//
// Classification works as follows:
//
// Discrete features -> Embeddings -> Concatenation -> Hidden+ -> Softmax
//
// In words: given some discrete features, this class extracts the embeddings
// for these features, concatenates them, passes them through one or two hidden
// layers (each layer uses Relu) and next through a softmax layer that computes
// an unnormalized score for each possible class.  Note: there is always a
// softmax layer.
//
// NOTE(salcianu): current code can easily be changed to allow more than two
// hidden layers.  Feel free to do so if you have a genuine need for that.
class EmbeddingNetwork {
 public:
  // Class used to represent an embedding matrix.  Each row is the embedding on
  // a vocabulary element.  Number of columns = number of embedding dimensions.
  class EmbeddingMatrix {
   public:
    explicit EmbeddingMatrix(const EmbeddingNetworkParams::Matrix source_matrix)
        : rows_(source_matrix.rows),
          cols_(source_matrix.cols),
          quant_type_(source_matrix.quant_type),
          data_(source_matrix.elements),
          row_size_in_bytes_(GetRowSizeInBytes(cols_, quant_type_)),
          quant_scales_(source_matrix.quant_scales) {}

    // Returns vocabulary size; one embedding for each vocabulary element.
    int size() const { return rows_; }

    // Returns number of weights in embedding of each vocabulary element.
    int dim() const { return cols_; }

    // Returns quantization type for this embedding matrix.
    QuantizationType quant_type() const { return quant_type_; }

    // Gets embedding for k-th vocabulary element: on return, sets *data to
    // point to the embedding weights and *scale to the quantization scale (1.0
    // if no quantization).
    void get_embedding(int k, const void **data, float *scale) const {
      CLD3_CHECK(k >= 0);
      CLD3_CHECK(k < size());
      *data = reinterpret_cast<const char *>(data_) + k * row_size_in_bytes_;
      if (quant_type_ == QuantizationType::NONE) {
        *scale = 1.0;
      } else {
        *scale = Float16To32(quant_scales_[k]);
      }
    }

   private:
    static int GetRowSizeInBytes(int cols, QuantizationType quant_type) {
      CLD3_DCHECK((quant_type == QuantizationType::NONE) ||
                  (quant_type == QuantizationType::UINT8));
      if (quant_type == QuantizationType::NONE) {
        return cols * sizeof(float);
      } else {  // QuantizationType::UINT8
        return cols * sizeof(uint8);
      }
    }

    // Vocabulary size.
    int rows_;

    // Number of elements in each embedding.
    int cols_;

    QuantizationType quant_type_;

    // Pointer to the embedding weights, in row-major order.  This is a pointer
    // to an array of floats / uint8, depending on the quantization type.
    // Not owned.
    const void *data_;

    // Number of bytes for one row.  Used to jump to next row in data_.
    int row_size_in_bytes_;

    // Pointer to quantization scales.  nullptr if no quantization.  Otherwise,
    // quant_scales_[i] is scale for embedding of i-th vocabulary element.
    const float16 *quant_scales_;
  };

  // An immutable vector that doesn't own the memory that stores the underlying
  // floats.  Can be used e.g., as a wrapper around model weights stored in the
  // static memory.
  class VectorWrapper {
   public:
    VectorWrapper() : VectorWrapper(nullptr, 0) {}

    // Constructs a vector wrapper around the size consecutive floats that start
    // at address data.  Note: the underlying data should be alive for at least
    // the lifetime of this VectorWrapper object.  That's trivially true if data
    // points to statically allocated data :)
    VectorWrapper(const float *data, int size) : data_(data), size_(size) {}

    int size() const { return size_; }

    const float *data() const { return data_; }

   private:
    const float *data_;  // Not owned.
    int size_;

    // Doesn't own anything, so it can be copied and assigned at will :)
  };

  typedef std::vector<VectorWrapper> Matrix;
  typedef std::vector<float> Vector;

  // Constructs an embedding network using the parameters from model.
  //
  // Note: model should stay alive for at least the lifetime of this
  // EmbeddingNetwork object.  TODO(salcianu): remove this constraint: we should
  // copy all necessary data (except, of course, the static weights) at
  // construction time and use that, instead of relying on model.
  explicit EmbeddingNetwork(const EmbeddingNetworkParams *model);

  virtual ~EmbeddingNetwork() {}

  // Runs forward computation to fill scores with unnormalized output unit
  // scores. This is useful for making predictions.
  void ComputeFinalScores(const std::vector<FeatureVector> &features,
                          Vector *scores) const;

 private:
  // Computes the softmax scores (prior to normalization) from the concatenated
  // representation.
  template <typename ScaleAdderClass>
  void FinishComputeFinalScores(const Vector &concat, Vector *scores) const;

  // Constructs the concatenated input embedding vector in place in output
  // vector concat.
  void ConcatEmbeddings(const std::vector<FeatureVector> &features,
                        Vector *concat) const;

  // Pointer to the model object passed to the constructor.  Not owned.
  const EmbeddingNetworkParams *model_;

  // Network parameters.

  // One weight matrix for each embedding.
  std::vector<EmbeddingMatrix> embedding_matrices_;

  // One weight matrix and one vector of bias weights for each hiden layer.
  std::vector<Matrix> hidden_weights_;
  std::vector<VectorWrapper> hidden_bias_;

  // Weight matrix and bias vector for the softmax layer.
  Matrix softmax_weights_;
  VectorWrapper softmax_bias_;
};

}  // namespace chrome_lang_id

#endif  // EMBEDDING_NETWORK_H_
