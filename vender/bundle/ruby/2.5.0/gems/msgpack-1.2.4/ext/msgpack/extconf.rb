require 'mkmf'

have_header("ruby/st.h")
have_header("st.h")
have_func("rb_str_replace", ["ruby.h"])
have_func("rb_intern_str", ["ruby.h"])
have_func("rb_sym2str", ["ruby.h"])
have_func("rb_str_intern", ["ruby.h"])
have_func("rb_block_lambda", ["ruby.h"])
have_func("rb_hash_dup", ["ruby.h"])
have_func("rb_hash_clear", ["ruby.h"])

unless RUBY_PLATFORM.include? 'mswin'
  $CFLAGS << %[ -I.. -Wall -O3 -g -std=gnu99]
end
#$CFLAGS << %[ -DDISABLE_RMEM]
#$CFLAGS << %[ -DDISABLE_RMEM_REUSE_INTERNAL_FRAGMENT]
#$CFLAGS << %[ -DDISABLE_BUFFER_READ_REFERENCE_OPTIMIZE]
#$CFLAGS << %[ -DDISABLE_BUFFER_READ_TO_S_OPTIMIZE]

if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
  # msgpack-ruby doesn't modify data came from RSTRING_PTR(str)
  $CFLAGS << %[ -DRSTRING_NOT_MODIFIED]
  # Rubinius C extensions don't grab GVL while rmem is not thread safe
  $CFLAGS << %[ -DDISABLE_RMEM]
end

if warnflags = CONFIG['warnflags']
  warnflags.slice!(/ -Wdeclaration-after-statement/)
end

create_makefile('msgpack/msgpack')

