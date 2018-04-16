require 'mkmf'

build_hiredis = true
unless have_header('sys/socket.h')
  puts "Could not find <sys/socket.h> (Likely Windows)."
  puts "Skipping building hiredis. The slower, pure-ruby implementation will be used instead."
  build_hiredis = false
end

RbConfig::MAKEFILE_CONFIG['CC'] = ENV['CC'] if ENV['CC']

hiredis_dir = File.join(File.dirname(__FILE__), %w{.. .. vendor hiredis})
unless File.directory?(hiredis_dir)
  STDERR.puts "vendor/hiredis missing, please checkout its submodule..."
  exit 1
end

RbConfig::CONFIG['configure_args'] =~ /with-make-prog\=(\w+)/
make_program = $1 || ENV['make']
make_program ||= case RUBY_PLATFORM
when /mswin/
  'nmake'
when /(bsd|solaris)/
  'gmake'
else
  'make'
end

if build_hiredis
  # Make sure hiredis is built...
  Dir.chdir(hiredis_dir) do
    success = system("#{make_program} static")
    raise "Building hiredis failed" if !success
  end

  # Statically link to hiredis (mkmf can't do this for us)
  $CFLAGS << " -I#{hiredis_dir}"
  $LDFLAGS << " #{hiredis_dir}/libhiredis.a"

  have_func("rb_thread_fd_select")
  create_makefile('hiredis/ext/hiredis_ext')
else
  File.open("Makefile", "wb") do |f|
    dummy_makefile(".").each do |line|
      f.puts(line)
    end
  end
end
