# frozen_string_literal: true

require "set"
require "forwardable"
require "hitimes"

require "timers/timer"
require "timers/events"

module Timers
  # A collection of timers which may fire at different times
  class Group
    include Enumerable

    extend Forwardable
    def_delegators :@timers, :each, :empty?

    def initialize
      @events = Events.new

      @timers = Set.new
      @paused_timers = Set.new

      @interval = Hitimes::Interval.new
      @interval.start
    end

    # Scheduled events:
    attr_reader :events

    # Active timers:
    attr_reader :timers

    # Paused timers:
    attr_reader :paused_timers

    # Call the given block after the given interval. The first argument will be
    # the time at which the group was asked to fire timers for.
    def after(interval, &block)
      Timer.new(self, interval, false, &block)
    end

    # Call the given block immediately, and then after the given interval. The first
    # argument will be the time at which the group was asked to fire timers for.
    def now_and_after(interval, &block)
      yield
      after(interval, &block)
    end

    # Call the given block periodically at the given interval. The first
    # argument will be the time at which the group was asked to fire timers for.
    def every(interval, recur = true, &block)
      Timer.new(self, interval, recur, &block)
    end

    # Call the given block immediately, and then periodically at the given interval. The first
    # argument will be the time at which the group was asked to fire timers for.
    def now_and_every(interval, recur = true, &block)
      yield
      every(interval, recur, &block)
    end

    # Wait for the next timer and fire it. Can take a block, which should behave
    # like sleep(n), except that n may be nil (sleep forever) or a negative
    # number (fire immediately after return).
    def wait
      if block_given?
        yield wait_interval

        while (interval = wait_interval) && interval > 0
          yield interval
        end
      else
        while (interval = wait_interval) && interval > 0
          # We cannot assume that sleep will wait for the specified time, it might be +/- a bit.
          sleep interval
        end
      end

      fire
    end

    # Interval to wait until when the next timer will fire.
    # - nil: no timers
    # - -ve: timers expired already
    # -   0: timers ready to fire
    # - +ve: timers waiting to fire
    def wait_interval(offset = current_offset)
      handle = @events.first
      handle.time - Float(offset) if handle
    end

    # Fire all timers that are ready.
    def fire(offset = current_offset)
      @events.fire(offset)
    end

    # Pause all timers.
    def pause
      @timers.dup.each(&:pause)
    end

    # Resume all timers.
    def resume
      @paused_timers.dup.each(&:resume)
    end

    alias continue resume

    # Delay all timers.
    def delay(seconds)
      @timers.each do |timer|
        timer.delay(seconds)
      end
    end

    # Cancel all timers.
    def cancel
      @timers.dup.each(&:cancel)
    end

    # The group's current time.
    def current_offset
      @interval.to_f
    end
  end
end
