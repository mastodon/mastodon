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

#include <ruby.h>
#include "idn.h"

/*
 * Document-class: IDN
 * The main module of LibIDN Ruby Bindings.
 *
 * === Example usage
 *
 *   require 'idn'
 *   include IDN
 *
 *   ...
 */

VALUE mIDN;

/*
 * Document-class: IDN::IDNError
 * The superclass for all exceptions raised by the IDN extension.
 */

VALUE eIDNError;

/*
 * Module Initialization.
 */

void Init_idn(void)
{
  mIDN = rb_define_module("IDN");
  eIDNError = rb_define_class_under(mIDN, "IDNError", rb_eStandardError);

  init_idna();
  init_punycode();
  init_stringprep();
}
