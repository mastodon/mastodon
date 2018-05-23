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
// Created by utf8tablebuilder version 2.9
//
//  Rejects all codes from file:
//    lettermarkspecial_6.2.0.txt
//  Accepts all other UTF-8 codes 0000..10FFFF
//  Space optimized
//
// ** ASSUMES INPUT IS STRUCTURALLY VALID UTF-8 **
//
//  Table entries are absolute statetable subscripts

#ifndef SCRIPT_SPAN_UTF8SCANNOT_LETTERMARKSPECIAL_H_
#define SCRIPT_SPAN_UTF8SCANNOT_LETTERMARKSPECIAL_H_

#include "integral_types.h"
#include "utf8statetable.h"

namespace chrome_lang_id {
namespace CLD2 {

#define X__ (kExitIllegalStructure)
#define RJ_ (kExitReject)
#define S1_ (kExitReplace1)
#define S2_ (kExitReplace2)
#define S3_ (kExitReplace3)
#define S21 (kExitReplace21)
#define S31 (kExitReplace31)
#define S32 (kExitReplace32)
#define T1_ (kExitReplaceOffset1)
#define T2_ (kExitReplaceOffset2)
#define S11 (kExitReplace1S0)
#define SP_ (kExitSpecial)
#define D__ (kExitDoAgain)
#define RJA (kExitRejectAlt)

//  Entire table has 221 state blocks of 64 entries each

static const unsigned int utf8scannot_lettermarkspecial_STATE0 = 0;		// state[0]
static const unsigned int utf8scannot_lettermarkspecial_STATE0_SIZE = 64;	// =[1]
static const unsigned int utf8scannot_lettermarkspecial_TOTAL_SIZE = 14144;
static const unsigned int utf8scannot_lettermarkspecial_MAX_EXPAND_X4 = 0;
static const unsigned int utf8scannot_lettermarkspecial_SHIFT = 6;
static const unsigned int utf8scannot_lettermarkspecial_BYTES = 1;
static const unsigned int utf8scannot_lettermarkspecial_LOSUB = 0x27272727;
static const unsigned int utf8scannot_lettermarkspecial_HIADD = 0x44444444;

static const uint8 utf8scannot_lettermarkspecial[] = {
// state[0] 0x000000 Byte 1
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,RJ_,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,RJ_,  0,RJ_,  0,

  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,  6,  7,  8,  8,  8,  8,   8,  8,  8,  9,  8, 10, 11, 12,
  8,  8, 13,  8, 14, 15, 16, 17,  18, 19,  8, 20, 21, 22, 23, 24,
 25, 57, 95,110,117,118,118,118, 118,119,121,118,118,140,  2,143,
159,  4,  4,216,  5,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[2 + 2] 0x00e000 Byte 2 of 3
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,

// state[3 + 2] 0x001ac0 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[4 + 2] 0x040000 Byte 2 of 4
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,

// state[5 + 2] 0x100000 Byte 2 of 4
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[6 + 2] 0x000080 Byte 2 of 2
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,RJ_,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,RJ_,  0,  0,   0,  0,RJ_,  0,  0,  0,  0,  0,

// state[7 + 2] 0x0000c0 Byte 2 of 2
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[8 + 2] 0x000100 Byte 2 of 2
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[9 + 2] 0x0002c0 Byte 2 of 2
RJ_,RJ_,  0,  0,  0,  0,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,   0,  0,  0,  0,RJ_,  0,RJ_,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[10 + 2] 0x000340 Byte 2 of 2
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,   0,  0,RJ_,RJ_,RJ_,RJ_,  0,  0,

// state[11 + 2] 0x000380 Byte 2 of 2
  0,  0,  0,  0,  0,  0,RJ_,  0, RJ_,RJ_,RJ_,  0,RJ_,  0,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[12 + 2] 0x0003c0 Byte 2 of 2
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[13 + 2] 0x000480 Byte 2 of 2
RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[14 + 2] 0x000500 Byte 2 of 2
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,  0,  0,  0,  0,  0,  0,  0,
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[15 + 2] 0x000540 Byte 2 of 2
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,RJ_,  0,  0,  0,  0,  0,  0,
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[16 + 2] 0x000580 Byte 2 of 2
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,  0,  0,  0,  0,  0,  0,  0,
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,

// state[17 + 2] 0x0005c0 Byte 2 of 2
  0,RJ_,RJ_,  0,RJ_,RJ_,  0,RJ_,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[18 + 2] 0x000600 Byte 2 of 2
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[19 + 2] 0x000640 Byte 2 of 2
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[20 + 2] 0x0006c0 Byte 2 of 2
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,RJ_,RJ_,RJ_,  0,  0,RJ_,

// state[21 + 2] 0x000700 Byte 2 of 2
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[22 + 2] 0x000740 Byte 2 of 2
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[23 + 2] 0x000780 Byte 2 of 2
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[24 + 2] 0x0007c0 Byte 2 of 2
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,   0,  0,RJ_,  0,  0,  0,  0,  0,

// state[25 + 2] 0x000000 Byte 2 of 3
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
 26, 27, 28, 29,  8, 30, 31, 32,  33, 34, 35, 36, 37, 38, 39, 40,
 41, 42, 43, 44, 45, 46, 47, 48,  49, 50, 51, 52, 53, 54, 55, 56,

// state[26 + 2] 0x000800 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[27 + 2] 0x000840 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[28 + 2] 0x000880 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[29 + 2] 0x0008c0 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,

// state[30 + 2] 0x000940 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[31 + 2] 0x000980 Byte 3 of 3
  0,RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,RJ_,
RJ_,  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,  0,RJ_,  0,  0,  0,RJ_,RJ_, RJ_,RJ_,  0,  0,RJ_,RJ_,RJ_,RJ_,

// state[32 + 2] 0x0009c0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,RJ_, RJ_,  0,  0,RJ_,RJ_,RJ_,RJ_,  0,
  0,  0,  0,  0,  0,  0,  0,RJ_,   0,  0,  0,  0,RJ_,RJ_,  0,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[33 + 2] 0x000a00 Byte 3 of 3
  0,RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,RJ_,
RJ_,  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,  0,RJ_,RJ_,  0,RJ_,RJ_,  0, RJ_,RJ_,  0,  0,RJ_,  0,RJ_,RJ_,

// state[34 + 2] 0x000a40 Byte 3 of 3
RJ_,RJ_,RJ_,  0,  0,  0,  0,RJ_, RJ_,  0,  0,RJ_,RJ_,RJ_,  0,  0,
  0,RJ_,  0,  0,  0,  0,  0,  0,   0,RJ_,RJ_,RJ_,RJ_,  0,RJ_,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[35 + 2] 0x000a80 Byte 3 of 3
  0,RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,
RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,  0,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,  0,  0,RJ_,RJ_,RJ_,RJ_,

// state[36 + 2] 0x000ac0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_, RJ_,RJ_,  0,RJ_,RJ_,RJ_,  0,  0,
RJ_,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[37 + 2] 0x000b00 Byte 3 of 3
  0,RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,RJ_,
RJ_,  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,  0,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,  0,  0,RJ_,RJ_,RJ_,RJ_,

// state[38 + 2] 0x000b40 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,RJ_, RJ_,  0,  0,RJ_,RJ_,RJ_,  0,  0,
  0,  0,  0,  0,  0,  0,RJ_,RJ_,   0,  0,  0,  0,RJ_,RJ_,  0,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,RJ_,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[39 + 2] 0x000b80 Byte 3 of 3
  0,  0,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,RJ_,RJ_,
RJ_,  0,RJ_,RJ_,RJ_,RJ_,  0,  0,   0,RJ_,RJ_,  0,RJ_,  0,RJ_,RJ_,
  0,  0,  0,RJ_,RJ_,  0,  0,  0, RJ_,RJ_,RJ_,  0,  0,  0,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,  0,  0,  0,  0,RJ_,RJ_,

// state[40 + 2] 0x000bc0 Byte 3 of 3
RJ_,RJ_,RJ_,  0,  0,  0,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,  0,  0,
RJ_,  0,  0,  0,  0,  0,  0,RJ_,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[41 + 2] 0x000c00 Byte 3 of 3
  0,RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,
RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,  0,  0,  0,RJ_,RJ_,RJ_,

// state[42 + 2] 0x000c40 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,  0,  0,
  0,  0,  0,  0,  0,RJ_,RJ_,  0, RJ_,RJ_,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[43 + 2] 0x000c80 Byte 3 of 3
  0,  0,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,
RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,  0,  0,RJ_,RJ_,RJ_,RJ_,

// state[44 + 2] 0x000cc0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,  0,  0,
  0,  0,  0,  0,  0,RJ_,RJ_,  0,   0,  0,  0,  0,  0,  0,RJ_,  0,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,RJ_,RJ_,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[45 + 2] 0x000d00 Byte 3 of 3
  0,  0,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,
RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,RJ_,RJ_,RJ_,

// state[46 + 2] 0x000d40 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
  0,  0,  0,  0,  0,  0,  0,RJ_,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[47 + 2] 0x000d80 Byte 3 of 3
  0,  0,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,RJ_,  0,  0,

// state[48 + 2] 0x000dc0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,RJ_,  0,  0,  0,  0,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[49 + 2] 0x000e00 Byte 3 of 3
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,

// state[50 + 2] 0x000e40 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[51 + 2] 0x000e80 Byte 3 of 3
  0,RJ_,RJ_,  0,RJ_,  0,  0,RJ_, RJ_,  0,RJ_,  0,  0,RJ_,  0,  0,
  0,  0,  0,  0,RJ_,RJ_,RJ_,RJ_,   0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,RJ_,RJ_,RJ_,  0,RJ_,  0,RJ_,   0,  0,RJ_,RJ_,  0,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,  0,RJ_,RJ_,RJ_,  0,  0,

// state[52 + 2] 0x000ec0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[53 + 2] 0x000f00 Byte 3 of 3
RJ_,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0, RJ_,RJ_,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,RJ_,  0,RJ_,   0,RJ_,  0,  0,  0,  0,RJ_,RJ_,

// state[54 + 2] 0x000f40 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[55 + 2] 0x000f80 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,

// state[56 + 2] 0x000fc0 Byte 3 of 3
  0,  0,  0,  0,  0,  0,RJ_,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[57 + 2] 0x001000 Byte 2 of 3
  8, 21, 58, 59,  8,  8,  8,  8,   8, 60, 61, 62, 63, 64, 65, 66,
 67,  8,  8,  8,  8,  8,  8,  8,   8, 68, 69, 70, 71, 72,  8, 73,
 74, 75, 76, 77, 78, 79, 80, 81,  82, 83, 84,  3,  8, 85, 86, 87,
 75, 88,  3, 89,  8,  8,  8, 90,   8,  8,  8,  8, 91, 92, 93, 94,

// state[58 + 2] 0x001080 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,RJ_,RJ_,RJ_,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[59 + 2] 0x0010c0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,   0,  0,  0,  0,  0,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,

// state[60 + 2] 0x001240 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0, RJ_,  0,RJ_,RJ_,RJ_,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[61 + 2] 0x001280 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,  0,RJ_,RJ_,RJ_,RJ_,  0,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,

// state[62 + 2] 0x0012c0 Byte 3 of 3
RJ_,  0,RJ_,RJ_,RJ_,RJ_,  0,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[63 + 2] 0x001300 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,  0,RJ_,RJ_,RJ_,RJ_,  0,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[64 + 2] 0x001340 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[65 + 2] 0x001380 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[66 + 2] 0x0013c0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[67 + 2] 0x001400 Byte 3 of 3
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[68 + 2] 0x001640 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[69 + 2] 0x001680 Byte 3 of 3
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[70 + 2] 0x0016c0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[71 + 2] 0x001700 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[72 + 2] 0x001740 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,
RJ_,  0,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[73 + 2] 0x0017c0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,RJ_,   0,  0,  0,  0,RJ_,RJ_,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[74 + 2] 0x001800 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,RJ_,RJ_,RJ_,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[75 + 2] 0x001840 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,  0,  0,  0,  0,  0,  0,  0,

// state[76 + 2] 0x001880 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[77 + 2] 0x0018c0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[78 + 2] 0x001900 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,

// state[79 + 2] 0x001940 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[80 + 2] 0x001980 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[81 + 2] 0x0019c0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[82 + 2] 0x001a00 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[83 + 2] 0x001a40 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,RJ_,

// state[84 + 2] 0x001a80 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,RJ_,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[85 + 2] 0x001b40 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[86 + 2] 0x001b80 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[87 + 2] 0x001bc0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[88 + 2] 0x001c40 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,

// state[89 + 2] 0x001cc0 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[90 + 2] 0x001dc0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,RJ_,RJ_,RJ_,RJ_,

// state[91 + 2] 0x001f00 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[92 + 2] 0x001f40 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,RJ_,  0,RJ_,  0,RJ_,  0,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,

// state[93 + 2] 0x001f80 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,  0,

// state[94 + 2] 0x001fc0 Byte 3 of 3
  0,  0,RJ_,RJ_,RJ_,  0,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,  0,  0,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,
  0,  0,RJ_,RJ_,RJ_,  0,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,

// state[95 + 2] 0x002000 Byte 2 of 3
  3, 96, 97, 98, 99,100,101,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
102,103,  8,104,105,106,107,108, 109,  3,  3,  3,  3,  3,  3,  3,

// state[96 + 2] 0x002040 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,RJ_,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,RJ_,

// state[97 + 2] 0x002080 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[98 + 2] 0x0020c0 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[99 + 2] 0x002100 Byte 3 of 3
  0,  0,RJ_,  0,  0,  0,  0,RJ_,   0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,RJ_,  0,  0,   0,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
  0,  0,  0,  0,RJ_,  0,RJ_,  0, RJ_,  0,RJ_,RJ_,RJ_,RJ_,  0,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,  0,  0,RJ_,RJ_,RJ_,RJ_,

// state[100 + 2] 0x002140 Byte 3 of 3
  0,  0,  0,  0,  0,RJ_,RJ_,RJ_, RJ_,RJ_,  0,  0,  0,  0,RJ_,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[101 + 2] 0x002180 Byte 3 of 3
  0,  0,  0,RJ_,RJ_,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[102 + 2] 0x002c00 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[103 + 2] 0x002c40 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[104 + 2] 0x002cc0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,   0,  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[105 + 2] 0x002d00 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,   0,  0,  0,  0,  0,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[106 + 2] 0x002d40 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,  0,  0,  0,  0,  0,  0,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,RJ_,

// state[107 + 2] 0x002d80 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,

// state[108 + 2] 0x002dc0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[109 + 2] 0x002e00 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[110 + 2] 0x003000 Byte 2 of 3
111, 67,112,113,114,  8,115,116,   3,  3,  3,  3,  3,  3,  3,  3,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,

// state[111 + 2] 0x003000 Byte 3 of 3
  0,  0,  0,  0,  0,RJ_,RJ_,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,   0,  0,  0,RJ_,RJ_,  0,  0,  0,

// state[112 + 2] 0x003080 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[113 + 2] 0x0030c0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,

// state[114 + 2] 0x003100 Byte 3 of 3
  0,  0,  0,  0,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[115 + 2] 0x003180 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,

// state[116 + 2] 0x0031c0 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[117 + 2] 0x004000 Byte 2 of 3
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8, 77,  3,   8,  8,  8,  8,  8,  8,  8,  8,

// state[118 + 2] 0x005000 Byte 2 of 3
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,

// state[119 + 2] 0x009000 Byte 2 of 3
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,120,

// state[120 + 2] 0x009fc0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[121 + 2] 0x00a000 Byte 2 of 3
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,120,122,  8,  8,  8,  8, 123,124,125,126,127,  8,128,129,
130, 87,  8,131,132,133,  8,134, 135,136,  8,137,138,  3,  3,139,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,

// state[122 + 2] 0x00a4c0 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,

// state[123 + 2] 0x00a600 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,RJ_,RJ_,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[124 + 2] 0x00a640 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,

// state[125 + 2] 0x00a680 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,  0,  0,  0,  0,  0,  0,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[126 + 2] 0x00a6c0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[127 + 2] 0x00a700 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[128 + 2] 0x00a780 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,  0,RJ_,RJ_,RJ_,RJ_,  0,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[129 + 2] 0x00a7c0 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[130 + 2] 0x00a800 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[131 + 2] 0x00a8c0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,  0,  0,RJ_,  0,  0,  0,  0,

// state[132 + 2] 0x00a900 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[133 + 2] 0x00a940 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,

// state[134 + 2] 0x00a9c0 Byte 3 of 3
RJ_,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[135 + 2] 0x00aa00 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[136 + 2] 0x00aa40 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,RJ_,RJ_,  0,  0,  0,  0,

// state[137 + 2] 0x00aac0 Byte 3 of 3
RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,RJ_,RJ_,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[138 + 2] 0x00ab00 Byte 3 of 3
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[139 + 2] 0x00abc0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,RJ_,RJ_,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[140 + 2] 0x00d000 Byte 2 of 3
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,141,142,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,

// state[141 + 2] 0x00d780 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[142 + 2] 0x00d7c0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,

// state[143 + 2] 0x00f000 Byte 2 of 3
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  8,  8,  8,  8,   8,144,  8,145,146,147, 23,148,
  8,  8,  8,  8,149, 21,150,151, 152,153,  8,154,155,156,157,158,

// state[144 + 2] 0x00fa40 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[145 + 2] 0x00fac0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[146 + 2] 0x00fb00 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,   0,  0,  0,  0,  0,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0, RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,  0,

// state[147 + 2] 0x00fb40 Byte 3 of 3
RJ_,RJ_,  0,RJ_,RJ_,  0,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[148 + 2] 0x00fbc0 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[149 + 2] 0x00fd00 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,

// state[150 + 2] 0x00fd80 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[151 + 2] 0x00fdc0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,

// state[152 + 2] 0x00fe00 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[153 + 2] 0x00fe40 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[154 + 2] 0x00fec0 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,

// state[155 + 2] 0x00ff00 Byte 3 of 3
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,

// state[156 + 2] 0x00ff40 Byte 3 of 3
  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[157 + 2] 0x00ff80 Byte 3 of 3
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,

// state[158 + 2] 0x00ffc0 Byte 3 of 3
  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,  0,RJ_,RJ_,RJ_,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[159 + 2] 0x000000 Byte 2 of 4
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
160,180,184,186,  2,  2,187,  2,   2,  2,  2,191,  2,193,208,  2,
118,118,118,118,118,118,118,118, 118,118,212,214,  2,  2,  2,215,
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,

// state[160 + 2] 0x010000 Byte 3 of 4
161,162,  8,163,  3,  3,  3,164,   3,  3,165,166,167,168,169,170,
  8,  8,171,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
172,173,  3,  3,174,  3,175,  3, 176,177,  3,  3, 77,178,  3,  3,
  8,179,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,

// state[161 + 2] 0x010000 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,RJ_,RJ_,  0,RJ_,

// state[162 + 2] 0x010040 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[163 + 2] 0x0100c0 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,

// state[164 + 2] 0x0101c0 Byte 4 of 4
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,RJ_,  0,  0,

// state[165 + 2] 0x010280 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[166 + 2] 0x0102c0 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[167 + 2] 0x010300 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[168 + 2] 0x010340 Byte 4 of 4
RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[169 + 2] 0x010380 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[170 + 2] 0x0103c0 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[171 + 2] 0x010480 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[172 + 2] 0x010800 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0, RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_, RJ_,  0,  0,  0,RJ_,  0,  0,RJ_,

// state[173 + 2] 0x010840 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[174 + 2] 0x010900 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,  0,  0,  0,  0,  0,  0,

// state[175 + 2] 0x010980 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,   0,  0,  0,  0,  0,  0,RJ_,RJ_,

// state[176 + 2] 0x010a00 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,  0,   0,  0,  0,  0,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_,   0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0, RJ_,RJ_,RJ_,  0,  0,  0,  0,RJ_,

// state[177 + 2] 0x010a40 Byte 4 of 4
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,

// state[178 + 2] 0x010b40 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[179 + 2] 0x010c40 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[180 + 2] 0x011000 Byte 3 of 4
  8,181,163,182, 66,  3,  8,183,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3, 75,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,

// state[181 + 2] 0x011040 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[182 + 2] 0x0110c0 Byte 4 of 4
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[183 + 2] 0x0111c0 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[184 + 2] 0x012000 Byte 3 of 4
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,185,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,

// state[185 + 2] 0x012340 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[186 + 2] 0x013000 Byte 3 of 4
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
185,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,

// state[187 + 2] 0x016000 Byte 3 of 4
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  8,  8,  8,  8,  8,  8,  8,  8, 188,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  8,189,190,  3,

// state[188 + 2] 0x016a00 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,  0,  0,  0,  0,  0,  0,

// state[189 + 2] 0x016f40 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,

// state[190 + 2] 0x016f80 Byte 4 of 4
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[191 + 2] 0x01b000 Byte 3 of 4
192,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,

// state[192 + 2] 0x01b000 Byte 4 of 4
RJ_,RJ_,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[193 + 2] 0x01d000 Byte 3 of 4
  3,  3,  3,  3,  3,194,195,  3,   3,196,  3,  3,  3,  3,  3,  3,
  8,197,198,199,200,201,  8,  8,   8,  8,202,203,204,205,206,207,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,

// state[194 + 2] 0x01d140 Byte 4 of 4
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,RJ_,RJ_,RJ_, RJ_,RJ_,  0,  0,  0,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,  0,  0,  0,  0,  0,   0,  0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[195 + 2] 0x01d180 Byte 4 of 4
RJ_,RJ_,RJ_,  0,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,RJ_,RJ_,RJ_,RJ_,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[196 + 2] 0x01d240 Byte 4 of 4
  0,  0,RJ_,RJ_,RJ_,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[197 + 2] 0x01d440 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[198 + 2] 0x01d480 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,
  0,  0,RJ_,  0,  0,RJ_,RJ_,  0,   0,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,  0,RJ_,  0,RJ_,RJ_,RJ_,

// state[199 + 2] 0x01d4c0 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[200 + 2] 0x01d500 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_, RJ_,RJ_,RJ_,  0,  0,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,  0,

// state[201 + 2] 0x01d540 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,  0,   0,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[202 + 2] 0x01d680 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,  0, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[203 + 2] 0x01d6c0 Byte 4 of 4
RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,

// state[204 + 2] 0x01d700 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[205 + 2] 0x01d740 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[206 + 2] 0x01d780 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

// state[207 + 2] 0x01d7c0 Byte 4 of 4
RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[208 + 2] 0x01e000 Byte 3 of 4
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3, 209,210,211,  3,  3,  3,  3,  3,

// state[209 + 2] 0x01ee00 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,RJ_,RJ_,  0,RJ_,  0,  0,RJ_,   0,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,   0,RJ_,  0,RJ_,  0,  0,  0,  0,

// state[210 + 2] 0x01ee40 Byte 4 of 4
  0,  0,RJ_,  0,  0,  0,  0,RJ_,   0,RJ_,  0,RJ_,  0,RJ_,RJ_,RJ_,
  0,RJ_,RJ_,  0,RJ_,  0,  0,RJ_,   0,RJ_,  0,RJ_,  0,RJ_,  0,RJ_,
  0,RJ_,RJ_,  0,RJ_,  0,  0,RJ_, RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,   0,RJ_,RJ_,RJ_,RJ_,  0,RJ_,  0,

// state[211 + 2] 0x01ee80 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,
  0,RJ_,RJ_,RJ_,  0,RJ_,RJ_,RJ_, RJ_,RJ_,  0,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,  0,  0,  0,  0,

// state[212 + 2] 0x02a000 Byte 3 of 4
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,213,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,

// state[213 + 2] 0x02a6c0 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

// state[214 + 2] 0x02b000 Byte 3 of 4
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8,  8,  8,  8,  8,
  8,  8,  8,  8,  8,  8,  8,  8,   8,  8,  8,  8, 66,  8,  8,  8,
171,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,

// state[215 + 2] 0x02f000 Byte 3 of 4
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  8,  8,  8,  8,  8,  8,  8,  8, 171,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,

// state[216 + 2] 0x0c0000 Byte 2 of 4
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,
217,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,

// state[217 + 2] 0x0e0000 Byte 3 of 4
  3,  3,  3,  3,  8,  8,  8,218,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,

// state[218 + 2] 0x0e01c0 Byte 4 of 4
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

};

// Remap base[0] = (del, add, string_offset)
static const RemapEntry utf8scannot_lettermarkspecial_remap_base[] = {
{0,0,0} };

// Remap string[0]
static const unsigned char utf8scannot_lettermarkspecial_remap_string[] = {
0 };

static const unsigned char utf8scannot_lettermarkspecial_fast[256] = {
0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
0,0,0,0,0,0,1,0, 0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0, 0,0,0,0,1,0,1,0,

0,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,0,0,0,0,0,
0,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,0,0,0,0,0,

1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,

1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,

};

static const UTF8ScanObj utf8scannot_lettermarkspecial_obj = {
  utf8scannot_lettermarkspecial_STATE0,
  utf8scannot_lettermarkspecial_STATE0_SIZE,
  utf8scannot_lettermarkspecial_TOTAL_SIZE,
  utf8scannot_lettermarkspecial_MAX_EXPAND_X4,
  utf8scannot_lettermarkspecial_SHIFT,
  utf8scannot_lettermarkspecial_BYTES,
  utf8scannot_lettermarkspecial_LOSUB,
  utf8scannot_lettermarkspecial_HIADD,
  utf8scannot_lettermarkspecial,
  utf8scannot_lettermarkspecial_remap_base,
  utf8scannot_lettermarkspecial_remap_string,
  utf8scannot_lettermarkspecial_fast
};


#undef X__
#undef RJ_
#undef S1_
#undef S2_
#undef S3_
#undef S21
#undef S31
#undef S32
#undef T1_
#undef T2_
#undef S11
#undef SP_
#undef D__
#undef RJA

// Table has 14400 bytes, Hash = 9E4D-F2F2

}       // End namespace CLD2
}       // End namespace chrome_lang_id

#endif  // SCRIPT_SPAN_UTF8SCANNOT_LETTERMARKSPECIAL_H_
