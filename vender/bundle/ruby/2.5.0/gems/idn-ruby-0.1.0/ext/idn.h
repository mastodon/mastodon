/*
 * Copyright (c) 2005 Erik Abele. All rights reserved.
 * Portions Copyright (c) 2005 Yuki Mitsui. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * Please see the file called LICENSE for further details.
 *
 * You may also obtain a copy of the License at
 *
 * * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * This software is OSI Certified Open Source Software.
 * OSI Certified is a certification mark of the Open Source Initiative.
 */

#ifndef ___IDN_IDN_H_
#define ___IDN_IDN_H_

#include <ruby.h>
#include <ruby/encoding.h>

/*
 * idn.c
 */
extern VALUE mIDN;
extern VALUE eIDNError;

/*
 * idna.c
 */
extern VALUE mIdna;
extern VALUE eIdnaError;

void init_idna(void);

/*
 * punycode.c
 */
extern VALUE mPunycode;
extern VALUE ePunycodeError;

void init_punycode(void);

/*
 * stringprep.c
 */
extern VALUE mStringprep;
extern VALUE eStringprepError;

void init_stringprep(void);

#endif /* ___IDN_IDN_H_ */
