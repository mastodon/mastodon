#--
# Copyright (c) 2008, 2009 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Hitimes
  #
  # A TimedValueMetric holds the metrics on how long it takes to do a batch of something.
  # something.  For measuring how long a method takes to operate on N items.
  #
  #   tm = TimedValueMetric.new( 'my-batch-method' )
  #
  #   42.times do 
  #     tm.start
  #     number_of_items_processed = do_something
  #     tm.stop( number_of_items_processed )
  #   end
  #
  #   puts "#{ tm.name } operated at a rate of #{ tm.rate } calls per second"
  #
  # TimedValueMetric combines the usefulness of a ValueMetric and a TimedMetric.
  # The stats are available for both the time it took to do the operation and
  # the sizes of the batches that were run.
  #
  # A TimedValueMetric keeps track of both the time it took to do an operation
  # and the size of the batch that was operated on.  These metrics are kept
  # separately as +timed_stats+ and +value_stats+ accessors.
  #
  class TimedValueMetric < Metric
    # holds all the Timed statistics
    attr_reader :timed_stats

    # holds all the Value statistics
    attr_reader :value_stats

    class << TimedValueMetric
      #
      # :call-seq:
      #   TimedValueMetric.now( 'name' ) -> TimedValueMetric
      #
      # Return a TimedValueMetric that has been started
      #
      def now( name, additional_data = {} )
        t = TimedValueMetric.new( name, additional_data )
        t.start
        return t
      end
    end

    #
    # :call-seq:
    #   TimedValueMetric.new( 'name') -> TimedValueMetric
    #   TimedValueMetric.new( 'name', 'other' => 'data') -> TimedValueMetric
    #
    # Create a new TimedValueMetric giving it a name and additional data.
    # +additional_data+ may be anything that follows the +to_hash+ protocol
    #
    def initialize( name, additional_data = {} )
      super( name, additional_data )
      @timed_stats      = Stats.new
      @value_stats      = Stats.new
      @current_interval = Interval.new
    end

    #
    # :call-seq:
    #   timed_value_metric.running? -> true or false
    #
    # return whether or not the metric is currently timing something.
    #
    def running?
      @current_interval.running?
    end

    # 
    # :call-seq:
    #   timed_value_metric.start -> nil
    #
    # Start the current timer, if the current timer is already started, then
    # this is a noop.  
    #
    def start
      if not @current_interval.running? then
        @current_interval.start
        @sampling_start_time ||= self.utc_microseconds() 
        @sampling_start_interval ||= Interval.now
      end
      nil
    end

    #
    # :call-seq:
    #   timed_value_metric.stop( count ) -> Float or nil
    #
    # Stop the current metric.  The +count+ parameter must be a
    # value to update to the _value_ portion of the TimedValueMetric.  Generally
    # this is probably the number of things that were operated upon since
    # +start+ was invoked.
    #
    # This updates both the +value_stats+ and +timed_stats+ stats and removes
    # the current interval. If the metric is stopped then the duration of the
    # last Interval is returned.  If the metric was already stopped before this
    # call, then false is returned and no stats are updated.
    # 
    #
    def stop( value )
      if @current_interval.running? then
        d = @current_interval.stop
        @timed_stats.update( d )
        @current_interval = Interval.new
        @value_stats.update( value )

        # update the lenght of time we have been sampling
        @sampling_delta = @sampling_start_interval.duration_so_far

        return d
      end
      return false
    end

    #
    # :call-seq:
    #   timed_value_metric.measure( value ) {  ... } -> Object
    #
    # Measure the execution of a block and add those stats to the running stats.
    # The return value is the return value of the block.  A value must be passed
    # into +measure+ to update the +value_stats+ portion of the TimedValueMetric.
    #
    def measure( value, &block )
      return_value = nil
      begin
        start
        return_value = yield
      ensure
        stop( value )
      end
      return return_value
    end

    #
    # :call-seq:
    #   timed_value_metric.split( value ) -> Float
    #
    # Split the current metric.  Essentially, mark a split time.  This means
    # stop the current interval, with the givein +value+ and create a new
    # interval, but make sure that the new interval lines up exactly, timewise,
    # behind the previous interval.
    #
    # If the metric is running, then split returns the duration of the previous
    # interval, i.e. the split-time.  If the metric is not running, nothing
    # happens, no stats are updated, and false is returned.  
    #
    #
    def split( value )
      if @current_interval.running? then 
        next_interval = @current_interval.split
        d = @current_interval.duration
        @timed_stats.update( d )
        @value_stats.update( value )
        @current_interval = next_interval 
        return d
      end 
      return false
    end

    #
    # :call-seq:
    #   timed_value_metric.duration -> Float
    #
    # The duration of measured time from the metric.
    #
    def duration
      @timed_stats.sum
    end

    #
    # :call-seq:
    #   timed_value_metric.unit_count -> Float
    #
    # The sum of all values passed to +stop+ or +skip+ or +measure+
    #
    def unit_count
      @value_stats.sum
    end

    #
    # :call-seq:
    #   timed_value_metric.rate -> Float
    #
    # Rate in the context of the TimedValueMetric is different than the
    # TimedMetric.  In the TimedValueMetric, each measurement of time is
    # associated with a quantity of things done during that unit of time.  So
    # the +rate+ for a TimedValueMetric is the (sum of all quantities sampled) /
    # ( sum of all durations measured )
    # 
    # For example, say you were measuring, using a TimedValueMetric batch jobs
    # that had individual units of work.
    #
    #   tvm = TimedValueMetric.new( 'some-batch' )
    #   tvm.start
    #   # process a batch of 12 units
    #   duration1 = tvm.stop( 12 )
    #
    #   tvm.start
    #   # process a larger batch of 42 units
    #   duration2 = tvm.stop( 42 )
    #
    # At this point the rate of units per second is calculated as ( 12 + 42 ) / ( duration1 + duration2 )
    #
    #   some_batch_rate = tvm.rate # returns ( 34 / ( duration1+duration2 ) )
    # 
    def rate
      @value_stats.sum / @timed_stats.sum
    end

    #
    # :call-seq:
    #   metric.to_hash -> Hash
    #   
    # Convert the metric to a hash
    #
    def to_hash
      h = super
      h['timed_stats'] = @timed_stats.to_hash
      h['value_stats'] = @value_stats.to_hash( Stats::STATS - %w[ rate ] )
      h['rate'] = self.rate
      h['unit_count'] = self.unit_count
      return h
    end


  end
end
