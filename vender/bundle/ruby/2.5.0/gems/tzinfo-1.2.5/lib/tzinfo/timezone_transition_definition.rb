module TZInfo
  # A TimezoneTransition defined by as integer timestamp, as a rational to
  # create a DateTime or as both.
  #
  # @private 
  class TimezoneTransitionDefinition < TimezoneTransition #:nodoc:
    # The numerator of the DateTime if the transition time is defined as a 
    # DateTime, otherwise the transition time as a timestamp.
    attr_reader :numerator_or_time
    protected :numerator_or_time
    
    # Either the denominator of the DateTime if the transition time is defined
    # as a DateTime, otherwise nil. 
    attr_reader :denominator
    protected :denominator
    
    # Creates a new TimezoneTransitionDefinition with the given offset, 
    # previous_offset (both TimezoneOffset instances) and UTC time.
    #
    # The time can be specified as a timestamp, as a rational to create a
    # DateTime, or as both.
    #
    # If both a timestamp and rational are given, then the rational will only
    # be used if the timestamp falls outside of the range of Time on the
    # platform being used at runtime.
    #
    # DateTimes are created from the rational as follows:
    # 
    #  RubyCoreSupport.datetime_new!(RubyCoreSupport.rational_new!(numerator, denominator), 0, Date::ITALY)
    #
    # For performance reasons, the numerator and denominator must be specified
    # in their lowest form.
    def initialize(offset, previous_offset, numerator_or_timestamp, denominator_or_numerator = nil, denominator = nil)
      super(offset, previous_offset)
      
      if denominator
        numerator = denominator_or_numerator
        timestamp = numerator_or_timestamp
      elsif denominator_or_numerator
        numerator = numerator_or_timestamp
        denominator = denominator_or_numerator
        timestamp = nil
      else
        numerator = nil
        denominator = nil
        timestamp = numerator_or_timestamp
      end
      
      # Determine whether to use the timestamp or the numerator and denominator.
      if numerator && (
        !timestamp || 
        (timestamp < 0 && !RubyCoreSupport.time_supports_negative) || 
        ((timestamp < -2147483648 || timestamp > 2147483647) && !RubyCoreSupport.time_supports_64bit)
        )
        
        @numerator_or_time = numerator
        @denominator = denominator
      else
        @numerator_or_time = timestamp
        @denominator = nil
      end
      
      @at = nil
    end
    
    # A TimeOrDateTime instance representing the UTC time when this transition
    # occurs.
    def at
      # Thread-safety: It is possible that the value of @at may be calculated
      # multiple times in concurrently executing threads. It is not worth the
      # overhead of locking to ensure that @at is only calculated once.
      
      unless @at
        result = unless @denominator
          TimeOrDateTime.new(@numerator_or_time)
        else
          r = RubyCoreSupport.rational_new!(@numerator_or_time, @denominator)
          dt = RubyCoreSupport.datetime_new!(r, 0, Date::ITALY)
          TimeOrDateTime.new(dt)
        end

        return result if frozen?
        @at = result
      end
      
      @at
    end
    
    # Returns true if this TimezoneTransitionDefinition is equal to the given
    # TimezoneTransitionDefinition. Two TimezoneTransitionDefinition instances 
    # are considered to be equal by eql? if offset, previous_offset, 
    # numerator_or_time and denominator are all equal.
    def eql?(tti)
      tti.kind_of?(TimezoneTransitionDefinition) &&
        offset == tti.offset && previous_offset == tti.previous_offset &&
        numerator_or_time == tti.numerator_or_time && denominator == tti.denominator        
    end
    
    # Returns a hash of this TimezoneTransitionDefinition instance.
    def hash
      @offset.hash ^ @previous_offset.hash ^ @numerator_or_time.hash ^ @denominator.hash
    end
  end
end
