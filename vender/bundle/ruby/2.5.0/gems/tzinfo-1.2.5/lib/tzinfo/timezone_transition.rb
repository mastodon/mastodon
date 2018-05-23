module TZInfo
  # Represents a transition from one timezone offset to another at a particular
  # date and time.
  class TimezoneTransition
    # The offset this transition changes to (a TimezoneOffset instance).
    attr_reader :offset
    
    # The offset this transition changes from (a TimezoneOffset instance).
    attr_reader :previous_offset
    
    # Initializes a new TimezoneTransition.
    #
    # TimezoneTransition instances should not normally be constructed manually.
    def initialize(offset, previous_offset)
      @offset = offset
      @previous_offset = previous_offset
      @local_end_at = nil
      @local_start_at = nil
    end
    
    # A TimeOrDateTime instance representing the UTC time when this transition
    # occurs.
    def at
      raise_not_implemented('at')
    end
    
    # The UTC time when this transition occurs, returned as a DateTime instance.
    def datetime
      at.to_datetime
    end
    
    # The UTC time when this transition occurs, returned as a Time instance.
    def time
      at.to_time
    end
    
    # A TimeOrDateTime instance representing the local time when this transition
    # causes the previous observance to end (calculated from at using 
    # previous_offset).
    def local_end_at
      # Thread-safety: It is possible that the value of @local_end_at may be
      # calculated multiple times in concurrently executing threads. It is not 
      # worth the overhead of locking to ensure that @local_end_at is only
      # calculated once.
    
      unless @local_end_at
        result = at.add_with_convert(@previous_offset.utc_total_offset)
        return result if frozen?
        @local_end_at = result
      end

      @local_end_at
    end
    
    # The local time when this transition causes the previous observance to end,
    # returned as a DateTime instance.
    def local_end
      local_end_at.to_datetime
    end
    
    # The local time when this transition causes the previous observance to end,
    # returned as a Time instance.
    def local_end_time
      local_end_at.to_time
    end
    
    # A TimeOrDateTime instance representing the local time when this transition
    # causes the next observance to start (calculated from at using offset).
    def local_start_at
      # Thread-safety: It is possible that the value of @local_start_at may be
      # calculated multiple times in concurrently executing threads. It is not 
      # worth the overhead of locking to ensure that @local_start_at is only
      # calculated once.
    
      unless @local_start_at
        result = at.add_with_convert(@offset.utc_total_offset)
        return result if frozen?
        @local_start_at = result
      end

      @local_start_at
    end
    
    # The local time when this transition causes the next observance to start,
    # returned as a DateTime instance.
    def local_start
      local_start_at.to_datetime
    end
    
    # The local time when this transition causes the next observance to start,
    # returned as a Time instance.
    def local_start_time
      local_start_at.to_time
    end
    
    # Returns true if this TimezoneTransition is equal to the given
    # TimezoneTransition. Two TimezoneTransition instances are 
    # considered to be equal by == if offset, previous_offset and at are all 
    # equal.
    def ==(tti)
      tti.kind_of?(TimezoneTransition) &&
        offset == tti.offset && previous_offset == tti.previous_offset && at == tti.at
    end
    
    # Returns true if this TimezoneTransition is equal to the given
    # TimezoneTransition. Two TimezoneTransition instances are 
    # considered to be equal by eql? if offset, previous_offset and at are all
    # equal and the type used to define at in both instances is the same.
    def eql?(tti)
      tti.kind_of?(TimezoneTransition) &&
        offset == tti.offset && previous_offset == tti.previous_offset && at.eql?(tti.at)
    end
    
    # Returns a hash of this TimezoneTransition instance.
    def hash
      @offset.hash ^ @previous_offset.hash ^ at.hash
    end
    
    # Returns internal object state as a programmer-readable string.
    def inspect
      "#<#{self.class}: #{at.inspect},#{@offset.inspect}>"      
    end

    private

    def raise_not_implemented(method_name)
      raise NotImplementedError, "Subclasses must override #{method_name}"
    end
  end
end
