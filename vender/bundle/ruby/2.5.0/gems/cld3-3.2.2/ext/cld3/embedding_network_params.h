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

#ifndef EMBEDDING_NETWORK_PARAMS_H_
#define EMBEDDING_NETWORK_PARAMS_H_

#include <string>

#include "base.h"
#include "float16.h"

namespace chrome_lang_id {

enum class QuantizationType { NONE = 0, UINT8 };

// API for accessing parameters from a statically-linked EmbeddingNetworkProto.
class EmbeddingNetworkParams {
 public:
  virtual ~EmbeddingNetworkParams() {}

  // **** High-level API.

  // Simple representation of a matrix.  This small struct that doesn't own any
  // resource intentionally supports copy / assign, to simplify our APIs.
  struct Matrix {
    // Number of rows.
    int rows;

    // Number of columns.
    int cols;

    QuantizationType quant_type;

    // Pointer to matrix elements, in row-major order
    // (https://en.wikipedia.org/wiki/Row-major_order) Not owned.
    const void *elements;

    // Quantization scales: one scale for each row.
    const float16 *quant_scales;
  };

  // Returns i-th embedding matrix.  Crashes on out of bounds indices.
  //
  // This is the transpose of the corresponding matrix from the original proto.
  Matrix GetEmbeddingMatrix(int i) const {
    CheckMatrixRange(i, embeddings_size(), "embedding matrix");
    Matrix matrix;
    matrix.rows = embeddings_num_rows(i);
    matrix.cols = embeddings_num_cols(i);
    matrix.elements = embeddings_weights(i);
    matrix.quant_type = embeddings_quant_type(i);
    matrix.quant_scales = embeddings_quant_scales(i);
    return matrix;
  }

  // Returns weight matrix for i-th hidden layer.  Crashes on out of bounds
  // indices.
  //
  // This is the transpose of the corresponding matrix from the original proto.
  Matrix GetHiddenLayerMatrix(int i) const {
    CheckMatrixRange(i, hidden_size(), "hidden layer");
    Matrix matrix;
    matrix.rows = hidden_num_rows(i);
    matrix.cols = hidden_num_cols(i);

    // Quantization not supported here.
    matrix.quant_type = QuantizationType::NONE;
    matrix.elements = hidden_weights(i);
    return matrix;
  }

  // Returns bias for i-th hidden layer.  Technically a Matrix, but we expect it
  // to be a row/column vector (i.e., num rows or num cols is 1).  However, we
  // don't CHECK for that: we just provide access to underlying data.  Crashes
  // on out of bounds indices.
  Matrix GetHiddenLayerBias(int i) const {
    CheckMatrixRange(i, hidden_bias_size(), "hidden layer bias");
    Matrix matrix;
    matrix.rows = hidden_bias_num_rows(i);
    matrix.cols = hidden_bias_num_cols(i);

    // Quantization not supported here.
    matrix.quant_type = QuantizationType::NONE;
    matrix.elements = hidden_bias_weights(i);
    return matrix;
  }

  // Returns true if a softmax layer exists.
  bool HasSoftmax() const { return softmax_size() == 1; }

  // Returns weight matrix for the softmax layer.  Note: should be called only
  // if HasSoftmax() is true.
  //
  // This is the transpose of the corresponding matrix from the original proto.
  Matrix GetSoftmaxMatrix() const {
    CLD3_DCHECK(HasSoftmax());
    Matrix matrix;
    matrix.rows = softmax_num_rows(0);
    matrix.cols = softmax_num_cols(0);

    // Quantization not supported here.
    matrix.quant_type = QuantizationType::NONE;
    matrix.elements = softmax_weights(0);
    return matrix;
  }

  // Returns bias for the softmax layer.  Technically a Matrix, but we expect it
  // to be a row/column vector (i.e., num rows or num cols is 1).  However, we
  // don't CHECK for that: we just provide access to underlying data.
  Matrix GetSoftmaxBias() const {
    CLD3_DCHECK(HasSoftmax());
    Matrix matrix;
    matrix.rows = softmax_bias_num_rows(0);
    matrix.cols = softmax_bias_num_cols(0);

    // Quantization not supported here.
    matrix.quant_type = QuantizationType::NONE;
    matrix.elements = softmax_bias_weights(0);
    return matrix;
  }

  // **** Low-level API.
  //
  // * Most low-level API methods are documented by giving an equivalent
  //   function call on proto, the original proto (of type
  //   EmbeddingNetworkProto) which was used to generate the C++ code.
  //
  // * To simplify our generation code, optional proto fields of message type
  //   are treated as repeated fields with 0 or 1 instances.  As such, we have
  //   *_size() methods for such optional fields: they return 0 or 1.
  //
  // * "transpose(M)" denotes the transpose of a matrix M.

  // ** Access methods for repeated MatrixParams embeddings.
  //
  // Returns proto.embeddings_size().
  virtual int embeddings_size() const = 0;

  // Returns number of rows of transpose(proto.embeddings(i)).
  virtual int embeddings_num_rows(int i) const = 0;

  // Returns number of columns of transpose(proto.embeddings(i)).
  virtual int embeddings_num_cols(int i) const = 0;

  // Returns pointer to elements of transpose(proto.embeddings(i)), in row-major
  // order.
  virtual const void *embeddings_weights(int i) const = 0;

  virtual QuantizationType embeddings_quant_type(int i) const {
    return QuantizationType::NONE;
  }

  virtual const float16 *embeddings_quant_scales(int i) const {
    return nullptr;
  }

  // ** Access methods for repeated MatrixParams hidden.
  //
  // Returns embedding_network_proto.hidden_size().
  virtual int hidden_size() const = 0;

  // Returns embedding_network_proto.hidden(i).rows().
  virtual int hidden_num_rows(int i) const = 0;

  // Returns embedding_network_proto.hidden(i).rows().
  virtual int hidden_num_cols(int i) const = 0;

  // Returns pointer to beginning of array of floats with all values from
  // embedding_network_proto.hidden(i).
  virtual const void *hidden_weights(int i) const = 0;

  // ** Access methods for repeated MatrixParams hidden_bias.
  //
  // Returns proto.hidden_bias_size().
  virtual int hidden_bias_size() const = 0;

  // Returns number of rows of proto.hidden_bias(i).
  virtual int hidden_bias_num_rows(int i) const = 0;

  // Returns number of columns of proto.hidden_bias(i).
  virtual int hidden_bias_num_cols(int i) const = 0;

  // Returns pointer to elements of proto.hidden_bias(i), in row-major order.
  virtual const void *hidden_bias_weights(int i) const = 0;

  // ** Access methods for optional MatrixParams softmax.
  //
  // Returns 1 if proto has optional field softmax, 0 otherwise.
  virtual int softmax_size() const = 0;

  // Returns number of rows of transpose(proto.softmax()).
  virtual int softmax_num_rows(int i) const = 0;

  // Returns number of columns of transpose(proto.softmax()).
  virtual int softmax_num_cols(int i) const = 0;

  // Returns pointer to elements of transpose(proto.softmax()), in row-major
  // order.
  virtual const void *softmax_weights(int i) const = 0;

  // ** Access methods for optional MatrixParams softmax_bias.
  //
  // Returns 1 if proto has optional field softmax_bias, 0 otherwise.
  virtual int softmax_bias_size() const = 0;

  // Returns number of rows of proto.softmax_bias().
  virtual int softmax_bias_num_rows(int i) const = 0;

  // Returns number of columns of proto.softmax_bias().
  virtual int softmax_bias_num_cols(int i) const = 0;

  // Returns pointer to elements of proto.softmax_bias(), in row-major order.
  virtual const void *softmax_bias_weights(int i) const = 0;

  // ** Access methods for repeated int32 embedding_dim.
  //
  // Returns proto.embedding_dim_size().
  virtual int embedding_dim_size() const = 0;

  // Returns proto.embedding_dim(i).
  virtual int embedding_dim(int i) const = 0;

  // ** Access methods for repeated int32 embedding_num_features.
  //
  // Returns proto.embedding_num_features_size().
  virtual int embedding_num_features_size() const = 0;

  // Returns proto.embedding_num_features(i).
  virtual int embedding_num_features(int i) const = 0;

  // ** Access methods for repeated int32 embedding_features_domain_size.
  //
  // Returns proto.embedding_features_domain_size_size().
  virtual int embedding_features_domain_size_size() const = 0;

  // Returns proto.embedding_features_domain_size(i).
  virtual int embedding_features_domain_size(int i) const = 0;

  // ** Access methods for repeated int32 concat_offset.
  //
  // Returns proto.concat_offset_size().
  virtual int concat_offset(int i) const = 0;

  // Returns proto.concat_offset(i).
  virtual int concat_offset_size() const = 0;

  // ** Access methods for concat_layer_size.
  //
  // Returns proto.has_concat_layer_size().
  virtual bool has_concat_layer_size() const = 0;

  // Returns proto.concat_layer_size().
  virtual int concat_layer_size() const = 0;

  // ** Access methods for is_precomputed
  //
  // Returns proto.has_is_precomputed().
  virtual bool has_is_precomputed() const = 0;

  // Returns proto.is_precomputed().
  virtual bool is_precomputed() const = 0;

 private:
  void CheckMatrixRange(int index, int num_matrices,
                        const string &description) const {
    CLD3_DCHECK(index >= 0);
    CLD3_DCHECK(index < num_matrices);
  }
};  // class EmbeddingNetworkParams

}  // namespace chrome_lang_id

#endif  // EMBEDDING_NETWORK_PARAMS_H_
