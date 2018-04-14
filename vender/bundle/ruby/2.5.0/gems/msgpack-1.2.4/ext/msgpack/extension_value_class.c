/*
 * MessagePack for Ruby
 *
 * Copyright (C) 2008-2013 Sadayuki Furuhashi
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

#include "factory_class.h"

VALUE cMessagePack_ExtensionValue;

VALUE MessagePack_ExtensionValue_new(int ext_type, VALUE payload)
{
    return rb_struct_new(cMessagePack_ExtensionValue, INT2FIX(ext_type), payload);
}

void MessagePack_ExtensionValue_module_init(VALUE mMessagePack)
{
    /* rb_struct_define_under is not available ruby < 2.1 */
    //cMessagePack_ExtensionValue = rb_struct_define_under(mMessagePack, "ExtensionValue", "type", "payload", NULL);
    cMessagePack_ExtensionValue = rb_struct_define(NULL, "type", "payload", NULL);
    rb_define_const(mMessagePack, "ExtensionValue", cMessagePack_ExtensionValue);
}
