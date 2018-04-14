module TZInfo
  # Represents a timezone defined by a data source.
  class TimezoneInfo
    
    # The timezone identifier.
    attr_reader :identifier
    
    # Constructs a new TimezoneInfo with an identifier.
    def initialize(identifier)
      @identifier = identifier
    end
    
    # Returns internal object state as a programmer-readable string.
    def inspect
      "#<#{self.class}: #@identifier>"
    end
    
    # Constructs a Timezone instance for the timezone represented by this
    # TimezoneInfo.
    def create_timezone
      raise_not_implemented('create_timezone')
    end

    private

    def raise_not_implemented(method_name)
      raise NotImplementedError, "Subclasses must override #{method_name}"
    end
  end
end
