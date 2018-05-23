# frozen_string_literal: true

module Timers
  # An individual timer set to fire a given proc at a given time. A timer is
  # always connected to a Timer::Group but it would ONLY be in @group.timers
  # if it also has a @handle specified. Otherwise it is either PAUSED or has
  # been FIRED and is not recurring. You can manually enter this state by
  # calling #cancel and resume normal operation by calling #reset.
  class Timer
    include Comparable
    attr_reader :interval, :offset, :recurring

    def initialize(group, interval, recurring = false, offset = nil, &block)
      @group = group

      @interval = interval
      @recurring = recurring
      @block = block
      @offset = offset

      @handle = nil

      # If a start offset was supplied, use that, otherwise use the current timers offset.
      reset(@offset || @group.current_offset)
    end

    def paused?
      @group.paused_timers.include? self
    end

    def pause
      return if paused?

      @group.timers.delete self
      @group.paused_timers.add self

      @handle.cancel! if @handle
      @handle = nil
    end

    def resume
      return unless paused?

      @group.paused_timers.delete self

      # This will add us back to the group:
      reset
    end

    alias continue resume

    # Extend this timer
    def delay(seconds)
      @handle.cancel! if @handle

      @offset += seconds

      @handle = @group.events.schedule(@offset, self)
    end

    # Cancel this timer. Do not call while paused.
    def cancel
      return unless @handle

      @handle.cancel! if @handle
      @handle = nil

      # This timer is no longer valid:
      @group.timers.delete self if @group
    end

    # Reset this timer. Do not call while paused.
    def reset(offset = @group.current_offset)
      # This logic allows us to minimise the interaction with @group.timers.
      # A timer with a handle is always registered with the group.
      if @handle
        @handle.cancel!
      else
        @group.timers << self
      end

      @offset = Float(offset) + @interval

      @handle = @group.events.schedule(@offset, self)
    end

    # Fire the block.
    def fire(offset = @group.current_offset)
      if recurring == :strict
        # ... make the next interval strictly the last offset + the interval:
        reset(@offset)
      elsif recurring
        reset(offset)
      else
        @offset = offset
      end

      @block.call(offset)

      cancel unless recurring
    end

    alias call fire

    # Number of seconds until next fire / since last fire
    def fires_in
      @offset - @group.current_offset if @offset
    end

    # Inspect a timer
    def inspect
      str = "#<Timers::Timer:#{object_id.to_s(16)} ".dup

      if @offset
        str << if fires_in >= 0
                 "fires in #{fires_in} seconds"
               else
                 "fired #{fires_in.abs} seconds ago"
               end

        str << ", recurs every #{interval}" if recurring
      else
        str << "dead"
      end

      str << ">"
    end
  end
end
