module TZInfo
  # The timezone index file includes TimezoneIndexDefinition which provides
  # methods used to define timezones in the index.
  #
  # @private
  module TimezoneIndexDefinition #:nodoc:
    # Add class methods to the includee and initialize class instance variables.
    def self.append_features(base)
      super
      base.extend(ClassMethods)
      base.instance_eval do
        @timezones = []
        @data_timezones = []
        @linked_timezones = []
      end
    end
    
    # Class methods for inclusion.
    #
    # @private
    module ClassMethods #:nodoc:
      # Defines a timezone based on data.
      def timezone(identifier)
        @timezones << identifier
        @data_timezones << identifier
      end
      
      # Defines a timezone which is a link to another timezone.
      def linked_timezone(identifier)
        @timezones << identifier
        @linked_timezones << identifier
      end
      
      # Returns a frozen array containing the identifiers of all the timezones.
      # Identifiers appear in the order they were defined in the index.
      def timezones
        @timezones.freeze
      end
      
      # Returns a frozen array containing the identifiers of all data timezones.
      # Identifiers appear in the order they were defined in the index.
      def data_timezones
        @data_timezones.freeze
      end
      
      # Returns a frozen array containing the identifiers of all linked
      # timezones. Identifiers appear in the order they were defined in 
      # the index.
      def linked_timezones
        @linked_timezones.freeze
      end      
    end
  end
end
