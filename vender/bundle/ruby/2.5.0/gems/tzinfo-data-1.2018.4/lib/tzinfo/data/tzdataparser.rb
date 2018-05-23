require 'date'
require 'fileutils'

module TZInfo
  module Data
  
    # Utility methods used by TZDataParser and associated classes.
    #
    # @private
    module TZDataParserUtils #:nodoc:
      # Wrapper for File.open that supports passing hash options for specifying
      # encodings on Ruby 1.9+. The options are ignored on earlier versions of
      # Ruby.
      if RUBY_VERSION =~ /\A1\.[0-8]\./
        def open_file(file_name, mode, opts, &block)
          File.open(file_name, mode, &block)
        end
      else
        def open_file(file_name, mode, opts, &block)
          File.open(file_name, mode, opts, &block)
        end
      end
      
      private :open_file
      
      private
      
        # Parses a month specified in the tz data and converts it to a number
        # between 1 and 12 representing January to December.
        def parse_month(month)
          lower = month.downcase
          if lower =~ /^jan/
            @month = 1
          elsif lower =~ /^feb/
            @month = 2
          elsif lower =~ /^mar/
            @month = 3
          elsif lower =~ /^apr/
            @month = 4
          elsif lower =~ /^may/
            @month = 5
          elsif lower =~ /^jun/
            @month = 6
          elsif lower =~ /^jul/
            @month = 7
          elsif lower =~ /^aug/
            @month = 8
          elsif lower =~ /^sep/
            @month = 9
          elsif lower =~ /^oct/
            @month = 10
          elsif lower =~ /^nov/
            @month = 11
          elsif lower =~ /^dec/
            @month = 12
          else
            raise "Invalid month: #{month}"
          end
        end
        
        # Parses an offset string [-]h:m:s (minutes and seconds are optional). Returns
        # the offset in seconds.
        def parse_offset(offset)
          raise "Invalid time: #{offset}" if offset !~ /^(-)?(?:([0-9]+)(?::([0-9]+)(?::([0-9]+))?)?)?$/
          
          negative = !$1.nil?      
          hour = $2.nil? ? 0 : $2.to_i
          minute = $3.nil? ? 0 : $3.to_i
          second = $4.nil? ? 0 : $4.to_i
          
          seconds = hour
          seconds = seconds * 60
          seconds = seconds + minute
          seconds = seconds * 60
          seconds = seconds + second
          seconds = -seconds if negative
          seconds
        end
        
        # Encloses the string in single quotes and escapes any single quotes in
        # the content.
        def quote_str(str)
          "'#{str.gsub('\'', '\\\\\'')}'"
        end
    end 
  
    # Parses Time Zone Data from the IANA Time Zone Database and transforms it 
    # into a set of Ruby modules that can be used with TZInfo.
    # 
    # Normally, this class wouldn't be used. It is only run to update the 
    # timezone data and index modules.
    class TZDataParser
      include TZDataParserUtils
    
      # Default earliest year that will be considered.
      DEFAULT_MIN_YEAR = 1800
      
      # Default number of future years data to generate (not including the 
      # current year).
      DEFAULT_FUTURE_YEARS = 50
      
      # Earliest year that will be considered. Defaults to DEFAULT_MIN_YEAR.
      attr_accessor :min_year
      
      # Latest year that will be considered. Defaults to the current year plus
      # FUTURE_YEARS.
      attr_accessor :max_year
      
      # Whether to generate zone definitions (set to false to stop zones being
      # generated).    
      attr_accessor :generate_zones
      
      # Whether to generate country definitions (set to false to stop countries
      # being generated).
      attr_accessor :generate_countries
      
      # Limit the set of zones to generate (set to an array containing zone
      # identifiers).
      attr_accessor :only_zones
          
      # Zones to exclude from generation when not using only_zones (set to an
      # array containing zone identifiers).
      attr_accessor :exclude_zones
      
      # Initializes a new TZDataParser. input_dir must contain the extracted
      # tzdata tarball. output_dir is the location to output the modules
      # (in definitions and indexes directories).
      def initialize(input_dir, output_dir)
        super()
        @input_dir = input_dir
        @output_dir = output_dir
        @min_year = DEFAULT_MIN_YEAR
        @max_year = Time.now.year + DEFAULT_FUTURE_YEARS
        @rule_sets = {}
        @zones = {}
        @countries = {}
        @no_rules = TZDataNoRules.new
        @generate_zones = true
        @generate_countries = true
        @only_zones = []
        @exclude_zones = []
      end
      
      # Reads the tzdata source and generates the classes. Progress information
      # is written to standard out.
      def execute
        # Note that the backzone file is ignored. backzone contains alternative
        # definitions of certain zones, primarily for pre-1970 data. It is not
        # recommended for ordinary use and the tzdata Makefile does not
        # install its entries by default.

        files = Dir.entries(@input_dir).select do |file|
          file =~ /\A[^\.]+\z/ &&            
            !%w(backzone calendars leapseconds CONTRIBUTING LICENSE Makefile NEWS README SOURCE Theory version).include?(file) &&
            File.file?(File.join(@input_dir, file))
        end
      
        files.each {|file| load_rules(file) }
        files.each {|file| load_zones(file) }
        files.each {|file| load_links(file) }
        
        load_countries
        
        if @generate_zones
          modules = []
          
          if @only_zones.nil? || @only_zones.empty?
            @zones.each_value {|zone|
              zone.write_module(@output_dir) unless @exclude_zones.include?(zone.name)
            }
          else
            @only_zones.each {|id|
              zone = @zones[id]
              zone.write_module(@output_dir)            
            }          
          end
          
          write_timezones_index
        end
        
        if @generate_countries        
          write_countries_index
        end
      end
          
      private     
        # Loads all the Rule definitions from the tz data and stores them in
        # the rule_sets instance variable.
        def load_rules(file)
          puts 'load_rules: ' + file
          
          # Files are in ASCII, but may change to UTF-8 (a superset of ASCII)
          # in the future.
          open_file(File.join(@input_dir, file), 'r', :external_encoding => 'UTF-8', :internal_encoding => 'UTF-8') do |file|
            file.each_line do |line|
              line = line.gsub(/#.*$/, '')
              line = line.gsub(/\s+$/, '')
            
              if line =~ /^Rule\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)/
                
                name = $1    
                
                if @rule_sets[name].nil? 
                  @rule_sets[name] = TZDataRuleSet.new(name) 
                end
                
                @rule_sets[name].add_rule(TZDataRule.new($2, $3, $4, $5, $6, $7, $8, $9))
              end          
            end
          end
        end
        
        # Gets a rules object for the given reference. Might be a named rule set,
        # a fixed offset or an empty ruleset.
        def get_rules(ref)
          if ref == '-'
            @no_rules
          elsif ref =~ /^[0-9]+:[0-9]+$/
            TZDataFixedOffsetRules.new(parse_offset(ref))
          else
            rule_set = @rule_sets[ref]
            raise "Ruleset not found: #{ref}" if rule_set.nil?    
            rule_set
          end  
        end
        
        # Loads in the Zone definitions from the tz data and stores them in @zones.
        def load_zones(file)
          puts 'load_zones: ' + file
          
          in_zone = nil
          
          # Files are in ASCII, but may change to UTF-8 (a superset of ASCII)
          # in the future.
          open_file(File.join(@input_dir, file), 'r', :external_encoding => 'UTF-8', :internal_encoding => 'UTF-8') do |file|
            file.each_line do |line|
              line = line.gsub(/#.*$/, '')
              line = line.gsub(/\s+$/, '')
            
              if in_zone
                if line =~ /^\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)(\s+([0-9]+(\s+.*)?))?$/              
                  
                  in_zone.add_observance(TZDataObservance.new($1, get_rules($2), $3, $5))
                  
                  in_zone = nil if $4.nil? 
                end
              else
                if line =~ /^Zone\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)\s+([^\s]+)(\s+([0-9]+(\s+.*)?))?$/              
                  name = $1
                  
                  if @zones[name].nil? 
                    @zones[name] = TZDataZone.new(name, @min_year..@max_year)
                  end                            
                  
                  @zones[name].add_observance(TZDataObservance.new($2, get_rules($3), $4, $6))
                  
                  in_zone = @zones[name] if !$5.nil?
                end
              end
            end
          end
        end
        
        # Loads in the links and stores them in @zones.
        def load_links(file)
          puts 'load_links: ' + file
          
          # Files are in ASCII, but may change to UTF-8 (a superset of ASCII)
          # in the future.
          open_file(File.join(@input_dir, file), 'r', :external_encoding => 'UTF-8', :internal_encoding => 'UTF-8') do |file|
            file.each_line do |line|
              line = line.gsub(/#.*$/, '')
              line = line.gsub(/\s+$/, '')
            
              if line =~ /^Link\s+([^\s]+)\s+([^\s]+)/            
                name = $2           
                link_to = @zones[$1]
                raise "Link to zone not found (#{name}->#{link_to})" if link_to.nil?
                raise "Zone already defined: #{name}" if !@zones[name].nil?
                @zones[name] = TZDataLink.new(name, link_to)
              end          
            end
          end
        end
        
        # Loads countries from iso3166.tab and zone1970.tab and stores the
        # result in the countries instance variable.
        def load_countries
          puts 'load_countries'
          
          # iso3166.tab is ASCII encoded, but is planned to change to UTF-8 (a
          # superset of ASCII) in the future.
          open_file(File.join(@input_dir, 'iso3166.tab'), 'r', :external_encoding => 'UTF-8', :internal_encoding => 'UTF-8') do |file|
            file.each_line do |line|
          
              if line =~ /^([A-Z]{2})\t(.*)$/
                code = $1
                name = $2
                @countries[code] = TZDataCountry.new(code, name)
              end
            end
          end

          primary_zones = {}
          secondary_zones = {}

          # zone1970.tab is UTF-8 encoded.
          open_file(File.join(@input_dir, 'zone1970.tab'), 'r', :external_encoding => 'UTF-8', :internal_encoding => 'UTF-8') do |file|
            file.each_line do |line|
                    
              line.chomp!          

              if line =~ /^([A-Z]{2}(?:,[A-Z]{2})*)\t([^\t]+)\t([^\t]+)(\t(.*))?$/
                codes = $1
                location_str = $2
                zone_name = $3
                description = $5
                
                location = TZDataLocation.new(location_str)
                
                zone = @zones[zone_name]
                raise "Zone not found: #{zone_name}" if zone.nil?                        
                
                description = nil if description == ''
                
                country_timezone = TZDataCountryTimezone.new(zone, description, location)

                codes = codes.split(',')

                (primary_zones[codes.first] ||= []) << country_timezone

                codes[1..-1].each do |code|
                  (secondary_zones[code] ||= []) << country_timezone
                end
              end
            end
          end

          [primary_zones, secondary_zones].each do |zones|
            zones.each_pair do |code, country_timezones|
              country = @countries[code]
              raise "Country not found: #{code}" if country.nil?

              country_timezones.each do |country_timezone|
                country.add_zone(country_timezone)
              end
            end
          end
        end
        
        # Writes a country index file.
        def write_countries_index
          dir = File.join(@output_dir, 'indexes')
          FileUtils.mkdir_p(dir)
          
          open_file(File.join(dir, 'countries.rb'), 'w', :external_encoding => 'UTF-8', :universal_newline => true) do |file|
            file.puts('# encoding: UTF-8')
            file.puts('')
            file.puts('# This file contains data derived from the IANA Time Zone Database')
            file.puts('# (http://www.iana.org/time-zones).')
            file.puts('')
            
            file.puts('module TZInfo')
            file.puts('  module Data')
            file.puts('    module Indexes')
            file.puts('      module Countries')
            file.puts('        include CountryIndexDefinition')
            file.puts('')
            
            countries = @countries.values.sort {|c1,c2| c1.code <=> c2.code}  
            countries.each {|country| country.write_index_record(file)}
                      
            file.puts('      end') # end module Countries                    
            file.puts('    end') # end module Indexes
            file.puts('  end') # end module Data
            file.puts('end') # end module TZInfo
          end                      
        end
        
        # Writes a timezone index file.
        def write_timezones_index
          dir = File.join(@output_dir, 'indexes')
          FileUtils.mkdir_p(dir)
          
          open_file(File.join(dir, 'timezones.rb'), 'w', :external_encoding => 'UTF-8', :universal_newline => true) do |file|
            file.puts('# encoding: UTF-8')
            file.puts('')
            file.puts('# This file contains data derived from the IANA Time Zone Database')
            file.puts('# (http://www.iana.org/time-zones).')
            file.puts('')
            
            file.puts('module TZInfo')
            file.puts('  module Data')
            file.puts('    module Indexes')
            file.puts('      module Timezones')
            file.puts('        include TimezoneIndexDefinition')
            file.puts('')
            
            zones = @zones.values.sort {|t1,t2| t1.name <=> t2.name}
            zones.each {|zone| zone.write_index_record(file)}
            
            file.puts('      end') # end module Timezones
            file.puts('    end') # end module Indexes
            file.puts('  end') # end module Data
            file.puts('end') # end module TZInfo
          end
          
        end
    end
    
    # Base class for all rule sets.
    #
    # @private
    class TZDataRules #:nodoc:
      # Name of the rule set, e.g. EU.
      attr_reader :name
      
      def initialize(name)
        @name = name
      end
      
      def count
        0
      end
    end
    
    # Empty rule set with a fixed daylight savings (std) offset.
    #
    # @private
    class TZDataFixedOffsetRules < TZDataRules #:nodoc:
      attr_reader :offset
      
      def initialize(offset)
        super(offset.to_s)
        @offset = offset
      end        
    end
    
    # An empty set of rules.
    #
    # @private
    class TZDataNoRules < TZDataRules #:nodoc:
      def initialize
        super('-')
      end
    end
    
    # A rule set (as defined by Rule name in the tz data).
    #
    # @private
    class TZDataRuleSet < TZDataRules #:nodoc:       
      attr_reader :rules
      
      def initialize(name)
        super
        @rules = []
      end
      
      # Adds a new rule to the set.
      def add_rule(rule)
        @rules << rule
      end
      
      def count
        @rules.length
      end
      
      def each
        @rules.each {|rule| yield rule}
      end
    end    
    
    # A rule in a RuleSet (a single Rule line in the tz data).
    #
    # @private
    class TZDataRule #:nodoc:
      include TZDataParserUtils
    
      attr_reader :from
      attr_reader :to
      attr_reader :type
      attr_reader :in_month
      attr_reader :on_day
      attr_reader :at_time
      attr_reader :save
      attr_reader :letter
      
      def initialize(from, to, type, in_month, on_day, at_time, save, letter)
        @from = parse_from(from)
        @to = parse_to(to)
        
        # replace a to of :only with the from year
        raise 'to cannot be only if from is minimum' if @to == :only && @from == :min
        @to = @from if @to == :only      
        
        @type = parse_type(type)
        @in_month = parse_month(in_month)
        @on_day = TZDataDayOfMonth.new(on_day)
        @at_time = TZDataTime.new(at_time)
        @save = parse_offset(save)
        @letter = parse_letter(letter)
      end
      
      def activate(year)
        # The following test ignores yearistype at present (currently unused in
        # the data. parse_type currently excepts on encountering a year type.
        if (@from == :min || @from <= year) && (@to == :max || @to >= year)                        
          TZDataActivatedRule.new(self, year)
        else
          nil
        end
      end
      
      def at_utc_time(year, utc_offset, std_offset)
        @at_time.to_utc(utc_offset, std_offset,
          year, @in_month, @on_day.to_absolute(year, @in_month))
      end
      
      private
        def parse_from(from)
          lower = from.downcase
          if lower =~ /^min/
            :min
          elsif lower =~ /^[0-9]+$/
            lower.to_i
          else
            raise "Invalid from: #{from}"
          end
        end
        
        def parse_to(to)
          lower = to.downcase
          if lower =~ /^max/
            :max
          elsif lower =~ /^o/
            :only
          elsif lower =~ /^[0-9]+$/
            lower.to_i
          else
            raise "Invalid to: #{to}"
          end
        end
        
        def parse_type(type)
          raise "Unsupported rule type: #{type}" if type != '-'
          nil
        end        
        
        def parse_letter(letter)
          if letter == '-'
            nil
          else
            letter
          end
        end
    end
    
    # Base class for Zones and Links.
    #
    # @private
    class TZDataDefinition #:nodoc:
      include TZDataParserUtils
      
      attr_reader :name
      attr_reader :name_elements
      attr_reader :path_elements
      
      def initialize(name)
        @name = name
        
        # + and - aren't allowed in class names
        @name_elements = name.gsub(/-/, '__m__').gsub(/\+/, '__p__').split(/\//)
        @path_elements = @name_elements.clone
        @path_elements.pop
      end        
      
      # Creates necessary directories, the file, writes the class header and footer
      # and yields to a block to write the content.    
      def create_file(output_dir) 
        dir = File.join(output_dir, 'definitions', @path_elements.join(File::SEPARATOR))
        FileUtils.mkdir_p(dir)
        
        open_file(File.join(output_dir, 'definitions', @name_elements.join(File::SEPARATOR)) + '.rb', 'w', :external_encoding => 'UTF-8', :universal_newline => true) do |file|

          file.instance_variable_set(:@tz_indent, 0)
          
          def file.indent(by)
            @tz_indent += by
          end
          
          def file.puts(s)
            super("#{' ' * @tz_indent}#{s}")
          end

          file.puts('# encoding: UTF-8')
          file.puts('')
          file.puts('# This file contains data derived from the IANA Time Zone Database')
          file.puts('# (http://www.iana.org/time-zones).')
          file.puts('')
          file.puts('module TZInfo')
          file.indent(2)
          file.puts('module Data')
          file.indent(2)
          file.puts('module Definitions')
          file.indent(2)                
          
          @name_elements.each do |part| 
            file.puts("module #{part}")
            file.indent(2)
          end
          
          file.puts('include TimezoneDefinition')
          file.puts('')
          
          yield file
                          
          @name_elements.each do
            file.indent(-2)  
            file.puts('end')          
          end
          file.indent(-2)
          file.puts('end') # end module Definitions
          file.indent(-2)
          file.puts('end') # end module Data
          file.indent(-2)
          file.puts('end') # end module TZInfo
        end
      end    
    end
    
    # A tz data Link.
    #
    # @private
    class TZDataLink < TZDataDefinition #:nodoc:
      include TZDataParserUtils
    
      attr_reader :link_to
      
      def initialize(name, link_to)
        super(name)
        @link_to = link_to
      end
                  
      # Writes a module for this link.
      def write_module(output_dir)
        puts "writing link #{name}"
              
        create_file(output_dir) {|file|
          file.puts("linked_timezone #{quote_str(@name)}, #{quote_str(@link_to.name)}")        
        }
      end
      
      # Writes an index record for this link.    
      def write_index_record(file)
        file.puts("        linked_timezone #{quote_str(@name)}")
      end
    end
    
    # A tz data Zone. Each line from the tz data is loaded as a TZDataObservance.
    #
    # @private
    class TZDataZone < TZDataDefinition #:nodoc:
      include TZDataParserUtils
      
      attr_reader :observances
      
      def initialize(name, years)
        super(name)
        @years = years
        @observances = []
      end
      
      def add_observance(observance)      
        @observances << observance
      end                
      
      # Writes the module for the zone. Iterates all the periods and asks them
      # to write all periods in the timezone.
      def write_module(output_dir) 
        puts "writing zone #{name}"
        
        create_file(output_dir) {|file|        
          
          file.puts("timezone #{quote_str(@name)} do |tz|")
          file.indent(2)
                
          transitions = find_transitions
          transitions.output_module(file)
          
          file.indent(-2)
          file.puts('end')
        }      
      end
      
      # Writes an index record for this zone.    
      def write_index_record(file)
        file.puts("        timezone #{quote_str(@name)}")
      end
      
      private
        def find_transitions
          transitions = TZDataTransitions.new(@years)
          
          # algorithm from zic.c outzone
          
          start_time = nil
          until_time = nil
          
          
          @observances.each_with_index {|observance, i|
            std_offset = 0
            use_start = i > 0
            use_until = i < @observances.length - 1
            utc_offset = observance.utc_offset
            start_zone_id = nil
            start_utc_offset = observance.utc_offset
            start_std_offset = 0
            
            if observance.rule_set.count == 0
              std_offset = observance.std_offset
              start_zone_id = observance.format.expand(utc_offset, std_offset, nil)
              
              if use_start
                transitions << TZDataTransition.new(start_time, utc_offset, std_offset, start_zone_id)
                use_start = false
              else
                # zic algorithm only outputs this if std_offset is non-zero
                # to get the initial LMT range, we output this regardless
                transitions << TZDataTransition.new(nil, utc_offset, std_offset, start_zone_id)
              end  
            else
              @years.each {|year|
                if use_until && year > observance.valid_until.year
                  break
                end
                
                activated_rules = []
                
                observance.rule_set.each {|rule|
                  activated_rule = rule.activate(year)
                  activated_rules << activated_rule unless activated_rule.nil?
                }
                
                while true 
                  # turn until_time into UTC using the current utc_offset and std_offset
                  until_time = observance.valid_until.to_utc(utc_offset, std_offset) if use_until
                  
                  earliest = nil

                  activated_rules.each {|activated_rule| 
                    # recalculate the time using the current std_offset
                    activated_rule.calculate_time(utc_offset, std_offset) 
                    earliest = activated_rule if earliest.nil? || activated_rule.at < earliest.at                   
                  }
                  
                  break if earliest.nil?                
                  activated_rules.delete(earliest)                               
                  break if use_until && earliest.at >= until_time                
                  std_offset = earliest.rule.save                   
                  use_start = false if use_start && earliest.at == start_time
                  
                  if use_start
                    if earliest.at < start_time
                      start_utc_offset = observance.utc_offset
                      start_std_offset = std_offset
                      start_zone_id = observance.format.expand(start_utc_offset, earliest.rule.save, earliest.rule.letter)
                      next
                    end
                    
                    if start_zone_id.nil? && start_utc_offset + start_std_offset == observance.utc_offset + std_offset
                      start_zone_id = observance.format.expand(start_utc_offset, earliest.rule.save, earliest.rule.letter)
                    end
                  end
                  
                  zone_id = observance.format.expand(observance.utc_offset, earliest.rule.save, earliest.rule.letter)
                  transitions << TZDataTransition.new(earliest.at, observance.utc_offset, earliest.rule.save, zone_id)
                end              
              }
            end
          
            if use_start
              start_zone_id = observance.format.expand(nil, nil, nil) if start_zone_id.nil? && observance.format.fixed?
              raise 'Could not determine time zone abbreviation to use just after until time' if start_zone_id.nil?            
              transitions << TZDataTransition.new(start_time, start_utc_offset, start_std_offset, start_zone_id)
            end
                      
            start_time = observance.valid_until.to_utc(utc_offset, std_offset) if use_until 
          }
          
          transitions
        end
    end
    
    # A observance within a zone (a line within the zone definition).
    #
    # @private
    class TZDataObservance #:nodoc:
      include TZDataParserUtils
    
      attr_reader :utc_offset
      attr_reader :rule_set
      attr_reader :format
      attr_reader :valid_until
      
      def initialize(utc_offset, rule_set, format, valid_until)
        @utc_offset = parse_offset(utc_offset)
        @rule_set = rule_set      
        @format = TZDataFormat.new(format)
        @valid_until = valid_until.nil? ? nil : TZDataUntil.new(valid_until)      
      end 
      
      def std_offset
        if @rule_set.kind_of?(TZDataFixedOffsetRules)
          @rule_set.offset
        else
          0
        end
      end
    end
    
    # Collection of TZDataTransition instances used when building a zone class.
    #
    # @private
    class TZDataTransitions #:nodoc:
      include TZDataParserUtils
      
      def initialize(years)
        @years = years
        @transitions = []
      end
      
      def << (transition)
        @transitions << transition
      end 
      
      def output_module(file)
        optimize
        
        # Try and end on a transition to std if one happens in the last year.
        if @transitions.length > 1 && 
            @transitions.last.std_offset != 0 &&
            @transitions[@transitions.length - 2].std_offset == 0 &&
            @transitions[@transitions.length - 2].at_utc.year == @years.max
          
          transitions = @transitions[0..@transitions.length - 2]
        else
          transitions = @transitions
        end
        
        process_offsets(file)
        file.puts('')
        
        transitions.each do |t|        
          t.write(file)
        end            
      end
      
      private
        def optimize
          @transitions.sort!
          
          # Optimization logic from zic.c writezone.
          
          from_i = 0
          to_i = 0
          
          while from_i < @transitions.length
            if to_i > 1 && 
                !@transitions[from_i].at_utc.nil?  &&
                !@transitions[to_i - 1].at_utc.nil? &&
                @transitions[from_i].at_utc + Rational(@transitions[to_i - 1].total_offset, 86400) <=
                @transitions[to_i - 1].at_utc + Rational(@transitions[to_i - 2].total_offset, 86400)
                        
              @transitions[to_i - 1] = @transitions[from_i].clone_with_at(@transitions[to_i - 1].at_utc)             
              from_i += 1
              next
            end
            
            # Shuffle transitions up, eliminating any redundant transitions 
            # along the way.
            if to_i == 0 ||
                @transitions[to_i - 1].utc_offset != @transitions[from_i].utc_offset ||
                @transitions[to_i - 1].std_offset != @transitions[from_i].std_offset ||
                @transitions[to_i - 1].zone_id != @transitions[from_i].zone_id
                        
              @transitions[to_i] = @transitions[from_i]
              to_i += 1            
            end
            
            from_i += 1
          end                
          
          if to_i > 0
            @transitions = @transitions[0..to_i - 1]
          else
            @transitions = []
          end                
        end
        
        def quote_zone_id(zone_id)     
          if zone_id =~ %r{[\-+']}
            ":#{quote_str(zone_id)}"          
          else
            ":#{zone_id}"
          end
        end  
        
        def process_offsets(file)
          # A bit of a hack at the moment. The offset used to be output with
          # each period (pair of transitions). They are now separated from the
          # transition data. The code should probably be changed at some point to
          # setup the offsets at an earlier stage.   
          
          # Assume that when this is called, the first transition is the Local
          # Mean Time initial rule or a transition with no time that defines the
          # offset for the entire zone.
          
          offsets = []
          
          # Find the first std offset. Timezones always start in std.
          @transitions.each do |t|
            if t.std_offset == 0
              offset = {:utc_offset => t.utc_offset, 
                :std_offset => t.std_offset,
                :zone_id => t.zone_id,
                :name => 'o0'}
                
              offsets << offset
              break
            end
          end
          
          @transitions.each do |t|
            offset = offsets.find do |o| 
              o[:utc_offset] == t.utc_offset &&
                o[:std_offset] == t.std_offset &&
                o[:zone_id] == t.zone_id
            end
          
            unless offset
              offset = {:utc_offset => t.utc_offset, 
                :std_offset => t.std_offset,
                :zone_id => t.zone_id,
                :name => "o#{offsets.length}"}
                                         
              offsets << offset
            end
            
            t.offset_name = offset[:name]
          end
          
          offsets.each do |offset|
            file.puts("tz.offset :#{offset[:name]}, #{offset[:utc_offset]}, #{offset[:std_offset]}, #{quote_zone_id(offset[:zone_id])}")
          end
          
        end
    end
    
    # A transition that will be used to write the periods in a zone class.
    #
    # @private
    class TZDataTransition #:nodoc:
      include Comparable
      
      EPOCH = DateTime.new(1970, 1, 1)
      
      attr_reader :at_utc
      attr_reader :utc_offset
      attr_reader :std_offset
      attr_reader :zone_id
      attr_accessor :offset_name
      
      def initialize(at_utc, utc_offset, std_offset, zone_id)
        @at_utc = at_utc
        @utc_offset = utc_offset
        @std_offset = std_offset
        @zone_id = zone_id
        @offset_name = nil
      end
      
      def to_s
        "At #{at_utc} UTC switch to UTC offset #{@utc_offset} with std offset #{@std_offset}, zone id #{@zone_id}"
      end
      
      def <=>(transition)
        if @at_utc == transition.at_utc
          0
        elsif @at_utc.nil?
          -1
        elsif transition.nil?
          1
        else       
          @at_utc - transition.at_utc
        end
      end
      
      def total_offset
        @utc_offset + @std_offset
      end
      
      def clone_with_at(at_utc)
        TZDataTransition.new(at_utc, @utc_offset, @std_offset, @zone_id)
      end
          
      def write(file)        
        if @at_utc
          file.puts "tz.transition #{@at_utc.year}, #{@at_utc.mon}, :#{@offset_name}, #{timestamp_parameters(@at_utc)}" 
        end        
      end
       
      private
        def timestamp_parameters(datetime)
          timestamp = ((datetime - EPOCH) * 86400).to_i
          
          if timestamp < 0 || timestamp > 2147483647
            # Output DateTime parameters as well as a timestamp for platforms
            # where Time doesn't support negative or 64-bit values.
            "#{timestamp}, #{datetime.ajd.numerator}, #{datetime.ajd.denominator}"
          else
            timestamp
          end
        end
    end
     
    # An instance of a rule for a year.
    #
    # @private
    class TZDataActivatedRule #:nodoc:
      attr_reader :rule
      attr_reader :year
      attr_reader :at
      
      def initialize(rule, year)
        @rule = rule
        @year = year
        @at = nil
      end
      
      def calculate_time(utc_offset, std_offset)
        @at = @rule.at_utc_time(@year, utc_offset, std_offset)
      end
    end
    
    # A tz data time definition - an hour, minute, second and reference. Reference
    # is either :utc, :standard or :wall_clock.
    #
    # @private
    class TZDataTime #:nodoc:
      attr_reader :hour
      attr_reader :minute
      attr_reader :second
      attr_reader :ref
      
      def initialize(spec)
        raise "Invalid time: #{spec}" if spec !~ /^([0-9]+)(:([0-9]+)(:([0-9]+))?)?([wguzs])?$/
        
        @hour = $1.to_i
        @minute = $3.nil? ? 0 : $3.to_i
        @second = $5.nil? ? 0 : $5.to_i
        
        if $6 == 's'
          @ref = :standard
        elsif $6 == 'g' || $6 == 'u' || $6 == 'z'
          @ref = :utc
        else
          @ref = :wall_clock
        end
      end
      
      # Converts the time to UTC given a utc_offset and std_offset.
      def to_utc(utc_offset, std_offset, year, month, day)      
        result = DateTime.new(year, month, day, @hour, @minute, @second)
        offset = 0
        offset = offset + utc_offset if @ref == :standard || @ref == :wall_clock            
        offset = offset + std_offset if @ref == :wall_clock       
        result - Rational(offset, 86400)            
      end
    end
      
    # A tz data day of the month reference. Can either be an absolute day,
    # a last week day or a week day >= or <= than a specific day of month.
    #
    # @private
    class TZDataDayOfMonth #:nodoc:
      attr_reader :type
      attr_reader :day_of_month
      attr_reader :day_of_week
      attr_reader :operator
      
      def initialize(spec)
        raise "Invalid on: #{spec}" if spec !~ /^([0-9]+)|(last([A-Za-z]+))|(([A-Za-z]+)([<>]=)([0-9]+))$/
        
        if $1
          @type = :absolute
          @day_of_month = $1.to_i
        elsif $3
          @type = :last
          @day_of_week = parse_day_of_week($3)
        else
          @type = :comparison
          @day_of_week = parse_day_of_week($5)
          @operator = parse_operator($6)
          @day_of_month = $7.to_i
        end
      end
      
      # Returns the absolute day of month for the given year and month.
      def to_absolute(year, month)
        case @type
          when :last
            last_day_in_month = (Date.new(year, month, 1) >> 1) - 1          
            offset = last_day_in_month.wday - @day_of_week
            offset = offset + 7 if offset < 0
            (last_day_in_month - offset).day
          when :comparison
            pivot = Date.new(year, month, @day_of_month)         
            offset = @day_of_week - pivot.wday
            offset = -offset if @operator == :less_equal
            offset = offset + 7 if offset < 0
            offset = -offset if @operator == :less_equal          
            result = pivot + offset
            if result.month != pivot.month
              puts self.inspect
              puts year
              puts month
            end
            raise 'No suitable date found' if result.month != pivot.month
            result.day          
          else #absolute
            @day_of_month
        end
      end
      
      private
        def parse_day_of_week(day_of_week)
          lower = day_of_week.downcase
          if lower =~ /^mon/
            1
          elsif lower =~ /^tue/
            2
          elsif lower =~ /^wed/
            3
          elsif lower =~ /^thu/
            4
          elsif lower =~ /^fri/
            5
          elsif lower =~ /^sat/
            6
          elsif lower =~ /^sun/
            0
          else
            raise "Invalid day of week: #{day_of_week}"
          end
        end
        
        def parse_operator(operator)
          if operator == '>='
            :greater_equal
          elsif operator == '<='
            :less_equal
          else
            raise "Invalid operator: #{operator}"
          end
        end
    end   
    
    # A tz data Zone until reference.
    #
    # @private
    class TZDataUntil #:nodoc:
      include TZDataParserUtils
    
      attr_reader :year
      attr_reader :month
      attr_reader :day
      attr_reader :time
      
      def initialize(spec)      
        parts = spec.split(/\s+/)      
        raise "Invalid until: #{spec}" if parts.length < 1
        
        @year = parts[0].to_i
        @month = parts.length > 1 ? parse_month(parts[1]) : 1
        @day = TZDataDayOfMonth.new(parts.length > 2 ? parts[2] : '1')
        @time = TZDataTime.new(parts.length > 3 ? parts[3] : '00:00')
      end
      
      # Converts the reference to a UTC DateTime.
      def to_utc(utc_offset, std_offset)
        @time.to_utc(utc_offset, std_offset, @year, @month, @day.to_absolute(@year, @month))            
      end
    end
    
    # A tz data Zone format string. Either alternate standard/daylight-savings,
    # substitution (%s) format or a fixed string.
    #
    # @private
    class TZDataFormat #:nodoc:        
      def initialize(spec)
        if spec =~ /\A([^\/]*)\/(.*)\z/
          @type = :alternate
          @standard_abbrev = $1
          @daylight_abbrev = $2
        elsif spec =~ /%[sz]/
          @type = :subst
          @abbrev = spec
        else
          @type = :fixed
          @abbrev = spec
        end
      end
      
      # Expands given the base offset to UTC, the current daylight savings
      # offset and rule string.
      def expand(utc_offset, std_offset, rule_string)
        if @type == :alternate
          if std_offset == 0
            @standard_abbrev
          else
            @daylight_abbrev
          end
        elsif @type == :subst
          @abbrev.gsub(/%([sz])/) do
            $1 == 's' ? rule_string : format_offset(utc_offset + std_offset)
          end
        else
          @abbrev
        end        
      end
      
      # True if the format requires substitutions (%s or %z).
      def subst?
        @type == :subst
      end
      
      # Is a fixed format string.
      def fixed?
        @type == :fixed
      end

      private

        # Formats an offset according to the rules for %z.
        def format_offset(offset)
          if offset < 0
            offset = -offset
            sign = '-'
          else
            sign = '+'
          end

          offset, seconds = offset.divmod(60)
          offset, minutes = offset.divmod(60)

          if offset > 99
            # unsupported
            '%z'
          else
            result = "#{sign}#{offset.to_s.rjust(2, '0')}"

            if minutes != 0 || seconds != 0
              result << minutes.to_s.rjust(2, '0')

              if seconds != 0
                result << seconds.to_s.rjust(2, '0')
              end
            end

            result
          end
        end
    end
    
    # A location (latitude + longitude)
    #
    # @private
    class TZDataLocation #:nodoc:
      attr_reader :latitude
      attr_reader :longitude
      
      # Constructs a new TZDataLocation from a string in ISO 6709 
      # sign-degrees-minutes-seconds format, either +-DDMM+-DDDMM 
      # or +-DDMMSS+-DDDMMSS, first latitude (+ is north), 
      # then longitude (+ is east).
      def initialize(coordinates)
        if coordinates !~ /^([+\-])([0-9]{2})([0-9]{2})([0-9]{2})?([+\-])([0-9]{3})([0-9]{2})([0-9]{2})?$/
          raise "Invalid coordinates: #{coordinates}"
        end
        
        @latitude = Rational($2.to_i) + Rational($3.to_i, 60)
        @latitude += Rational($4.to_i, 3600) unless $4.nil?
        @latitude = -@latitude if $1 == '-'
        
        @longitude = Rational($6.to_i) + Rational($7.to_i, 60)
        @longitude += Rational($8.to_i, 3600) unless $8.nil?
        @longitude = -@longitude if $5 == '-'
      end
    end  

    # @private
    TZDataCountryTimezone = Struct.new(:timezone, :description, :location)  #:nodoc:
    
    # An ISO 3166 country.
    #
    # @private
    class TZDataCountry #:nodoc:
      include TZDataParserUtils
      
      attr_reader :code
      attr_reader :name
      attr_reader :zones
      
      def initialize(code, name)
        @code = code
        @name = name
        @zones = []
      end
      
      # Adds a TZDataCountryTimezone
      def add_zone(zone)      
        @zones << zone      
      end  
      
      def write_index_record(file)
        s = "        country #{quote_str(@code)}, #{quote_str(@name)}"      
        s << ' do |c|' if @zones.length > 0
        
        file.puts s
        
        @zones.each do |zone|
          file.puts "          c.timezone #{quote_str(zone.timezone.name)}, #{zone.location.latitude.numerator}, #{zone.location.latitude.denominator}, #{zone.location.longitude.numerator}, #{zone.location.longitude.denominator}#{zone.description.nil? ? '' : ', ' + quote_str(zone.description)}" 
        end
        
        file.puts '        end' if @zones.length > 0
      end
    end
  end
end
