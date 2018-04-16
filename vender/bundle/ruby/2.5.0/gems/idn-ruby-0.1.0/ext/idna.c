/*
 * Copyright (c) 2005 Erik Abele. All rights reserved.
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
#include <idna.h>
#include "idn.h"

/*
 * Document-class: IDN::Idna
 * The Idna module of LibIDN Ruby Bindings.
 *
 * === Example usage
 *
 *   require 'idn'
 *   include IDN
 *
 *   puts 'ACE-Prefix: ' + Idna::ACE_PREFIX
 *
 *   domain = Idna.toUnicode('xn--rksmrgs-5wao1o.josefsson.org',
 *     Idna::USE_STD3_ASCII_RULES | Idna::ALLOW_UNASSIGNED)
 *
 * === Constants
 *
 * <b>ACE_PREFIX</b>
 * - The ACE prefix: 'xn--'.
 *
 * <b>ALLOW_UNASSIGNED</b>
 * - Used as flag for toASCII/toUnicode.
 *
 * <b>USE_STD3_ASCII_RULES</b>
 * - Used as flag for toASCII/toUnicode.
 */

VALUE mIdna;

/*
 * Document-class: IDN::Idna::IdnaError
 * The base class for all exceptions raised by the IDN::Idna module.
 */

VALUE eIdnaError;

/*
 * call-seq:
 *   IDN::Idna.toASCII(string, flags=nil) => string
 *
 * Converts a domain name in UTF-8 format into an ASCII string. The domain
 * name may contain several labels, separated by dots.
 *
 * Raises IDN::Idna::IdnaError on failure.
 */

static VALUE toASCII(int argc, VALUE argv[], VALUE self)
{
  int rc;
  char *buf;
  VALUE str, flags, retv;

  rb_scan_args(argc, argv, "11", &str, &flags);
  str = rb_check_convert_type(str, T_STRING, "String", "to_s");

  if (flags != Qnil) {
    Check_Type(flags, T_FIXNUM);
    flags = FIX2INT(flags);
  } else {
    flags = 0x0000;
  }

  rc = idna_to_ascii_8z(RSTRING_PTR(str), &buf, flags);

  if (rc != IDNA_SUCCESS) {
    xfree(buf);
    rb_raise(eIdnaError, "%s (%d)", idna_strerror(rc), rc);
    return Qnil;
  }

  retv = rb_str_new2(buf);
  xfree(buf);
  return retv;
}

/*
 * call-seq:
 *   IDN::Idna.toUnicode(string, flags=nil) => string
 *
 * Converts a possibly ACE encoded domain name in UTF-8 format into an
 * UTF-8 string. The domain name may contain several labels, separated
 * by dots.
 *
 * Raises IDN::Idna::IdnaError on failure.
 */

static VALUE toUnicode(int argc, VALUE argv[], VALUE self)
{
  int rc;
  char *buf;
  VALUE str, flags, retv;

  rb_scan_args(argc, argv, "11", &str, &flags);
  str = rb_check_convert_type(str, T_STRING, "String", "to_s");

  if (flags != Qnil) {
    Check_Type(flags, T_FIXNUM);
    flags = FIX2INT(flags);
  } else {
    flags = 0x0000;
  }

  rc = idna_to_unicode_8z8z(RSTRING_PTR(str), &buf, flags);

  if (rc != IDNA_SUCCESS) {
    xfree(buf);
    rb_raise(eIdnaError, "%s (%d)", idna_strerror(rc), rc);
    return Qnil;
  }

  retv = rb_enc_str_new(buf, strlen(buf), rb_utf8_encoding());
  xfree(buf);
  return retv;
}

/*
 * Module Initialization.
 */

void init_idna(void)
{
#ifdef mIDN_RDOC_HACK
  mIDN = rb_define_module("IDN");
  eIDNError = rb_define_class_under(mIDN, "IDNError", rb_eStandardError);
#endif

  mIdna = rb_define_module_under(mIDN, "Idna");
  eIdnaError = rb_define_class_under(mIdna, "IdnaError", eIDNError);

  rb_define_const(mIdna, "ACE_PREFIX",
                  rb_str_new2(IDNA_ACE_PREFIX));
  rb_define_const(mIdna, "ALLOW_UNASSIGNED",
                  INT2FIX(IDNA_ALLOW_UNASSIGNED));
  rb_define_const(mIdna, "USE_STD3_ASCII_RULES",
                  INT2FIX(IDNA_USE_STD3_ASCII_RULES));

  rb_define_singleton_method(mIdna, "toASCII", toASCII, -1);
  rb_define_singleton_method(mIdna, "toUnicode", toUnicode, -1);
}
