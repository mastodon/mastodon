require_relative "namespace"
require_relative "scheduler"

class Rack::Timeout::Scheduler::Timeout
  class Error < RuntimeError; end
  ON_TIMEOUT = ->thr { thr.raise Error, "execution expired" } # default action to take when a timeout happens

  # initializes a timeout object with an optional block to handle the timeout differently. the block is passed the thread that's gone overtime.
  def initialize(&on_timeout)
    @on_timeout = on_timeout || ON_TIMEOUT
    @scheduler  = Rack::Timeout::Scheduler.singleton
  end

  # takes number of seconds to wait before timing out, and code block subject to time out
  def timeout(secs, &block)
    return block.call if secs.nil? || secs.zero?            # skip timeout flow entirely for zero or nil
    thr = Thread.current                                    # reference to current thread to be used in timeout thread
    job = @scheduler.run_in(secs) { @on_timeout.call thr }  # schedule this thread to be timed out; should get cancelled if block completes on time
    return block.call                                       # do what you gotta do
  ensure                                                    #
    job.cancel! if job                                      # cancel the scheduled timeout job; if the block completed on time, this
  end                                                       # will get called before the timeout code's had a chance to run.

  # timeout method on singleton instance for when a custom on_timeout is not required
  def self.timeout(secs, &block)
    (@singleton ||= new).timeout(secs, &block)
  end

end
