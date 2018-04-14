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
//  Rejects all codes that are not interchange-valid
//  Accepts all other UTF-8 codes 0000..10FFFF
//  Exit optimized -- exits after four times in state 0
//  All bytes are checked for structurally valid UTF-8
//  Table entries are absolute statetable subscripts

#ifndef SCRIPT_SPAN_UTF8ACCEPTINTERCHANGE_H_
#define SCRIPT_SPAN_UTF8ACCEPTINTERCHANGE_H_

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

//  Entire table has 17 state blocks of 256 entries each

static const unsigned int utf8acceptinterchange_STATE0 = 0;		// state[0]
static const unsigned int utf8acceptinterchange_STATE0_SIZE = 1024;	// =[4]
static const unsigned int utf8acceptinterchange_TOTAL_SIZE = 4352;
static const unsigned int utf8acceptinterchange_MAX_EXPAND_X4 = 0;
static const unsigned int utf8acceptinterchange_SHIFT = 8;
static const unsigned int utf8acceptinterchange_BYTES = 1;
static const unsigned int utf8acceptinterchange_LOSUB = 0x20202020;
static const unsigned int utf8acceptinterchange_HIADD = 0x01010101;

static const uint8 utf8acceptinterchange[] = {
// state[0] 0x000000 Byte 1
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  1,  1,RJ_,  1,  1,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  1,  1,  1,  1,  1,  1,  1,  1,   1,  1,  1,  1,  1,  1,  1,  1,
  1,  1,  1,  1,  1,  1,  1,  1,   1,  1,  1,  1,  1,  1,  1,  1,

  1,  1,  1,  1,  1,  1,  1,  1,   1,  1,  1,  1,  1,  1,  1,  1,
  1,  1,  1,  1,  1,  1,  1,  1,   1,  1,  1,  1,  1,  1,  1,  1,
  1,  1,  1,  1,  1,  1,  1,  1,   1,  1,  1,  1,  1,  1,  1,  1,
  1,  1,  1,  1,  1,  1,  1,  1,   1,  1,  1,  1,  1,  1,  1,RJ_,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,  7,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  5,  6,  6,  6,  6,  6,  6,  6,   6,  6,  6,  6,  6,  8,  6, 10,
 13, 15, 15, 15, 16,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[1] 0x000000 Byte 1
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  2,  2,RJ_,  2,  2,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,

  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,  2,
  2,  2,  2,  2,  2,  2,  2,  2,   2,  2,  2,  2,  2,  2,  2,RJ_,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,  7,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  5,  6,  6,  6,  6,  6,  6,  6,   6,  6,  6,  6,  6,  8,  6, 10,
 13, 15, 15, 15, 16,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[2] 0x000000 Byte 1
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,  3,  3,RJ_,  3,  3,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,

  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,  3,
  3,  3,  3,  3,  3,  3,  3,  3,   3,  3,  3,  3,  3,  3,  3,RJ_,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,  7,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  5,  6,  6,  6,  6,  6,  6,  6,   6,  6,  6,  6,  6,  8,  6, 10,
 13, 15, 15, 15, 16,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[3] 0x000000 Byte 1
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,D__,D__,RJ_,D__,D__,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
D__,D__,D__,D__,D__,D__,D__,D__, D__,D__,D__,D__,D__,D__,D__,D__,
D__,D__,D__,D__,D__,D__,D__,D__, D__,D__,D__,D__,D__,D__,D__,D__,

D__,D__,D__,D__,D__,D__,D__,D__, D__,D__,D__,D__,D__,D__,D__,D__,
D__,D__,D__,D__,D__,D__,D__,D__, D__,D__,D__,D__,D__,D__,D__,D__,
D__,D__,D__,D__,D__,D__,D__,D__, D__,D__,D__,D__,D__,D__,D__,D__,
D__,D__,D__,D__,D__,D__,D__,D__, D__,D__,D__,D__,D__,D__,D__,RJ_,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,  7,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  5,  6,  6,  6,  6,  6,  6,  6,   6,  6,  6,  6,  6,  8,  6, 10,
 13, 15, 15, 15, 16,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[4] 0x0000c0 Byte 2 of 2
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[5] 0x000000 Byte 2 of 3
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[6] 0x001000 Byte 2 of 3
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[7] 0x000080 Byte 2 of 2
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[8] 0x00d000 Byte 2 of 3
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  9,  9,  9,  9,  9,  9,  9,  9,   9,  9,  9,  9,  9,  9,  9,  9,
  9,  9,  9,  9,  9,  9,  9,  9,   9,  9,  9,  9,  9,  9,  9,  9,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[9] 0x00d800 Byte 3 of 3
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[10] 0x00f000 Byte 2 of 3
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4, 11,   4,  4,  4,  4,  4,  4,  4, 12,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[11] 0x00fdc0 Byte 3 of 3
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_, RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,RJ_,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[12] 0x00ffc0 Byte 3 of 3
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,  0,  0,
  0,  0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0,  0,  0,RJ_,RJ_,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[13] 0x000000 Byte 2 of 4
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
  6,  6,  6,  6,  6,  6,  6,  6,   6,  6,  6,  6,  6,  6,  6, 14,
  6,  6,  6,  6,  6,  6,  6,  6,   6,  6,  6,  6,  6,  6,  6, 14,
  6,  6,  6,  6,  6,  6,  6,  6,   6,  6,  6,  6,  6,  6,  6, 14,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[14] 0x01f000 Byte 3 of 4
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4,  4,
  4,  4,  4,  4,  4,  4,  4,  4,   4,  4,  4,  4,  4,  4,  4, 12,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[15] 0x040000 Byte 2 of 4
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

  6,  6,  6,  6,  6,  6,  6,  6,   6,  6,  6,  6,  6,  6,  6, 14,
  6,  6,  6,  6,  6,  6,  6,  6,   6,  6,  6,  6,  6,  6,  6, 14,
  6,  6,  6,  6,  6,  6,  6,  6,   6,  6,  6,  6,  6,  6,  6, 14,
  6,  6,  6,  6,  6,  6,  6,  6,   6,  6,  6,  6,  6,  6,  6, 14,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

// state[16] 0x100000 Byte 2 of 4
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

  6,  6,  6,  6,  6,  6,  6,  6,   6,  6,  6,  6,  6,  6,  6, 14,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,
X__,X__,X__,X__,X__,X__,X__,X__, X__,X__,X__,X__,X__,X__,X__,X__,

};

// Remap base[0] = (del, add, string_offset)
static const RemapEntry utf8acceptinterchange_remap_base[] = {
{0,0,0} };

// Remap string[0]
static const unsigned char utf8acceptinterchange_remap_string[] = {
0 };

static const unsigned char utf8acceptinterchange_fast[256] = {
1,1,1,1,1,1,1,1, 1,0,0,1,0,0,1,1,
1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,

0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,1,

1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,

1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,
1,1,1,1,1,1,1,1, 1,1,1,1,1,1,1,1,

};

static const UTF8ScanObj utf8acceptinterchange_obj = {
  utf8acceptinterchange_STATE0,
  utf8acceptinterchange_STATE0_SIZE,
  utf8acceptinterchange_TOTAL_SIZE,
  utf8acceptinterchange_MAX_EXPAND_X4,
  utf8acceptinterchange_SHIFT,
  utf8acceptinterchange_BYTES,
  utf8acceptinterchange_LOSUB,
  utf8acceptinterchange_HIADD,
  utf8acceptinterchange,
  utf8acceptinterchange_remap_base,
  utf8acceptinterchange_remap_string,
  utf8acceptinterchange_fast
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

// Table has 4608 bytes, Hash = 505C-3D29

}       // End namespace CLD2
}       // End namespace chrome_lang_id

#endif  // SCRIPT_SPAN_UTF8ACCEPTINTERCHANGE_H_
