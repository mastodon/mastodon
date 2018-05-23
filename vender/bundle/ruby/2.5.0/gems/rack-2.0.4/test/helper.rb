require 'minitest/autorun'

module Rack
  class TestCase < Minitest::Test
    # Check for Lighttpd and launch it for tests if available.
    `which lighttpd`

    if $?.success?
      begin
        # Keep this first.
        LIGHTTPD_PID = fork {
          ENV['RACK_ENV'] = 'deployment'
          ENV['RUBYLIB'] = [
            ::File.expand_path('../../lib', __FILE__),
            ENV['RUBYLIB'],
          ].compact.join(':')

          Dir.chdir(::File.expand_path("../cgi", __FILE__)) do
            exec "lighttpd -D -f lighttpd.conf"
          end
        }
      rescue NotImplementedError
        warn "Your Ruby doesn't support Kernel#fork. Skipping Rack::Handler::CGI and ::FastCGI tests."
      else
        Minitest.after_run do
          Process.kill 15, LIGHTTPD_PID
          Process.wait LIGHTTPD_PID
        end
      end
    else
      warn "Lighttpd isn't installed. Skipping Rack::Handler::CGI and FastCGI tests. Install lighttpd to run them."
    end
  end
end
