// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
// Author: dsites@google.com (Dick Sites)
//

#ifndef SCRIPT_SPAN_OFFSETMAP_H_
#define SCRIPT_SPAN_OFFSETMAP_H_

#include <string>                       // for string

#include "integral_types.h"             // for uint32

// ***************************** OffsetMap **************************
//
// An OffsetMap object is a container for a mapping from offsets in one text
// buffer A' to offsets in another text buffer A. It is most useful when A' is
// built from A via substitutions that occasionally do not preserve byte length.
//
// A series of operators are used to build the correspondence map, then
// calls can be made to map an offset in A' to an offset in A, or vice versa.
// The map starts with offset 0 in A corresponding to offset 0 in A'.
// The mapping is then built sequentially, adding on byte ranges that are
// identical in A and A', byte ranges that are inserted in A', and byte ranges
// that are deleted from A. All bytes beyond those specified when building the
// map are assumed to correspond, i.e. a Copy(infinity) is assumed at the
// end of the map.
//
// The internal data structure records positions at which bytes are added or
// deleted. Using the map is O(1) when increasing the A' or A offset
// monotonically, and O(n) when accessing random offsets, where n is the
// number of differences.
//

namespace chrome_lang_id {
namespace CLD2 {

class OffsetMap {
 public:
  // Constructor, destructor
  OffsetMap();
  ~OffsetMap();

  // Clear the map
  void Clear();

  // Add to  mapping from A to A', specifying how many next bytes correspond
  // in A and A'
  void Copy(int bytes);

  // Add to mapping from A to A', specifying how many next bytes are
  // inserted in A' while not advancing in A at all
  void Insert(int bytes);

  // Add to mapping from A to A', specifying how many next bytes are
  // deleted from A while not advancing in A' at all
  void Delete(int bytes);

  // [Finish building map,] Re-position to offset 0
  // This call is optional; MapForward and MapBack finish building the map
  // if necessary
  void Reset();

  // Map an offset in A' to the corresponding offset in A
  int MapBack(int aprimeoffset);

  // Map an offset in A to the corresponding offset in A'
  int MapForward(int aoffset);

  // h = ComposeOffsetMap(g, f), where f is a map from A to A', g is
  // from A' to A'' and h is from A to A''.
  //
  // Note that g->MoveForward(f->MoveForward(aoffset)) always equals
  // to h->MoveForward(aoffset), while
  // f->MoveBack(g->MoveBack(aprimeprimeoffset)) doesn't always equals
  // to h->MoveBack(aprimeprimeoffset). This happens when deletion in
  // f and insertion in g are at the same place.  For example,
  //
  // A    1   2   3   4
  //      ^   |  ^    ^
  //      |   | /     |  f
  //      v   vv      v
  // A'   1'  2'      3'
  //      ^   ^^      ^
  //      |   | \     |  g
  //      v   |  v    v
  // A''  1'' 2'' 3'' 4''
  //
  // results in:
  //
  // A    1   2   3   4
  //      ^   ^\  ^   ^
  //      |   | \ |   |  h
  //      v   |  vv   v
  // A''  1'' 2'' 3'' 4''
  //
  // 2'' is mapped 3 in the former figure, while 2'' is mapped to 2 in
  // the latter figure.
  static void ComposeOffsetMap(OffsetMap* g, OffsetMap* f, OffsetMap* h);

  // For testing only -- force a mapping
  void StuffIt(const std::string& diffs, int max_aoffset, int max_aprimeoffset);

 private:
  enum MapOp {PREFIX_OP, COPY_OP, INSERT_OP, DELETE_OP};

  void Flush();
  void FlushAll();
  void MaybeFlushAll();
  void Emit(MapOp op, int len);

  void SetLeft();
  void SetRight();

  // Back up over previous range, 1..5 bytes
  // Return subscript at the beginning of that. Pins at 0
  int Backup(int sub);

  // Parse next range, 1..5 bytes
  // Return subscript just off the end of that
  int ParseNext(int sub, MapOp* op, int* length);

  // Parse previous range, 1..5 bytes
  // Return current subscript
  int ParsePrevious(int sub, MapOp* op, int* length);

  bool MoveRight();     // Returns true if OK
  bool MoveLeft();      // Returns true if OK

  // Copies insert operations from source to dest. Returns true if no
  // other operations are found.
  static bool CopyInserts(OffsetMap* source, OffsetMap* dest);

  // Copies delete operations from source to dest. Returns true if no other
  // operations are found.
  static bool CopyDeletes(OffsetMap* source, OffsetMap* dest);

  std::string diffs_;
  MapOp pending_op_;
  uint32 pending_length_;

  // Offsets in the ranges below correspond to each other, with A' = A + diff
  int next_diff_sub_;
  int current_lo_aoffset_;
  int current_hi_aoffset_;
  int current_lo_aprimeoffset_;
  int current_hi_aprimeoffset_;
  int current_diff_;
  int max_aoffset_;
  int max_aprimeoffset_;
};

}  // namespace CLD2
}  // namespace chrome_lang_id

#endif  // SCRIPT_SPAN_OFFSETMAP_H_
