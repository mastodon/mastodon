begin
  require "#{RUBY_VERSION[/\A[0-9]+\.[0-9]+/]}/unf_ext.so"
rescue LoadError
  require "unf_ext.so"
end
