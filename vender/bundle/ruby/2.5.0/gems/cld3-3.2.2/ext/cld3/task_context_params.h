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

#ifndef TASK_CONTEXT_PARAMS_H_
#define TASK_CONTEXT_PARAMS_H_

#include <string>

#include "base.h"
#include "task_context.h"

namespace chrome_lang_id {

// Encapsulates the TaskContext specifying only the parameters for the model.
// The model weights are loaded statically.
class TaskContextParams {
 public:
  // Gets the name of the i'th language.
  static const char *language_names(int i) { return kLanguageNames[i]; }

  // Saves the parameters to the given TaskContext.
  static void ToTaskContext(TaskContext *context);

  // Gets the number of languages.
  static int GetNumLanguages();

 private:
  // Names of all the languages.
  static const char *const kLanguageNames[];

  // Features in FML format.
  static const char kLanguageIdentifierFeatures[];

  // Names of the embedding spaces.
  static const char kLanguageIdentifierEmbeddingNames[];

  // Dimensions of the embedding spaces.
  static const char kLanguageIdentifierEmbeddingDims[];
};
}  // namespace chrome_lang_id

#endif  // TASK_CONTEXT_PARAMS_H_
