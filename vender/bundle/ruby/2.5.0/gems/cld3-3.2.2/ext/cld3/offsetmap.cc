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
//

#include "offsetmap.h"

#include <string.h>                     // for strcmp
#include <algorithm>                    // for min

using namespace std;

namespace chrome_lang_id {
namespace CLD2 {

// Constructor, destructor
OffsetMap::OffsetMap() {
  Clear();
}

OffsetMap::~OffsetMap() {
}

// Clear the map
// After:
//   next_diff_sub_ is 0
//   Windows are the a and a' ranges covered by diffs_[next_diff_sub_-1]
//   which is a fake range of width 0 mapping 0=>0
void OffsetMap::Clear() {
  diffs_.clear();
  pending_op_ = COPY_OP;
  pending_length_ = 0;
  next_diff_sub_ = 0;
  current_lo_aoffset_ = 0;
  current_hi_aoffset_ = 0;
  current_lo_aprimeoffset_ = 0;
  current_hi_aprimeoffset_ = 0;
  current_diff_ = 0;
  max_aoffset_ = 0;           // Largest seen so far
  max_aprimeoffset_ = 0;      // Largest seen so far
}

static inline char OpPart(const char c) {
  return (c >> 6) & 3;
}
static inline char LenPart(const char c) {
  return c & 0x3f;
}

// Reset to offset 0
void OffsetMap::Reset() {
  MaybeFlushAll();

  next_diff_sub_ = 0;
  current_lo_aoffset_ = 0;
  current_hi_aoffset_ = 0;
  current_lo_aprimeoffset_ = 0;
  current_hi_aprimeoffset_ = 0;
  current_diff_ = 0;
}

// Add to  mapping from A to A', specifying how many next bytes are
// identical in A and A'
void OffsetMap::Copy(int bytes) {
  if (bytes == 0) {return;}
  max_aoffset_ += bytes;           // Largest seen so far
  max_aprimeoffset_ += bytes;      // Largest seen so far
  if (pending_op_ == COPY_OP) {
    pending_length_ += bytes;
  } else {
    Flush();
    pending_op_ = COPY_OP;
    pending_length_ = bytes;
  }
}

// Add to mapping from A to A', specifying how many next bytes are
// inserted in A' while not advancing in A at all
void OffsetMap::Insert(int bytes){
  if (bytes == 0) {return;}
  max_aprimeoffset_ += bytes;      // Largest seen so far
  if (pending_op_ == INSERT_OP) {
    pending_length_ += bytes;
  } else if ((bytes == 1) &&
             (pending_op_ == DELETE_OP) && (pending_length_ == 1)) {
    // Special-case exactly delete(1) insert(1) +> copy(1);
    // all others backmap inserts to after deletes
    pending_op_ = COPY_OP;
  } else {
    Flush();
    pending_op_ = INSERT_OP;
    pending_length_ = bytes;
  }
}

// Add to mapping from A to A', specifying how many next bytes are
// deleted from A while not advancing in A' at all
void OffsetMap::Delete(int bytes){
  if (bytes == 0) {return;}
  max_aoffset_ += bytes;           // Largest seen so far
  if (pending_op_ == DELETE_OP) {
    pending_length_ += bytes;
    } else if ((bytes == 1) &&
               (pending_op_ == INSERT_OP) && (pending_length_ == 1)) {
      // Special-case exactly insert(1) delete(1) => copy(1);
      // all others backmap deletes to after insertss
      pending_op_ = COPY_OP;
  } else {
    Flush();
    pending_op_ = DELETE_OP;
    pending_length_ = bytes;
  }
}

void OffsetMap::Flush() {
  if (pending_length_ == 0) {
    return;
  }
  // We may be emitting a copy op just after a copy op because +1 -1 cancelled
  // inbetween. If the lengths don't need a prefix byte, combine them
  if ((pending_op_ == COPY_OP) && !diffs_.empty()) {
    char c = diffs_[diffs_.size() - 1];
    MapOp prior_op = static_cast<MapOp>(OpPart(c));
    int prior_len = LenPart(c);
    if ((prior_op == COPY_OP) && ((prior_len + pending_length_) <= 0x3f)) {
      diffs_[diffs_.size() - 1] += pending_length_;
      pending_length_ = 0;
      return;
    }
  }
  if (pending_length_ > 0x3f) {
    bool non_zero_emitted = false;
    for (int shift = 30; shift > 0; shift -= 6) {
      int prefix = (pending_length_ >> shift) & 0x3f;
      if ((prefix > 0) || non_zero_emitted) {
        Emit(PREFIX_OP, prefix);
        non_zero_emitted = true;
      }
    }
  }
  Emit(pending_op_, pending_length_ & 0x3f);
  pending_length_ = 0;
}


// Add one more entry to copy one byte off the end, then flush
void OffsetMap::FlushAll() {
  Copy(1);
  Flush();
}

// Flush all if necessary
void OffsetMap::MaybeFlushAll() {
  if ((0 < pending_length_) || diffs_.empty()) {
    FlushAll();
  }
}

// Len may be 0, for example as the low piece of length=64
void OffsetMap::Emit(MapOp op, int len) {
  char c = (static_cast<char>(op) << 6) | (len & 0x3f);
  diffs_.push_back(c);
}

//----------------------------------------------------------------------------//
// The guts of the 2013 design                                                //
// If there are three ranges a b c in  diffs_, we can be in one of five       //
// states: LEFT of a, in ranges a b c, or RIGHT of c                          //
// In each state, there are windows A[Alo..Ahi), A'[A'lo..A'hi) and diffs_    //
// position next_diff_sub_                                                    //
// There also are mapping constants max_aoffset_ and max_aprimeoffset_        //
// If LEFT, Alo=Ahi=0, A'lo=A'hi=0 and next_diff_sub_=0                       //
// If RIGHT, Alo=Ahi=max_aoffset_, A'lo=A'hi=max_aprimeoffset_ and            //
//   next_diff_sub_=diffs_.size()                                             //
// Otherwise, at least one of A[) and A'[) is non-empty and the first bytes   //
//   correspond to each other. If range i is active, next_diff_sub_ is at     //
//   the first byte of range i+1. Because of the length-prefix operator,      //
//   an individual range item in diffs_ may be multiple bytes                 //
// In all cases aprimeoffset = aoffset + current_diff_                        //
//   i.e. current_diff_ = aprimeoffset - aoffset                              //
//                                                                            //
// In the degenerate case of diffs_.empty(), there are only two states        //
//   LEFT and RIGHT and the mapping is the identity mapping.                  //
// The initial state is LEFT.                                                 //
// It is an error to move left into LEFT or right into RIGHT, but the code    //
//   below is robust in these cases.                                          //
//----------------------------------------------------------------------------//

void OffsetMap::SetLeft() {
   current_lo_aoffset_ = 0;
   current_hi_aoffset_ = 0;
   current_lo_aprimeoffset_ = 0;
   current_hi_aprimeoffset_ = 0;
   current_diff_ = 0;
   next_diff_sub_ = 0;
}

void OffsetMap::SetRight() {
   current_lo_aoffset_ = max_aoffset_;
   current_hi_aoffset_ = max_aoffset_;
   current_lo_aprimeoffset_ = max_aprimeoffset_;
   current_hi_aprimeoffset_ = max_aprimeoffset_;
   current_diff_ = max_aprimeoffset_ - max_aoffset_;
   next_diff_sub_ = 0;
}

// Back up over previous range, 1..5 bytes
// Return subscript at the beginning of that. Pins at 0
int OffsetMap::Backup(int sub) {
  if (sub <= 0) {return 0;}
  --sub;
  while ((0 < sub) &&
         (static_cast<MapOp>(OpPart(diffs_[sub - 1]) == PREFIX_OP))) {
    --sub;
  }
  return sub;
}

// Parse next range, 1..5 bytes
// Return subscript just off the end of that
int OffsetMap::ParseNext(int sub, MapOp* op, int* length) {
   *op = PREFIX_OP;
   *length = 0;
   char c;
   while ((sub < static_cast<int>(diffs_.size())) && (*op == PREFIX_OP)) {
     c = diffs_[sub++];
     *op = static_cast<MapOp>(OpPart(c));
     int len = LenPart(c);
     *length = (*length << 6) + len;
   }
   // If mal-formed or in RIGHT, this will return with op = PREFIX_OP
   // Mal-formed can include a trailing prefix byte with no following op
   return sub;
}

// Parse previous range, 1..5 bytes
// Return current subscript
int OffsetMap::ParsePrevious(int sub, MapOp* op, int* length) {
  sub = Backup(sub);
  return ParseNext(sub, op, length);
}

// Move active window one range to the right
// Return true if move was OK
bool OffsetMap::MoveRight() {
  // If at last range or RIGHT, set to RIGHT, return error
  if (next_diff_sub_ >= static_cast<int>(diffs_.size())) {
    SetRight();
    return false;
  }
  // Actually OK to move right
  MapOp op;
  int length;
  bool retval = true;
  // If mal-formed or in RIGHT, this will return with op = PREFIX_OP
  next_diff_sub_ = ParseNext(next_diff_sub_, &op, &length);

  current_lo_aoffset_ = current_hi_aoffset_;
  current_lo_aprimeoffset_ = current_hi_aprimeoffset_;
  if (op == COPY_OP) {
    current_hi_aoffset_ = current_lo_aoffset_ + length;
    current_hi_aprimeoffset_ = current_lo_aprimeoffset_ + length;
  } else if (op == INSERT_OP) {
    current_hi_aoffset_ = current_lo_aoffset_ + 0;
    current_hi_aprimeoffset_ = current_lo_aprimeoffset_ + length;
  } else if (op == DELETE_OP) {
    current_hi_aoffset_ = current_lo_aoffset_ + length;
    current_hi_aprimeoffset_ = current_lo_aprimeoffset_ + 0;
  } else {
    SetRight();
    retval = false;
  }
  current_diff_ = current_lo_aprimeoffset_ - current_lo_aoffset_;
  return retval;
}

// Move active window one range to the left
// Return true if move was OK
bool OffsetMap::MoveLeft() {
  // If at first range or LEFT, set to LEFT, return error
  if (next_diff_sub_ <= 0) {
    SetLeft();
    return false;
  }
  // Back up over current active window
  next_diff_sub_ = Backup(next_diff_sub_);
  if (next_diff_sub_ <= 0) {
    SetLeft();
    return false;
  }
  // Actually OK to move left
  MapOp op;
  int length;

  // TODO(abakalov): 'retval' below is set but not used, which is suspicious.
  // Did the authors mean to return this variable, analogously to MoveRight()?
  // bool retval = true;
  // If mal-formed or in LEFT, this will return with op = PREFIX_OP
  next_diff_sub_ = ParsePrevious(next_diff_sub_, &op, &length);

  current_hi_aoffset_ = current_lo_aoffset_;
  current_hi_aprimeoffset_ = current_lo_aprimeoffset_;
  if (op == COPY_OP) {
    current_lo_aoffset_ = current_hi_aoffset_ - length;
    current_lo_aprimeoffset_ = current_hi_aprimeoffset_ - length;
  } else if (op == INSERT_OP) {
    current_lo_aoffset_ = current_hi_aoffset_ - 0;
    current_lo_aprimeoffset_ = current_hi_aprimeoffset_ - length;
  } else if (op == DELETE_OP) {
    current_lo_aoffset_ = current_hi_aoffset_ - length;
    current_lo_aprimeoffset_ = current_hi_aprimeoffset_ - 0;
  } else {
    SetLeft();
    // retval = false;
  }
  current_diff_ = current_lo_aprimeoffset_ - current_lo_aoffset_;
  return true;
}

// Map an offset in A' to the corresponding offset in A
int OffsetMap::MapBack(int aprimeoffset){
  MaybeFlushAll();
  if (aprimeoffset < 0) {return 0;}
  if (max_aprimeoffset_ <= aprimeoffset) {
     return (aprimeoffset - max_aprimeoffset_) + max_aoffset_;
  }

  // If current_lo_aprimeoffset_ <= aprimeoffset < current_hi_aprimeoffset_,
  // use current mapping, else move window left/right
  bool ok = true;
  while (ok && (aprimeoffset < current_lo_aprimeoffset_)) {
    ok = MoveLeft();
  }
  while (ok && (current_hi_aprimeoffset_ <= aprimeoffset)) {
    ok = MoveRight();
  }
  // So now current_lo_aprimeoffset_ <= aprimeoffset < current_hi_aprimeoffset_

  int aoffset = aprimeoffset - current_diff_;
  if (aoffset >= current_hi_aoffset_) {
    // A' is in an insert region, all bytes of which backmap to A=hi_aoffset_
    aoffset = current_hi_aoffset_;
  }
  return aoffset;
}

// Map an offset in A to the corresponding offset in A'
int OffsetMap::MapForward(int aoffset){
  MaybeFlushAll();
  if (aoffset < 0) {return 0;}
  if (max_aoffset_ <= aoffset) {
     return (aoffset - max_aoffset_) + max_aprimeoffset_;
  }

  // If current_lo_aoffset_ <= aoffset < current_hi_aoffset_,
  // use current mapping, else move window left/right
  bool ok = true;
  while (ok && (aoffset < current_lo_aoffset_)) {
    ok = MoveLeft();
  }
  while (ok && (current_hi_aoffset_ <= aoffset)) {
    ok = MoveRight();
  }

  int aprimeoffset = aoffset + current_diff_;
  if (aprimeoffset >= current_hi_aprimeoffset_) {
    // A is in a delete region, all bytes of which map to A'=hi_aprimeoffset_
    aprimeoffset = current_hi_aprimeoffset_;
  }
  return aprimeoffset;
}


// static
bool OffsetMap::CopyInserts(OffsetMap* source, OffsetMap* dest) {
  bool ok = true;
  while (ok && (source->next_diff_sub_ !=
                static_cast<int>(source->diffs_.size()))) {
    ok = source->MoveRight();
    if (source->current_lo_aoffset_ != source->current_hi_aoffset_) {
      return false;
    }
    dest->Insert(
        source->current_hi_aprimeoffset_ - source->current_lo_aprimeoffset_);
  }
  return true;
}

// static
bool OffsetMap::CopyDeletes(OffsetMap* source, OffsetMap* dest) {
  bool ok = true;
  while (ok && (source->next_diff_sub_ !=
                static_cast<int>(source->diffs_.size()))) {
    ok = source->MoveRight();
    if (source->current_lo_aprimeoffset_ != source->current_hi_aprimeoffset_) {
      return false;
    }
    dest->Delete(source->current_hi_aoffset_ - source->current_lo_aoffset_);
  }
  return true;
}

// static
void OffsetMap::ComposeOffsetMap(
    OffsetMap* g, OffsetMap* f, OffsetMap* h) {
  h->Clear();
  f->Reset();
  g->Reset();

  int lo = 0;
  for (;;) {
     // Consume delete operations in f. This moves A without moving
     // A' and A''.
     if (lo >= g->current_hi_aoffset_ && CopyInserts(g, h)) {
       if (lo >= f->current_hi_aprimeoffset_ && CopyDeletes(f, h)) {
          // fprintf(stderr,
          //         "ComposeOffsetMap ERROR, f is longer than g.<br>\n");
       }

       // FlushAll(), called by Reset(), MapForward() or MapBack(), has
       // added an extra COPY_OP to f and g, so this function has
       // composed an extra COPY_OP in h from those. To avoid
       // FlushAll() adds one more extra COPY_OP to h later, dispatch
       // Flush() right now.
       h->Flush();
       return;
     }

     // Consume insert operations in g. This moves A'' without moving A
     // and A'.
     if (lo >= f->current_hi_aprimeoffset_) {
       if (!CopyDeletes(f, h)) {
          // fprintf(stderr,
          //         "ComposeOffsetMap ERROR, g is longer than f.<br>\n");
       }
     }

     // Compose one operation which moves A' from lo to hi.
     int hi = min(f->current_hi_aprimeoffset_, g->current_hi_aoffset_);
     if (f->current_lo_aoffset_ != f->current_hi_aoffset_ &&
         g->current_lo_aprimeoffset_ != g->current_hi_aprimeoffset_) {
       h->Copy(hi - lo);
     } else if (f->current_lo_aoffset_ != f->current_hi_aoffset_) {
       h->Delete(hi - lo);
     } else if (g->current_lo_aprimeoffset_ != g->current_hi_aprimeoffset_) {
       h->Insert(hi - lo);
     }

     lo = hi;
  }
}

// For testing only -- force a mapping
void OffsetMap::StuffIt(const std::string& diffs,
                        int max_aoffset, int max_aprimeoffset) {
  Clear();
  diffs_ = diffs;
  max_aoffset_ = max_aoffset;
  max_aprimeoffset_ = max_aprimeoffset;
}


}  // namespace CLD2
}  // namespace chrome_lang_id
