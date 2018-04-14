
#--
# Copyright (c) 2008, 2009 Jeremy Hinegardner
# All rights reserved.  See LICENSE and/or COPYING for details.
#++

module Hitimes
  #
  # Metric hold the common meta information for all derived metric classes
  #
  # All metrics hold the meta information of:
  #
  # * The name of the metric
  # * The time of day the first measurement is taken
  # * The time of day the last measurement is taken
  # * additional data 
  #
  # Each derived class is assumed to set the sampling_start_time and
  # sampling_stop_time appropriately.
  # 
  # Metric itself should generally not be used.  Only use the derived classes.
  #
  class Metric

    # the number of seconds as a float since the sampling_start_time
    attr_reader :sampling_delta

    # An additional hash of data to associate with the metric
    attr_reader :additional_data

    # The 'name' to associate with the metric
    attr_reader :name

    #
    # :call-seq:
    #   Metric.new( 'my_metric' ) -> Metric
    #   Metric.new( 'my_metric', 'foo' => 'bar', 'this' => 42 ) -> Metric
    #
    # Create a new ValueMetric giving it a name and additional data.
    #
    # +additional_data+ may be anything that follows the +to_hash+ protocol.
    # +name+ may be anything that follows the +to_s+ protocol.
    #
    def initialize( name, additional_data = {} )
      @sampling_start_time     = nil
      @sampling_start_interval = nil
      @sampling_delta          = 0

      @name                = name.to_s
      @additional_data     = additional_data.to_hash
    end

    #
    # :call-seq: 
    #   metric.sampling_start_time -> Float or nil
    #
    # The time at which the first sample was taken.
    # This is the number of microseconds since UNIX epoch UTC as a Float
    #
    # If the metric has not started measuring then the start time is nil.
    #
    def sampling_start_time
      if @sampling_start_interval then
        @sampling_start_time ||= self.utc_microseconds()
      else
        nil
      end
    end

    #
    # :call-seq:
    #   metric.sampling_stop_time -> Float or nil
    #
    # The time at which the last sample was taken
    # This is the number of microseconds since UNIX epoch UTC as a Float
    # 
    # If the metric has not completely measured at least one thing then 
    # stop time is nil.
    #
    # Because accessing the actual 'time of day' is an expesive operation, we
    # only get the time of day at the beginning of the first measurement and we
    # keep track of the offset from that point in @sampling_delta.
    #
    # When sampling_stop_time is called, the actual time of day is caculated.
    #
    def sampling_stop_time
      if @sampling_delta > 0 then
        (self.sampling_start_time + (@sampling_delta * 1_000_000))
      else 
        nil
      end
    end

    #
    # :call-seq:
    #    metric.to_hash -> Hash
    #    metric.to_hash
    #
    # Convert the metric to a Hash.  
    #
    def to_hash
      { 'sampling_start_time' => self.sampling_start_time,
        'sampling_stop_time'  => self.sampling_stop_time,
        'additional_data'     => self.additional_data,
        'name'                => self.name }
    end

    #
    # :call-seq:
    #   metric.utc_microseconds -> Float
    #
    # The current time in microseconds from the UNIX Epoch in the UTC
    #
    def utc_microseconds
      Time.now.gmtime.to_f * 1_000_000
    end
  end
end
