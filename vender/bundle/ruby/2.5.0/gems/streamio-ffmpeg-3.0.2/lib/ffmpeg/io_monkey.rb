require 'timeout'
require 'thread'
if RUBY_PLATFORM =~ /(win|w)(32|64)$/
  begin
    require 'win32/process'
  rescue LoadError
    "Warning: streamio-ffmpeg is missing the win32-process gem to properly handle hung transcodings. Install the gem (in Gemfile if using bundler) to avoid errors."
  end
end

#
# Monkey Patch timeout support into the IO class
#
class IO
  def each_with_timeout(pid, seconds, sep_string=$/)
    last_update = Time.now

    current_thread = Thread.current
    check_update_thread = Thread.new do
      loop do
        sleep 0.1
        if last_update - Time.now < -seconds
          current_thread.raise Timeout::Error.new('output wait time expired')
        end
      end
    end

    each(sep_string) do |buffer|
      last_update = Time.now
      yield buffer
    end
  rescue Timeout::Error
    if RUBY_PLATFORM =~ /(win|w)(32|64)$/
      Process.kill(1, pid)
    else
      Process.kill('SIGKILL', pid)
    end
    raise
  ensure
    check_update_thread.kill
  end
end
