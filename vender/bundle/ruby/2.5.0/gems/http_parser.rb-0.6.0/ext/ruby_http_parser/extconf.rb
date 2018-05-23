require 'mkmf'

# check out code if it hasn't been already
if Dir[File.expand_path('../vendor/http-parser/*', __FILE__)].empty?
  Dir.chdir(File.expand_path('../../../', __FILE__)) do
    xsystem 'git submodule init'
    xsystem 'git submodule update'
  end
end

# mongrel and http-parser both define http_parser_(init|execute), so we
# rename functions in http-parser before using them.
vendor_dir = File.expand_path('../vendor/http-parser/', __FILE__)
src_dir = File.expand_path('../', __FILE__)
%w[ http_parser.c http_parser.h ].each do |file|
  File.open(File.join(src_dir, "ryah_#{file}"), 'w'){ |f|
    f.write File.read(File.join(vendor_dir, file)).gsub('http_parser', 'ryah_http_parser')
  }
end

$CFLAGS << " -I#{src_dir}"

dir_config("ruby_http_parser")
create_makefile("ruby_http_parser")
