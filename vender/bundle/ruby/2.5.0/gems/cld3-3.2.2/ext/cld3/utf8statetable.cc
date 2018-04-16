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
// State Table follower for scanning UTF-8 strings without converting to
// 32- or 16-bit Unicode values.
//

#ifdef COMPILER_MSVC
// MSVC warns: warning C4309: 'initializing' : truncation of constant value
// But the value is in fact not truncated.  0xFF still comes out 0xFF at
// runtime.
#pragma warning ( disable : 4309 )
#endif

#include "utf8statetable.h"

#include <stdint.h>                     // for uintptr_t
#include <string.h>                     // for NULL, memcpy, memmove

#include "integral_types.h" // for uint8, uint32, int8
#include "offsetmap.h"
#include "port.h"
#include "stringpiece.h"

namespace chrome_lang_id {
namespace CLD2 {

static const int kReplaceAndResumeFlag = 0x80; // Bit in del byte to distinguish
                                               // optional next-state field
                                               // after replacement text
static const int kHtmlPlaintextFlag = 0x80;    // Bit in add byte to distinguish
                                               // HTML replacement vs. plaintext

/**
 * This code implements a little interpreter for UTF8 state
 * tables. There are three kinds of quite-similar state tables,
 * property, scanning, and replacement. Each state in one of
 * these tables consists of an array of 256 or 64 one-byte
 * entries. The state is subscripted by an incoming source byte,
 * and the entry either specifies the next state or specifies an
 * action. Space-optimized tables have full 256-entry states for
 * the first byte of a UTF-8 character, but only 64-entry states
 * for continuation bytes. Space-optimized tables may only be
 * used with source input that has been checked to be
 * structurally- (or stronger interchange-) valid.
 *
 * A property state table has an unsigned one-byte property for
 * each possible UTF-8 character. One-byte character properties
 * are in the state[0] array, while for other lengths the
 * state[0] array gives the next state, which contains the
 * property value for two-byte characters or yet another state
 * for longer ones. The code simply loads the right number of
 * next-state values, then returns the final byte as property
 * value. There are no actions specified in property tables.
 * States are typically shared for multi-byte UTF-8 characters
 * that all have the same property value.
 *
 * A scanning state table has entries that are either a
 * next-state specifier for bytes that are accepted by the
 * scanner, or an exit action for the last byte of each
 * character that is rejected by the scanner.
 *
 * Scanning long strings involves a tight loop that picks up one
 * byte at a time and follows next-state value back to state[0]
 * for each accepted UTF-8 character. Scanning stops at the end
 * of the string or at the first character encountered that has
 * an exit action such as "reject". Timing information is given
 * below.
 *
 * Since so much of Google's text is 7-bit-ASCII values
 * (approximately 94% of the bytes of web documents), the
 * scanning interpreter has two speed optimizations. One checks
 * 8 bytes at a time to see if they are all in the range lo..hi,
 * as specified in constants in the overall statetable object.
 * The check involves ORing together four 4-byte values that
 * overflow into the high bit of some byte when a byte is out of
 * range. For seven-bit-ASCII, lo is 0x20 and hi is 0x7E. This
 * loop is about 8x faster than the one-byte-at-a-time loop.
 *
 * If checking for exit bytes in the 0x00-0x1F and 7F range is
 * unneeded, an even faster loop just looks at the high bits of
 * 8 bytes at once, and is about 1.33x faster than the lo..hi
 * loop.
 *
 * Exit from the scanning routines backs up to the first byte of
 * the rejected character, so the text spanned is always a
 * complete number of UTF-8 characters. The normal scanning exit
 * is at the first rejected character, or at the end of the
 * input text. Scanning also exits on any detected ill-formed
 * character or at a special do-again action built into some
 * exit-optimized tables. The do-again action gets back to the
 * top of the scanning loop to retry eight-byte ASCII scans. It
 * is typically put into state tables after four seven-bit-ASCII
 * characters in a row are seen, to allow restarting the fast
 * scan after some slower processing of multi-byte characters.
 *
 * A replacement state table is similar to a scanning state
 * table but has more extensive actions. The default
 * byte-at-a-time loop copies one byte from source to
 * destination and goes to the next state. The replacement
 * actions overwrite 1-3 bytes of the destination with different
 * bytes, possibly shortening the output by 1 or 2 bytes. The
 * replacement bytes come from within the state table, from
 * dummy states inserted just after any state that contains a
 * replacement action. This gives a quick address calculation for
 * the replacement byte(s) and gives some cache locality.
 *
 * Additional replacement actions use one or two bytes from
 * within dummy states to index a side table of more-extensive
 * replacements. The side table specifies a length of 0..15
 * destination bytes to overwrite and a length of 0..127 bytes
 * to overwrite them with, plus the actual replacement bytes.
 *
 * This side table uses one extra bit to specify a pair of
 * replacements, the first to be used in an HTML context and the
 * second to be used in a plaintext context. This allows
 * replacements that are spelled with "&lt;" in the former
 * context and "<" in the latter.
 *
 * The side table also uses an extra bit to specify a non-zero
 * next state after a replacement. This allows a combination
 * replacement and state change, used to implement a limited
 * version of the Boyer-Moore algorithm for multi-character
 * replacement without backtracking. This is useful when there
 * are overlapping replacements, such as ch => x and also c =>
 * y, the latter to be used only if the character after c is not
 * h. in this case, the state[0] table's entry for c would
 * change c to y and also have a next-state of say n, and the
 * state[n] entry for h would specify a replacement of the two
 * bytes yh by x. No backtracking is needed.
 *
 * A replacement table may also include the exit actions of a
 * scanning state table, so some character sequences can
 * terminate early.
 *
 * During replacement, an optional data structure called an
 * offset map can be updated to reflect each change in length
 * between source and destination. This offset map can later be
 * used to map destination-string offsets to corresponding
 * source-string offsets or vice versa.
 *
 * The routines below also have variants in which state-table
 * entries are all two bytes instead of one byte. This allows
 * tables with more than 240 total states, but takes up twice as
 * much space per state.
 *
**/

// Return true if current Tbl pointer is within state0 range
// Note that unsigned compare checks both ends of range simultaneously
static inline bool InStateZero(const UTF8ScanObj* st, const uint8* Tbl) {
  const uint8* Tbl0 = &st->state_table[st->state0];
  return (static_cast<uint32>(Tbl - Tbl0) < st->state0_size);
}

static inline bool InStateZero_2(const UTF8ReplaceObj_2* st,
                                 const unsigned short int* Tbl) {
  const unsigned short int* Tbl0 =  &st->state_table[st->state0];
  // Word difference, not byte difference
  return (static_cast<uint32>(Tbl - Tbl0) < st->state0_size);
}

// Look up property of one UTF-8 character and advance over it
// Return 0 if input length is zero
// Return 0 and advance one byte if input is ill-formed
uint8 UTF8GenericProperty(const UTF8PropObj* st,
                          const uint8** src,
                          int* srclen) {
  if (*srclen <= 0) {
    return 0;
  }

  const uint8* lsrc = *src;
  const uint8* Tbl_0 = &st->state_table[st->state0];
  const uint8* Tbl = Tbl_0;
  int e;
  int eshift = st->entry_shift;

  // Short series of tests faster than switch, optimizes 7-bit ASCII
  unsigned char c = lsrc[0];
  if (static_cast<signed char>(c) >= 0) {           // one byte
    e = Tbl[c];
    *src += 1;
    *srclen -= 1;
  } else if (((c & 0xe0) == 0xc0) && (*srclen >= 2)) {     // two bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
    *src += 2;
    *srclen -= 2;
  } else if (((c & 0xf0) == 0xe0) && (*srclen >= 3)) {     // three bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[2]];
    *src += 3;
    *srclen -= 3;
  }else if (((c & 0xf8) == 0xf0) && (*srclen >= 4)) {     // four bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[2]];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[3]];
    *src += 4;
    *srclen -= 4;
  } else {                                                // Ill-formed
    e = 0;
    *src += 1;
    *srclen -= 1;
  }
  return e;
}

bool UTF8HasGenericProperty(const UTF8PropObj& st, const char* src) {
  const uint8* lsrc = reinterpret_cast<const uint8*>(src);
  const uint8* Tbl_0 = &st.state_table[st.state0];
  const uint8* Tbl = Tbl_0;
  int e;
  int eshift = st.entry_shift;

  // Short series of tests faster than switch, optimizes 7-bit ASCII
  unsigned char c = lsrc[0];
  if (static_cast<signed char>(c) >= 0) {           // one byte
    e = Tbl[c];
  } else if ((c & 0xe0) == 0xc0) {     // two bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
  } else if ((c & 0xf0) == 0xe0) {     // three bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[2]];
  } else {                             // four bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[2]];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[3]];
  }

  // Comparing against 0 to avoid a warning due to implicit conversion.
  return (e != 0);
}


// BigOneByte versions are needed for tables > 240 states, but most
// won't need the TwoByte versions.
// Internally, to next-to-last offset is multiplied by 16 and the last
// offset is relative instead of absolute.
// Look up property of one UTF-8 character and advance over it
// Return 0 if input length is zero
// Return 0 and advance one byte if input is ill-formed
uint8 UTF8GenericPropertyBigOneByte(const UTF8PropObj* st,
                          const uint8** src,
                          int* srclen) {
  if (*srclen <= 0) {
    return 0;
  }

  const uint8* lsrc = *src;
  const uint8* Tbl_0 = &st->state_table[st->state0];
  const uint8* Tbl = Tbl_0;
  int e;
  int eshift = st->entry_shift;

  // Short series of tests faster than switch, optimizes 7-bit ASCII
  unsigned char c = lsrc[0];
  if (static_cast<signed char>(c) >= 0) {           // one byte
    e = Tbl[c];
    *src += 1;
    *srclen -= 1;
  } else if (((c & 0xe0) == 0xc0) && (*srclen >= 2)) {     // two bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
    *src += 2;
    *srclen -= 2;
  } else if (((c & 0xf0) == 0xe0) && (*srclen >= 3)) {     // three bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << (eshift + 4)];  // 16x the range
    e = (reinterpret_cast<const int8*>(Tbl))[lsrc[1]];
    Tbl = &Tbl[e << eshift];          // Relative +/-
    e = Tbl[lsrc[2]];
    *src += 3;
    *srclen -= 3;
  }else if (((c & 0xf8) == 0xf0) && (*srclen >= 4)) {     // four bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
    Tbl = &Tbl_0[e << (eshift + 4)];  // 16x the range
    e = (reinterpret_cast<const int8*>(Tbl))[lsrc[2]];
    Tbl = &Tbl[e << eshift];          // Relative +/-
    e = Tbl[lsrc[3]];
    *src += 4;
    *srclen -= 4;
  } else {                                                // Ill-formed
    e = 0;
    *src += 1;
    *srclen -= 1;
  }
  return e;
}

// BigOneByte versions are needed for tables > 240 states, but most
// won't need the TwoByte versions.
bool UTF8HasGenericPropertyBigOneByte(const UTF8PropObj& st, const char* src) {
  const uint8* lsrc = reinterpret_cast<const uint8*>(src);
  const uint8* Tbl_0 = &st.state_table[st.state0];
  const uint8* Tbl = Tbl_0;
  int e;
  int eshift = st.entry_shift;

  // Short series of tests faster than switch, optimizes 7-bit ASCII
  unsigned char c = lsrc[0];
  if (static_cast<signed char>(c) >= 0) {           // one byte
    e = Tbl[c];
  } else if ((c & 0xe0) == 0xc0) {    // two bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
  } else if ((c & 0xf0) == 0xe0) {    // three bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << (eshift + 4)];  // 16x the range
    e = (reinterpret_cast<const int8*>(Tbl))[lsrc[1]];
    Tbl = &Tbl[e << eshift];          // Relative +/-
    e = Tbl[lsrc[2]];
  } else {                            // four bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
    Tbl = &Tbl_0[e << (eshift + 4)];  // 16x the range
    e = (reinterpret_cast<const int8*>(Tbl))[lsrc[2]];
    Tbl = &Tbl[e << eshift];          // Relative +/-
    e = Tbl[lsrc[3]];
  }

  // Comparing against 0 to avoid implicit conversion and a warning.
  return (e != 0);
}


// TwoByte versions are needed for tables > 240 states
// Look up property of one UTF-8 character and advance over it
// Return 0 if input length is zero
// Return 0 and advance one byte if input is ill-formed
uint8 UTF8GenericPropertyTwoByte(const UTF8PropObj_2* st,
                          const uint8** src,
                          int* srclen) {
  if (*srclen <= 0) {
    return 0;
  }

  const uint8* lsrc = *src;
  const unsigned short* Tbl_0 = &st->state_table[st->state0];
  const unsigned short* Tbl = Tbl_0;
  int e;
  int eshift = st->entry_shift;

  // Short series of tests faster than switch, optimizes 7-bit ASCII
  unsigned char c = lsrc[0];
  if (static_cast<signed char>(c) >= 0) {           // one byte
    e = Tbl[c];
    *src += 1;
    *srclen -= 1;
  } else if (((c & 0xe0) == 0xc0) && (*srclen >= 2)) {     // two bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
    *src += 2;
    *srclen -= 2;
  } else if (((c & 0xf0) == 0xe0) && (*srclen >= 3)) {     // three bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[2]];
    *src += 3;
    *srclen -= 3;
  }else if (((c & 0xf8) == 0xf0) && (*srclen >= 4)) {     // four bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[2]];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[3]];
    *src += 4;
    *srclen -= 4;
  } else {                                                // Ill-formed
    e = 0;
    *src += 1;
    *srclen -= 1;
  }
  return e;
}

// TwoByte versions are needed for tables > 240 states
bool UTF8HasGenericPropertyTwoByte(const UTF8PropObj_2& st, const char* src) {
  const uint8* lsrc = reinterpret_cast<const uint8*>(src);
  const unsigned short* Tbl_0 = &st.state_table[st.state0];
  const unsigned short* Tbl = Tbl_0;
  int e;
  int eshift = st.entry_shift;

  // Short series of tests faster than switch, optimizes 7-bit ASCII
  unsigned char c = lsrc[0];
  if (static_cast<signed char>(c) >= 0) {           // one byte
    e = Tbl[c];
  } else if ((c & 0xe0) == 0xc0) {     // two bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
  } else if ((c & 0xf0) == 0xe0) {     // three bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[2]];
  } else {                             // four bytes
    e = Tbl[c];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[1]];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[2]];
    Tbl = &Tbl_0[e << eshift];
    e = Tbl[lsrc[3]];
  }

  // Comparing against 0 to avoid implicit conversion and a warning.
  return (e != 0);
}


// Approximate speeds on 2.8 GHz Pentium 4:
//   GenericScan 1-byte loop           300 MB/sec *
//   GenericScan 4-byte loop          1200 MB/sec
//   GenericScan 8-byte loop          2400 MB/sec *
//   GenericScanFastAscii 4-byte loop 3000 MB/sec
//   GenericScanFastAscii 8-byte loop 3200 MB/sec *
//
// * Implemented below. FastAscii loop is memory-bandwidth constrained.

// Scan a UTF-8 stringpiece based on state table.
// Always scan complete UTF-8 characters
// Set number of bytes scanned. Return reason for exiting
int UTF8GenericScan(const UTF8ScanObj* st,
                    const StringPiece& str,
                    int* bytes_consumed) {
  int eshift = st->entry_shift;       // 6 (space optimized) or 8
  // int nEntries = (1 << eshift);       // 64 or 256 entries per state

  const uint8* isrc =
    reinterpret_cast<const uint8*>(str.data());
  const uint8* src = isrc;
  const int len = str.length();
  const uint8* srclimit = isrc + len;
  const uint8* srclimit8 = srclimit - 7;
  *bytes_consumed = 0;
  if (len == 0) return kExitOK;

  const uint8* Tbl_0 = &st->state_table[st->state0];

DoAgain:
  // Do state-table scan
  int e = 0;
  uint8 c;

  // Do fast for groups of 8 identity bytes.
  // This covers a lot of 7-bit ASCII ~8x faster than the 1-byte loop,
  // including slowing slightly on cr/lf/ht
  //----------------------------
  const uint8* Tbl2 = &st->fast_state[0];
  uint32 losub = st->losub;
  uint32 hiadd = st->hiadd;
  while (src < srclimit8) {
    const uint32* src32 = reinterpret_cast<const uint32 *>(src);
    uint32 s0123 = UNALIGNED_LOAD32(&src32[0]);
    uint32 s4567 = UNALIGNED_LOAD32(&src32[1]);
    src += 8;
    // This is a fast range check for all bytes in [lowsub..0x80-hiadd)
    uint32 temp = (s0123 - losub) | (s0123 + hiadd) |
                  (s4567 - losub) | (s4567 + hiadd);
    if ((temp & 0x80808080) != 0) {
      // We typically end up here on cr/lf/ht; src was incremented
      int e0123 = (Tbl2[src[-8]] | Tbl2[src[-7]]) |
                  (Tbl2[src[-6]] | Tbl2[src[-5]]);
      if (e0123 != 0) {src -= 8; break;}    // Exit on Non-interchange
      e0123 = (Tbl2[src[-4]] | Tbl2[src[-3]]) |
              (Tbl2[src[-2]] | Tbl2[src[-1]]);
      if (e0123 != 0) {src -= 4; break;}    // Exit on Non-interchange
      // Else OK, go around again
    }
  }
  //----------------------------

  // Byte-at-a-time scan
  //----------------------------
  const uint8* Tbl = Tbl_0;
  while (src < srclimit) {
    c = *src;
    e = Tbl[c];
    src++;
    if (e >= kExitIllegalStructure) {break;}
    Tbl = &Tbl_0[e << eshift];
  }
  //----------------------------


  // Exit possibilities:
  //  Some exit code, !state0, back up over last char
  //  Some exit code, state0, back up one byte exactly
  //  source consumed, !state0, back up over partial char
  //  source consumed, state0, exit OK
  // For illegal byte in state0, avoid backup up over PREVIOUS char
  // For truncated last char, back up to beginning of it

  if (e >= kExitIllegalStructure) {
    // Back up over exactly one byte of rejected/illegal UTF-8 character
    src--;
    // Back up more if needed
    if (!InStateZero(st, Tbl)) {
      do {src--;} while ((src > isrc) && ((src[0] & 0xc0) == 0x80));
    }
  } else if (!InStateZero(st, Tbl)) {
    // Back up over truncated UTF-8 character
    e = kExitIllegalStructure;
    do {src--;} while ((src > isrc) && ((src[0] & 0xc0) == 0x80));
  } else {
    // Normal termination, source fully consumed
    e = kExitOK;
  }

  if (e == kExitDoAgain) {
    // Loop back up to the fast scan
    goto DoAgain;
  }

  *bytes_consumed = src - isrc;
  return e;
}

// Scan a UTF-8 stringpiece based on state table.
// Always scan complete UTF-8 characters
// Set number of bytes scanned. Return reason for exiting
// OPTIMIZED for case of 7-bit ASCII 0000..007f all valid
int UTF8GenericScanFastAscii(const UTF8ScanObj* st,
                    const StringPiece& str,
                    int* bytes_consumed) {
  const uint8* isrc =
    reinterpret_cast<const uint8*>(str.data());
  const uint8* src = isrc;
  const int len = str.length();
  const uint8* srclimit = isrc + len;
  const uint8* srclimit8 = srclimit - 7;
  *bytes_consumed = 0;
  if (len == 0) return kExitOK;

  int n;
  int rest_consumed;
  int exit_reason;
  do {
    // Skip 8 bytes of ASCII at a whack; no endianness issue
    while ((src < srclimit8) &&
           (((UNALIGNED_LOAD32(&reinterpret_cast<const uint32*>(src)[0]) |
              UNALIGNED_LOAD32(&reinterpret_cast<const uint32*>(src)[1]))
             & 0x80808080) == 0)) {
      src += 8;
    }
    // Run state table on the rest
    n = src - isrc;
    StringPiece str2(str.data() + n, str.length() - n);
    exit_reason = UTF8GenericScan(st, str2, &rest_consumed);
    src += rest_consumed;
  } while ( exit_reason == kExitDoAgain );

  *bytes_consumed = src - isrc;
  return exit_reason;
}

// Hack to change halfwidth katakana to match an old UTF8CharToLower()

// Return number of src bytes skipped
static int DoSpecialFixup(const unsigned char c,
                    const unsigned char** srcp, const unsigned char* srclimit,
                    unsigned char** dstp, unsigned char* dstlimit) {
  return 0;
}


// Scan a UTF-8 stringpiece based on state table, copying to output stringpiece
//   and doing text replacements.
// DO NOT CALL DIRECTLY. Use UTF8GenericReplace() below
//   Needs caller to loop on kExitDoAgain
static int UTF8GenericReplaceInternal(const UTF8ReplaceObj* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    bool is_plain_text,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed,
                    OffsetMap* offsetmap) {
  int eshift = st->entry_shift;
  int nEntries = (1 << eshift);       // 64 or 256 entries per state
  const uint8* isrc = reinterpret_cast<const uint8*>(istr.data());
  const int ilen = istr.length();
  const uint8* copystart = isrc;
  const uint8* src = isrc;
  const uint8* srclimit = src + ilen;
  *bytes_consumed = 0;
  *bytes_filled = 0;
  *chars_changed = 0;

  const uint8* odst = reinterpret_cast<const uint8*>(ostr.data());
  const int olen = ostr.length();
  uint8* dst = const_cast<uint8*>(odst);
  uint8* dstlimit = dst + olen;

  int total_changed = 0;

  // Invariant condition during replacements:
  //  remaining dst size >= remaining src size
  if ((dstlimit - dst) < (srclimit - src)) {
    if (offsetmap != NULL) {
      offsetmap->Copy(src - copystart);
      copystart = src;
    }
    return kExitDstSpaceFull;
  }
  const uint8* Tbl_0 = &st->state_table[st->state0];

 Do_state_table:
  // Do state-table scan, copying as we go
  const uint8* Tbl = Tbl_0;
  int e = 0;
  uint8 c = 0;

 Do_state_table_newe:

  //----------------------------
  while (src < srclimit) {
    c = *src;
    e = Tbl[c];
    *dst = c;
    src++;
    dst++;
    if (e >= kExitIllegalStructure) {break;}
    Tbl = &Tbl_0[e << eshift];
  }
  //----------------------------

  // Exit possibilities:
  //  Replacement code, do the replacement and loop
  //  Some other exit code, state0, back up one byte exactly
  //  Some other exit code, !state0, back up over last char
  //  source consumed, state0, exit OK
  //  source consumed, !state0, back up over partial char
  // For illegal byte in state0, avoid backup up over PREVIOUS char
  // For truncated last char, back up to beginning of it

  if (e >= kExitIllegalStructure) {
    // Switch on exit code; most loop back to top
    int offset = 0;
    switch (e) {
    // These all make the output string the same size or shorter
    // No checking needed
    case kExitReplace31:    // del 2, add 1 bytes to change
      dst -= 2;
      if (offsetmap != NULL) {
        offsetmap->Copy(src - copystart - 2);
        offsetmap->Delete(2);
        copystart = src;
      }
      dst[-1] = (unsigned char)Tbl[c + (nEntries * 1)];
      total_changed++;
      goto Do_state_table;
    case kExitReplace32:    // del 3, add 2 bytes to change
      dst--;
      if (offsetmap != NULL) {
        offsetmap->Copy(src - copystart - 1);
        offsetmap->Delete(1);
        copystart = src;
      }
      dst[-2] = (unsigned char)Tbl[c + (nEntries * 2)];
      dst[-1] = (unsigned char)Tbl[c + (nEntries * 1)];
      total_changed++;
      goto Do_state_table;
    case kExitReplace21:    // del 2, add 1 bytes to change
      dst--;
      if (offsetmap != NULL) {
        offsetmap->Copy(src - copystart - 1);
        offsetmap->Delete(1);
        copystart = src;
      }
      dst[-1] = (unsigned char)Tbl[c + (nEntries * 1)];
      total_changed++;
      goto Do_state_table;
    case kExitReplace3:    // update 3 bytes to change
      dst[-3] = (unsigned char)Tbl[c + (nEntries * 3)];
      // Fall into next case
    case kExitReplace2:    // update 2 bytes to change
      dst[-2] = (unsigned char)Tbl[c + (nEntries * 2)];
      // Fall into next case
    case kExitReplace1:    // update 1 byte to change
      dst[-1] = (unsigned char)Tbl[c + (nEntries * 1)];
      total_changed++;
      goto Do_state_table;
    case kExitReplace1S0:     // update 1 byte to change, 256-entry state
      dst[-1] = (unsigned char)Tbl[c + (256 * 1)];
      total_changed++;
      goto Do_state_table;
    // These can make the output string longer than the input
    case kExitReplaceOffset2:
      if ((nEntries != 256) && InStateZero(st, Tbl)) {
        // For space-optimized table, we need multiples of 256 bytes
        // in state0 and multiples of nEntries in other states
        offset += ((unsigned char)Tbl[c + (256 * 2)] << 8);
      } else {
        offset += ((unsigned char)Tbl[c + (nEntries * 2)] << 8);
      }
      // Fall into next case
    case kExitSpecial:      // Apply special fixups [read: hacks]
    case kExitReplaceOffset1:
      if ((nEntries != 256) && InStateZero(st, Tbl)) {
        // For space-optimized table, we need multiples of 256 bytes
        // in state0 and multiples of nEntries in other states
        offset += (unsigned char)Tbl[c + (256 * 1)];
      } else {
        offset += (unsigned char)Tbl[c + (nEntries * 1)];
      }
      {
        const RemapEntry* re = &st->remap_base[offset];
        int del_len = re->delete_bytes & ~kReplaceAndResumeFlag;
        int add_len = re->add_bytes & ~kHtmlPlaintextFlag;

        // Special-case non-HTML replacement of five sensitive entities
        //   &quot; &amp; &apos; &lt; &gt;
        //   0022   0026  0027   003c 003e
        // A replacement creating one of these is expressed as a pair of
        // entries, one for HTML output and one for plaintext output.
        // The first of the pair has the high bit of add_bytes set.
        if (re->add_bytes & kHtmlPlaintextFlag) {
          // Use this entry for plain text
          if (!is_plain_text) {
            // Use very next entry for HTML text (same back/delete length)
            re = &st->remap_base[offset + 1];
            add_len = re->add_bytes & ~kHtmlPlaintextFlag;
          }
        }

        int string_offset = re->bytes_offset;
        // After the replacement, need (dstlimit - newdst) >= (srclimit - src)
        uint8* newdst = dst - del_len + add_len;
        if ((dstlimit - newdst) < (srclimit - src)) {
          // Won't fit; don't do the replacement. Caller may realloc and retry
          e = kExitDstSpaceFull;
          break;    // exit, backing up over this char for later retry
        }
        dst -= del_len;
        memcpy(dst, &st->remap_string[string_offset], add_len);
        dst += add_len;
        total_changed++;
        if (offsetmap != NULL) {
          if (add_len > del_len) {
            offsetmap->Copy(src - copystart);
            offsetmap->Insert(add_len - del_len);
            copystart = src;
          } else if (add_len < del_len) {
            offsetmap->Copy(src - copystart + add_len - del_len);
            offsetmap->Delete(del_len - add_len);
            copystart = src;
          }
        }
        if (re->delete_bytes & kReplaceAndResumeFlag) {
          // There is a non-zero  target state at the end of the
          // replacement string
          e = st->remap_string[string_offset + add_len];
          Tbl = &Tbl_0[e << eshift];
          goto Do_state_table_newe;
        }
      }
      if (e == kExitRejectAlt) {break;}
      if (e != kExitSpecial) {goto Do_state_table;}

    // case kExitSpecial:      // Apply special fixups [read: hacks]
      // In this routine, do either UTF8CharToLower()
      //   fullwidth/halfwidth mapping or
      //   voiced mapping or
      //   semi-voiced mapping

      // First, do EXIT_REPLACE_OFFSET1 action (above)
      // Second: do additional code fixup
      {
        int srcdel = DoSpecialFixup(c, &src, srclimit, &dst, dstlimit);
        if (offsetmap != NULL) {
          if (srcdel != 0) {
            offsetmap->Copy(src - copystart - srcdel);
            offsetmap->Delete(srcdel);
            copystart = src;
          }
        }
      }
      goto Do_state_table;

    case kExitIllegalStructure:   // structurally illegal byte; quit
    case kExitReject:             // NUL or illegal code encountered; quit
    case kExitRejectAlt:          // Apply replacement, then exit
    default:                      // and all other exits
      break;
    }   // End switch (e)

    // Exit possibilities:
    //  Some other exit code, state0, back up one byte exactly
    //  Some other exit code, !state0, back up over last char

    // Back up over exactly one byte of rejected/illegal UTF-8 character
    src--;
    dst--;
    // Back up more if needed
    if (!InStateZero(st, Tbl)) {
      do {src--;dst--;} while ((src > isrc) && ((src[0] & 0xc0) == 0x80));
    }
  } else if (!InStateZero(st, Tbl)) {
    // src >= srclimit, !state0
    // Back up over truncated UTF-8 character
    e = kExitIllegalStructure;
    do {src--; dst--;} while ((src > isrc) && ((src[0] & 0xc0) == 0x80));
  } else {
    // src >= srclimit, state0
    // Normal termination, source fully consumed
    e = kExitOK;
  }

  if (offsetmap != NULL) {
    if (src > copystart) {
      offsetmap->Copy(src - copystart);
      copystart = src;
    }
  }

  // Possible return values here:
  //  kExitDstSpaceFull         caller may realloc and retry from middle
  //  kExitIllegalStructure     caller my overwrite/truncate
  //  kExitOK                   all done and happy
  //  kExitReject               caller may overwrite/truncate
  //  kExitDoAgain              LOOP NOT DONE; caller must retry from middle
  //                            (may do fast ASCII loop first)
  //  kExitPlaceholder          -unused-
  //  kExitNone                 -unused-
  *bytes_consumed = src - isrc;
  *bytes_filled = dst - odst;
  *chars_changed = total_changed;
  return e;
}

// TwoByte versions are needed for tables > 240 states, such
// as the table for full Unicode 4.1 canonical + compatibility mapping

// Scan a UTF-8 stringpiece based on state table with two-byte entries,
//   copying to output stringpiece
//   and doing text replacements.
// DO NOT CALL DIRECTLY. Use UTF8GenericReplace() below
//   Needs caller to loop on kExitDoAgain
static int UTF8GenericReplaceInternalTwoByte(const UTF8ReplaceObj_2* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    bool is_plain_text,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed,
                    OffsetMap* offsetmap) {
  int eshift = st->entry_shift;
  int nEntries = (1 << eshift);       // 64 or 256 entries per state
  const uint8* isrc = reinterpret_cast<const uint8*>(istr.data());
  const int ilen = istr.length();
  const uint8* copystart = isrc;
  const uint8* src = isrc;
  const uint8* srclimit = src + ilen;
  *bytes_consumed = 0;
  *bytes_filled = 0;
  *chars_changed = 0;

  const uint8* odst = reinterpret_cast<const uint8*>(ostr.data());
  const int olen = ostr.length();
  uint8* dst = const_cast<uint8*>(odst);
  uint8* dstlimit = dst + olen;

  *chars_changed = 0;

  int total_changed = 0;

  // Invariant condition during replacements:
  //  remaining dst size >= remaining src size
  if ((dstlimit - dst) < (srclimit - src)) {
    if (offsetmap != NULL) {
      offsetmap->Copy(src - copystart);
      copystart = src;
    }
    return kExitDstSpaceFull_2;
  }
  const unsigned short* Tbl_0 = &st->state_table[st->state0];

 Do_state_table_2:
  // Do state-table scan, copying as we go
  const unsigned short* Tbl = Tbl_0;
  int e = 0;
  uint8 c = 0;

 Do_state_table_newe_2:

  //----------------------------
  while (src < srclimit) {
    c = *src;
    e = Tbl[c];
    *dst = c;
    src++;
    dst++;
    if (e >= kExitIllegalStructure_2) {break;}
    Tbl = &Tbl_0[e << eshift];
  }
  //----------------------------

  // Exit possibilities:
  //  Replacement code, do the replacement and loop
  //  Some other exit code, state0, back up one byte exactly
  //  Some other exit code, !state0, back up over last char
  //  source consumed, state0, exit OK
  //  source consumed, !state0, back up over partial char
  // For illegal byte in state0, avoid backup up over PREVIOUS char
  // For truncated last char, back up to beginning of it

  if (e >= kExitIllegalStructure_2) {
    // Switch on exit code; most loop back to top
    int offset = 0;
    switch (e) {
    // These all make the output string the same size or shorter
    // No checking needed
    case kExitReplace31_2:    // del 2, add 1 bytes to change
      dst -= 2;
      if (offsetmap != NULL) {
        offsetmap->Copy(src - copystart - 2);
        offsetmap->Delete(2);
        copystart = src;
      }
      dst[-1] = (unsigned char)(Tbl[c + (nEntries * 1)] & 0xff);
      total_changed++;
      goto Do_state_table_2;
    case kExitReplace32_2:    // del 3, add 2 bytes to change
      dst--;
      if (offsetmap != NULL) {
        offsetmap->Copy(src - copystart - 1);
        offsetmap->Delete(1);
        copystart = src;
      }
      dst[-2] = (unsigned char)(Tbl[c + (nEntries * 1)] >> 8 & 0xff);
      dst[-1] = (unsigned char)(Tbl[c + (nEntries * 1)] & 0xff);
      total_changed++;
      goto Do_state_table_2;
    case kExitReplace21_2:    // del 2, add 1 bytes to change
      dst--;
      if (offsetmap != NULL) {
        offsetmap->Copy(src - copystart - 1);
        offsetmap->Delete(1);
        copystart = src;
      }
      dst[-1] = (unsigned char)(Tbl[c + (nEntries * 1)] & 0xff);
      total_changed++;
      goto Do_state_table_2;
    case kExitReplace3_2:    // update 3 bytes to change
      dst[-3] = (unsigned char)(Tbl[c + (nEntries * 2)] & 0xff);
      // Fall into next case
    case kExitReplace2_2:    // update 2 bytes to change
      dst[-2] = (unsigned char)(Tbl[c + (nEntries * 1)] >> 8 & 0xff);
      // Fall into next case
    case kExitReplace1_2:    // update 1 byte to change
      dst[-1] = (unsigned char)(Tbl[c + (nEntries * 1)] & 0xff);
      total_changed++;
      goto Do_state_table_2;
    case kExitReplace1S0_2:     // update 1 byte to change, 256-entry state
      dst[-1] = (unsigned char)(Tbl[c + (256 * 1)] & 0xff);
      total_changed++;
      goto Do_state_table_2;
    // These can make the output string longer than the input
    case kExitReplaceOffset2_2:
      if ((nEntries != 256) && InStateZero_2(st, Tbl)) {
        // For space-optimized table, we need multiples of 256 bytes
        // in state0 and multiples of nEntries in other states
        offset += ((unsigned char)(Tbl[c + (256 * 1)] >> 8 & 0xff) << 8);
      } else {
        offset += ((unsigned char)(Tbl[c + (nEntries * 1)] >> 8 & 0xff) << 8);
      }
      // Fall into next case
    case kExitReplaceOffset1_2:
      if ((nEntries != 256) && InStateZero_2(st, Tbl)) {
        // For space-optimized table, we need multiples of 256 bytes
        // in state0 and multiples of nEntries in other states
        offset += (unsigned char)(Tbl[c + (256 * 1)] & 0xff);
      } else {
        offset += (unsigned char)(Tbl[c + (nEntries * 1)] & 0xff);
      }
      {
        const RemapEntry* re = &st->remap_base[offset];
        int del_len = re->delete_bytes & ~kReplaceAndResumeFlag;
        int add_len = re->add_bytes & ~kHtmlPlaintextFlag;
        // Special-case non-HTML replacement of five sensitive entities
        //   &quot; &amp; &apos; &lt; &gt;
        //   0022   0026  0027   003c 003e
        // A replacement creating one of these is expressed as a pair of
        // entries, one for HTML output and one for plaintext output.
        // The first of the pair has the high bit of add_bytes set.
        if (re->add_bytes & kHtmlPlaintextFlag) {
          // Use this entry for plain text
          if (!is_plain_text) {
            // Use very next entry for HTML text (same back/delete length)
            re = &st->remap_base[offset + 1];
            add_len = re->add_bytes & ~kHtmlPlaintextFlag;
          }
        }

        // After the replacement, need (dstlimit - dst) >= (srclimit - src)
        int string_offset = re->bytes_offset;
        // After the replacement, need (dstlimit - newdst) >= (srclimit - src)
        uint8* newdst = dst - del_len + add_len;
        if ((dstlimit - newdst) < (srclimit - src)) {
          // Won't fit; don't do the replacement. Caller may realloc and retry
          e = kExitDstSpaceFull_2;
          break;    // exit, backing up over this char for later retry
        }
        dst -= del_len;
        memcpy(dst, &st->remap_string[string_offset], add_len);
        dst += add_len;
        if (offsetmap != NULL) {
          if (add_len > del_len) {
            offsetmap->Copy(src - copystart);
            offsetmap->Insert(add_len - del_len);
            copystart = src;
          } else if (add_len < del_len) {
            offsetmap->Copy(src - copystart + add_len - del_len);
            offsetmap->Delete(del_len - add_len);
            copystart = src;
          }
        }
        if (re->delete_bytes & kReplaceAndResumeFlag) {
          // There is a two-byte non-zero target state at the end of the
          // replacement string
          uint8 c1 = st->remap_string[string_offset + add_len];
          uint8 c2 = st->remap_string[string_offset + add_len + 1];
          e = (c1 << 8) | c2;
          Tbl = &Tbl_0[e << eshift];
          total_changed++;
          goto Do_state_table_newe_2;
        }
      }
      total_changed++;
      if (e == kExitRejectAlt_2) {break;}
      goto Do_state_table_2;

    case kExitSpecial_2:           // NO special fixups [read: hacks]
    case kExitIllegalStructure_2:  // structurally illegal byte; quit
    case kExitReject_2:            // NUL or illegal code encountered; quit
                                   // and all other exits
    default:
      break;
    }   // End switch (e)

    // Exit possibilities:
    //  Some other exit code, state0, back up one byte exactly
    //  Some other exit code, !state0, back up over last char

    // Back up over exactly one byte of rejected/illegal UTF-8 character
    src--;
    dst--;
    // Back up more if needed
    if (!InStateZero_2(st, Tbl)) {
      do {src--;dst--;} while ((src > isrc) && ((src[0] & 0xc0) == 0x80));
    }
  } else if (!InStateZero_2(st, Tbl)) {
    // src >= srclimit, !state0
    // Back up over truncated UTF-8 character
    e = kExitIllegalStructure_2;

    do {src--; dst--;} while ((src > isrc) && ((src[0] & 0xc0) == 0x80));
  } else {
    // src >= srclimit, state0
    // Normal termination, source fully consumed
    e = kExitOK_2;
  }

  if (offsetmap != NULL) {
    if (src > copystart) {
      offsetmap->Copy(src - copystart);
      copystart = src;
    }
  }


  // Possible return values here:
  //  kExitDstSpaceFull_2         caller may realloc and retry from middle
  //  kExitIllegalStructure_2     caller my overwrite/truncate
  //  kExitOK_2                   all done and happy
  //  kExitReject_2               caller may overwrite/truncate
  //  kExitDoAgain_2              LOOP NOT DONE; caller must retry from middle
  //                            (may do fast ASCII loop first)
  //  kExitPlaceholder_2          -unused-
  //  kExitNone_2                 -unused-
  *bytes_consumed = src - isrc;
  *bytes_filled = dst - odst;
  *chars_changed = total_changed;
  return e;
}


// Scan a UTF-8 stringpiece based on state table, copying to output stringpiece
//   and doing text replacements.
// Also writes an optional OffsetMap. Pass NULL to skip writing one.
// Always scan complete UTF-8 characters
// Set number of bytes consumed from input, number filled to output.
// Return reason for exiting
int UTF8GenericReplace(const UTF8ReplaceObj* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    bool is_plain_text,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed,
                    OffsetMap* offsetmap) {
  StringPiece local_istr(istr.data(), istr.length());
  StringPiece local_ostr(ostr.data(), ostr.length());
  int total_consumed = 0;
  int total_filled = 0;
  int total_changed = 0;
  int local_bytes_consumed, local_bytes_filled, local_chars_changed;
  int e;
  do {
    e = UTF8GenericReplaceInternal(st,
                    local_istr, local_ostr, is_plain_text,
                    &local_bytes_consumed, &local_bytes_filled,
                    &local_chars_changed,
                    offsetmap);
    local_istr.remove_prefix(local_bytes_consumed);
    local_ostr.remove_prefix(local_bytes_filled);
    total_consumed += local_bytes_consumed;
    total_filled += local_bytes_filled;
    total_changed += local_chars_changed;
  } while ( e == kExitDoAgain );
  *bytes_consumed = total_consumed;
  *bytes_filled = total_filled;
  *chars_changed = total_changed;
  return e;
}

// Older version without offsetmap
int UTF8GenericReplace(const UTF8ReplaceObj* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    bool is_plain_text,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed) {
  return UTF8GenericReplace(st,
                    istr,
                    ostr,
                    is_plain_text,
                    bytes_consumed,
                    bytes_filled,
                    chars_changed,
                    NULL);
}

// Older version without is_plain_text or offsetmap
int UTF8GenericReplace(const UTF8ReplaceObj* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed) {
  bool is_plain_text = false;
  return UTF8GenericReplace(st,
                    istr,
                    ostr,
                    is_plain_text,
                    bytes_consumed,
                    bytes_filled,
                    chars_changed,
                    NULL);
}

// Scan a UTF-8 stringpiece based on state table with two-byte entries,
//   copying to output stringpiece
//   and doing text replacements.
// Also writes an optional OffsetMap. Pass NULL to skip writing one.
// Always scan complete UTF-8 characters
// Set number of bytes consumed from input, number filled to output.
// Return reason for exiting
int UTF8GenericReplaceTwoByte(const UTF8ReplaceObj_2* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    bool is_plain_text,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed,
                    OffsetMap* offsetmap) {
  StringPiece local_istr(istr.data(), istr.length());
  StringPiece local_ostr(ostr.data(), ostr.length());
  int total_consumed = 0;
  int total_filled = 0;
  int total_changed = 0;
  int local_bytes_consumed, local_bytes_filled, local_chars_changed;
  int e;
  do {
    e = UTF8GenericReplaceInternalTwoByte(st,
                    local_istr, local_ostr, is_plain_text,
                    &local_bytes_consumed,
                    &local_bytes_filled,
                    &local_chars_changed,
                    offsetmap);
    local_istr.remove_prefix(local_bytes_consumed);
    local_ostr.remove_prefix(local_bytes_filled);
    total_consumed += local_bytes_consumed;
    total_filled += local_bytes_filled;
    total_changed += local_chars_changed;
  } while ( e == kExitDoAgain_2 );
  *bytes_consumed = total_consumed;
  *bytes_filled = total_filled;
  *chars_changed = total_changed;

  return e - kExitOK_2 + kExitOK;
}

// Older version without offsetmap
int UTF8GenericReplaceTwoByte(const UTF8ReplaceObj_2* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    bool is_plain_text,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed) {
  return UTF8GenericReplaceTwoByte(st,
                    istr,
                    ostr,
                    is_plain_text,
                    bytes_consumed,
                    bytes_filled,
                    chars_changed,
                    NULL);
}

// Older version without is_plain_text or offsetmap
int UTF8GenericReplaceTwoByte(const UTF8ReplaceObj_2* st,
                    const StringPiece& istr,
                    StringPiece& ostr,
                    int* bytes_consumed,
                    int* bytes_filled,
                    int* chars_changed) {
  bool is_plain_text = false;
  return UTF8GenericReplaceTwoByte(st,
                    istr,
                    ostr,
                    is_plain_text,
                    bytes_consumed,
                    bytes_filled,
                    chars_changed,
                    NULL);
}



// Adjust a stringpiece to encompass complete UTF-8 characters.
// The data pointer will be increased by 0..3 bytes to get to a character
// boundary, and the length will then be decreased by 0..3 bytes
// to encompass the last complete character.
void UTF8TrimToChars(StringPiece* istr) {
  const char* src = istr->data();
  int len = istr->length();
  // Exit if empty string
  if (len == 0) {
    return;
  }

  // Exit on simple, common case
  if ( ((src[0] & 0xc0) != 0x80) &&
       (static_cast<signed char>(src[len - 1]) >= 0) ) {
    // First byte is not a continuation and last byte is 7-bit ASCII -- done
    return;
  }

  // Adjust the back end, len > 0
  const char* srclimit = src + len;
  // Backscan over any ending continuation bytes to find last char start
  const char* s = srclimit - 1;         // Last byte of the string
  while ((src <= s) && ((*s & 0xc0) == 0x80)) {
    s--;
  }
  // Include entire last char if it fits
  if (src <= s) {
    int last_char_len = UTF8OneCharLen(s);
    if (s + last_char_len <= srclimit) {
      // Last char fits, so include it, else exclude it
      s += last_char_len;
    }
  }
  if (s != srclimit) {
    // s is one byte beyond the last full character, if any
    istr->remove_suffix(srclimit - s);
    // Exit if now empty string
    if (istr->length() == 0) {
      return;
    }
  }

  // Adjust the front end, len > 0
  len = istr->length();
  srclimit = src + len;
  s = src;                            // First byte of the string
  // Scan over any beginning continuation bytes to find first char start
  while ((s < srclimit) && ((*s & 0xc0) == 0x80)) {
    s++;
  }
  if (s != src) {
    // s is at the first full character, if any
    istr->remove_prefix(s - src);
  }
}

}       // End namespace CLD2
}       // End namespace chrome_lang_id
