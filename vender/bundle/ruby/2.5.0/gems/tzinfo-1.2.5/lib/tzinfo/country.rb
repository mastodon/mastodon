require 'thread_safe'

module TZInfo
  # Raised by Country#get if the code given is not valid.
  class InvalidCountryCode < StandardError
  end
  
  # The Country class represents an ISO 3166-1 country. It can be used to 
  # obtain a list of Timezones for a country. For example:
  #
  #  us = Country.get('US')
  #  us.zone_identifiers
  #  us.zones
  #  us.zone_info
  #
  # The Country class is thread-safe. It is safe to use class and instance 
  # methods of Country in concurrently executing threads. Instances of Country
  # can be shared across thread boundaries.
  #
  # Country information available through TZInfo is intended as an aid for 
  # users, to help them select time zone data appropriate for their practical 
  # needs. It is not intended to take or endorse any position on legal or 
  # territorial claims.
  class Country
    include Comparable
    
    # Defined countries.
    #
    # @!visibility private
    @@countries = nil
    
    # Whether the countries index has been loaded yet.
    #
    # @!visibility private
    @@index_loaded = false
    
    # Gets a Country by its ISO 3166-1 alpha-2 code. Raises an 
    # InvalidCountryCode exception if it couldn't be found.
    def self.get(identifier)
      instance = @@countries[identifier]
      
      unless instance
        # Thread-safety: It is possible that multiple equivalent Country 
        # instances could be created here in concurrently executing threads. 
        # The consequences of this are that the data may be loaded more than 
        # once (depending on the data source) and memoized calculations could
        # be discarded. The performance benefit of ensuring that only a single
        # instance is created is unlikely to be worth the overhead of only
        # allowing one Country to be loaded at a time.
        info = data_source.load_country_info(identifier)  
        instance = Country.new(info)
        @@countries[identifier] = instance
      end      
      
      instance        
    end
    
    # If identifier is a CountryInfo object, initializes the Country instance, 
    # otherwise calls get(identifier).
    def self.new(identifier)      
      if identifier.kind_of?(CountryInfo)
        instance = super()
        instance.send :setup, identifier
        instance
      else
        get(identifier)
      end
    end
    
    # Returns an Array of all the valid country codes.
    def self.all_codes
      data_source.country_codes
    end
    
    # Returns an Array of all the defined Countries.
    def self.all
      data_source.country_codes.collect {|code| get(code)}
    end       
    
    # The ISO 3166-1 alpha-2 country code.
    def code
      @info.code
    end
    
    # The name of the country.
    def name
      @info.name
    end
    
    # Alias for name.
    def to_s
      name
    end
    
    # Returns internal object state as a programmer-readable string.
    def inspect
      "#<#{self.class}: #{@info.code}>"
    end
    
    # Returns a frozen array of all the zone identifiers for the country. These
    # are in an order that
    #
    # 1. makes some geographical sense, and
    # 2. puts the most populous zones first, where that does not contradict 1.
    #
    # Returned zone identifiers may refer to cities and regions outside of the
    # country. This will occur if the zone covers multiple countries. Any zones
    # referring to a city or region in a different country will be listed after
    # those relating to this country.
    def zone_identifiers
      @info.zone_identifiers
    end
    alias zone_names zone_identifiers
    
    # An array of all the Timezones for this country. Returns TimezoneProxy
    # objects to avoid the overhead of loading Timezone definitions until
    # a conversion is actually required. The Timezones are returned in an order
    # that
    #
    # 1. makes some geographical sense, and
    # 2. puts the most populous zones first, where that does not contradict 1.
    #
    # Identifiers of the zones returned may refer to cities and regions outside
    # of the country. This will occur if the zone covers multiple countries. Any
    # zones referring to a city or region in a different country will be listed
    # after those relating to this country.
    def zones
      zone_identifiers.collect {|id|
        Timezone.get_proxy(id)        
      }
    end
    
    # Returns a frozen array of all the timezones for the for the country as
    # CountryTimezone instances (containing extra information about each zone). 
    # These are in an order that
    #
    # 1. makes some geographical sense, and
    # 2. puts the most populous zones first, where that does not contradict 1.
    #
    # Identifiers and descriptions of the zones returned may refer to cities and
    # regions outside of the country. This will occur if the zone covers
    # multiple countries. Any zones referring to a city or region in a different
    # country will be listed after those relating to this country.
    def zone_info
      @info.zones
    end
        
    # Compare two Countries based on their code. Returns -1 if c is less
    # than self, 0 if c is equal to self and +1 if c is greater than self.
    #
    # Returns nil if c is not comparable with Country instances.
    def <=>(c)
      return nil unless c.is_a?(Country)
      code <=> c.code
    end
    
    # Returns true if and only if the code of c is equal to the code of this
    # Country.
    def eql?(c)
      self == c
    end
    
    # Returns a hash value for this Country.
    def hash
      code.hash
    end
    
    # Dumps this Country for marshalling.
    def _dump(limit)
      code
    end
    
    # Loads a marshalled Country.
    def self._load(data)
      Country.get(data)
    end
    
    private
      # Called by Country.new to initialize a new Country instance. The info
      # parameter is a CountryInfo that defines the country.
      def setup(info)
        @info = info        
      end

      # Initializes @@countries.
      def self.init_countries
        @@countries = ThreadSafe::Cache.new
      end
      init_countries
      
      # Returns the current DataSource
      def self.data_source
        DataSource.get
      end
  end 
end
