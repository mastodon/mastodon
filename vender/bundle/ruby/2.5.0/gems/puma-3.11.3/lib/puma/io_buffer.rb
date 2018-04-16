require 'puma/detect'

if Puma.jruby?
  require 'puma/java_io_buffer'
else
  require 'puma/puma_http11'
end
