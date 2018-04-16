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

// Notes on thread-safety: All of the classes here are thread-compatible.  More
// specifically, the registry machinery is thread-safe, as long as each thread
// performs feature extraction on a different Sentence object.

#ifndef WORKSPACE_H_
#define WORKSPACE_H_

#include <stddef.h>
#include <string>
#include <typeindex>
#include <unordered_map>
#include <utility>
#include <vector>

#include "base.h"

namespace chrome_lang_id {

// A base class for shared workspaces. Derived classes implement a static member
// function TypeName() which returns a human readable string name for the class.
class Workspace {
 public:
  // Polymorphic destructor.
  virtual ~Workspace() {}

 protected:
  // Create an empty workspace.
  Workspace() {}

 private:
  CLD3_DISALLOW_COPY_AND_ASSIGN(Workspace);
};

// A registry that keeps track of workspaces.
class WorkspaceRegistry {
 public:
  // Create an empty registry.
  WorkspaceRegistry();
  ~WorkspaceRegistry();

  const std::unordered_map<std::type_index, std::vector<std::string>>
      &WorkspaceNames() const {
    return workspace_names_;
  }

  // Returns a string describing the registered workspaces.
  string DebugString() const;

 private:
  // Workspace type names, indexed as workspace_types_[typeid].
  std::unordered_map<std::type_index, string> workspace_types_;

  // Workspace names, indexed as workspace_names_[typeid][workspace].
  std::unordered_map<std::type_index, std::vector<string>> workspace_names_;

  CLD3_DISALLOW_COPY_AND_ASSIGN(WorkspaceRegistry);
};

// A typed collected of workspaces. The workspaces are indexed according to an
// external WorkspaceRegistry. If the WorkspaceSet is const, the contents are
// also immutable.
class WorkspaceSet {
 public:
  WorkspaceSet();
  ~WorkspaceSet();

  void Reset(const WorkspaceRegistry &registry) {
    // Deallocate current workspaces.
    for (auto &it : workspaces_) {
      for (size_t index = 0; index < it.second.size(); ++index) {
        delete it.second[index];
      }
    }
    workspaces_.clear();

    // Allocate space for new workspaces.
    for (auto &it : registry.WorkspaceNames()) {
      workspaces_[it.first].resize(it.second.size());
    }
  }

 private:
  // The set of workspaces, indexed as workspaces_[typeid][index].
  std::unordered_map<std::type_index, std::vector<Workspace *>> workspaces_;
};

// A workspace that wraps around a single int.
class SingletonIntWorkspace : public Workspace {
 public:
  // Default-initializes the int value.
  SingletonIntWorkspace() {}

  // Initializes the int with the given value.
  explicit SingletonIntWorkspace(int value) : value_(value) {}

  // Returns the name of this type of workspace.
  static string TypeName() { return "SingletonInt"; }

  // Returns the int value.
  int get() const { return value_; }

  // Sets the int value.
  void set(int value) { value_ = value; }

 private:
  // The enclosed int.
  int value_ = 0;
};

// A workspace that wraps around a vector of int.
class VectorIntWorkspace : public Workspace {
 public:
  // Creates a vector of the given size.
  explicit VectorIntWorkspace(int size);

  // Creates a vector initialized with the given array.
  explicit VectorIntWorkspace(const std::vector<int> &elements);

  // Creates a vector of the given size, with each element initialized to the
  // given value.
  VectorIntWorkspace(int size, int value);

  ~VectorIntWorkspace() override;

  // Returns the name of this type of workspace.
  static string TypeName();

  // Returns the i'th element.
  int element(int i) const { return elements_[i]; }

  // Sets the i'th element.
  void set_element(int i, int value) { elements_[i] = value; }

 private:
  // The enclosed vector.
  std::vector<int> elements_;
};

// A workspace that wraps around a vector of vector of int.
class VectorVectorIntWorkspace : public Workspace {
 public:
  // Creates a vector of empty vectors of the given size.
  explicit VectorVectorIntWorkspace(int size);
  ~VectorVectorIntWorkspace() override;

  // Returns the name of this type of workspace.
  static string TypeName();

  // Returns the i'th vector of elements.
  const std::vector<int> &elements(int i) const { return elements_[i]; }

  // Mutable access to the i'th vector of elements.
  std::vector<int> *mutable_elements(int i) { return &(elements_[i]); }

 private:
  // The enclosed vector of vector of elements.
  std::vector<std::vector<int>> elements_;
};

}  // namespace chrome_lang_id

#endif  // WORKSPACE_H_
