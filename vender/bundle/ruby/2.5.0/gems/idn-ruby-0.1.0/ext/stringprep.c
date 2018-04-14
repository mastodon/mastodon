/*
 * Copyright (c) 2005-2006 Erik Abele. All rights reserved.
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

#include <stdlib.h>
#include <ruby.h>
#include <stringprep.h>
#include "idn.h"

/*
 * Document-class: IDN::Stringprep
 * The Stringprep module of LibIDN Ruby Bindings.
 *
 * === Example usage
 *
 *   require 'idn'
 *   include IDN
 *
 *   str = Stringprep.with_profile('FOO', 'Nameprep')
 */

VALUE mStringprep;

/*
 * Document-class: IDN::Stringprep::StringprepError
 * The base class for all exceptions raised by the IDN::Stringprep module.
 */

VALUE eStringprepError;

/*
 * Internal helper function:
 *   stringprep_internal
 *
 * Prepares the given string in UTF-8 format according to the given
 * stringprep profile name. See the various public wrapper functions
 * below for details.
 *
 * Raises IDN::Stringprep::StringprepError on failure.
 */

static VALUE stringprep_internal(VALUE str, const char *profile)
{
  int rc;
  char *buf;
  VALUE retv;

  str = rb_check_convert_type(str, T_STRING, "String", "to_s");
  rc = stringprep_profile(RSTRING_PTR(str), &buf, profile, 0);

  if (rc != STRINGPREP_OK) {
    rb_raise(eStringprepError, "%s (%d)", stringprep_strerror(rc), rc);
    return Qnil;
  }

  retv = rb_str_new2(buf);
  xfree(buf);
  return retv;
}

/*
 * call-seq:
 *   IDN::Stringprep.nameprep(string) => string
 *
 * Prepares a string in UTF-8 format according to the 'Nameprep'
 * profile.
 *
 * Raises IDN::Stringprep::StringprepError on failure.
 */

static VALUE nameprep(VALUE self, VALUE str)
{
  return stringprep_internal(str, "Nameprep");
}

/*
 * call-seq:
 *   IDN::Stringprep.nodeprep(string) => string
 *
 * Prepares a string in UTF-8 format according to the 'Nodeprep'
 * profile.
 *
 * Raises IDN::Stringprep::StringprepError on failure.
 */

static VALUE nodeprep(VALUE self, VALUE str)
{
  return stringprep_internal(str, "Nodeprep");
}

/*
 * call-seq:
 *   IDN::Stringprep.resourceprep(string) => string
 *
 * Prepares a string in UTF-8 format according to the 'Resourceprep'
 * profile.
 *
 * Raises IDN::Stringprep::StringprepError on failure.
 */

static VALUE resourceprep(VALUE self, VALUE str)
{
  return stringprep_internal(str, "Resourceprep");
}

/*
 * call-seq:
 *   IDN::Stringprep.with_profile(string, profile) => string
 *
 * Prepares a string in UTF-8 format according to the given stringprep
 * profile name which must be one of the internally supported stringprep
 * profiles (for details see IANA's Profile Names in RFC3454).
 *
 * Raises IDN::Stringprep::StringprepError on failure.
 */

static VALUE with_profile(VALUE self, VALUE str, VALUE profile)
{
  profile = rb_check_convert_type(profile, T_STRING, "String", "to_s");
  return stringprep_internal(str, RSTRING_PTR(profile));
}

/*
 * call-seq:
 *   IDN::Stringprep.nfkc_normalize(string) => string
 *
 * Converts a string in UTF-8 format into canonical form, standardizing
 * such issues as whether a character with an accent is represented as a
 * base character and combining accent or as a single precomposed character.
 */

static VALUE nfkc_normalize(VALUE self, VALUE str)
{
  char *buf;
  VALUE retv;

  str = rb_check_convert_type(str, T_STRING, "String", "to_s");
  buf = stringprep_utf8_nfkc_normalize(RSTRING_PTR(str), RSTRING_LEN(str));

  retv = rb_str_new2(buf);
  xfree(buf);
  return retv;
}

/*
 * Module Initialization.
 */

void init_stringprep(void)
{
#ifdef mIDN_RDOC_HACK
  mIDN = rb_define_module("IDN");
  eIDNError = rb_define_class_under(mIDN, "IDNError", rb_eStandardError);
#endif

  mStringprep = rb_define_module_under(mIDN, "Stringprep");
  eStringprepError = rb_define_class_under(mStringprep, "StringprepError",
                                           eIDNError);

  rb_define_singleton_method(mStringprep, "nameprep", nameprep, 1);
  rb_define_singleton_method(mStringprep, "nodeprep", nodeprep, 1);
  rb_define_singleton_method(mStringprep, "resourceprep", resourceprep, 1);
  rb_define_singleton_method(mStringprep, "with_profile", with_profile, 2);
  rb_define_singleton_method(mStringprep, "nfkc_normalize", nfkc_normalize, 1);
}
