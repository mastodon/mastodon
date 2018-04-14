if !defined?(RUBY_ENGINE) || RUBY_ENGINE == 'ruby' || RUBY_ENGINE == 'rbx'
  Object.send(:remove_const, :FFI) if defined?(::FFI)
  begin
    require RUBY_VERSION.split('.')[0, 2].join('.') + '/ffi_c'
  rescue Exception
    require 'ffi_c'
  end

  require 'ffi/ffi'

elsif defined?(RUBY_ENGINE)
  # Remove the ffi gem dir from the load path, then reload the internal ffi implementation
  $LOAD_PATH.delete(File.dirname(__FILE__))
  $LOAD_PATH.delete(File.join(File.dirname(__FILE__), 'ffi'))
  unless $LOADED_FEATURES.nil?
    $LOADED_FEATURES.delete(__FILE__)
    $LOADED_FEATURES.delete('ffi.rb')
  end
  require 'ffi.rb'
end
