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

#include <stdlib.h>
#include <ruby.h>
#include <stringprep.h>
#include <punycode.h>
#include "idn.h"

/*
 * Document-class: IDN::Punycode
 * The Punycode module of LibIDN Ruby Bindings.
 *
 * === Example usage
 *
 *   require 'idn'
 *   include IDN
 *
 *   str = Punycode.decode('egbpdaj6bu4bxfgehfvwxn')
 */

VALUE mPunycode;

/*
 * Document-class: IDN::Punycode::PunycodeError
 * The base class for all exceptions raised by the IDN::Punycode module.
 */

VALUE ePunycodeError;

/*
 * call-seq:
 *   IDN::Punycode.encode(string) => string
 *
 * Converts a string in UTF-8 format to Punycode.
 *
 * Raises IDN::Punycode::PunycodeError on failure.
 */

static VALUE encode(VALUE self, VALUE str)
{
  int rc;
  punycode_uint *ustr;
  size_t len;
  size_t buflen = 0x100;
  char *buf = NULL;
  VALUE retv;

  str = rb_check_convert_type(str, T_STRING, "String", "to_s");
  ustr = stringprep_utf8_to_ucs4(RSTRING_PTR(str), RSTRING_LEN(str), &len);

  while (1) {
    buf = realloc(buf, buflen);

    if (buf == NULL) {
      xfree(ustr);
      rb_raise(rb_eNoMemError, "cannot allocate memory (%d bytes)", (uint32_t)buflen);
      return Qnil;
    }

    rc = punycode_encode(len, ustr, NULL, &buflen, buf);

    if (rc == PUNYCODE_SUCCESS) {
      break;
    } else if (rc == PUNYCODE_BIG_OUTPUT) {
      buflen += 0x100;
    } else {
      xfree(ustr);
      xfree(buf);
      rb_raise(ePunycodeError, "%s (%d)", punycode_strerror(rc), rc);
      return Qnil;
    }
  }

  retv = rb_str_new(buf, buflen);
  xfree(ustr);
  xfree(buf);
  return retv;
}

/*
 * call-seq:
 *   IDN::Punycode.decode(string) => string
 *
 * Converts Punycode to a string in UTF-8 format.
 *
 * Raises IDN::Punycode::PunycodeError on failure.
 */

static VALUE decode(VALUE self, VALUE str)
{
  int rc;
  punycode_uint *ustr;
  size_t len;
  char *buf = NULL;
  VALUE retv;

  str = rb_check_convert_type(str, T_STRING, "String", "to_s");

  len = RSTRING_LEN(str);
  ustr = malloc(len * sizeof(punycode_uint));

  if (ustr == NULL) {
    rb_raise(rb_eNoMemError, "cannot allocate memory (%d bytes)", (uint32_t)len);
    return Qnil;
  }

  rc = punycode_decode(RSTRING_LEN(str), RSTRING_PTR(str),
                       &len, ustr, NULL);

  if (rc != PUNYCODE_SUCCESS) {
    xfree(ustr);
    rb_raise(ePunycodeError, "%s (%d)", punycode_strerror(rc), rc);
    return Qnil;
  }

  buf = stringprep_ucs4_to_utf8(ustr, len, NULL, &len);
  retv = rb_enc_str_new(buf, len, rb_utf8_encoding());
  xfree(ustr);
  xfree(buf);
  return retv;
}

/*
 * Module Initialization.
 */

void init_punycode(void)
{
#ifdef mIDN_RDOC_HACK
  mIDN = rb_define_module("IDN");
  eIDNError = rb_define_class_under(mIDN, "IDNError", rb_eStandardError);
#endif

  mPunycode = rb_define_module_under(mIDN, "Punycode");
  ePunycodeError = rb_define_class_under(mPunycode, "PunycodeError",
                                         eIDNError);

  rb_define_singleton_method(mPunycode, "encode", encode, 1);
  rb_define_singleton_method(mPunycode, "decode", decode, 1);
}
