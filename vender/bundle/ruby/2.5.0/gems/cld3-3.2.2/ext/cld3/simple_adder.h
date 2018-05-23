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

#ifndef SIMPLE_ADDER_H_
#define SIMPLE_ADDER_H_

#include "base.h"

namespace chrome_lang_id {

// Class for adding (possibly) scaled arrays.
class SimpleAdder {
 public:
  static constexpr const int kNumFloatsPerBatch = 1;

  CLD3_ATTRIBUTE_ALWAYS_INLINE SimpleAdder(float *dest, int num_floats)
      : dest_(dest), num_floats_(num_floats) {}

  CLD3_ATTRIBUTE_ALWAYS_INLINE ~SimpleAdder() {
    // Should call Finalize function before destruction.
    CLD3_DCHECK(dest_ == nullptr);
  }

  // Caller must call this function before calling deconstruct this object.
  CLD3_ATTRIBUTE_ALWAYS_INLINE void Finalize() { dest_ = nullptr; }

  CLD3_ATTRIBUTE_ALWAYS_INLINE void LazyAdd(const float *source) const {
    AddImpl(source, num_floats_, dest_);
  }

  CLD3_ATTRIBUTE_ALWAYS_INLINE void LazyScaleAdd(const float *source,
                                                 const float scale) const {
    ScaleAddImpl(source, num_floats_, scale, dest_);
  }

  // Simple fast while loop to implement dest += source.
  CLD3_ATTRIBUTE_ALWAYS_INLINE static void AddImpl(
      const float *__restrict source, uint32 size, float *__restrict dest) {
    for (uint32 i = 0; i < size; ++i) {
      dest[i] += source[i];
    }
  }

  // Simple fast while loop to implement dest += scale * source.
  CLD3_ATTRIBUTE_ALWAYS_INLINE static void ScaleAddImpl(
      const float *__restrict source, uint32 size, const float scale,
      float *__restrict dest) {
    for (uint32 i = 0; i < size; ++i) {
      dest[i] += source[i] * scale;
    }
  }

 private:
  float *dest_;
  int num_floats_;
};

}  // namespace chrome_lang_id

#endif  // SIMPLE_ADDER_H_
