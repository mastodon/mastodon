module TZInfo
  # The country index file includes CountryIndexDefinition which provides
  # a country method used to define each country in the index.
  #
  # @private
  module CountryIndexDefinition #:nodoc:
    def self.append_features(base)
      super
      base.extend(ClassMethods)
      base.instance_eval { @countries = {} }
    end
    
    # Class methods for inclusion.
    #
    # @private
    module ClassMethods #:nodoc:
      # Defines a country with an ISO 3166 country code, name and block. The
      # block will be evaluated to obtain all the timezones for the country.
      # Calls Country.country_defined with the definition of each country.
      def country(code, name, &block)
        @countries[code] = RubyCountryInfo.new(code, name, &block)      
      end
      
      # Returns a frozen hash of all the countries that have been defined in
      # the index.
      def countries
        @countries.freeze
      end
    end
  end
end
