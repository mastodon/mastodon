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

#include "feature_extractor.h"

#include <string>

#include "feature_types.h"
#include "fml_parser.h"
#include "utils.h"

namespace chrome_lang_id {

constexpr FeatureValue GenericFeatureFunction::kNone;

FeatureVector::FeatureVector() {}

FeatureVector::~FeatureVector() {}

GenericFeatureExtractor::GenericFeatureExtractor() {}

GenericFeatureExtractor::~GenericFeatureExtractor() {}

GenericFeatureExtractor::GenericFeatureExtractor(
    const GenericFeatureExtractor &extractor)
    : descriptor_(extractor.descriptor_),
      feature_types_(extractor.feature_types_) {}

void GenericFeatureExtractor::Parse(const string &source) {
  // Parse feature specification into descriptor.
  FMLParser parser;
  parser.Parse(source, mutable_descriptor());

  // Initialize feature extractor from descriptor.
  InitializeFeatureFunctions();
}

void GenericFeatureExtractor::InitializeFeatureTypes() {
  // Register all feature types.
  GetFeatureTypes(&feature_types_);
  for (size_t i = 0; i < feature_types_.size(); ++i) {
    FeatureType *ft = feature_types_[i];
    ft->set_base(i);

    // Check for feature space overflow.
    CLD3_DCHECK(ft->GetDomainSize() >= 0);
  }

  std::vector<string> types_names;
  GetFeatureTypeNames(&types_names);
  CLD3_DCHECK(feature_types_.size() == types_names.size());
}

void GenericFeatureExtractor::GetFeatureTypeNames(
    std::vector<string> *type_names) const {
  for (size_t i = 0; i < feature_types_.size(); ++i) {
    FeatureType *ft = feature_types_[i];
    type_names->push_back(ft->name());
  }
}

FeatureValue GenericFeatureExtractor::GetDomainSize() const {
  // Domain size of the set of features is equal to:
  //   [largest domain size of any feature types] * [number of feature types]
  FeatureValue max_feature_type_dsize = 0;
  for (size_t i = 0; i < feature_types_.size(); ++i) {
    FeatureType *ft = feature_types_[i];
    const FeatureValue feature_type_dsize = ft->GetDomainSize();
    if (feature_type_dsize > max_feature_type_dsize) {
      max_feature_type_dsize = feature_type_dsize;
    }
  }

  return max_feature_type_dsize;
}

string GenericFeatureFunction::GetParameter(const string &name) const {
  // Find named parameter in feature descriptor.
  for (int i = 0; i < descriptor_->parameter_size(); ++i) {
    if (name == descriptor_->parameter(i).name()) {
      return descriptor_->parameter(i).value();
    }
  }
  return "";
}

GenericFeatureFunction::GenericFeatureFunction() {}

GenericFeatureFunction::~GenericFeatureFunction() { delete feature_type_; }

int GenericFeatureFunction::GetIntParameter(const string &name,
                                            int default_value) const {
  string value = GetParameter(name);
  return value.empty() ? default_value
                       : utils::ParseUsing<int>(value, utils::ParseInt32);
}

bool GenericFeatureFunction::GetBoolParameter(const string &name,
                                              bool default_value) const {
  string value = GetParameter(name);
  if (value.empty()) return default_value;
  if (value == "true") return true;
  if (value == "false") return false;
  return false;
}

void GenericFeatureFunction::GetFeatureTypes(
    std::vector<FeatureType *> *types) const {
  if (feature_type_ != nullptr) types->push_back(feature_type_);
}

FeatureType *GenericFeatureFunction::GetFeatureType() const {
  // If a single feature type has been registered return it.
  if (feature_type_ != nullptr) return feature_type_;

  // Get feature types for function.
  std::vector<FeatureType *> types;
  GetFeatureTypes(&types);

  // If there is exactly one feature type return this, else return null.
  if (types.size() == 1) return types[0];
  return nullptr;
}

}  // namespace chrome_lang_id
