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


#include "getonescriptspan.h"

#include <string.h>

#include "fixunicodevalue.h"
#include "port.h"
#include "utf8acceptinterchange.h"
#include "utf8repl_lettermarklower.h"
#include "utf8prop_lettermarkscriptnum.h"
#include "utf8scannot_lettermarkspecial.h"
#include "utf8statetable.h"

namespace chrome_lang_id {
namespace CLD2 {

// Alphabetical order for binary search, from
// generated_entities.cc
extern const int kNameToEntitySize;
extern const CharIntPair kNameToEntity[];

static const char kSpecialSymbol[256] = {       // true for < > &
  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,1,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,1,0,1,0,
  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,

  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
  0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
};



#define LT 0      // <
#define GT 1      // >
#define EX 2      // !
#define HY 3      // -
#define QU 4      // "
#define AP 5      // '
#define SL 6      // /
#define S_ 7
#define C_ 8
#define R_ 9
#define I_ 10
#define P_ 11
#define T_ 12
#define Y_ 13
#define L_ 14
#define E_ 15
#define CR 16     // <cr> or <lf>
#define NL 17     // non-letter: ASCII whitespace, digit, punctuation
#define PL 18     // possible letter, incl. &
#define xx 19     // <unused>

// Map byte to one of ~20 interesting categories for cheap tag parsing
static const uint8 kCharToSub[256] = {
  NL,NL,NL,NL, NL,NL,NL,NL, NL,NL,CR,NL, NL,CR,NL,NL,
  NL,NL,NL,NL, NL,NL,NL,NL, NL,NL,NL,NL, NL,NL,NL,NL,
  NL,EX,QU,NL, NL,NL,PL,AP, NL,NL,NL,NL, NL,HY,NL,SL,
  NL,NL,NL,NL, NL,NL,NL,NL, NL,NL,NL,NL, LT,NL,GT,NL,

  PL,PL,PL,C_, PL,E_,PL,PL, PL,I_,PL,PL, L_,PL,PL,PL,
  P_,PL,R_,S_, T_,PL,PL,PL, PL,Y_,PL,NL, NL,NL,NL,NL,
  PL,PL,PL,C_, PL,E_,PL,PL, PL,I_,PL,PL, L_,PL,PL,PL,
  P_,PL,R_,S_, T_,PL,PL,PL, PL,Y_,PL,NL, NL,NL,NL,NL,

  NL,NL,NL,NL, NL,NL,NL,NL, NL,NL,NL,NL, NL,NL,NL,NL,
  NL,NL,NL,NL, NL,NL,NL,NL, NL,NL,NL,NL, NL,NL,NL,NL,
  NL,NL,NL,NL, NL,NL,NL,NL, NL,NL,NL,NL, NL,NL,NL,NL,
  NL,NL,NL,NL, NL,NL,NL,NL, NL,NL,NL,NL, NL,NL,NL,NL,

  PL,PL,PL,PL, PL,PL,PL,PL, PL,PL,PL,PL, PL,PL,PL,PL,
  PL,PL,PL,PL, PL,PL,PL,PL, PL,PL,PL,PL, PL,PL,PL,PL,
  PL,PL,PL,PL, PL,PL,PL,PL, PL,PL,PL,PL, PL,PL,PL,PL,
  PL,PL,PL,PL, PL,PL,PL,PL, PL,PL,PL,PL, PL,PL,PL,PL,
};

#undef LT
#undef GT
#undef EX
#undef HY
#undef QU
#undef AP
#undef SL
#undef S_
#undef C_
#undef R_
#undef I_
#undef P_
#undef T_
#undef Y_
#undef L_
#undef E_
#undef CR
#undef NL
#undef PL
#undef xx


#define OK 0
#define X_ 1


static const int kMaxExitStateLettersMarksOnly = 1;
static const int kMaxExitStateAllText = 2;


// State machine to do cheap parse of non-letter strings incl. tags
// advances <tag>
//          |    |
// advances <tag> ... </tag>  for <script> <style>
//          |               |
// advances <!-- ... <tag> ... -->
//          |                     |
// advances <tag
//          ||  (0)
// advances <tag <tag2>
//          ||  (0)
//
// We start in state [0] at a non-letter and make at least one transition
// When scanning for just letters, arriving back at state [0] or [1] exits
//   the state machine.
// When scanning for any non-tag text, arriving at state [2] also exits
static const uint8 kTagParseTbl_0[] = {
// <  >  !  -   "  '  /  S   C  R  I  P   T  Y  L  E  CR NL PL xx
   3, 2, 2, 2,  2, 2, 2,OK, OK,OK,OK,OK, OK,OK,OK,OK,  2, 2,OK,X_, // [0] OK    exit state
  X_,X_,X_,X_, X_,X_,X_,X_, X_,X_,X_,X_, X_,X_,X_,X_, X_,X_,X_,X_, // [1] error exit state
   3, 2, 2, 2,  2, 2, 2,OK, OK,OK,OK,OK, OK,OK,OK,OK,  2, 2,OK,X_, // [2] NL*   [exit state]
  X_, 2, 4, 9, 10,11, 9,13,  9, 9, 9, 9,  9, 9, 9, 9,  9, 9, 9,X_, // [3] <
  X_, 2, 9, 5, 10,11, 9, 9,  9, 9, 9, 9,  9, 9, 9, 9,  9, 9, 9,X_, // [4] <!
  X_, 2, 9, 6, 10,11, 9, 9,  9, 9, 9, 9,  9, 9, 9, 9,  9, 9, 9,X_, // [5] <!-
   6, 6, 6, 7,  6, 6, 6, 6,  6, 6, 6, 6,  6, 6, 6, 6,  6, 6, 6,X_, // [6] <!--.*
   6, 6, 6, 8,  6, 6, 6, 6,  6, 6, 6, 6,  6, 6, 6, 6,  6, 6, 6,X_, // [7] <!--.*-
   6, 2, 6, 8,  6, 6, 6, 6,  6, 6, 6, 6,  6, 6, 6, 6,  6, 6, 6,X_, // [8] <!--.*--
  X_, 2, 9, 9, 10,11, 9, 9,  9, 9, 9, 9,  9, 9, 9, 9,  9, 9, 9,X_, // [9] <.*
  10,10,10,10,  9,10,10,10, 10,10,10,10, 10,10,10,10, 12,10,10,X_, // [10] <.*"
  11,11,11,11, 11, 9,11,11, 11,11,11,11, 11,11,11,11, 12,11,11,X_, // [11] <.*'
  X_, 2,12,12, 12,12,12,12, 12,12,12,12, 12,12,12,12, 12,12,12,X_, // [12] <.* no " '

// <  >  !  -   "  '  /  S   C  R  I  P   T  Y  L  E  CR NL PL xx
  X_, 2, 9, 9, 10,11, 9, 9, 14, 9, 9, 9, 28, 9, 9, 9,  9, 9, 9,X_, // [13] <S
  X_, 2, 9, 9, 10,11, 9, 9,  9,15, 9, 9,  9, 9, 9, 9,  9, 9, 9,X_, // [14] <SC
  X_, 2, 9, 9, 10,11, 9, 9,  9, 9,16, 9,  9, 9, 9, 9,  9, 9, 9,X_, // [15] <SCR
  X_, 2, 9, 9, 10,11, 9, 9,  9, 9, 9,17,  9, 9, 9, 9,  9, 9, 9,X_, // [16] <SCRI
  X_, 2, 9, 9, 10,11, 9, 9,  9, 9, 9, 9, 18, 9, 9, 9,  9, 9, 9,X_, // [17] <SCRIP
  X_,19, 9, 9, 10,11, 9, 9,  9, 9, 9, 9,  9, 9, 9, 9, 19,19, 9,X_, // [18] <SCRIPT
  20,19,19,19, 19,19,19,19, 19,19,19,19, 19,19,19,19, 19,19,19,X_, // [19] <SCRIPT .*
  19,19,19,19, 19,19,21,19, 19,19,19,19, 19,19,19,19, 19,19,19,X_, // [20] <SCRIPT .*<
  19,19,19,19, 19,19,19,22, 19,19,19,19, 19,19,19,19, 21,21,19,X_, // [21] <SCRIPT .*</ allow SP CR LF
  19,19,19,19, 19,19,19,19, 23,19,19,19, 19,19,19,19, 19,19,19,X_, // [22] <SCRIPT .*</S
  19,19,19,19, 19,19,19,19, 19,24,19,19, 19,19,19,19, 19,19,19,X_, // [23] <SCRIPT .*</SC
  19,19,19,19, 19,19,19,19, 19,19,25,19, 19,19,19,19, 19,19,19,X_, // [24] <SCRIPT .*</SCR
  19,19,19,19, 19,19,19,19, 19,19,19,26, 19,19,19,19, 19,19,19,X_, // [25] <SCRIPT .*</SCRI
  19,19,19,19, 19,19,19,19, 19,19,19,19, 27,19,19,19, 19,19,19,X_, // [26] <SCRIPT .*</SCRIP
  19, 2,19,19, 19,19,19,19, 19,19,19,19, 19,19,19,19, 19,19,19,X_, // [27] <SCRIPT .*</SCRIPT

// <  >  !  -   "  '  /  S   C  R  I  P   T  Y  L  E  CR NL PL xx
  X_, 2, 9, 9, 10,11, 9, 9,  9, 9, 9, 9,  9,29, 9, 9,  9, 9, 9,X_, // [28] <ST
  X_, 2, 9, 9, 10,11, 9, 9,  9, 9, 9, 9,  9, 9,30, 9,  9, 9, 9,X_, // [29] <STY
  X_, 2, 9, 9, 10,11, 9, 9,  9, 9, 9, 9,  9, 9, 9,31,  9, 9, 9,X_, // [30] <STYL
  X_,32, 9, 9, 10,11, 9, 9,  9, 9, 9, 9,  9, 9, 9, 9, 32,32, 9,X_, // [31] <STYLE
  33,32,32,32, 32,32,32,32, 32,32,32,32, 32,32,32,32, 32,32,32,X_, // [32] <STYLE .*
  32,32,32,32, 32,32,34,32, 32,32,32,32, 32,32,32,32, 32,32,32,X_, // [33] <STYLE .*<
  32,32,32,32, 32,32,32,35, 32,32,32,32, 32,32,32,32, 34,34,32,X_, // [34] <STYLE .*</ allow SP CR LF
  32,32,32,32, 32,32,32,32, 32,32,32,32, 36,32,32,32, 32,32,32,X_, // [35] <STYLE .*</S
  32,32,32,32, 32,32,32,32, 32,32,32,32, 32,37,32,32, 32,32,32,X_, // [36] <STYLE .*</ST
  32,32,32,32, 32,32,32,32, 32,32,32,32, 32,32,38,32, 32,32,32,X_, // [37] <STYLE .*</STY
  32,32,32,32, 32,32,32,32, 32,32,32,32, 32,32,32,39, 32,32,32,X_, // [38] <STYLE .*</STYL
  32, 2,32,32, 32,32,32,32, 32,32,32,32, 32,32,32,32, 32,32,32,X_, // [39] <STYLE .*</STYLE
};

#undef OK
#undef X_

enum
{
  UTFmax        = 4,            // maximum bytes per rune
  Runesync      = 0x80,         // cannot represent part of a UTF sequence (<)
  Runeself      = 0x80,         // rune and UTF sequences are the same (<)
  Runeerror     = 0xFFFD,       // decoding error in UTF
  Runemax       = 0x10FFFF,     // maximum rune value
};

// Debugging. Not thread safe.
static char gDisplayPiece[32];
const uint8 gCharlen[16] = {1,1,1,1, 1,1,1,1, 1,1,1,1, 2,2,3,4};
char* DisplayPiece(const char* next_byte_, int byte_length_) {
  // Copy up to 8 UTF-8 chars to buffer
  int k = 0;    // byte count
  int n = 0;    // character count
  for (int i = 0; i < byte_length_; ++i) {
    char c = next_byte_[i];
    if ((c & 0xc0) != 0x80) {
      // Beginning of a UTF-8 character
      int charlen = gCharlen[static_cast<uint8>(c) >> 4];
      if (i + charlen > byte_length_) {break;} // Not enough room for full char
      if (k >= (32 - 7)) {break;}   // Not necessarily enough room
      if (n >= 8) {break;}          // Enough characters already
      ++n;
    }
    if (c == '<') {
      memcpy(&gDisplayPiece[k], "&lt;", 4); k += 4;
    } else if (c == '>') {
      memcpy(&gDisplayPiece[k], "&gt;", 4); k += 4;
    } else if (c == '&') {
      memcpy(&gDisplayPiece[k], "&amp;", 5); k += 5;
    } else if (c == '\'') {
      memcpy(&gDisplayPiece[k], "&apos;", 6); k += 6;
    } else if (c == '"') {
      memcpy(&gDisplayPiece[k], "&quot;", 6); k += 6;
    } else {
      gDisplayPiece[k++] = c;
    }
  }
  gDisplayPiece[k++] = '\0';
  return gDisplayPiece;
}



// runetochar copies (encodes) one rune, pointed to by r, to at most
// UTFmax bytes starting at s and returns the number of bytes generated.
int runetochar(char *str, const char32 *rune) {
  // Convert to unsigned for range check.
  unsigned long c;

  // 1 char 00-7F
  c = *rune;
  if(c <= 0x7F) {
    str[0] = static_cast<char>(c);
    return 1;
  }

  // 2 char 0080-07FF
  if(c <= 0x07FF) {
    str[0] = 0xC0 | static_cast<char>(c >> 1*6);
    str[1] = 0x80 | (c & 0x3F);
    return 2;
  }

  // Range check
  if (c > Runemax) {
    c = Runeerror;
  }

  // 3 char 0800-FFFF
  if (c <= 0xFFFF) {
    str[0] = 0xE0 | static_cast<char>(c >> 2*6);
    str[1] = 0x80 | ((c >> 1*6) & 0x3F);
    str[2] = 0x80 | (c & 0x3F);
    return 3;
  }

  // 4 char 10000-1FFFFF
  str[0] = 0xF0 | static_cast<char>(c >> 3*6);
  str[1] = 0x80 | ((c >> 2*6) & 0x3F);
  str[2] = 0x80 | ((c >> 1*6) & 0x3F);
  str[3] = 0x80 | (c & 0x3F);
  return 4;
}



// Useful for converting an entity to an ascii value.
// RETURNS unicode value, or -1 if entity isn't valid.  Don't include & or ;
int LookupEntity(const char* entity_name, int entity_len) {
  // Make a C string
  if (entity_len >= 16) {return -1;}    // All real entities are shorter
  char temp[16];
  memcpy(temp, entity_name, entity_len);
  temp[entity_len] = '\0';
  int match = BinarySearch(temp, 0, kNameToEntitySize, kNameToEntity);
  if (match >= 0) {return kNameToEntity[match].i;}
  return -1;
}

bool ascii_isdigit(char c) {
  return ('0' <= c) && (c <= '9');
}
bool ascii_isxdigit(char c) {
  if (('0' <= c) && (c <= '9')) {return true;}
  if (('a' <= c) && (c <= 'f')) {return true;}
  if (('A' <= c) && (c <= 'F')) {return true;}
  return false;
}
bool ascii_isalnum(char c) {
  if (('0' <= c) && (c <= '9')) {return true;}
  if (('a' <= c) && (c <= 'z')) {return true;}
  if (('A' <= c) && (c <= 'Z')) {return true;}
  return false;
}
int hex_digit_to_int(char c) {
  if (('0' <= c) && (c <= '9')) {return c - '0';}
  if (('a' <= c) && (c <= 'f')) {return c - 'a' + 10;}
  if (('A' <= c) && (c <= 'F')) {return c - 'A' + 10;}
  return 0;
}

static int32 strto32_base10(const char* nptr, const char* limit,
                            const char **endptr) {
  *endptr = nptr;
  while (nptr < limit && *nptr == '0') {
    ++nptr;
  }
  if (nptr == limit || !ascii_isdigit(*nptr))
    return -1;
  const char* end_digits_run = nptr;
  while (end_digits_run < limit && ascii_isdigit(*end_digits_run)) {
    ++end_digits_run;
  }
  *endptr = end_digits_run;
  const int num_digits = end_digits_run - nptr;
  // kint32max == 2147483647.
  if (num_digits < 9 ||
      (num_digits == 10 && memcmp(nptr, "2147483647", 10) <= 0)) {
    int value = 0;
    for (; nptr < end_digits_run; ++nptr) {
      value *= 10;
      value += *nptr - '0';
    }
    // Overflow past the last valid unicode codepoint
    // (0x10ffff) is converted to U+FFFD by FixUnicodeValue().
    return FixUnicodeValue(value);
  } else {
    // Overflow: can't fit in an int32;
    // returns the replacement character 0xFFFD.
    return 0xFFFD;
  }
}

static int32 strto32_base16(const char* nptr, const char* limit,
                            const char **endptr) {
  *endptr = nptr;
  while (nptr < limit && *nptr == '0') {
    ++nptr;
  }
  if (nptr == limit || !ascii_isxdigit(*nptr)) {
    return -1;
  }
  const char* end_xdigits_run = nptr;
  while (end_xdigits_run < limit && ascii_isxdigit(*end_xdigits_run)) {
    ++end_xdigits_run;
  }
  *endptr = end_xdigits_run;
  const int num_xdigits = end_xdigits_run - nptr;
  // kint32max == 0x7FFFFFFF.
  if (num_xdigits < 8 || (num_xdigits == 8 && nptr[0] < '8')) {
    int value = 0;
    for (; nptr < end_xdigits_run; ++nptr) {
      value <<= 4;
      value += hex_digit_to_int(*nptr);
    }
    // Overflow past the last valid unicode codepoint
    // (0x10ffff) is converted to U+FFFD by FixUnicodeValue().
    return FixUnicodeValue(value);
  } else {
    // Overflow: can't fit in an int32;
    // returns the replacement character 0xFFFD.
    return 0xFFFD;
  }
}

// Unescape the current character pointed to by src.  SETS the number
// of chars read for the conversion (in UTF8).  If src isn't a valid entity,
// just consume the & and RETURN -1.  If src doesn't point to & -- which it
// should -- set src_consumed to 0 and RETURN -1.
int ReadEntity(const char* src, int srcn, int* src_consumed) {
  const char* const srcend = src + srcn;

  if (srcn == 0 || *src != '&') {      // input should start with an ampersand
    *src_consumed = 0;
    return -1;
  }
  *src_consumed = 1;                   // we'll get the & at least

  // The standards are a bit unclear on when an entity ends.  Certainly a ";"
  // ends one, but spaces probably do too.  We follow the lead of both IE and
  // Netscape, which as far as we can tell end numeric entities (1st case below)
  // at any non-digit, and end character entities (2nd case) at any non-alnum.
  const char* entstart, *entend;  // where the entity starts and ends
  entstart = src + 1;             // read past the &
  int entval;                     // UCS2 value of the entity
  if ( *entstart == '#' ) {       // -- 1st case: numeric entity
    if ( entstart + 2 >= srcend ) {
      return -1;                  // no way a legitimate number could fit
    } else if ( entstart[1] == 'x' || entstart[1] == 'X' ) {   // hex numeric
      entval = strto32_base16(entstart + 2, srcend, &entend);
    } else {                                  // decimal numeric entity
      entval = strto32_base10(entstart+1, srcend, &entend);
    }
    if (entval == -1 || entend > srcend) {
      return -1;                 // not entirely correct, but close enough
    }
  } else {                       // -- 2nd case: character entity
    for (entend = entstart;
         entend < srcend && ascii_isalnum(*entend);
         ++entend ) {
      // entity consists of alphanumeric chars
    }
    entval = LookupEntity(entstart, entend - entstart);
    if (entval < 0) {
      return -1;  // not a legal entity name
    }
    // Now we do a strange-seeming IE6-compatibility check: if entval is
    // >= 256, it *must* be followed by a semicolon or it's not considered
    // an entity.  The problem is lots of the newfangled entity names, like
    // "lang", also occur in URL CGI arguments: "/search?q=test&lang=en".
    // When these links are written in HTML, it would be really bad if the
    // "&lang" were treated as an entity, which is what the spec says
    // *should* happen (even when the HTML is inside an "A HREF" tag!)
    // IE ignores the spec for these new, high-value entities, so we do too.
    if ( entval >= 256 && !(entend < srcend && *entend == ';') ) {
      return -1;                 // make non-;-terminated entity illegal
    }
  }

  // Finally, figure out how much src was consumed
  if ( entend < srcend && *entend == ';' ) {
    entend++;                    // standard says ; terminator is special
  }
  *src_consumed = entend - src;
  return entval;
}


// Src points to '&'
// Writes entity value to dst. Returns take(src), put(dst) byte counts
void EntityToBuffer(const char* src, int len, char* dst,
                    int* tlen, int* plen) {
  char32 entval = ReadEntity(src, len, tlen);

  // ReadEntity does this already: entval = FixUnicodeValue(entval);

  // Convert UTF-32 to UTF-8
  if (entval > 0) {
    *plen = runetochar(dst, &entval);
  } else {
    // Illegal entity; ignore the '&'
    *tlen = 1;
    *plen = 0;
  }
}

// Returns true if character is < > or &, none of which are letters
bool inline IsSpecial(char c) {
  // Comparison (int != 0) is used to silence the warning:
  // 'const char': forcing value to bool
  if ((c & 0xe0) == 0x20) {
    return (kSpecialSymbol[static_cast<uint8>(c)] != 0);
  }
  return false;
}

// Quick Skip to next letter or < > & or to end of string (eos)
// Always return is_letter for eos
int ScanToLetterOrSpecial(const char* src, int len) {
  int bytes_consumed;
  StringPiece str(src, len);
  UTF8GenericScan(&utf8scannot_lettermarkspecial_obj, str, &bytes_consumed);
  return bytes_consumed;
}




// src points to non-letter, such as tag-opening '<'
// Return length from here to next possible letter
// On another < before >, return 1
// advances <tag>
//          |    |
// advances <tag> ... </tag>  for <script> <style>
//          |               |
// advances <!-- ... <tag> ... -->
//          |                     |
// advances <tag
//          |    | end of string
// advances <tag <tag2>
//          ||
int ScanToPossibleLetter(const char* isrc, int len, int max_exit_state) {
  const uint8* src = reinterpret_cast<const uint8*>(isrc);
  const uint8* srclimit = src + len;
  const uint8* tagParseTbl = kTagParseTbl_0;
  int e = 0;
  while (src < srclimit) {
    e = tagParseTbl[kCharToSub[*src++]];
    if (e <= max_exit_state) {
      // We overshot by one byte
      --src;
      break;
    }
    tagParseTbl = &kTagParseTbl_0[e * 20];
  }

  if (src >= srclimit) {
    // We fell off the end of the text.
    // It looks like the most common case for this is a truncated file, not
    // mismatched angle brackets. So we pretend that the last char was '>'
    return len;
  }

  // OK to be in state 0 or state 2 at exit
  if ((e != 0) && (e != 2)) {
    // Error, '<' followed by '<'
    // We want to back up to first <, then advance by one byte past it
    int offset = src - reinterpret_cast<const uint8*>(isrc);

    // Backscan to first '<' and return enough length to just get past it
    --offset;   // back up over the second '<', which caused us to stop
    while ((0 < offset) && (isrc[offset] != '<')) {
      // Find the first '<', which is unmatched
      --offset;
    }
    // skip to just beyond first '<'
    return offset + 1;
  }

  return src - reinterpret_cast<const uint8*>(isrc);
}

// Returns mid if key found in lo <= mid < hi, else -1
int BinarySearch(const char* key, int lo, int hi, const CharIntPair* cipair) {
  // binary search
  while (lo < hi) {
    int mid = (lo + hi) >> 1;
    if (strcmp(key, cipair[mid].s) < 0) {
      hi = mid;
    } else if (strcmp(key, cipair[mid].s) > 0) {
      lo = mid + 1;
    } else {
      return mid;
    }
  }
  return -1;
}

// Returns the length in bytes of the prefix of src that is all
//  interchange valid UTF-8
int SpanInterchangeValid(const char* src, int byte_length) {
  int bytes_consumed;
  const UTF8ReplaceObj* st = &utf8acceptinterchange_obj;
  StringPiece str(src, byte_length);
  UTF8GenericScan(st, str, &bytes_consumed);
  return bytes_consumed;
}

ScriptScanner::ScriptScanner(const char* buffer,
                             int buffer_length,
                             bool is_plain_text)
  : start_byte_(buffer),
  next_byte_(buffer),
  byte_length_(buffer_length),
  is_plain_text_(is_plain_text),
  letters_marks_only_(true),
  one_script_only_(true),
  exit_state_(kMaxExitStateLettersMarksOnly) {
    script_buffer_ = new char[kMaxScriptBuffer];
    script_buffer_lower_ = new char[kMaxScriptLowerBuffer];
    map2original_.Clear();    // map from script_buffer_ to buffer
    map2uplow_.Clear();       // map from script_buffer_lower_ to script_buffer_
}

// Extended version to allow spans of any non-tag text and spans of mixed script
ScriptScanner::ScriptScanner(const char* buffer,
                             int buffer_length,
                             bool is_plain_text,
                             bool any_text,
                             bool any_script)
  : start_byte_(buffer),
  next_byte_(buffer),
  byte_length_(buffer_length),
  is_plain_text_(is_plain_text),
  letters_marks_only_(!any_text),
  one_script_only_(!any_script),
  exit_state_(any_text ? kMaxExitStateAllText : kMaxExitStateLettersMarksOnly) {
    script_buffer_ = new char[kMaxScriptBuffer];
    script_buffer_lower_ = new char[kMaxScriptLowerBuffer];
    map2original_.Clear();    // map from script_buffer_ to buffer
    map2uplow_.Clear();       // map from script_buffer_lower_ to script_buffer_
}


ScriptScanner::~ScriptScanner() {
  delete[] script_buffer_;
  delete[] script_buffer_lower_;
}




// Get to the first real non-tag letter or entity that is a letter
// Sets script of that letter
// Return len if no more letters
int ScriptScanner::SkipToFrontOfSpan(const char* src, int len, int* script) {
  int sc = UNKNOWN_ULSCRIPT;
  int skip = 0;
  int tlen, plen;

  // Do run of non-letters (tag | &NL | NL)*
  tlen = 0;
  while (skip < len) {
    // Do fast scan to next interesting byte
    // int oldskip = skip;
    skip += ScanToLetterOrSpecial(src + skip, len - skip);

    // Check for no more letters/specials
    if (skip >= len) {
      // All done
      *script = sc;
      return len;
    }

    // We are at a letter, nonletter, tag, or entity
    if (IsSpecial(src[skip]) && !is_plain_text_) {
      if (src[skip] == '<') {
        // Begining of tag; skip to end and go around again
        tlen = ScanToPossibleLetter(src + skip, len - skip,
                                    exit_state_);
        sc = 0;
      } else if (src[skip] == '>') {
        // Unexpected end of tag; skip it and go around again
        tlen = 1;         // Over the >
        sc = 0;
      } else if (src[skip] == '&') {
        // Expand entity, no advance
        char temp[4];
        EntityToBuffer(src + skip, len - skip,
                       temp, &tlen, &plen);
        if (plen > 0) {
          sc = GetUTF8LetterScriptNum(temp);
        }
      }
    } else {
      // Update 1..4 bytes
      tlen = UTF8OneCharLen(src + skip);
      sc = GetUTF8LetterScriptNum(src + skip);
    }
    if (sc != 0) {break;}           // Letter found
    skip += tlen;                   // Else advance
  }

  *script = sc;
  return skip;
}


// These are for ASCII-only tag names
// Compare one letter uplow to c, ignoring case of uplowp
inline bool EqCase(char uplow, char c) {
  return (uplow | 0x20) == c;
}

// These are for ASCII-only tag names
// Return true for space / < > etc. all less than 0x40
inline bool NeqLetter(char c) {
  return c < 0x40;
}

// These are for ASCII-only tag names
// Return true for space \n false for \r
inline bool WS(char c) {
  return (c == ' ') || (c == '\n');
}

// Canonical CR or LF
static const char LF = '\n';


// The naive loop scans from next_byte_ to script_buffer_ until full.
// But this can leave an awkward hard-to-identify short fragment at the
// end of the input. We would prefer to make the next-to-last fragment
// shorter and the last fragment longer.

// Copy next run of non-tag characters to buffer [NUL terminated]
// This just replaces tags with space or \n and removes entities.
// Tags <br> <p> and <tr> are replaced with \n. Non-letter sequences
// including \r or \n are replaced by \n. All other tags and skipped text
// are replaced with ASCII space.
//
// Buffer ALWAYS has leading space and trailing space space space NUL
bool ScriptScanner::GetOneTextSpan(LangSpan* span) {
  span->text = script_buffer_;
  span->text_bytes = 0;
  span->offset = next_byte_ - start_byte_;
  span->ulscript = UNKNOWN_ULSCRIPT;
  span->truncated = false;

  int put_soft_limit = kMaxScriptBytes - kWithinScriptTail;
  if ((kMaxScriptBytes <= byte_length_) &&
      (byte_length_ < (2 * kMaxScriptBytes))) {
    // Try to split the last two fragments in half
    put_soft_limit = byte_length_ / 2;
  }

  script_buffer_[0] = ' ';  // Always a space at front of output
  script_buffer_[1] = '\0';
  int take = 0;
  int put = 1;              // Start after the initial space
  int tlen = 0, plen = 0;

  if (byte_length_ <= 0) {
    return false;          // No more text to be found
  }

  // Go over alternating spans of text and tags,
  // copying letters to buffer with single spaces for each run of non-letters
  bool last_byte_was_space = false;
  while (take < byte_length_) {
    char c = next_byte_[take];
    if (c == '\r') {c = LF;}      // Canonical CR or LF
    if (c == '\n') {c = LF;}      // Canonical CR or LF

    if (IsSpecial(c) && !is_plain_text_) {
      if (c == '<') {
        // Replace tag with space
        c = ' ';                      // for almost-full test below
        // or if <p> <br> <tr>, replace with \n
        if (take < (byte_length_ - 3)) {
          if (EqCase(next_byte_[take + 1], 'p') &&
              NeqLetter(next_byte_[take + 2])) {
            c = LF;
          }
          if (EqCase(next_byte_[take + 1], 'b') &&
              EqCase(next_byte_[take + 2], 'r') &&
              NeqLetter(next_byte_[take + 3])) {
            c = LF;
          }
          if (EqCase(next_byte_[take + 1], 't') &&
              EqCase(next_byte_[take + 2], 'r') &&
              NeqLetter(next_byte_[take + 3])) {
            c = LF;
          }
        }
        // Begining of tag; skip to end and go around again
        tlen = 1 + ScanToPossibleLetter(next_byte_ + take, byte_length_ - take,
                                    exit_state_);
        // Copy one byte, compressing spaces
        if (!last_byte_was_space || !WS(c)) {
          script_buffer_[put++] = c;      // Advance dest
          last_byte_was_space = WS(c);
        }
      } else if (c == '>') {
        // Unexpected end of tag; copy it and go around again
        tlen = 1;         // Over the >
        script_buffer_[put++] = c;    // Advance dest
      } else if (c == '&') {
        // Expand entity, no advance
        EntityToBuffer(next_byte_ + take, byte_length_ - take,
                       script_buffer_ + put, &tlen, &plen);
        put += plen;                  // Advance dest
      }
      take += tlen;                   // Advance source
    } else {
      // Copy one byte, compressing spaces
      if (!last_byte_was_space || !WS(c)) {
        script_buffer_[put++] = c;      // Advance dest
        last_byte_was_space = WS(c);
      }
      ++take;                         // Advance source
    }

    if (WS(c) &&
        (put >= put_soft_limit)) {
      // Buffer is almost full
      span->truncated = true;
      break;
    }
    if (put >= kMaxScriptBytes) {
      // Buffer is completely full
      span->truncated = true;
      break;
    }
  }

  // Almost done. Back up to a character boundary if needed
  while ((0 < take) && ((next_byte_[take] & 0xc0) == 0x80)) {
    // Back up over continuation byte
    --take;
    --put;
  }

  // Update input position
  next_byte_ += take;
  byte_length_ -= take;

  // Put four more spaces/NUL. Worst case is abcd _ _ _ \0
  //                          kMaxScriptBytes |   | put
  script_buffer_[put + 0] = ' ';
  script_buffer_[put + 1] = ' ';
  script_buffer_[put + 2] = ' ';
  script_buffer_[put + 3] = '\0';

  span->text_bytes = put;       // Does not include the last four chars above
  return true;
}


// Copy next run of same-script non-tag letters to buffer [NUL terminated]
// Buffer ALWAYS has leading space and trailing space space space NUL
bool ScriptScanner::GetOneScriptSpan(LangSpan* span) {
  if (!letters_marks_only_) {
    // Return non-tag text, including punctuation and digits
    return GetOneTextSpan(span);
  }

  span->text = script_buffer_;
  span->text_bytes = 0;
  span->offset = next_byte_ - start_byte_;
  span->ulscript = UNKNOWN_ULSCRIPT;
  span->truncated = false;

  // struct timeval script_start, script_mid, script_end;

  int put_soft_limit = kMaxScriptBytes - kWithinScriptTail;
  if ((kMaxScriptBytes <= byte_length_) &&
      (byte_length_ < (2 * kMaxScriptBytes))) {
    // Try to split the last two fragments in half
    put_soft_limit = byte_length_ / 2;
  }


  int spanscript;           // The script of this span
  int sc = UNKNOWN_ULSCRIPT;  // The script of next character
  int tlen = 0;
  int plen = 0;

  script_buffer_[0] = ' ';  // Always a space at front of output
  script_buffer_[1] = '\0';
  int take = 0;
  int put = 1;              // Start after the initial space

  // Build offsets from span->text back to start_byte_ + span->offset
  // This mapping reflects deletion of non-letters, expansion of
  // entities, etc.
  map2original_.Clear();
  map2original_.Delete(span->offset);   // So that MapBack(0) gives offset

  // Get to the first real non-tag letter or entity that is a letter
  int skip = SkipToFrontOfSpan(next_byte_, byte_length_, &spanscript);
  next_byte_ += skip;
  byte_length_ -= skip;

  if (skip != 1) {
    map2original_.Delete(skip);
    map2original_.Insert(1);
  } else {
    map2original_.Copy(1);
  }
  if (byte_length_ <= 0) {
    map2original_.Reset();
    return false;               // No more letters to be found
  }

  // There is at least one letter, so we know the script for this span
  span->ulscript = (ULScript)spanscript;


  // Go over alternating spans of same-script letters and non-letters,
  // copying letters to buffer with single spaces for each run of non-letters
  while (take < byte_length_) {
    // Copy run of letters in same script (&LS | LS)*
    int letter_count = 0;              // Keep track of word length
    bool need_break = false;

    while (take < byte_length_) {
      // We are at a letter, nonletter, tag, or entity
      if (IsSpecial(next_byte_[take]) && !is_plain_text_) {
        if (next_byte_[take] == '<') {
          // Begining of tag
          sc = 0;
          break;
        } else if (next_byte_[take] == '>') {
          // Unexpected end of tag
          sc = 0;
          break;
        } else if (next_byte_[take] == '&') {
          // Copy entity, no advance
          EntityToBuffer(next_byte_ + take, byte_length_ - take,
                         script_buffer_ + put, &tlen, &plen);
          if (plen > 0) {
            sc = GetUTF8LetterScriptNum(script_buffer_ + put);
          }
        }
      } else {
        // Real letter, safely copy up to 4 bytes, increment by 1..4
        // Will update by 1..4 bytes at Advance, below
        tlen = plen = UTF8OneCharLen(next_byte_ + take);
        if (take < (byte_length_ - 3)) {
          // X86 fast case, does unaligned load/store
          UNALIGNED_STORE32(script_buffer_ + put,
                            UNALIGNED_LOAD32(next_byte_ + take));

        } else {
          // Slow case, happens 1-3 times per input document
          memcpy(script_buffer_ + put, next_byte_ + take, plen);
        }
        sc = GetUTF8LetterScriptNum(next_byte_ + take);
      }

      // Allow continue across a single letter in a different script:
      // A B D = three scripts, c = common script, i = inherited script,
      // - = don't care, ( = take position before the += below
      //  AAA(A-    continue
      //
      //  AAA(BA    continue
      //  AAA(BB    break
      //  AAA(Bc    continue (breaks after B)
      //  AAA(BD    break
      //  AAA(Bi    break
      //
      //  AAA(c-    break
      //
      //  AAA(i-    continue
      //

      if ((sc != spanscript) && (sc != ULScript_Inherited)) {
        // Might need to break this script span
        if (sc == ULScript_Common) {
          need_break = true;
        } else {
          // Look at next following character, ignoring entity as Common
          int sc2 = GetUTF8LetterScriptNum(next_byte_ + take + tlen);
          if ((sc2 != ULScript_Common) && (sc2 != spanscript)) {
            // We found a non-trivial change of script
            if (one_script_only_) {
              need_break = true;
            }
          }
        }
      }
      if (need_break) {break;}  // Non-letter or letter in wrong script

      take += tlen;                   // Advance
      put += plen;                    // Advance

      // Update the offset map to reflect take/put lengths
      if (tlen == plen) {
        map2original_.Copy(tlen);
      } else if (tlen < plen) {
        map2original_.Copy(tlen);
        map2original_.Insert(plen - tlen);
      } else {    // plen < tlen
        map2original_.Copy(plen);
        map2original_.Delete(tlen - plen);
      }

      ++letter_count;
      if (put >= kMaxScriptBytes) {
        // Buffer is full
        span->truncated = true;
        break;
      }
    }     // End while letters

    // Do run of non-letters (tag | &NL | NL)*
    while (take < byte_length_) {
      // Do fast scan to next interesting byte
      tlen = ScanToLetterOrSpecial(next_byte_ + take, byte_length_ - take);
      take += tlen;
      map2original_.Delete(tlen);
      if (take >= byte_length_) {break;}    // Might have scanned to end

      // We are at a letter, nonletter, tag, or entity
      if (IsSpecial(next_byte_[take]) && !is_plain_text_) {
        if (next_byte_[take] == '<') {
          // Begining of tag; skip to end and go around again
          tlen = ScanToPossibleLetter(next_byte_ + take, byte_length_ - take,
                                      exit_state_);
          sc = 0;
        } else if (next_byte_[take] == '>') {
          // Unexpected end of tag; skip it and go around again
          tlen = 1;         // Over the >
          sc = 0;
        } else if (next_byte_[take] == '&') {
          // Expand entity, no advance
          EntityToBuffer(next_byte_ + take, byte_length_ - take,
                         script_buffer_ + put, &tlen, &plen);
          if (plen > 0) {
            sc = GetUTF8LetterScriptNum(script_buffer_ + put);
          }
        }
      } else {
        // Update 1..4
        tlen = UTF8OneCharLen(next_byte_ + take);
        sc = GetUTF8LetterScriptNum(next_byte_ + take);
      }
      if (sc != 0) {break;}           // Letter found
      take += tlen;                   // Else advance
      map2original_.Delete(tlen);
    }     // End while not-letters

    script_buffer_[put++] = ' ';
    map2original_.Insert(1);

    // Letter in wrong script ?
    if ((sc != spanscript) && (sc != ULScript_Inherited)) {break;}
    if (put >= put_soft_limit) {
      // Buffer is almost full
      span->truncated = true;
      break;
    }
  }

  // Almost done. Back up to a character boundary if needed
  while ((0 < take) && (take < byte_length_) &&
         ((next_byte_[take] & 0xc0) == 0x80)) {
    // Back up over continuation byte
    --take;
    --put;
  }

  // Update input position
  next_byte_ += take;
  byte_length_ -= take;

  // Put four more spaces/NUL. Worst case is abcd _ _ _ \0
  //                          kMaxScriptBytes |   | put
  script_buffer_[put + 0] = ' ';
  script_buffer_[put + 1] = ' ';
  script_buffer_[put + 2] = ' ';
  script_buffer_[put + 3] = '\0';
  map2original_.Insert(4);
  map2original_.Reset();

  span->text_bytes = put;       // Does not include the last four chars above
  return true;
}

// Force Latin, Cyrillic, Armenian, Greek scripts to be lowercase
// List changes with each version of Unicode, so just always lowercase
// Unicode 6.2.0:
//   ARMENIAN COPTIC CYRILLIC DESERET GEORGIAN GLAGOLITIC GREEK LATIN
void ScriptScanner::LowerScriptSpan(LangSpan* span) {
  // If needed, lowercase all the text. If we do it sooner, might miss
  // lowercasing an entity such as &Aacute;
  // We only need to do this for Latn and Cyrl scripts
  map2uplow_.Clear();
  // Full Unicode lowercase of the entire buffer, including
  // four pad bytes off the end.
  // Ahhh. But the last byte 0x00 is not interchange-valid, so we do 3 pad
  // bytes and put the 0x00 in explicitly.
  // Build an offset map from script_buffer_lower_ back to script_buffer_
  int consumed, filled, changed;
  StringPiece istr(span->text, span->text_bytes + 3);
  StringPiece ostr(script_buffer_lower_, kMaxScriptLowerBuffer);

  UTF8GenericReplace(&utf8repl_lettermarklower_obj,
                            istr, ostr, is_plain_text_,
                            &consumed, &filled, &changed, &map2uplow_);
  script_buffer_lower_[filled] = '\0';
  span->text = script_buffer_lower_;
  span->text_bytes = filled - 3;
  map2uplow_.Reset();
}

// Copy next run of same-script non-tag letters to buffer [NUL terminated]
// Force Latin, Cyrillic, Greek scripts to be lowercase
// Buffer ALWAYS has leading space and trailing space space space NUL
bool ScriptScanner::GetOneScriptSpanLower(LangSpan* span) {
  bool ok = GetOneScriptSpan(span);
  if (ok) {
    LowerScriptSpan(span);
  }
  return ok;
}

// Maps byte offset in most recent GetOneScriptSpan/Lower
// span->text [0..text_bytes] into an additional byte offset from
// span->offset, to get back to corresponding text in the original
// input buffer.
// text_offset must be the first byte
// of a UTF-8 character, or just beyond the last character. Normally this
// routine is called with the first byte of an interesting range and
// again with the first byte of the following range.
int ScriptScanner::MapBack(int text_offset) {
  return map2original_.MapBack(map2uplow_.MapBack(text_offset));
}


// Gets lscript number for letters; always returns
//   0 (common script) for non-letters
int GetUTF8LetterScriptNum(const char* src) {
  int srclen = UTF8OneCharLen(src);
  const uint8* usrc = reinterpret_cast<const uint8*>(src);
  return UTF8GenericPropertyTwoByte(&utf8prop_lettermarkscriptnum_obj,
                                    &usrc, &srclen);
}

}  // namespace CLD2
}  // namespace chrome_lang_id
