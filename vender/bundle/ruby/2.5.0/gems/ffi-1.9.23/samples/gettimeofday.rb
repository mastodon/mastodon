require 'rubygems'
require 'ffi'
class Timeval < FFI::Struct
  rb_maj, rb_min, rb_micro = RUBY_VERSION.split('.')
  if rb_maj.to_i >= 1 && rb_min.to_i >= 9 || RUBY_PLATFORM =~ /java/
    layout :tv_sec => :ulong, :tv_usec => :ulong
  else
    layout :tv_sec, :ulong, 0, :tv_usec, :ulong, 4
  end
end
module LibC
  extend FFI::Library
  ffi_lib FFI::Library::LIBC
  attach_function :gettimeofday, [ :pointer, :pointer ], :int
end
t = Timeval.new
LibC.gettimeofday(t.pointer, nil)
puts "t.tv_sec=#{t[:tv_sec]} t.tv_usec=#{t[:tv_usec]}"
