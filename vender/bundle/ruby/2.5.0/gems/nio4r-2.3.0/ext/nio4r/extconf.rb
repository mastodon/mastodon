# frozen_string_literal: true

require "rubygems"

# Write a dummy Makefile on Windows because we use the pure Ruby implementation there
if Gem.win_platform?
  File.write("Makefile", "all install::\n")
  File.write("nio4r_ext.so", "")
  exit
end

require "mkmf"

have_header("unistd.h")

$defs << "-DEV_USE_SELECT"       if have_header("sys/select.h")
$defs << "-DEV_USE_POLL"         if have_type("port_event_t", "poll.h")
$defs << "-DEV_USE_EPOLL"        if have_header("sys/epoll.h")
$defs << "-DEV_USE_KQUEUE"       if have_header("sys/event.h") && have_header("sys/queue.h")
$defs << "-DEV_USE_PORT"         if have_type("port_event_t", "port.h")
$defs << "-DHAVE_SYS_RESOURCE_H" if have_header("sys/resource.h")

CONFIG["optflags"] << " -fno-strict-aliasing" unless RUBY_PLATFORM =~ /mswin/

dir_config "nio4r_ext"
create_makefile "nio4r_ext"
