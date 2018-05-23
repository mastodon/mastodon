require 'rbconfig'
require 'mkmf'

if RbConfig::CONFIG['host_os'] =~ /darwin/ then
  $CFLAGS += " -DUSE_INSTANT_OSX=1 -Wall"
  $LDFLAGS += " -framework CoreServices"
elsif RbConfig::CONFIG['host_os'] =~ /win(32|64)/ or RbConfig::CONFIG['host_os'] =~ /mingw/ then
  $CFLAGS += " -DUSE_INSTANT_WINDOWS=1"
else
  if have_library("rt", "clock_gettime") then
    $CFLAGS += " -DUSE_INSTANT_CLOCK_GETTIME=1"
  elsif have_library("c", "clock_gettime") then
    $CFLAGS += " -DUSE_INSTANT_CLOCK_GETTIME=1"
  else
    raise NotImplementedError, <<-_
Unable to find the function 'clock_gettime' in either libc or librt.
Please file an issue at https://github.com/copiousfreetime/hitimes.
_
  end
end

# put in a different location if on windows so we can have fat binaries
subdir = RUBY_VERSION.gsub(/\.\d+$/,'')
create_makefile("hitimes/#{subdir}/hitimes")
