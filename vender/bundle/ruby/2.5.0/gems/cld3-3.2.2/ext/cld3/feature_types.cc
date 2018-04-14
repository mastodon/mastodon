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

#include "feature_types.h"

#include <algorithm>
#include <map>
#include <string>
#include <utility>

#include "base.h"

namespace chrome_lang_id {

FeatureType::FeatureType(const string &name)
    : name_(name),
      base_(0),
      is_continuous_(name.find("continuous") != string::npos) {}

FeatureType::~FeatureType() {}

template <class Resource>
ResourceBasedFeatureType<Resource>::ResourceBasedFeatureType(
    const string &name, const Resource *resource,
    const std::map<FeatureValue, string> &values)
    : FeatureType(name), resource_(resource), values_(values) {
  max_value_ = resource->NumValues() - 1;
  for (const auto &pair : values) {
    CLD3_DCHECK(pair.first >= resource->NumValues());
    max_value_ = pair.first > max_value_ ? pair.first : max_value_;
  }
}

template <class Resource>
ResourceBasedFeatureType<Resource>::ResourceBasedFeatureType(
    const string &name, const Resource *resource)
    : ResourceBasedFeatureType(name, resource, {}) {}

EnumFeatureType::EnumFeatureType(
    const string &name, const std::map<FeatureValue, string> &value_names)
    : FeatureType(name), value_names_(value_names) {
  for (const auto &pair : value_names) {
    CLD3_DCHECK(pair.first >= 0);
    domain_size_ = std::max(domain_size_, pair.first + 1);
  }
}

EnumFeatureType::~EnumFeatureType() {}

string EnumFeatureType::GetFeatureValueName(FeatureValue value) const {
  auto it = value_names_.find(value);
  if (it == value_names_.end()) {
    return "<INVALID>";
  }
  return it->second;
}

FeatureValue EnumFeatureType::GetDomainSize() const { return domain_size_; }

}  // namespace chrome_lang_id
