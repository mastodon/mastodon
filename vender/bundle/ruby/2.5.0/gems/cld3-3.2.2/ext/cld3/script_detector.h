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

#ifndef SCRIPT_DETECTOR_H_
#define SCRIPT_DETECTOR_H_

namespace chrome_lang_id {

// Unicode scripts we care about.  To get compact and fast code, we detect only
// a few Unicode scripts that offer a strong indication about the language of
// the text (e.g., Hiragana -> Japanese).
enum Script {
  // Special value to indicate internal errors in the script detection code.
  kScriptError,

  // Special values for all Unicode scripts that we do not detect.  One special
  // value for Unicode characters of 1, 2, 3, respectively 4 bytes (as we
  // already have that information, we use it).  kScriptOtherUtf8OneByte means
  // ~Latin and kScriptOtherUtf8FourBytes means ~Han.
  kScriptOtherUtf8OneByte,
  kScriptOtherUtf8TwoBytes,
  kScriptOtherUtf8ThreeBytes,
  kScriptOtherUtf8FourBytes,

  kScriptGreek,
  kScriptCyrillic,
  kScriptHebrew,
  kScriptArabic,
  kScriptHangulJamo,  // Used primarily for Korean.
  kScriptHiragana,    // Used primarily for Japanese.
  kScriptKatakana,    // Used primarily for Japanese.

  // Add new scripts here.

  // Do not add any script after kNumRelevantScripts.  This value indicates the
  // number of elements in this enum Script (except this value) such that we can
  // easily iterate over the scripts.
  kNumRelevantScripts,
};

template <typename IntType>
inline bool InRange(IntType value, IntType low, IntType hi) {
  return (value >= low) && (value <= hi);
}

// Returns Script for the UTF8 character that starts at address p.
// Precondition: p points to a valid UTF8 character of num_bytes bytes.
inline Script GetScript(const unsigned char *p, int num_bytes) {
  switch (num_bytes) {
    case 1:
      return kScriptOtherUtf8OneByte;

    case 2: {
      // 2-byte UTF8 characters have 11 bits of information.  unsigned int has
      // at least 16 bits (http://en.cppreference.com/w/cpp/language/types) so
      // it's enough.  It's also usually the fastest int type on the current
      // CPU, so it's better to use than int32.
      static const unsigned int kGreekStart = 0x370;

      // Commented out (unsued in the code): kGreekEnd = 0x3FF;
      static const unsigned int kCyrillicStart = 0x400;
      static const unsigned int kCyrillicEnd = 0x4FF;
      static const unsigned int kHebrewStart = 0x590;

      // Commented out (unsued in the code): kHebrewEnd = 0x5FF;
      static const unsigned int kArabicStart = 0x600;
      static const unsigned int kArabicEnd = 0x6FF;
      const unsigned int codepoint = ((p[0] & 0x1F) << 6) | (p[1] & 0x3F);
      if (codepoint > kCyrillicEnd) {
        if (codepoint >= kArabicStart) {
          if (codepoint <= kArabicEnd) {
            return kScriptArabic;
          }
        } else {
          // At this point, codepoint < kArabicStart = kHebrewEnd + 1, so
          // codepoint <= kHebrewEnd.
          if (codepoint >= kHebrewStart) {
            return kScriptHebrew;
          }
        }
      } else {
        if (codepoint >= kCyrillicStart) {
          return kScriptCyrillic;
        } else {
          // At this point, codepoint < kCyrillicStart = kGreekEnd + 1, so
          // codepoint <= kGreekEnd.
          if (codepoint >= kGreekStart) {
            return kScriptGreek;
          }
        }
      }
      return kScriptOtherUtf8TwoBytes;
    }

    case 3: {
      // 3-byte UTF8 characters have 16 bits of information.  unsigned int has
      // at least 16 bits.
      static const unsigned int kHangulJamoStart = 0x1100;
      static const unsigned int kHangulJamoEnd = 0x11FF;
      static const unsigned int kHiraganaStart = 0x3041;
      static const unsigned int kHiraganaEnd = 0x309F;

      // Commented out (unsued in the code): kKatakanaStart = 0x30A0;
      static const unsigned int kKatakanaEnd = 0x30FF;
      const unsigned int codepoint =
          ((p[0] & 0x0F) << 12) | ((p[1] & 0x3F) << 6) | (p[2] & 0x3F);
      if (codepoint > kHiraganaEnd) {
        // On this branch, codepoint > kHiraganaEnd = kKatakanaStart - 1, so
        // codepoint >= kKatakanaStart.
        if (codepoint <= kKatakanaEnd) {
          return kScriptKatakana;
        }
      } else {
        if (codepoint >= kHiraganaStart) {
          return kScriptHiragana;
        } else {
          if (InRange(codepoint, kHangulJamoStart, kHangulJamoEnd)) {
            return kScriptHangulJamo;
          }
        }
      }
      return kScriptOtherUtf8ThreeBytes;
    }

    case 4:
      return kScriptOtherUtf8FourBytes;

    default:
      return kScriptError;
  }
}

// Returns Script for the UTF8 character that starts at address p.  Similar to
// the previous version of GetScript, except for "char" vs "unsigned char".
// Most code works with "char *" pointers, ignoring the fact that char is
// unsigned (by default) on most platforms, but signed on iOS.  This code takes
// care of making sure we always treat chars as unsigned.
inline Script GetScript(const char *p, int num_bytes) {
  return GetScript(reinterpret_cast<const unsigned char *>(p), num_bytes);
}

}  // namespace chrome_lang_id

#endif  // SCRIPT_DETECTOR_H_
