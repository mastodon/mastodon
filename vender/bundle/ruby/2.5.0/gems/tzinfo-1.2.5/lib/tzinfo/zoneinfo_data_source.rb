module TZInfo
  # An InvalidZoneinfoDirectory exception is raised if the DataSource is
  # set to a specific zoneinfo path, which is not a valid zoneinfo directory
  # (i.e. a directory containing index files named iso3166.tab and zone.tab
  # as well as other timezone files).
  class InvalidZoneinfoDirectory < StandardError
  end
  
  # A ZoneinfoDirectoryNotFound exception is raised if no valid zoneinfo 
  # directory could be found when checking the paths listed in
  # ZoneinfoDataSource.search_path. A valid zoneinfo directory is one that
  # contains timezone files, a country code index file named iso3166.tab and a
  # timezone index file named zone1970.tab or zone.tab.
  class ZoneinfoDirectoryNotFound < StandardError
  end
  
  # A DataSource that loads data from a 'zoneinfo' directory containing
  # compiled "TZif" version 3 (or earlier) files in addition to iso3166.tab and
  # zone1970.tab or zone.tab index files.
  #
  # To have TZInfo load the system zoneinfo files, call TZInfo::DataSource.set 
  # as follows:
  #
  #   TZInfo::DataSource.set(:zoneinfo)
  #
  # To load zoneinfo files from a particular directory, pass the directory to 
  # TZInfo::DataSource.set:
  #
  #   TZInfo::DataSource.set(:zoneinfo, directory)
  #
  # Note that the platform used at runtime may limit the range of available
  # transition data that can be loaded from zoneinfo files. There are two
  # factors to consider:
  #
  # First of all, the zoneinfo support in TZInfo makes use of Ruby's Time class. 
  # On 32-bit builds of Ruby 1.8, the Time class only supports 32-bit 
  # timestamps. This means that only Times between 1901-12-13 20:45:52 and
  # 2038-01-19 03:14:07 can be represented. Furthermore, certain platforms only
  # allow for positive 32-bit timestamps (notably Windows), making the earliest
  # representable time 1970-01-01 00:00:00.
  #
  # 64-bit builds of Ruby 1.8 and all builds of Ruby 1.9 support 64-bit 
  # timestamps. This means that there is no practical restriction on the range
  # of the Time class on these platforms.
  #
  # TZInfo will only load transitions that fall within the supported range of
  # the Time class. Any queries performed on times outside of this range may
  # give inaccurate results.
  #
  # The second factor concerns the zoneinfo files. Versions of the 'zic' tool
  # (used to build zoneinfo files) that were released prior to February 2006
  # created zoneinfo files that used 32-bit integers for transition timestamps.
  # Later versions of zic produce zoneinfo files that use 64-bit integers. If
  # you have 32-bit zoneinfo files on your system, then any queries falling
  # outside of the range 1901-12-13 20:45:52 to 2038-01-19 03:14:07 may be
  # inaccurate.
  #
  # Most modern platforms include 64-bit zoneinfo files. However, Mac OS X (up
  # to at least 10.8.4) still uses 32-bit zoneinfo files.
  #
  # To check whether your zoneinfo files contain 32-bit or 64-bit transition
  # data, you can run the following code (substituting the identifier of the 
  # zone you want to test for zone_identifier):
  #
  #   TZInfo::DataSource.set(:zoneinfo)
  #   dir = TZInfo::DataSource.get.zoneinfo_dir
  #   File.open(File.join(dir, zone_identifier), 'r') {|f| f.read(5) }
  #
  # If the last line returns "TZif\\x00", then you have a 32-bit zoneinfo file.
  # If it returns "TZif2" or "TZif3" then you have a 64-bit zoneinfo file.
  #
  # If you require support for 64-bit transitions, but are restricted to 32-bit
  # zoneinfo support, then you may want to consider using TZInfo::RubyDataSource 
  # instead.
  class ZoneinfoDataSource < DataSource
    # The default value of ZoneinfoDataSource.search_path.
    DEFAULT_SEARCH_PATH = ['/usr/share/zoneinfo', '/usr/share/lib/zoneinfo', '/etc/zoneinfo'].freeze
    
    # The default value of ZoneinfoDataSource.alternate_iso3166_tab_search_path.
    DEFAULT_ALTERNATE_ISO3166_TAB_SEARCH_PATH = ['/usr/share/misc/iso3166.tab', '/usr/share/misc/iso3166'].freeze
    
    # Paths to be checked to find the system zoneinfo directory.
    @@search_path = DEFAULT_SEARCH_PATH.dup
    
    # Paths to possible alternate iso3166.tab files (used to locate the 
    # system-wide iso3166.tab files on FreeBSD and OpenBSD).
    @@alternate_iso3166_tab_search_path = DEFAULT_ALTERNATE_ISO3166_TAB_SEARCH_PATH.dup
    
    # An Array of directories that will be checked to find the system zoneinfo
    # directory.
    #
    # Directories are checked in the order they appear in the Array.
    #
    # The default value is ['/usr/share/zoneinfo', '/usr/share/lib/zoneinfo', '/etc/zoneinfo'].
    def self.search_path
      @@search_path
    end
    
    # Sets the directories to be checked when locating the system zoneinfo 
    # directory.
    #
    # Can be set to an Array of directories or a String containing directories
    # separated with File::PATH_SEPARATOR.
    #
    # Directories are checked in the order they appear in the Array or String.
    #
    # Set to nil to revert to the default paths.
    def self.search_path=(search_path)
      @@search_path = process_search_path(search_path, DEFAULT_SEARCH_PATH)      
    end
    
    # An Array of paths that will be checked to find an alternate iso3166.tab 
    # file if one was not included in the zoneinfo directory (for example, on 
    # FreeBSD and OpenBSD systems).
    #
    # Paths are checked in the order they appear in the array.
    #
    # The default value is ['/usr/share/misc/iso3166.tab', '/usr/share/misc/iso3166'].
    def self.alternate_iso3166_tab_search_path
      @@alternate_iso3166_tab_search_path
    end
    
    # Sets the paths to check to locate an alternate iso3166.tab file if one was
    # not included in the zoneinfo directory.
    #
    # Can be set to an Array of directories or a String containing directories
    # separated with File::PATH_SEPARATOR.
    #
    # Paths are checked in the order they appear in the array.
    #
    # Set to nil to revert to the default paths.
    def self.alternate_iso3166_tab_search_path=(alternate_iso3166_tab_search_path)
      @@alternate_iso3166_tab_search_path = process_search_path(alternate_iso3166_tab_search_path, DEFAULT_ALTERNATE_ISO3166_TAB_SEARCH_PATH)
    end
    
    # The zoneinfo directory being used.
    attr_reader :zoneinfo_dir
    
    # Creates a new ZoneinfoDataSource.
    #
    # If zoneinfo_dir is specified, it will be checked and used as the source
    # of zoneinfo files. 
    #
    # The directory must contain a file named iso3166.tab and a file named
    # either zone1970.tab or zone.tab. These may either be included in the root
    # of the directory or in a 'tab' sub-directory and named 'country.tab' and
    # 'zone_sun.tab' respectively (as is the case on Solaris.
    #
    # Additionally, the path to iso3166.tab can be overridden using the 
    # alternate_iso3166_tab_path parameter.
    #
    # InvalidZoneinfoDirectory will be raised if the iso3166.tab and
    # zone1970.tab or zone.tab files cannot be found using the zoneinfo_dir and
    # alternate_iso3166_tab_path parameters.
    # 
    # If zoneinfo_dir is not specified or nil, the paths referenced in
    # search_path are searched in order to find a valid zoneinfo directory 
    # (one that contains zone1970.tab or zone.tab and iso3166.tab files as
    # above).
    #
    # The paths referenced in alternate_iso3166_tab_search_path are also
    # searched to find an iso3166.tab file if one of the searched zoneinfo
    # directories doesn't contain an iso3166.tab file.
    # 
    # If no valid directory can be found by searching, ZoneinfoDirectoryNotFound
    # will be raised.
    def initialize(zoneinfo_dir = nil, alternate_iso3166_tab_path = nil)
      if zoneinfo_dir
        iso3166_tab_path, zone_tab_path = validate_zoneinfo_dir(zoneinfo_dir, alternate_iso3166_tab_path)
      
        unless iso3166_tab_path && zone_tab_path
          raise InvalidZoneinfoDirectory, "#{zoneinfo_dir} is not a directory or doesn't contain a iso3166.tab file and a zone1970.tab or zone.tab file." 
        end
        
        @zoneinfo_dir = zoneinfo_dir
      else
        @zoneinfo_dir, iso3166_tab_path, zone_tab_path = find_zoneinfo_dir
        
        unless @zoneinfo_dir && iso3166_tab_path && zone_tab_path
          raise ZoneinfoDirectoryNotFound, "None of the paths included in TZInfo::ZoneinfoDataSource.search_path are valid zoneinfo directories."
        end
      end
      
      @zoneinfo_dir = File.expand_path(@zoneinfo_dir).freeze
      @timezone_index = load_timezone_index.freeze
      @country_index = load_country_index(iso3166_tab_path, zone_tab_path).freeze
    end
    
    # Returns a TimezoneInfo instance for a given identifier. 
    # Raises InvalidTimezoneIdentifier if the timezone is not found or the 
    # identifier is invalid.
    def load_timezone_info(identifier)
      begin
        if @timezone_index.include?(identifier)
          path = File.join(@zoneinfo_dir, identifier)
          
          # Untaint path rather than identifier. We don't want to modify 
          # identifier. identifier may also be frozen and therefore cannot be
          # untainted.
          path.untaint
          
          begin
            ZoneinfoTimezoneInfo.new(identifier, path)
          rescue InvalidZoneinfoFile => e
            raise InvalidTimezoneIdentifier, e.message
          end
        else
          raise InvalidTimezoneIdentifier, 'Invalid identifier'
        end
      rescue Errno::ENOENT, Errno::ENAMETOOLONG, Errno::ENOTDIR
        raise InvalidTimezoneIdentifier, 'Invalid identifier'
      rescue Errno::EACCES => e
        raise InvalidTimezoneIdentifier, e.message
      end
    end    
    
    # Returns an array of all the available timezone identifiers.
    def timezone_identifiers
      @timezone_index
    end
    
    # Returns an array of all the available timezone identifiers for
    # data timezones (i.e. those that actually contain definitions).
    #
    # For ZoneinfoDataSource, this will always be identical to 
    # timezone_identifers.
    def data_timezone_identifiers
      @timezone_index
    end
    
    # Returns an array of all the available timezone identifiers that
    # are links to other timezones.
    #
    # For ZoneinfoDataSource, this will always be an empty array.
    def linked_timezone_identifiers
      [].freeze
    end
    
    # Returns a CountryInfo instance for the given ISO 3166-1 alpha-2
    # country code. Raises InvalidCountryCode if the country could not be found
    # or the code is invalid.
    def load_country_info(code)
      info = @country_index[code]
      raise InvalidCountryCode, 'Invalid country code' unless info
      info
    end
    
    # Returns an array of all the available ISO 3166-1 alpha-2
    # country codes.
    def country_codes
      @country_index.keys.freeze
    end
    
    # Returns the name and information about this DataSource.
    def to_s
      "Zoneinfo DataSource: #{@zoneinfo_dir}"
    end
    
    # Returns internal object state as a programmer-readable string.
    def inspect
      "#<#{self.class}: #{@zoneinfo_dir}>"
    end    
    
    private
    
    # Processes a path for use as the search_path or
    # alternate_iso3166_tab_search_path.
    def self.process_search_path(path, default)
      if path
        if path.kind_of?(String)
          path.split(File::PATH_SEPARATOR)
        else
          path.collect {|p| p.to_s}
        end
      else
        default.dup
      end
    end
    
    # Validates a zoneinfo directory and returns the paths to the iso3166.tab 
    # and zone1970.tab or zone.tab files if valid. If the directory is not
    # valid, returns nil.
    #
    # The path to the iso3166.tab file may be overriden by passing in a path.
    # This is treated as either absolute or relative to the current working
    # directory.    
    def validate_zoneinfo_dir(path, iso3166_tab_path = nil)
      if File.directory?(path)
        if iso3166_tab_path
          return nil unless File.file?(iso3166_tab_path)
        else
          iso3166_tab_path = resolve_tab_path(path, ['iso3166.tab'], 'country.tab')
          return nil unless iso3166_tab_path          
        end
        
        zone_tab_path = resolve_tab_path(path, ['zone1970.tab', 'zone.tab'], 'zone_sun.tab')
        return nil unless zone_tab_path
      
        [iso3166_tab_path, zone_tab_path]
      else
        nil
      end
    end
    
    # Attempts to resolve the path to a tab file given its standard names and
    # tab sub-directory name (as used on Solaris).
    def resolve_tab_path(zoneinfo_path, standard_names, tab_name)
      standard_names.each do |standard_name|
        path = File.join(zoneinfo_path, standard_name)
        return path if File.file?(path)
      end
      
      path = File.join(zoneinfo_path, 'tab', tab_name)
      return path if File.file?(path)
      
      nil
    end
    
    # Finds a zoneinfo directory using search_path and 
    # alternate_iso3166_tab_search_path. Returns the paths to the directory,
    # the iso3166.tab file and the zone.tab file or nil if not found.
    def find_zoneinfo_dir
      alternate_iso3166_tab_path = self.class.alternate_iso3166_tab_search_path.detect do |path|
        File.file?(path)
      end
      
      self.class.search_path.each do |path|
        # Try without the alternate_iso3166_tab_path first.
        iso3166_tab_path, zone_tab_path = validate_zoneinfo_dir(path)        
        return path, iso3166_tab_path, zone_tab_path if iso3166_tab_path && zone_tab_path
        
        if alternate_iso3166_tab_path
          iso3166_tab_path, zone_tab_path = validate_zoneinfo_dir(path, alternate_iso3166_tab_path)        
          return path, iso3166_tab_path, zone_tab_path if iso3166_tab_path && zone_tab_path
        end
      end
      
      # Not found.
      nil
    end
       
    # Scans @zoneinfo_dir and returns an Array of available timezone 
    # identifiers.
    def load_timezone_index
      index = []
      
      # Ignoring particular files:
      # +VERSION is included on Mac OS X.
      # leapseconds is a list of leap seconds.
        # localtime is the current local timezone (may be a link).
      # posix, posixrules and right are directories containing other versions of the zoneinfo files.
      # src is a directory containing the tzdata source included on Solaris.
      # timeconfig is a symlink included on Slackware.
      
      enum_timezones(nil, ['+VERSION', 'leapseconds', 'localtime', 'posix', 'posixrules', 'right', 'src', 'timeconfig']) do |identifier|
        index << identifier
      end
      
      index.sort
    end
    
    # Recursively scans a directory of timezones, calling the passed in block
    # for each identifier found.
    def enum_timezones(dir, exclude = [], &block)
      Dir.foreach(dir ? File.join(@zoneinfo_dir, dir) : @zoneinfo_dir) do |entry|
        unless entry =~ /\./ || exclude.include?(entry)
          entry.untaint
          path = dir ? File.join(dir, entry) : entry
          full_path = File.join(@zoneinfo_dir, path)
 
          if File.directory?(full_path)
            enum_timezones(path, [], &block)
          elsif File.file?(full_path)
            yield path
          end
        end
      end
    end
    
    # Uses the iso3166.tab and zone1970.tab or zone.tab files to build an index
    # of the available countries and their timezones.
    def load_country_index(iso3166_tab_path, zone_tab_path)
      
      # Handle standard 3 to 4 column zone.tab files as well as the 4 to 5 
      # column format used by Solaris.
      #
      # On Solaris, an extra column before the comment gives an optional 
      # linked/alternate timezone identifier (or '-' if not set).
      #
      # Additionally, there is a section at the end of the file for timezones
      # covering regions. These are given lower-case "country" codes. The timezone
      # identifier column refers to a continent instead of an identifier. These
      # lines will be ignored by TZInfo.
      #
      # Since the last column is optional in both formats, testing for the 
      # Solaris format is done in two passes. The first pass identifies if there
      # are any lines using 5 columns.


      # The first column is allowed to be a comma separated list of country
      # codes, as used in zone1970.tab (introduced in tzdata 2014f).
      #
      # The first country code in the comma-separated list is the country that
      # contains the city the zone identifer is based on. The first country
      # code on each line is considered to be primary with the others
      # secondary.
      #
      # The zones for each country are ordered primary first, then secondary.
      # Within the primary and secondary groups, the zones are ordered by their
      # order in the file.
      
      file_is_5_column = false
      zone_tab = []
      
      RubyCoreSupport.open_file(zone_tab_path, 'r', :external_encoding => 'UTF-8', :internal_encoding => 'UTF-8') do |file|
        file.each_line do |line|
          line.chomp!
          
          if line =~ /\A([A-Z]{2}(?:,[A-Z]{2})*)\t(?:([+\-])(\d{2})(\d{2})([+\-])(\d{3})(\d{2})|([+\-])(\d{2})(\d{2})(\d{2})([+\-])(\d{3})(\d{2})(\d{2}))\t([^\t]+)(?:\t([^\t]+))?(?:\t([^\t]+))?\z/
            codes = $1
            
            if $2
              latitude = dms_to_rational($2, $3, $4)
              longitude = dms_to_rational($5, $6, $7)
            else
              latitude = dms_to_rational($8, $9, $10, $11)
              longitude = dms_to_rational($12, $13, $14, $15)
            end
            
            zone_identifier = $16
            column4 = $17
            column5 = $18
            
            file_is_5_column = true if column5
            
            zone_tab << [codes.split(','.freeze), zone_identifier, latitude, longitude, column4, column5]
          end
        end
      end
      
      primary_zones = {}
      secondary_zones = {}
      
      zone_tab.each do |codes, zone_identifier, latitude, longitude, column4, column5|
        description = file_is_5_column ? column5 : column4
        country_timezone = CountryTimezone.new(zone_identifier, latitude, longitude, description)

        # codes will always have at least one element

        (primary_zones[codes.first] ||= []) << country_timezone

        codes[1..-1].each do |code|
          (secondary_zones[code] ||= []) << country_timezone
        end
      end
      
      countries = {}
      
      RubyCoreSupport.open_file(iso3166_tab_path, 'r', :external_encoding => 'UTF-8', :internal_encoding => 'UTF-8') do |file|
        file.each_line do |line|
          line.chomp!
          
          # Handle both the two column alpha-2 and name format used in the tz 
          # database as well as the 4 column alpha-2, alpha-3, numeric-3 and 
          # name format used by FreeBSD and OpenBSD.
          
          if line =~ /\A([A-Z]{2})(?:\t[A-Z]{3}\t[0-9]{3})?\t(.+)\z/
            code = $1
            name = $2
            zones = (primary_zones[code] || []) + (secondary_zones[code] || [])

            countries[code] = ZoneinfoCountryInfo.new(code, name, zones)
          end
        end
      end
      
      countries
    end
    
    # Converts degrees, minutes and seconds to a Rational.
    def dms_to_rational(sign, degrees, minutes, seconds = nil)
      result = degrees.to_i + Rational(minutes.to_i, 60)
      result += Rational(seconds.to_i, 3600) if seconds
      result = -result if sign == '-'.freeze
      result
    end
  end
end
