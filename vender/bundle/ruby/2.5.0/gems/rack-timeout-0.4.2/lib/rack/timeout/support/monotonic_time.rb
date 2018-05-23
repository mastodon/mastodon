require_relative "namespace"

# lifted from https://github.com/ruby-concurrency/concurrent-ruby/blob/master/lib/concurrent/utility/monotonic_time.rb

module Rack::Timeout::MonotonicTime
  extend self

  def fsecs_mono
    Process.clock_gettime Process::CLOCK_MONOTONIC
  end

  def fsecs_java
    java.lang.System.nanoTime() / 1_000_000_000.0
  end

  mutex = Mutex.new
  last_time = Time.now.to_f
  define_method(:fsecs_ruby) do
    now = Time.now.to_f
    mutex.synchronize { last_time = last_time < now ? now : last_time + 1e-6 }
  end

  case
  when defined? Process::CLOCK_MONOTONIC ; alias fsecs fsecs_mono
  when RUBY_PLATFORM == "java"           ; alias fsecs fsecs_java
  else                                   ; alias fsecs fsecs_ruby
  end

end
