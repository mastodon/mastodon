module TZInfo
  # Represents a timezone that is defined as a link or alias to another zone.
  class LinkedTimezoneInfo < TimezoneInfo
        
    # The zone that provides the data (that this zone is an alias for).
    attr_reader :link_to_identifier
    
    # Constructs a new LinkedTimezoneInfo with an identifier and the identifier
    # of the zone linked to.
    def initialize(identifier, link_to_identifier)
      super(identifier)
      @link_to_identifier = link_to_identifier      
    end
    
    # Returns internal object state as a programmer-readable string.
    def inspect
      "#<#{self.class}: #@identifier,#@link_to_identifier>"
    end
    
    # Constructs a Timezone instance for the timezone represented by this
    # DataTimezoneInfo.
    def create_timezone
      LinkedTimezone.new(self)
    end
  end
end
