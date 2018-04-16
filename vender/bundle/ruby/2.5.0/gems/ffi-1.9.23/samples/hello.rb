require File.expand_path(File.join(File.dirname(__FILE__), "sample_helper"))
module Foo
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  attach_function("cputs", "puts", [ :string ], :int)
end
Foo.cputs("Hello, World via libc puts using FFI on MRI ruby")
