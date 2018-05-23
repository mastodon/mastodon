module TZInfo
  # Represents a defined timezone containing transition data.
  class DataTimezoneInfo < TimezoneInfo  
  
    # Returns the TimezonePeriod for the given UTC time.
    def period_for_utc(utc)
      raise_not_implemented('period_for_utc')
    end
    
    # Returns the set of TimezonePeriods for the given local time as an array.    
    # Results returned are ordered by increasing UTC start date.
    # Returns an empty array if no periods are found for the given time.
    def periods_for_local(local)
      raise_not_implemented('periods_for_local')
    end
    
    # Returns an Array of TimezoneTransition instances representing the times
    # where the UTC offset of the timezone changes.
    #
    # Transitions are returned up to a given date and time up to a given date 
    # and time, specified in UTC (utc_to).
    #
    # A from date and time may also be supplied using the utc_from parameter
    # (also specified in UTC). If utc_from is not nil, only transitions from 
    # that date and time onwards will be returned.
    #
    # Comparisons with utc_to are exclusive. Comparisons with utc_from are
    # inclusive. If a transition falls precisely on utc_to, it will be excluded.
    # If a transition falls on utc_from, it will be included.
    #
    # Transitions returned are ordered by when they occur, from earliest to 
    # latest.
    #
    # utc_to and utc_from can be specified using either DateTime, Time or 
    # integer timestamps (Time.to_i).
    #
    # If utc_from is specified and utc_to is not greater than utc_from, then
    # transitions_up_to raises an ArgumentError exception.
    def transitions_up_to(utc_to, utc_from = nil)
      raise_not_implemented('transitions_up_to')
    end
    
    # Constructs a Timezone instance for the timezone represented by this
    # DataTimezoneInfo.
    def create_timezone
      DataTimezone.new(self)
    end

    private

    def raise_not_implemented(method_name)
      raise NotImplementedError, "Subclasses must override #{method_name}"
    end
  end
end
