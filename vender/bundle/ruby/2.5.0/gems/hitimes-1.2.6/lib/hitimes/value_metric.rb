#--
# Copyright (c) 2008, 2009 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

require 'forwardable'
module Hitimes
  #
  # A ValueMetric holds the data from measuring a single value over a period of
  # time.  In most cases this may be a single measurement at a single point in
  # time.
  #
  # A good example of a ValueMetric is measuring the number of items in a queue.
  #
  # A ValueMetric contains a Stats object, therefore ValueMetric has +count+, +max+, 
  # +mean+, +min+, +stddev+, +sum+, +sumsq+ methods that delegate to that Stats
  # object for convenience.
  #
  class ValueMetric < Metric

    # holds all the statistics
    attr_reader :stats
    
    #
    # :call-seq:
    #   ValueMetric.new( 'my_metric' ) -> ValueMetric
    #   ValueMetric.new( 'my_metric', 'foo' => 'bar', 'this' => 42 ) -> ValueMetric
    #
    # Create a new ValueMetric giving it a name and additional data.
    # +additional_data+ may be anything that follows the +to_hash+ protocol.
    #
    def initialize( name, additional_data = {} )
      super( name, additional_data )
      @stats = Stats.new
    end

    #
    # :call-seq:
    #   metric.measure( value ) -> Float
    #
    # Give the +value+ as the measurement to the metric.  The value is returned
    #
    def measure( value )
      @sampling_start_time ||= self.utc_microseconds()
      @sampling_start_interval ||= Interval.now

      @stats.update( value )
      
      # update the length of time we have been sampling
      @sampling_delta = @sampling_start_interval.duration_so_far
    end

    #
    # :call-seq:
    #   metric.to_hash -> Hash
    #   
    # Convert the metric to a hash
    #
    def to_hash
      h = super
      (Stats::STATS - %w[ rate ]).each do |s|
        h[s] = self.send( s ) 
      end
      return h
    end

    # forward appropriate calls directly to the stats object
    extend Forwardable
    def_delegators :@stats, :count, :max, :mean, :min, :stddev, :sum, :sumsq
  end
end
