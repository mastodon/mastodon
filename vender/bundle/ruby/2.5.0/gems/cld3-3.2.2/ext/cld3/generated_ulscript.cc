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

// generated_ulscript.cc
// Machine generated. Do Not Edit.
//
// Declarations for scripts recognized by CLD2
//

#include "generated_ulscript.h"

namespace chrome_lang_id {
namespace CLD2 {

// Subscripted by enum ULScript
extern const int kULScriptToNameSize = 102;
extern const char* const kULScriptToName[kULScriptToNameSize] = {
  "Common",                // 0 Zyyy
  "Latin",                 // 1 Latn
  "Greek",                 // 2 Grek
  "Cyrillic",              // 3 Cyrl
  "Armenian",              // 4 Armn
  "Hebrew",                // 5 Hebr
  "Arabic",                // 6 Arab
  "Syriac",                // 7 Syrc
  "Thaana",                // 8 Thaa
  "Devanagari",            // 9 Deva
  "Bengali",               // 10 Beng
  "Gurmukhi",              // 11 Guru
  "Gujarati",              // 12 Gujr
  "Oriya",                 // 13 Orya
  "Tamil",                 // 14 Taml
  "Telugu",                // 15 Telu
  "Kannada",               // 16 Knda
  "Malayalam",             // 17 Mlym
  "Sinhala",               // 18 Sinh
  "Thai",                  // 19 Thai
  "Lao",                   // 20 Laoo
  "Tibetan",               // 21 Tibt
  "Myanmar",               // 22 Mymr
  "Georgian",              // 23 Geor
  "Hani",                  // 24 Hani
  "Ethiopic",              // 25 Ethi
  "Cherokee",              // 26 Cher
  "Canadian_Aboriginal",   // 27 Cans
  "Ogham",                 // 28 Ogam
  "Runic",                 // 29 Runr
  "Khmer",                 // 30 Khmr
  "Mongolian",             // 31 Mong
  "",                      // 32
  "",                      // 33
  "Bopomofo",              // 34 Bopo
  "",                      // 35
  "Yi",                    // 36 Yiii
  "Old_Italic",            // 37 Ital
  "Gothic",                // 38 Goth
  "Deseret",               // 39 Dsrt
  "Inherited",             // 40 Zinh
  "Tagalog",               // 41 Tglg
  "Hanunoo",               // 42 Hano
  "Buhid",                 // 43 Buhd
  "Tagbanwa",              // 44 Tagb
  "Limbu",                 // 45 Limb
  "Tai_Le",                // 46 Tale
  "Linear_B",              // 47 Linb
  "Ugaritic",              // 48 Ugar
  "Shavian",               // 49 Shaw
  "Osmanya",               // 50 Osma
  "Cypriot",               // 51 Cprt
  "Braille",               // 52 Brai
  "Buginese",              // 53 Bugi
  "Coptic",                // 54 Copt
  "New_Tai_Lue",           // 55 Talu
  "Glagolitic",            // 56 Glag
  "Tifinagh",              // 57 Tfng
  "Syloti_Nagri",          // 58 Sylo
  "Old_Persian",           // 59 Xpeo
  "Kharoshthi",            // 60 Khar
  "Balinese",              // 61 Bali
  "Cuneiform",             // 62 Xsux
  "Phoenician",            // 63 Phnx
  "Phags_Pa",              // 64 Phag
  "Nko",                   // 65 Nkoo
  "Sundanese",             // 66 Sund
  "Lepcha",                // 67 Lepc
  "Ol_Chiki",              // 68 Olck
  "Vai",                   // 69 Vaii
  "Saurashtra",            // 70 Saur
  "Kayah_Li",              // 71 Kali
  "Rejang",                // 72 Rjng
  "Lycian",                // 73 Lyci
  "Carian",                // 74 Cari
  "Lydian",                // 75 Lydi
  "Cham",                  // 76 Cham
  "Tai_Tham",              // 77 Lana
  "Tai_Viet",              // 78 Tavt
  "Avestan",               // 79 Avst
  "Egyptian_Hieroglyphs",  // 80 Egyp
  "Samaritan",             // 81 Samr
  "Lisu",                  // 82 Lisu
  "Bamum",                 // 83 Bamu
  "Javanese",              // 84 Java
  "Meetei_Mayek",          // 85 Mtei
  "Imperial_Aramaic",      // 86 Armi
  "Old_South_Arabian",     // 87 Sarb
  "Inscriptional_Parthian",  // 88 Prti
  "Inscriptional_Pahlavi",  // 89 Phli
  "Old_Turkic",            // 90 Orkh
  "Kaithi",                // 91 Kthi
  "Batak",                 // 92 Batk
  "Brahmi",                // 93 Brah
  "Mandaic",               // 94 Mand
  "Chakma",                // 95 Cakm
  "Meroitic_Cursive",      // 96 Merc
  "Meroitic_Hieroglyphs",  // 97 Mero
  "Miao",                  // 98 Plrd
  "Sharada",               // 99 Shrd
  "Sora_Sompeng",          // 100 Sora
  "Takri",                 // 101 Takr
};

// Subscripted by enum ULScript
extern const int kULScriptToCodeSize = 102;
extern const char* const kULScriptToCode[kULScriptToCodeSize] = {
  "Zyyy",  // 0 Common
  "Latn",  // 1 Latin
  "Grek",  // 2 Greek
  "Cyrl",  // 3 Cyrillic
  "Armn",  // 4 Armenian
  "Hebr",  // 5 Hebrew
  "Arab",  // 6 Arabic
  "Syrc",  // 7 Syriac
  "Thaa",  // 8 Thaana
  "Deva",  // 9 Devanagari
  "Beng",  // 10 Bengali
  "Guru",  // 11 Gurmukhi
  "Gujr",  // 12 Gujarati
  "Orya",  // 13 Oriya
  "Taml",  // 14 Tamil
  "Telu",  // 15 Telugu
  "Knda",  // 16 Kannada
  "Mlym",  // 17 Malayalam
  "Sinh",  // 18 Sinhala
  "Thai",  // 19 Thai
  "Laoo",  // 20 Lao
  "Tibt",  // 21 Tibetan
  "Mymr",  // 22 Myanmar
  "Geor",  // 23 Georgian
  "Hani",  // 24 Hani
  "Ethi",  // 25 Ethiopic
  "Cher",  // 26 Cherokee
  "Cans",  // 27 Canadian_Aboriginal
  "Ogam",  // 28 Ogham
  "Runr",  // 29 Runic
  "Khmr",  // 30 Khmer
  "Mong",  // 31 Mongolian
  "",      // 32
  "",      // 33
  "Bopo",  // 34 Bopomofo
  "",      // 35
  "Yiii",  // 36 Yi
  "Ital",  // 37 Old_Italic
  "Goth",  // 38 Gothic
  "Dsrt",  // 39 Deseret
  "Zinh",  // 40 Inherited
  "Tglg",  // 41 Tagalog
  "Hano",  // 42 Hanunoo
  "Buhd",  // 43 Buhid
  "Tagb",  // 44 Tagbanwa
  "Limb",  // 45 Limbu
  "Tale",  // 46 Tai_Le
  "Linb",  // 47 Linear_B
  "Ugar",  // 48 Ugaritic
  "Shaw",  // 49 Shavian
  "Osma",  // 50 Osmanya
  "Cprt",  // 51 Cypriot
  "Brai",  // 52 Braille
  "Bugi",  // 53 Buginese
  "Copt",  // 54 Coptic
  "Talu",  // 55 New_Tai_Lue
  "Glag",  // 56 Glagolitic
  "Tfng",  // 57 Tifinagh
  "Sylo",  // 58 Syloti_Nagri
  "Xpeo",  // 59 Old_Persian
  "Khar",  // 60 Kharoshthi
  "Bali",  // 61 Balinese
  "Xsux",  // 62 Cuneiform
  "Phnx",  // 63 Phoenician
  "Phag",  // 64 Phags_Pa
  "Nkoo",  // 65 Nko
  "Sund",  // 66 Sundanese
  "Lepc",  // 67 Lepcha
  "Olck",  // 68 Ol_Chiki
  "Vaii",  // 69 Vai
  "Saur",  // 70 Saurashtra
  "Kali",  // 71 Kayah_Li
  "Rjng",  // 72 Rejang
  "Lyci",  // 73 Lycian
  "Cari",  // 74 Carian
  "Lydi",  // 75 Lydian
  "Cham",  // 76 Cham
  "Lana",  // 77 Tai_Tham
  "Tavt",  // 78 Tai_Viet
  "Avst",  // 79 Avestan
  "Egyp",  // 80 Egyptian_Hieroglyphs
  "Samr",  // 81 Samaritan
  "Lisu",  // 82 Lisu
  "Bamu",  // 83 Bamum
  "Java",  // 84 Javanese
  "Mtei",  // 85 Meetei_Mayek
  "Armi",  // 86 Imperial_Aramaic
  "Sarb",  // 87 Old_South_Arabian
  "Prti",  // 88 Inscriptional_Parthian
  "Phli",  // 89 Inscriptional_Pahlavi
  "Orkh",  // 90 Old_Turkic
  "Kthi",  // 91 Kaithi
  "Batk",  // 92 Batak
  "Brah",  // 93 Brahmi
  "Mand",  // 94 Mandaic
  "Cakm",  // 95 Chakma
  "Merc",  // 96 Meroitic_Cursive
  "Mero",  // 97 Meroitic_Hieroglyphs
  "Plrd",  // 98 Miao
  "Shrd",  // 99 Sharada
  "Sora",  // 100 Sora_Sompeng
  "Takr",  // 101 Takri
};

// Subscripted by enum ULScript
extern const int kULScriptToCNameSize = 102;
extern const char* const kULScriptToCName[kULScriptToCNameSize] = {
  "ULScript_Common",       // 0 Zyyy
  "ULScript_Latin",        // 1 Latn
  "ULScript_Greek",        // 2 Grek
  "ULScript_Cyrillic",     // 3 Cyrl
  "ULScript_Armenian",     // 4 Armn
  "ULScript_Hebrew",       // 5 Hebr
  "ULScript_Arabic",       // 6 Arab
  "ULScript_Syriac",       // 7 Syrc
  "ULScript_Thaana",       // 8 Thaa
  "ULScript_Devanagari",   // 9 Deva
  "ULScript_Bengali",      // 10 Beng
  "ULScript_Gurmukhi",     // 11 Guru
  "ULScript_Gujarati",     // 12 Gujr
  "ULScript_Oriya",        // 13 Orya
  "ULScript_Tamil",        // 14 Taml
  "ULScript_Telugu",       // 15 Telu
  "ULScript_Kannada",      // 16 Knda
  "ULScript_Malayalam",    // 17 Mlym
  "ULScript_Sinhala",      // 18 Sinh
  "ULScript_Thai",         // 19 Thai
  "ULScript_Lao",          // 20 Laoo
  "ULScript_Tibetan",      // 21 Tibt
  "ULScript_Myanmar",      // 22 Mymr
  "ULScript_Georgian",     // 23 Geor
  "ULScript_Hani",         // 24 Hani
  "ULScript_Ethiopic",     // 25 Ethi
  "ULScript_Cherokee",     // 26 Cher
  "ULScript_Canadian_Aboriginal",  // 27 Cans
  "ULScript_Ogham",        // 28 Ogam
  "ULScript_Runic",        // 29 Runr
  "ULScript_Khmer",        // 30 Khmr
  "ULScript_Mongolian",    // 31 Mong
  "ULScript_32",           // 32
  "ULScript_33",           // 33
  "ULScript_Bopomofo",     // 34 Bopo
  "ULScript_35",           // 35
  "ULScript_Yi",           // 36 Yiii
  "ULScript_Old_Italic",   // 37 Ital
  "ULScript_Gothic",       // 38 Goth
  "ULScript_Deseret",      // 39 Dsrt
  "ULScript_Inherited",    // 40 Zinh
  "ULScript_Tagalog",      // 41 Tglg
  "ULScript_Hanunoo",      // 42 Hano
  "ULScript_Buhid",        // 43 Buhd
  "ULScript_Tagbanwa",     // 44 Tagb
  "ULScript_Limbu",        // 45 Limb
  "ULScript_Tai_Le",       // 46 Tale
  "ULScript_Linear_B",     // 47 Linb
  "ULScript_Ugaritic",     // 48 Ugar
  "ULScript_Shavian",      // 49 Shaw
  "ULScript_Osmanya",      // 50 Osma
  "ULScript_Cypriot",      // 51 Cprt
  "ULScript_Braille",      // 52 Brai
  "ULScript_Buginese",     // 53 Bugi
  "ULScript_Coptic",       // 54 Copt
  "ULScript_New_Tai_Lue",  // 55 Talu
  "ULScript_Glagolitic",   // 56 Glag
  "ULScript_Tifinagh",     // 57 Tfng
  "ULScript_Syloti_Nagri",  // 58 Sylo
  "ULScript_Old_Persian",  // 59 Xpeo
  "ULScript_Kharoshthi",   // 60 Khar
  "ULScript_Balinese",     // 61 Bali
  "ULScript_Cuneiform",    // 62 Xsux
  "ULScript_Phoenician",   // 63 Phnx
  "ULScript_Phags_Pa",     // 64 Phag
  "ULScript_Nko",          // 65 Nkoo
  "ULScript_Sundanese",    // 66 Sund
  "ULScript_Lepcha",       // 67 Lepc
  "ULScript_Ol_Chiki",     // 68 Olck
  "ULScript_Vai",          // 69 Vaii
  "ULScript_Saurashtra",   // 70 Saur
  "ULScript_Kayah_Li",     // 71 Kali
  "ULScript_Rejang",       // 72 Rjng
  "ULScript_Lycian",       // 73 Lyci
  "ULScript_Carian",       // 74 Cari
  "ULScript_Lydian",       // 75 Lydi
  "ULScript_Cham",         // 76 Cham
  "ULScript_Tai_Tham",     // 77 Lana
  "ULScript_Tai_Viet",     // 78 Tavt
  "ULScript_Avestan",      // 79 Avst
  "ULScript_Egyptian_Hieroglyphs",  // 80 Egyp
  "ULScript_Samaritan",    // 81 Samr
  "ULScript_Lisu",         // 82 Lisu
  "ULScript_Bamum",        // 83 Bamu
  "ULScript_Javanese",     // 84 Java
  "ULScript_Meetei_Mayek",  // 85 Mtei
  "ULScript_Imperial_Aramaic",  // 86 Armi
  "ULScript_Old_South_Arabian",  // 87 Sarb
  "ULScript_Inscriptional_Parthian",  // 88 Prti
  "ULScript_Inscriptional_Pahlavi",  // 89 Phli
  "ULScript_Old_Turkic",   // 90 Orkh
  "ULScript_Kaithi",       // 91 Kthi
  "ULScript_Batak",        // 92 Batk
  "ULScript_Brahmi",       // 93 Brah
  "ULScript_Mandaic",      // 94 Mand
  "ULScript_Chakma",       // 95 Cakm
  "ULScript_Meroitic_Cursive",  // 96 Merc
  "ULScript_Meroitic_Hieroglyphs",  // 97 Mero
  "ULScript_Miao",         // 98 Plrd
  "ULScript_Sharada",      // 99 Shrd
  "ULScript_Sora_Sompeng",  // 100 Sora
  "ULScript_Takri",        // 101 Takr
};

// Subscripted by enum ULScript
extern const int kULScriptToRtypeSize = 102;
extern const ULScriptRType kULScriptToRtype[kULScriptToRtypeSize] = {
  RTypeNone,   // 0 Zyyy
  RTypeMany,   // 1 Latn
  RTypeOne,    // 2 Grek
  RTypeMany,   // 3 Cyrl
  RTypeOne,    // 4 Armn
  RTypeMany,   // 5 Hebr
  RTypeMany,   // 6 Arab
  RTypeOne,    // 7 Syrc
  RTypeOne,    // 8 Thaa
  RTypeMany,   // 9 Deva
  RTypeMany,   // 10 Beng
  RTypeOne,    // 11 Guru
  RTypeOne,    // 12 Gujr
  RTypeOne,    // 13 Orya
  RTypeOne,    // 14 Taml
  RTypeOne,    // 15 Telu
  RTypeOne,    // 16 Knda
  RTypeOne,    // 17 Mlym
  RTypeOne,    // 18 Sinh
  RTypeOne,    // 19 Thai
  RTypeOne,    // 20 Laoo
  RTypeMany,   // 21 Tibt
  RTypeOne,    // 22 Mymr
  RTypeOne,    // 23 Geor
  RTypeCJK,    // 24 Hani
  RTypeMany,   // 25 Ethi
  RTypeOne,    // 26 Cher
  RTypeOne,    // 27 Cans
  RTypeNone,   // 28 Ogam
  RTypeNone,   // 29 Runr
  RTypeOne,    // 30 Khmr
  RTypeOne,    // 31 Mong
  RTypeNone,   // 32
  RTypeNone,   // 33
  RTypeNone,   // 34 Bopo
  RTypeNone,   // 35
  RTypeNone,   // 36 Yiii
  RTypeNone,   // 37 Ital
  RTypeNone,   // 38 Goth
  RTypeNone,   // 39 Dsrt
  RTypeNone,   // 40 Zinh
  RTypeOne,    // 41 Tglg
  RTypeNone,   // 42 Hano
  RTypeNone,   // 43 Buhd
  RTypeNone,   // 44 Tagb
  RTypeOne,    // 45 Limb
  RTypeNone,   // 46 Tale
  RTypeNone,   // 47 Linb
  RTypeNone,   // 48 Ugar
  RTypeNone,   // 49 Shaw
  RTypeNone,   // 50 Osma
  RTypeNone,   // 51 Cprt
  RTypeNone,   // 52 Brai
  RTypeNone,   // 53 Bugi
  RTypeNone,   // 54 Copt
  RTypeNone,   // 55 Talu
  RTypeNone,   // 56 Glag
  RTypeNone,   // 57 Tfng
  RTypeNone,   // 58 Sylo
  RTypeNone,   // 59 Xpeo
  RTypeNone,   // 60 Khar
  RTypeNone,   // 61 Bali
  RTypeNone,   // 62 Xsux
  RTypeNone,   // 63 Phnx
  RTypeNone,   // 64 Phag
  RTypeNone,   // 65 Nkoo
  RTypeNone,   // 66 Sund
  RTypeNone,   // 67 Lepc
  RTypeNone,   // 68 Olck
  RTypeNone,   // 69 Vaii
  RTypeNone,   // 70 Saur
  RTypeNone,   // 71 Kali
  RTypeNone,   // 72 Rjng
  RTypeNone,   // 73 Lyci
  RTypeNone,   // 74 Cari
  RTypeNone,   // 75 Lydi
  RTypeNone,   // 76 Cham
  RTypeNone,   // 77 Lana
  RTypeNone,   // 78 Tavt
  RTypeNone,   // 79 Avst
  RTypeNone,   // 80 Egyp
  RTypeNone,   // 81 Samr
  RTypeNone,   // 82 Lisu
  RTypeNone,   // 83 Bamu
  RTypeNone,   // 84 Java
  RTypeNone,   // 85 Mtei
  RTypeNone,   // 86 Armi
  RTypeNone,   // 87 Sarb
  RTypeNone,   // 88 Prti
  RTypeNone,   // 89 Phli
  RTypeNone,   // 90 Orkh
  RTypeNone,   // 91 Kthi
  RTypeNone,   // 92 Batk
  RTypeNone,   // 93 Brah
  RTypeNone,   // 94 Mand
  RTypeNone,   // 95 Cakm
  RTypeNone,   // 96 Merc
  RTypeNone,   // 97 Mero
  RTypeNone,   // 98 Plrd
  RTypeNone,   // 99 Shrd
  RTypeNone,   // 100 Sora
  RTypeNone,   // 101 Takr
};

// Subscripted by enum ULScript
extern const int kULScriptToDefaultLangSize = 102;

// Alphabetical order for binary search
extern const int kNameToULScriptSize = 105;
extern const CharIntPair kNameToULScript[kNameToULScriptSize] = {
  {"Arabic",                 6},  // Arab
  {"Armenian",               4},  // Armn
  {"Avestan",               79},  // Avst
  {"Balinese",              61},  // Bali
  {"Bamum",                 83},  // Bamu
  {"Batak",                 92},  // Batk
  {"Bengali",               10},  // Beng
  {"Bopomofo",              34},  // Bopo
  {"Brahmi",                93},  // Brah
  {"Braille",               52},  // Brai
  {"Buginese",              53},  // Bugi
  {"Buhid",                 43},  // Buhd
  {"Canadian_Aboriginal",   27},  // Cans
  {"Carian",                74},  // Cari
  {"Chakma",                95},  // Cakm
  {"Cham",                  76},  // Cham
  {"Cherokee",              26},  // Cher
  {"Common",                 0},  // Zyyy
  {"Coptic",                54},  // Copt
  {"Cuneiform",             62},  // Xsux
  {"Cypriot",               51},  // Cprt
  {"Cyrillic",               3},  // Cyrl
  {"Deseret",               39},  // Dsrt
  {"Devanagari",             9},  // Deva
  {"Egyptian_Hieroglyphs",  80},  // Egyp
  {"Ethiopic",              25},  // Ethi
  {"Georgian",              23},  // Geor
  {"Glagolitic",            56},  // Glag
  {"Gothic",                38},  // Goth
  {"Greek",                  2},  // Grek
  {"Gujarati",              12},  // Gujr
  {"Gurmukhi",              11},  // Guru
  {"Han",                   24},  // Hant
  {"Han",                   24},  // Hans
  {"Han",                   24},  // Hani
  {"Hangul",                24},  // Hang
  {"Hani",                  24},  // Hani
  {"Hanunoo",               42},  // Hano
  {"Hebrew",                 5},  // Hebr
  {"Hiragana",              24},  // Hira
  {"Imperial_Aramaic",      86},  // Armi
  {"Inherited",             40},  // Zinh
  {"Inscriptional_Pahlavi",  89},  // Phli
  {"Inscriptional_Parthian",  88},  // Prti
  {"Javanese",              84},  // Java
  {"Kaithi",                91},  // Kthi
  {"Kannada",               16},  // Knda
  {"Katakana",              24},  // Kana
  {"Kayah_Li",              71},  // Kali
  {"Kharoshthi",            60},  // Khar
  {"Khmer",                 30},  // Khmr
  {"Lao",                   20},  // Laoo
  {"Latin",                  1},  // Latn
  {"Lepcha",                67},  // Lepc
  {"Limbu",                 45},  // Limb
  {"Linear_B",              47},  // Linb
  {"Lisu",                  82},  // Lisu
  {"Lycian",                73},  // Lyci
  {"Lydian",                75},  // Lydi
  {"Malayalam",             17},  // Mlym
  {"Mandaic",               94},  // Mand
  {"Meetei_Mayek",          85},  // Mtei
  {"Meroitic_Cursive",      96},  // Merc
  {"Meroitic_Hieroglyphs",  97},  // Mero
  {"Miao",                  98},  // Plrd
  {"Mongolian",             31},  // Mong
  {"Myanmar",               22},  // Mymr
  {"New_Tai_Lue",           55},  // Talu
  {"Nko",                   65},  // Nkoo
  {"Ogham",                 28},  // Ogam
  {"Ol_Chiki",              68},  // Olck
  {"Old_Italic",            37},  // Ital
  {"Old_Persian",           59},  // Xpeo
  {"Old_South_Arabian",     87},  // Sarb
  {"Old_Turkic",            90},  // Orkh
  {"Oriya",                 13},  // Orya
  {"Osmanya",               50},  // Osma
  {"Phags_Pa",              64},  // Phag
  {"Phoenician",            63},  // Phnx
  {"Rejang",                72},  // Rjng
  {"Runic",                 29},  // Runr
  {"Samaritan",             81},  // Samr
  {"Saurashtra",            70},  // Saur
  {"Sharada",               99},  // Shrd
  {"Shavian",               49},  // Shaw
  {"Sinhala",               18},  // Sinh
  {"Sora_Sompeng",         100},  // Sora
  {"Sundanese",             66},  // Sund
  {"Syloti_Nagri",          58},  // Sylo
  {"Syriac",                 7},  // Syrc
  {"Tagalog",               41},  // Tglg
  {"Tagbanwa",              44},  // Tagb
  {"Tai_Le",                46},  // Tale
  {"Tai_Tham",              77},  // Lana
  {"Tai_Viet",              78},  // Tavt
  {"Takri",                101},  // Takr
  {"Tamil",                 14},  // Taml
  {"Telugu",                15},  // Telu
  {"Thaana",                 8},  // Thaa
  {"Thai",                  19},  // Thai
  {"Tibetan",               21},  // Tibt
  {"Tifinagh",              57},  // Tfng
  {"Ugaritic",              48},  // Ugar
  {"Vai",                   69},  // Vaii
  {"Yi",                    36},  // Yiii
};

// Alphabetical order for binary search
extern const int kCodeToULScriptSize = 105;
extern const CharIntPair kCodeToULScript[kNameToULScriptSize] = {
  {"Arab",   6},  // Arab
  {"Armi",  86},  // Armi
  {"Armn",   4},  // Armn
  {"Avst",  79},  // Avst
  {"Bali",  61},  // Bali
  {"Bamu",  83},  // Bamu
  {"Batk",  92},  // Batk
  {"Beng",  10},  // Beng
  {"Bopo",  34},  // Bopo
  {"Brah",  93},  // Brah
  {"Brai",  52},  // Brai
  {"Bugi",  53},  // Bugi
  {"Buhd",  43},  // Buhd
  {"Cakm",  95},  // Cakm
  {"Cans",  27},  // Cans
  {"Cari",  74},  // Cari
  {"Cham",  76},  // Cham
  {"Cher",  26},  // Cher
  {"Copt",  54},  // Copt
  {"Cprt",  51},  // Cprt
  {"Cyrl",   3},  // Cyrl
  {"Deva",   9},  // Deva
  {"Dsrt",  39},  // Dsrt
  {"Egyp",  80},  // Egyp
  {"Ethi",  25},  // Ethi
  {"Geor",  23},  // Geor
  {"Glag",  56},  // Glag
  {"Goth",  38},  // Goth
  {"Grek",   2},  // Grek
  {"Gujr",  12},  // Gujr
  {"Guru",  11},  // Guru
  {"Hang",  24},  // Hang
  {"Hani",  24},  // Hani
  {"Hani",  24},  // Hani
  {"Hano",  42},  // Hano
  {"Hans",  24},  // Hans
  {"Hant",  24},  // Hant
  {"Hebr",   5},  // Hebr
  {"Hira",  24},  // Hira
  {"Ital",  37},  // Ital
  {"Java",  84},  // Java
  {"Kali",  71},  // Kali
  {"Kana",  24},  // Kana
  {"Khar",  60},  // Khar
  {"Khmr",  30},  // Khmr
  {"Knda",  16},  // Knda
  {"Kthi",  91},  // Kthi
  {"Lana",  77},  // Lana
  {"Laoo",  20},  // Laoo
  {"Latn",   1},  // Latn
  {"Lepc",  67},  // Lepc
  {"Limb",  45},  // Limb
  {"Linb",  47},  // Linb
  {"Lisu",  82},  // Lisu
  {"Lyci",  73},  // Lyci
  {"Lydi",  75},  // Lydi
  {"Mand",  94},  // Mand
  {"Merc",  96},  // Merc
  {"Mero",  97},  // Mero
  {"Mlym",  17},  // Mlym
  {"Mong",  31},  // Mong
  {"Mtei",  85},  // Mtei
  {"Mymr",  22},  // Mymr
  {"Nkoo",  65},  // Nkoo
  {"Ogam",  28},  // Ogam
  {"Olck",  68},  // Olck
  {"Orkh",  90},  // Orkh
  {"Orya",  13},  // Orya
  {"Osma",  50},  // Osma
  {"Phag",  64},  // Phag
  {"Phli",  89},  // Phli
  {"Phnx",  63},  // Phnx
  {"Plrd",  98},  // Plrd
  {"Prti",  88},  // Prti
  {"Rjng",  72},  // Rjng
  {"Runr",  29},  // Runr
  {"Samr",  81},  // Samr
  {"Sarb",  87},  // Sarb
  {"Saur",  70},  // Saur
  {"Shaw",  49},  // Shaw
  {"Shrd",  99},  // Shrd
  {"Sinh",  18},  // Sinh
  {"Sora", 100},  // Sora
  {"Sund",  66},  // Sund
  {"Sylo",  58},  // Sylo
  {"Syrc",   7},  // Syrc
  {"Tagb",  44},  // Tagb
  {"Takr", 101},  // Takr
  {"Tale",  46},  // Tale
  {"Talu",  55},  // Talu
  {"Taml",  14},  // Taml
  {"Tavt",  78},  // Tavt
  {"Telu",  15},  // Telu
  {"Tfng",  57},  // Tfng
  {"Tglg",  41},  // Tglg
  {"Thaa",   8},  // Thaa
  {"Thai",  19},  // Thai
  {"Tibt",  21},  // Tibt
  {"Ugar",  48},  // Ugar
  {"Vaii",  69},  // Vaii
  {"Xpeo",  59},  // Xpeo
  {"Xsux",  62},  // Xsux
  {"Yiii",  36},  // Yiii
  {"Zinh",  40},  // Zinh
  {"Zyyy",   0},  // Zyyy
};

}  // namespace CLD2
}  // namespace chrome_lang_id
