require 'thread'

module TZInfo
  # InvalidDataSource is raised if the DataSource is used doesn't implement one 
  # of the required methods.
  class InvalidDataSource < StandardError
  end
  
  # DataSourceNotFound is raised if no data source could be found (i.e. 
  # if 'tzinfo/data' cannot be found on the load path and no valid zoneinfo 
  # directory can be found on the system).
  class DataSourceNotFound < StandardError
  end

  # The base class for data sources of timezone and country data.
  #
  # Use DataSource.set to change the data source being used.
  class DataSource
    # The currently selected data source.
    @@instance = nil
    
    # Mutex used to ensure the default data source is only created once.
    @@default_mutex = Mutex.new
        
    # Returns the currently selected DataSource instance.
    def self.get
      # If a DataSource hasn't been manually set when the first request is
      # made to obtain a DataSource, then a Default data source is created.
      
      # This is done at the first request rather than when TZInfo is loaded to
      # avoid unnecessary (or in some cases potentially harmful) attempts to 
      # find a suitable DataSource.
      
      # A Mutex is used to ensure that only a single default instance is
      # created (having two different DataSources in use simultaneously could 
      # cause unexpected results).
      
      unless @@instance
        @@default_mutex.synchronize do
          set(create_default_data_source) unless @@instance
        end
      end      
      
      @@instance
    end
    
    # Sets the currently selected data source for Timezone and Country data.
    #
    # This should usually be set to one of the two standard data source types:
    #
    # * +:ruby+ - read data from the Ruby modules included in the TZInfo::Data 
    #   library (tzinfo-data gem).
    # * +:zoneinfo+ - read data from the zoneinfo files included with most
    #   Unix-like operating sytems (e.g. in /usr/share/zoneinfo).
    #
    # To set TZInfo to use one of the standard data source types, call
    # \TZInfo::DataSource.set in one of the following ways:
    #
    #   TZInfo::DataSource.set(:ruby)
    #   TZInfo::DataSource.set(:zoneinfo)
    #   TZInfo::DataSource.set(:zoneinfo, zoneinfo_dir)
    #   TZInfo::DataSource.set(:zoneinfo, zoneinfo_dir, iso3166_tab_file)
    #
    # \DataSource.set(:zoneinfo) will automatically search for the zoneinfo
    # directory by checking the paths specified in 
    # ZoneinfoDataSource.search_paths. ZoneinfoDirectoryNotFound will be raised
    # if no valid zoneinfo directory could be found.
    #
    # \DataSource.set(:zoneinfo, zoneinfo_dir) uses the specified zoneinfo
    # directory as the data source. If the directory is not a valid zoneinfo
    # directory, an InvalidZoneinfoDirectory exception will be raised.
    #
    # \DataSource.set(:zoneinfo, zoneinfo_dir, iso3166_tab_file) uses the
    # specified zoneinfo directory as the data source, but loads the iso3166.tab
    # file from an alternate path. If the directory is not a valid zoneinfo
    # directory, an InvalidZoneinfoDirectory exception will be raised.
    #
    # Custom data sources can be created by subclassing TZInfo::DataSource and
    # implementing the following methods:
    #
    # * \load_timezone_info
    # * \timezone_identifiers
    # * \data_timezone_identifiers
    # * \linked_timezone_identifiers
    # * \load_country_info
    # * \country_codes
    #
    # To have TZInfo use the custom data source, call \DataSource.set 
    # as follows:
    #
    #   TZInfo::DataSource.set(CustomDataSource.new)
    #
    # To avoid inconsistent data, \DataSource.set should be called before
    # accessing any Timezone or Country data.
    #
    # If \DataSource.set is not called, TZInfo will by default use TZInfo::Data 
    # as the data source. If TZInfo::Data is not available (i.e. if require 
    # 'tzinfo/data' fails), then TZInfo will search for a zoneinfo directory 
    # instead (using the search path specified by
    # TZInfo::ZoneinfoDataSource::DEFAULT_SEARCH_PATH).
    def self.set(data_source_or_type, *args)
      if data_source_or_type.kind_of?(DataSource)
        @@instance = data_source_or_type
      elsif data_source_or_type == :ruby
        @@instance = RubyDataSource.new
      elsif data_source_or_type == :zoneinfo
        @@instance = ZoneinfoDataSource.new(*args)
      else
        raise ArgumentError, 'data_source_or_type must be a DataSource instance or a data source type (:ruby)'
      end
    end
    
    # Returns a TimezoneInfo instance for a given identifier. The TimezoneInfo
    # instance should derive from either DataTimzoneInfo for timezones that
    # define their own data or LinkedTimezoneInfo for links or aliases to
    # other timezones.
    #
    # Raises InvalidTimezoneIdentifier if the timezone is not found or the 
    # identifier is invalid.
    def load_timezone_info(identifier)
      raise_invalid_data_source('load_timezone_info')
    end
    
    # Returns an array of all the available timezone identifiers.
    def timezone_identifiers
      raise_invalid_data_source('timezone_identifiers')
    end
    
    # Returns an array of all the available timezone identifiers for
    # data timezones (i.e. those that actually contain definitions).
    def data_timezone_identifiers
      raise_invalid_data_source('data_timezone_identifiers')
    end
    
    # Returns an array of all the available timezone identifiers that
    # are links to other timezones.
    def linked_timezone_identifiers
      raise_invalid_data_source('linked_timezone_identifiers')
    end
    
    # Returns a CountryInfo instance for the given ISO 3166-1 alpha-2
    # country code. Raises InvalidCountryCode if the country could not be found
    # or the code is invalid.
    def load_country_info(code)
      raise_invalid_data_source('load_country_info')
    end
    
    # Returns an array of all the available ISO 3166-1 alpha-2
    # country codes.
    def country_codes
      raise_invalid_data_source('country_codes')
    end
    
    # Returns the name of this DataSource.
    def to_s
      "Default DataSource"
    end
    
    # Returns internal object state as a programmer-readable string.
    def inspect
      "#<#{self.class}>"
    end
    
    private
    
    # Creates a DataSource instance for use as the default. Used if
    # no preference has been specified manually.
    def self.create_default_data_source
      has_tzinfo_data = false
      
      begin
        require 'tzinfo/data'
        has_tzinfo_data = true
      rescue LoadError
      end
    
      return RubyDataSource.new if has_tzinfo_data
      
      begin
        return ZoneinfoDataSource.new
      rescue ZoneinfoDirectoryNotFound
        raise DataSourceNotFound, "No source of timezone data could be found.\nPlease refer to http://tzinfo.github.io/datasourcenotfound for help resolving this error."
      end
    end

    def raise_invalid_data_source(method_name)
      raise InvalidDataSource, "#{method_name} not defined"
    end
  end
end
