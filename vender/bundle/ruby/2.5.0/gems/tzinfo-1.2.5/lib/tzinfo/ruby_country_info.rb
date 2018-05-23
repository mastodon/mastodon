module TZInfo  
  # Represents information about a country returned by RubyDataSource.
  #
  # @private
  class RubyCountryInfo < CountryInfo #:nodoc:
    # Constructs a new CountryInfo with an ISO 3166 country code, name and 
    # block. The block will be evaluated to obtain the timezones for the 
    # country when the zones are first needed.
    def initialize(code, name, &block)
      super(code, name)
      @block = block
      @zones = nil
      @zone_identifiers = nil
    end
    
    # Returns a frozen array of all the zone identifiers for the country. These
    # are in the order they were added using the timezone method.
    def zone_identifiers
      # Thread-safety: It is possible that the value of @zone_identifiers may be 
      # calculated multiple times in concurrently executing threads. It is not 
      # worth the overhead of locking to ensure that @zone_identifiers is only 
      # calculated once.
    
      unless @zone_identifiers
        result = zones.collect {|zone| zone.identifier}.freeze
        return result if frozen?
        @zone_identifiers = result
      end
      
      @zone_identifiers
    end
    
    # Returns a frozen array of all the timezones for the for the country as
    # CountryTimezone instances. These are in the order they were added using 
    # the timezone method.
    def zones
      # Thread-safety: It is possible that the value of @zones may be 
      # calculated multiple times in concurrently executing threads. It is not 
      # worth the overhead of locking to ensure that @zones is only 
      # calculated once.
    
      unless @zones
        zones = Zones.new
        @block.call(zones) if @block
        result = zones.list.freeze
        return result if frozen?
        @block = nil
        @zones = result
      end
      
      @zones
    end
    
    # An instance of the Zones class is passed to the block used to define
    # timezones.
    #
    # @private
    class Zones #:nodoc:
      attr_reader :list
    
      def initialize
        @list = []
      end
    
      # Called by the index data to define a timezone for the country.
      def timezone(identifier, latitude_numerator, latitude_denominator, 
                   longitude_numerator, longitude_denominator, description = nil)          
        @list << CountryTimezone.new!(identifier, latitude_numerator, 
          latitude_denominator, longitude_numerator, longitude_denominator,
          description)     
      end
    end
  end
end
