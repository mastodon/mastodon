module TZInfo
  # A Timezone within a Country. This contains extra information about the
  # Timezone that is specific to the Country (a Timezone could be used by
  # multiple countries).
  class CountryTimezone
    # The zone identifier.
    attr_reader :identifier      
    
    # A description of this timezone in relation to the country, e.g. 
    # "Eastern Time". This is usually nil for countries having only a single
    # Timezone.
    attr_reader :description
    
    class << self
      # Creates a new CountryTimezone with a timezone identifier, latitude,
      # longitude and description. The latitude and longitude are specified as
      # rationals - a numerator and denominator. For performance reasons, the 
      # numerators and denominators must be specified in their lowest form.
      #
      # For use internally within TZInfo.
      #
      # @!visibility private
      alias :new! :new
      
      # Creates a new CountryTimezone with a timezone identifier, latitude,
      # longitude and description. The latitude and longitude must be specified
      # as instances of Rational.
      #
      # CountryTimezone instances should normally only be constructed when
      # creating new DataSource implementations.
      def new(identifier, latitude, longitude, description = nil)
        super(identifier, latitude, nil, longitude, nil, description)      
      end
    end
    
    # Creates a new CountryTimezone with a timezone identifier, latitude,
    # longitude and description. The latitude and longitude are specified as
    # rationals - a numerator and denominator. For performance reasons, the 
    # numerators and denominators must be specified in their lowest form.
    #
    # @!visibility private
    def initialize(identifier, latitude_numerator, latitude_denominator, 
                   longitude_numerator, longitude_denominator, description = nil) #:nodoc:
      @identifier = identifier
      
      if latitude_numerator.kind_of?(Rational)
        @latitude = latitude_numerator
      else
        @latitude = nil
        @latitude_numerator = latitude_numerator
        @latitude_denominator = latitude_denominator
      end
      
      if longitude_numerator.kind_of?(Rational)
        @longitude = longitude_numerator
      else
        @longitude = nil
        @longitude_numerator = longitude_numerator
        @longitude_denominator = longitude_denominator
      end
        
      @description = description
    end
    
    # The Timezone (actually a TimezoneProxy for performance reasons).
    def timezone
      Timezone.get_proxy(@identifier)
    end
    
    # if description is not nil, this method returns description; otherwise it
    # returns timezone.friendly_identifier(true).
    def description_or_friendly_identifier
      description || timezone.friendly_identifier(true)
    end
    
    # The latitude of this timezone in degrees as a Rational.
    def latitude
      # Thread-safety: It is possible that the value of @latitude may be 
      # calculated multiple times in concurrently executing threads. It is not 
      # worth the overhead of locking to ensure that @latitude is only 
      # calculated once.
      unless @latitude
         result = RubyCoreSupport.rational_new!(@latitude_numerator, @latitude_denominator)
         return result if frozen?
         @latitude = result
      end

      @latitude
    end
    
    # The longitude of this timezone in degrees as a Rational.
    def longitude
      # Thread-safety: It is possible that the value of @longitude may be 
      # calculated multiple times in concurrently executing threads. It is not 
      # worth the overhead of locking to ensure that @longitude is only 
      # calculated once.
      unless @longitude
        result = RubyCoreSupport.rational_new!(@longitude_numerator, @longitude_denominator)
        return result if frozen?
        @longitude = result
      end

      @longitude
    end
    
    # Returns true if and only if the given CountryTimezone is equal to the
    # current CountryTimezone (has the same identifer, latitude, longitude
    # and description).
    def ==(ct)
      ct.kind_of?(CountryTimezone) &&
        identifier == ct.identifier  && latitude == ct.latitude &&
        longitude == ct.longitude   && description == ct.description         
    end
            
    # Returns true if and only if the given CountryTimezone is equal to the
    # current CountryTimezone (has the same identifer, latitude, longitude
    # and description).
    def eql?(ct)
      self == ct
    end
    
    # Returns a hash of this CountryTimezone. 
    def hash
      @identifier.hash ^ 
        (@latitude ? @latitude.numerator.hash ^ @latitude.denominator.hash : @latitude_numerator.hash ^ @latitude_denominator.hash) ^
        (@longitude ? @longitude.numerator.hash ^ @longitude.denominator.hash : @longitude_numerator.hash ^ @longitude_denominator.hash) ^
        @description.hash
    end
    
    # Returns internal object state as a programmer-readable string.
    def inspect
      "#<#{self.class}: #@identifier>"
    end
  end
end
