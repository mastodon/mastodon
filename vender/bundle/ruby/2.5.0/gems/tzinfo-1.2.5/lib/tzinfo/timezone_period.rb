module TZInfo
  # A period of time in a timezone where the same offset from UTC applies.
  #
  # All the methods that take times accept instances of Time or DateTime as well
  # as Integer timestamps.
  class TimezonePeriod
    # The TimezoneTransition that defines the start of this TimezonePeriod 
    # (may be nil if unbounded).
    attr_reader :start_transition
    
    # The TimezoneTransition that defines the end of this TimezonePeriod
    # (may be nil if unbounded).
    attr_reader :end_transition
    
    # The TimezoneOffset for this period.
    attr_reader :offset
    
    # Initializes a new TimezonePeriod.
    #
    # TimezonePeriod instances should not normally be constructed manually.
    def initialize(start_transition, end_transition, offset = nil)
      @start_transition = start_transition
      @end_transition = end_transition
      
      if offset
        raise ArgumentError, 'Offset specified with transitions' if @start_transition || @end_transition
        @offset = offset
      else
        if @start_transition 
          @offset = @start_transition.offset
        elsif @end_transition
          @offset = @end_transition.previous_offset
        else
          raise ArgumentError, 'No offset specified and no transitions to determine it from'
        end
      end
      
      @utc_total_offset_rational = nil      
    end
            
    # The base offset of the timezone from UTC in seconds. This does not include
    # any adjustment made for daylight savings time and will typically remain
    # constant throughout the year.
    #
    # To obtain the currently observed offset from UTC, including the effect of
    # daylight savings time, use utc_total_offset instead.
    #
    # Note that zoneinfo files only include the value of utc_total_offset and a
    # DST flag. When using ZoneinfoDataSource, the utc_offset will be derived
    # from changes to the UTC total offset and the DST flag. As a consequence,
    # utc_total_offset will always be correct, but utc_offset may be inaccurate.
    #
    # If you require utc_offset to be accurate, install the tzinfo-data gem and
    # set RubyDataSource as the DataSource.
    def utc_offset
      @offset.utc_offset
    end
    
    # The offset from the time zone's standard time in seconds. Zero
    # when daylight savings time is not in effect. Non-zero (usually 3600 = 1
    # hour) if daylight savings is being observed.
    #
    # Note that zoneinfo files only include the value of utc_total_offset and
    # a DST flag. When using DataSources::ZoneinfoDataSource, the std_offset
    # will be derived from changes to the UTC total offset and the DST flag. As
    # a consequence, utc_total_offset will always be correct, but std_offset
    # may be inaccurate.
    #
    # If you require std_offset to be accurate, install the tzinfo-data gem
    # and set RubyDataSource as the DataSource.
    def std_offset
      @offset.std_offset
    end
    
    # The identifier of this period, e.g. "GMT" (Greenwich Mean Time) or "BST"
    # (British Summer Time) for "Europe/London". The returned identifier is a 
    # symbol.
    def abbreviation
      @offset.abbreviation
    end
    alias :zone_identifier :abbreviation
    
    # Total offset from UTC (seconds). Equal to utc_offset + std_offset.
    def utc_total_offset
      @offset.utc_total_offset
    end
    
    # Total offset from UTC (days). Result is a Rational.
    def utc_total_offset_rational
      # Thread-safety: It is possible that the value of 
      # @utc_total_offset_rational may be calculated multiple times in 
      # concurrently executing threads. It is not worth the overhead of locking
      # to ensure that @zone_identifiers is only calculated once.
    
      unless @utc_total_offset_rational
        result = OffsetRationals.rational_for_offset(utc_total_offset)
        return result if frozen?
        @utc_total_offset_rational = result
      end
      @utc_total_offset_rational
    end
    
    # The start time of the period in UTC as a DateTime. May be nil if unbounded.
    def utc_start
      @start_transition ? @start_transition.at.to_datetime : nil
    end
    
    # The start time of the period in UTC as a Time. May be nil if unbounded.
    def utc_start_time
      @start_transition ? @start_transition.at.to_time : nil
    end
    
    # The end time of the period in UTC as a DateTime. May be nil if unbounded.
    def utc_end
      @end_transition ? @end_transition.at.to_datetime : nil
    end
    
    # The end time of the period in UTC as a Time. May be nil if unbounded.
    def utc_end_time
      @end_transition ? @end_transition.at.to_time : nil
    end
    
    # The start time of the period in local time as a DateTime. May be nil if 
    # unbounded.
    def local_start
      @start_transition ? @start_transition.local_start_at.to_datetime : nil
    end
    
    # The start time of the period in local time as a Time. May be nil if 
    # unbounded.
    def local_start_time
      @start_transition ? @start_transition.local_start_at.to_time : nil
    end
    
    # The end time of the period in local time as a DateTime. May be nil if 
    # unbounded.
    def local_end
      @end_transition ? @end_transition.local_end_at.to_datetime : nil
    end
    
    # The end time of the period in local time as a Time. May be nil if 
    # unbounded.
    def local_end_time
      @end_transition ? @end_transition.local_end_at.to_time : nil
    end
    
    # true if daylight savings is in effect for this period; otherwise false.
    def dst?
      @offset.dst?
    end
    
    # true if this period is valid for the given UTC DateTime; otherwise false.
    #
    # Deprecation warning: this method will be removed in TZInfo version 2.0.0.
    def valid_for_utc?(utc)
      utc_after_start?(utc) && utc_before_end?(utc) 
    end
    
    # true if the given UTC DateTime is after the start of the period 
    # (inclusive); otherwise false.
    #
    # Deprecation warning: this method will be removed in TZInfo version 2.0.0.
    def utc_after_start?(utc)
      !@start_transition || @start_transition.at <= utc
    end
    
    # true if the given UTC DateTime is before the end of the period 
    # (exclusive); otherwise false.
    #
    # Deprecation warning: this method will be removed in TZInfo version 2.0.0.
    def utc_before_end?(utc)
      !@end_transition || @end_transition.at > utc
    end
    
    # true if this period is valid for the given local DateTime; otherwise
    # false.
    #
    # Deprecation warning: this method will be removed in TZInfo version 2.0.0.
    def valid_for_local?(local)      
      local_after_start?(local) && local_before_end?(local) 
    end
    
    # true if the given local DateTime is after the start of the period 
    # (inclusive); otherwise false.
    #
    # Deprecation warning: this method will be removed in TZInfo version 2.0.0.
    def local_after_start?(local)
      !@start_transition || @start_transition.local_start_at <= local
    end
    
    # true if the given local DateTime is before the end of the period 
    # (exclusive); otherwise false.
    #
    # Deprecation warning: this method will be removed in TZInfo version 2.0.0.
    def local_before_end?(local)
      !@end_transition || @end_transition.local_end_at > local
    end
    
    # Converts a UTC DateTime to local time based on the offset of this period.
    #
    # Deprecation warning: this method will be removed in TZInfo version 2.0.0.
    def to_local(utc)
      @offset.to_local(utc)
    end
    
    # Converts a local DateTime to UTC based on the offset of this period.
    #
    # Deprecation warning: this method will be removed in TZInfo version 2.0.0.
    def to_utc(local)
      @offset.to_utc(local)
    end
    
    # Returns true if this TimezonePeriod is equal to p. This compares the 
    # start_transition, end_transition and offset using ==.
    def ==(p)
      p.kind_of?(TimezonePeriod) &&
        start_transition == p.start_transition &&
        end_transition == p.end_transition &&
        offset == p.offset
    end
    
    # Returns true if this TimezonePeriods is equal to p. This compares the
    # start_transition, end_transition and offset using eql?
    def eql?(p)
      p.kind_of?(TimezonePeriod) &&
        start_transition.eql?(p.start_transition) &&
        end_transition.eql?(p.end_transition) &&
        offset.eql?(p.offset)
    end
    
    # Returns a hash of this TimezonePeriod.
    def hash
      result = @start_transition.hash ^ @end_transition.hash
      result ^= @offset.hash unless @start_transition || @end_transition
      result       
    end
    
    # Returns internal object state as a programmer-readable string.
    def inspect
      result = "#<#{self.class}: #{@start_transition.inspect},#{@end_transition.inspect}"
      result << ",#{@offset.inspect}>" unless @start_transition || @end_transition
      result + '>'
    end
  end
end
