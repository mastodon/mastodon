#!/usr/bin/env ruby
require_relative "namespace"
require_relative "monotonic_time"

# Runs code at a later time
#
# Basic usage:
#
#     Scheduler.run_in(5) { do_stuff }  # <- calls do_stuff 5 seconds from now
#
# Scheduled events run in sequence in a separate thread, the main thread continues on.
# That means you may need to #join the scheduler if the main thread is only waiting on scheduled events to run.
#
#     Scheduler.join
#
# Basic usage is through a singleton instance, its methods are available as class methods, as shown above.
# One could also instantiate separate instances which would get you separate run threads, but generally there's no point in it.
class Rack::Timeout::Scheduler
  MAX_IDLE_SECS = 30 # how long the runner thread is allowed to live doing nothing
  include Rack::Timeout::MonotonicTime # gets us the #fsecs method

  # stores a proc to run later, and the time it should run at
  class RunEvent < Struct.new(:monotime, :proc)
    def cancel!
      @cancelled = true
    end

    def cancelled?
      !!@cancelled
    end

    def run!
      return if @cancelled
      proc.call(self)
    end
  end

  class RepeatEvent < RunEvent
    def initialize(monotime, proc, every)
      @start = monotime
      @every = every
      @iter  = 0
      super(monotime, proc)
    end

    def run!
      super
    ensure
      self.monotime = @start + @every * (@iter += 1) until monotime >= Rack::Timeout::MonotonicTime.fsecs
    end
  end

  def initialize
    @events    = []         # array of `RunEvent`s
    @mx_events = Mutex.new  # mutex to change said array
    @mx_runner = Mutex.new  # mutex for creating a runner thread
  end


  private

  # returns the runner thread, creating it if needed
  def runner
    @mx_runner.synchronize {
      return @runner unless @runner.nil? || !@runner.alive?
      @joined = false
      @runner = Thread.new { run_loop! }
    }
  end

  # the actual runner thread loop
  def run_loop!
    Thread.current.abort_on_exception = true                       # always be aborting
    sleep_for, run, last_run = nil, nil, fsecs                     # sleep_for: how long to sleep before next run; last_run: time of last run; run: just initializing it outside of the synchronize scope, will contain events to run now
    loop do                                                        # begin event reader loop
      @mx_events.synchronize {                                     #
        @events.reject!(&:cancelled?)                              # get rid of cancelled events
        if @events.empty?                                          # if there are no further events …
          return if @joined                                        # exit the run loop if this runner thread has been joined (the thread will die and the join will return)
          return if fsecs - last_run > MAX_IDLE_SECS               # exit the run loop if done nothing for the past MAX_IDLE_SECS seconds
          sleep_for = MAX_IDLE_SECS                                # sleep for MAX_IDLE_SECS (mind it that we get awaken when new events are scheduled)
        else                                                       #
          sleep_for = [@events.map(&:monotime).min - fsecs, 0].max # if we have events, set to sleep until it's time for the next one to run. (the max bit ensure we don't have negative sleep times)
        end                                                        #
        @mx_events.sleep sleep_for                                 # do sleep
                                                                   #
        now = fsecs                                                #
        run, defer = @events.partition { |ev| ev.monotime <= now } # separate events to run now and events to run later
        defer += run.select { |ev| ev.is_a? RepeatEvent }          # repeat events both run and are deferred
        @events.replace(defer)                                     # keep only events to run later
      }                                                            #
                                                                   #
      next if run.empty?                                           # done here if there's nothing to run now
      run.sort_by(&:monotime).each { |ev| ev.run! }                # run the events scheduled to run now
      last_run = fsecs                                             # store that we did run things at this time, go immediately on to the next loop iteration as it may be time to run more things
    end
  end


  public

  # waits on the runner thread to finish
  def join
    @joined = true
    runner.join
  end

  # adds a RunEvent struct to the run schedule
  def schedule(event)
    @mx_events.synchronize { @events << event }
    runner.run  # wakes up the runner thread so it can recalculate sleep length taking this new event into consideration
    return event
  end

  # reschedules an event by the given number of seconds. can be negative to run sooner.
  # returns nil and does nothing if the event is not already in the queue (might've run already), otherwise updates the event time in-place; returns the updated event.
  def delay(event, secs)
    @mx_events.synchronize {
      return unless @events.include? event
      event.monotime += secs
      runner.run
      return event
    }
  end

  # schedules a block to run in the given number of seconds; returns the created event object
  def run_in(secs, &block)
    schedule RunEvent.new(fsecs + secs, block)
  end

  # schedules a block to run every x seconds; returns the created event object
  def run_every(seconds, &block)
    schedule RepeatEvent.new(fsecs, block, seconds)
  end


  ### Singleton access

  # accessor to the singleton instance
  def self.singleton
    @singleton ||= new
  end

  # define public instance methods as class methods that delegate to the singleton instance
  instance_methods(false).each do |m|
    define_singleton_method(m) { |*a, &b| singleton.send(m, *a, &b) }
  end

end
