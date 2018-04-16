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

#include "text_processing.h"

#include <stdio.h>
#include <string.h>

namespace chrome_lang_id {
namespace CLD2 {
namespace {

static const int kMaxSpaceScan = 32;  // Bytes

int minint(int a, int b) { return (a < b) ? a : b; }

// Counts number of spaces; a little faster than one-at-a-time
// Doesn't count odd bytes at end
int CountSpaces4(const char *src, int src_len) {
  int s_count = 0;
  for (int i = 0; i < (src_len & ~3); i += 4) {
    s_count += (src[i] == ' ');
    s_count += (src[i + 1] == ' ');
    s_count += (src[i + 2] == ' ');
    s_count += (src[i + 3] == ' ');
  }
  return s_count;
}

// This uses a cheap predictor to get a measure of compression, and
// hence a measure of repetitiveness. It works on complete UTF-8 characters
// instead of bytes, because three-byte UTF-8 Indic, etc. text compress highly
// all the time when done with a byte-based count. Sigh.
//
// To allow running prediction across multiple chunks, caller passes in current
// 12-bit hash value and int[4096] prediction table. Caller inits these to 0.
//
// Returns the number of *bytes* correctly predicted, increments by 1..4 for
// each correctly-predicted character.
//
// NOTE: Overruns by up to three bytes. Not a problem with valid UTF-8 text
//

// TODO(dsites) make this use just one byte per UTF-8 char and incr by charlen

int CountPredictedBytes(const char *isrc, int src_len, int *hash, int *tbl) {
  typedef unsigned char uint8;

  int p_count = 0;
  const uint8 *src = reinterpret_cast<const uint8 *>(isrc);
  const uint8 *srclimit = src + src_len;
  int local_hash = *hash;

  while (src < srclimit) {
    int c = src[0];
    int incr = 1;

    // Pick up one char and length
    if (c < 0xc0) {
      // One-byte or continuation byte: 00xxxxxx 01xxxxxx 10xxxxxx
      // Do nothing more
    } else if ((c & 0xe0) == 0xc0) {
      // Two-byte
      c = (c << 8) | src[1];
      incr = 2;
    } else if ((c & 0xf0) == 0xe0) {
      // Three-byte
      c = (c << 16) | (src[1] << 8) | src[2];
      incr = 3;
    } else {
      // Four-byte
      c = (c << 24) | (src[1] << 16) | (src[2] << 8) | src[3];
      incr = 4;
    }
    src += incr;

    int p = tbl[local_hash];  // Prediction
    tbl[local_hash] = c;      // Update prediction
    if (c == p) {
      p_count += incr;  // Count bytes of good predictions
    }

    local_hash = ((local_hash << 4) ^ c) & 0xfff;
  }
  *hash = local_hash;
  return p_count;
}

// Backscan to word boundary, returning how many bytes n to go back
// so that src - n is non-space ans src - n - 1 is space.
// If not found in kMaxSpaceScan bytes, return 0..3 to a clean UTF-8 boundary
int BackscanToSpace(const char *src, int limit) {
  int n = 0;
  limit = minint(limit, kMaxSpaceScan);
  while (n < limit) {
    if (src[-n - 1] == ' ') {
      return n;
    }  // We are at _X
    ++n;
  }
  n = 0;
  while (n < limit) {
    if ((src[-n] & 0xc0) != 0x80) {
      return n;
    }  // We are at char begin
    ++n;
  }
  return 0;
}

// Forwardscan to word boundary, returning how many bytes n to go forward
// so that src + n is non-space ans src + n - 1 is space.
// If not found in kMaxSpaceScan bytes, return 0..3 to a clean UTF-8 boundary
int ForwardscanToSpace(const char *src, int limit) {
  int n = 0;
  limit = minint(limit, kMaxSpaceScan);
  while (n < limit) {
    if (src[n] == ' ') {
      return n + 1;
    }  // We are at _X
    ++n;
  }
  n = 0;
  while (n < limit) {
    if ((src[n] & 0xc0) != 0x80) {
      return n;
    }  // We are at char begin
    ++n;
  }
  return 0;
}

}  // namespace

// Must be exactly 4096 for cheap compressor.
static const int kPredictionTableSize = 4096;
static const int kChunksizeDefault = 48;      // Squeeze 48-byte chunks
static const int kSpacesThreshPercent = 30;   // Squeeze if >=30% spaces
static const int kPredictThreshPercent = 40;  // Squeeze if >=40% predicted

// Remove portions of text that have a high density of spaces, or that are
// overly repetitive, squeezing the remaining text in-place to the front of the
// input buffer.
//
// Squeezing looks at density of space/prediced chars in fixed-size chunks,
// specified by chunksize. A chunksize <= 0 uses the default size of 48 bytes.
//
// Return the new, possibly-shorter length
//
// Result Buffer ALWAYS has leading space and trailing space space space NUL,
// if input does
//
int CheapSqueezeInplace(char *isrc, int src_len, int ichunksize) {
  char *src = isrc;
  char *dst = src;
  char *srclimit = src + src_len;
  bool skipping = false;

  int hash = 0;

  // Allocate local prediction table.
  int *predict_tbl = new int[kPredictionTableSize];
  memset(predict_tbl, 0, kPredictionTableSize * sizeof(predict_tbl[0]));

  int chunksize = ichunksize;
  if (chunksize == 0) {
    chunksize = kChunksizeDefault;
  }
  int space_thresh = (chunksize * kSpacesThreshPercent) / 100;
  int predict_thresh = (chunksize * kPredictThreshPercent) / 100;

  while (src < srclimit) {
    int remaining_bytes = srclimit - src;
    int len = minint(chunksize, remaining_bytes);

    // Make len land us on a UTF-8 character boundary.
    // Ah. Also fixes mispredict because we could get out of phase
    // Loop always terminates at trailing space in buffer
    while ((src[len] & 0xc0) == 0x80) {
      ++len;
    }  // Move past continuation bytes

    int space_n = CountSpaces4(src, len);
    int predb_n = CountPredictedBytes(src, len, &hash, predict_tbl);
    if ((space_n >= space_thresh) || (predb_n >= predict_thresh)) {
      // Skip the text
      if (!skipping) {
        // Keeping-to-skipping transition; do it at a space
        int n = BackscanToSpace(dst, static_cast<int>(dst - isrc));
        dst -= n;
        if (dst == isrc) {
          // Force a leading space if the first chunk is deleted
          *dst++ = ' ';
        }
        skipping = true;
      }
    } else {
      // Keep the text
      if (skipping) {
        // Skipping-to-keeping transition; do it at a space
        int n = ForwardscanToSpace(src, len);
        src += n;
        remaining_bytes -= n;  // Shrink remaining length
        len -= n;
        skipping = false;
      }

      // "len" can be negative in some cases
      if (len > 0) {
        memmove(dst, src, len);
        dst += len;
      }
    }
    src += len;
  }

  if ((dst - isrc) < (src_len - 3)) {
    // Pad and make last char clean UTF-8 by putting following spaces
    dst[0] = ' ';
    dst[1] = ' ';
    dst[2] = ' ';
    dst[3] = '\0';
  } else if ((dst - isrc) < src_len) {
    // Make last char clean UTF-8 by putting following space off the end
    dst[0] = ' ';
  }

  // Deallocate local prediction table
  delete[] predict_tbl;
  return static_cast<int>(dst - isrc);
}

}  // namespace CLD2
}  // namespace chrome_lang_id
