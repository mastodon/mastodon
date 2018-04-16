# The ruby 2.0 stdlib includes the following changes
# to avoid "can't add a new key into hash during iteration" errors.
#   https://github.com/ruby/ruby/commit/3c491a92f6fbfecc065f7687c51c7d6d52a38883
#   https://github.com/ruby/ruby/commit/7b18633804c606e8bcccfbb44e7d7b795e777ea6
# However, these changes were not backported to the 1.9.x stdlib.
# These errors are causing intermittent errors in the tests (frequently in jruby),
# so we're applying those changes here. This is loaded by all rackups using WEBrick.
if RUBY_VERSION =~ /^1\.9/
  require 'webrick/utils'
  module WEBrick
    module Utils
      class TimeoutHandler
        def initialize
          @timeout_info = Hash.new
          Thread.start{
            while true
              now = Time.now
              @timeout_info.keys.each{|thread|
                ary = @timeout_info[thread]
                next unless ary
                ary.dup.each{|info|
                  time, exception = *info
                  interrupt(thread, info.object_id, exception) if time < now
                }
              }
              sleep 0.5
            end
          }
        end
      end
    end
  end
end

