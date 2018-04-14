module TZInfo  
  # Represents information about a country returned by ZoneinfoDataSource.
  #
  # @private
  class ZoneinfoCountryInfo < CountryInfo #:nodoc:
    # Constructs a new CountryInfo with an ISO 3166 country code, name and 
    # an array of CountryTimezones.
    def initialize(code, name, zones)
      super(code, name)
      @zones = zones.dup.freeze
      @zone_identifiers = nil
    end
    
    # Returns a frozen array of all the zone identifiers for the country ordered
    # geographically, most populous first.
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
    
    # Returns a frozen array of all the timezones for the for the country 
    # ordered geographically, most populous first.
    def zones
      @zones
    end
  end
end
