/* Copyright 2017 Akihiko Odaki <akihiko.odaki.4i@stu.hosei.ac.jp>
All Rights Reserved.

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

#include <iostream>
#include "nnet_language_identifier.h"

#if defined _WIN32 || defined __CYGWIN__
  #define EXPORT __declspec(dllexport)
#else
  #define EXPORT __attribute__ ((visibility ("default")))
#endif

struct NNetLanguageIdentifier {
  chrome_lang_id::NNetLanguageIdentifier context;
  std::string language;
};

extern "C" {
  #include <stddef.h>

  typedef struct {
    struct {
      const char *data;
      size_t size;
    } language;
    float probability;
    float proportion;
    bool is_reliable;
  } Result;

  EXPORT Result NNetLanguageIdentifier_find_language(void *pointer,
                                                     const char *data,
                                                     size_t size) {
    auto instance = reinterpret_cast<NNetLanguageIdentifier *>(pointer);
    auto result = instance->context.FindLanguage(std::string(data, size));
    instance->language = std::move(result.language);

    return Result {
        { instance->language.data(), instance->language.size() },
        std::move(result.probability),
        std::move(result.proportion),
        std::move(result.is_reliable)
    };
  }

  EXPORT void delete_NNetLanguageIdentifier(void *pointer) {
    delete reinterpret_cast<NNetLanguageIdentifier *>(pointer);
  }

  EXPORT void *new_NNetLanguageIdentifier(int min_num_bytes, int max_num_bytes) {
    return new NNetLanguageIdentifier{{min_num_bytes, max_num_bytes}, {}};
  }
}
