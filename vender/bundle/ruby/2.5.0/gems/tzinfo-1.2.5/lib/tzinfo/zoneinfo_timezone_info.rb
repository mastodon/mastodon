module TZInfo
  # An InvalidZoneinfoFile exception is raised if an attempt is made to load an
  # invalid zoneinfo file.
  class InvalidZoneinfoFile < StandardError
  end

  # Represents a timezone defined by a compiled zoneinfo TZif (\0, 2 or 3) file.
  #
  # @private
  class ZoneinfoTimezoneInfo < TransitionDataTimezoneInfo #:nodoc:
    
    # Minimum supported timestamp (inclusive).
    #
    # Time.utc(1700, 1, 1).to_i
    MIN_TIMESTAMP = -8520336000

    # Maximum supported timestamp (exclusive).
    #
    # Time.utc(2500, 1, 1).to_i
    MAX_TIMESTAMP = 16725225600

    # Constructs the new ZoneinfoTimezoneInfo with an identifier and path
    # to the file.
    def initialize(identifier, file_path)
      super(identifier)
      
      File.open(file_path, 'rb') do |file|
        parse(file)
      end
    end
    
    private
      # Unpack will return unsigned 32-bit integers. Translate to 
      # signed 32-bit.
      def make_signed_int32(long)
        long >= 0x80000000 ? long - 0x100000000 : long
      end
      
      # Unpack will return a 64-bit integer as two unsigned 32-bit integers
      # (most significant first). Translate to signed 64-bit
      def make_signed_int64(high, low)
        unsigned = (high << 32) | low
        unsigned >= 0x8000000000000000 ? unsigned - 0x10000000000000000 : unsigned
      end
      
      # Read bytes from file and check that the correct number of bytes could
      # be read. Raises InvalidZoneinfoFile if the number of bytes didn't match
      # the number requested.
      def check_read(file, bytes)
        result = file.read(bytes)
        
        unless result && result.length == bytes
          raise InvalidZoneinfoFile, "Expected #{bytes} bytes reading '#{file.path}', but got #{result ? result.length : 0} bytes"
        end
        
        result
      end
      
      # Zoneinfo files don't include the offset from standard time (std_offset)
      # for DST periods. Derive the base offset (utc_offset) where DST is
      # observed from either the previous or next non-DST period.
      #
      # Returns the index of the offset to be used prior to the first
      # transition.
      def derive_offsets(transitions, offsets)
        # The first non-DST offset (if there is one) is the offset observed
        # before the first transition. Fallback to the first DST offset if there
        # are no non-DST offsets.
        first_non_dst_offset_index = offsets.index {|o| !o[:is_dst] }
        first_offset_index = first_non_dst_offset_index || 0
        return first_offset_index if transitions.empty?

        # Determine the utc_offset of the next non-dst offset at each transition.
        utc_offset_from_next = nil

        transitions.reverse_each do |transition|
          offset = offsets[transition[:offset]]
          if offset[:is_dst]
            transition[:utc_offset_from_next] = utc_offset_from_next if utc_offset_from_next
          else
            utc_offset_from_next = offset[:utc_total_offset]
          end
        end

        utc_offset_from_previous = first_non_dst_offset_index ? offsets[first_non_dst_offset_index][:utc_total_offset] : nil
        defined_offsets = {}

        transitions.each do |transition|
          offset_index = transition[:offset]
          offset = offsets[offset_index]
          utc_total_offset = offset[:utc_total_offset]

          if offset[:is_dst]
            utc_offset_from_next = transition[:utc_offset_from_next]

            difference_to_previous = (utc_total_offset - (utc_offset_from_previous || utc_total_offset)).abs
            difference_to_next = (utc_total_offset - (utc_offset_from_next || utc_total_offset)).abs

            utc_offset = if difference_to_previous == 3600
              utc_offset_from_previous
            elsif difference_to_next == 3600
              utc_offset_from_next
            elsif difference_to_previous > 0 && difference_to_next > 0
              difference_to_previous < difference_to_next ? utc_offset_from_previous : utc_offset_from_next
            elsif difference_to_previous > 0
              utc_offset_from_previous
            elsif difference_to_next > 0
              utc_offset_from_next
            else
              # No difference, assume a 1 hour offset from standard time.
              utc_total_offset - 3600
            end

            if !offset[:utc_offset]
              offset[:utc_offset] = utc_offset
              defined_offsets[offset] = offset_index
            elsif offset[:utc_offset] != utc_offset
              # An earlier transition has already derived a different
              # utc_offset. Define a new offset or reuse an existing identically
              # defined offset.
              new_offset = offset.dup
              new_offset[:utc_offset] = utc_offset

              offset_index = defined_offsets[new_offset]

              unless offset_index
                offsets << new_offset
                offset_index = offsets.length - 1
                defined_offsets[new_offset] = offset_index
              end

              transition[:offset] = offset_index
            end
          else
            utc_offset_from_previous = utc_total_offset
          end
        end

        first_offset_index
      end

      # Defines an offset for the timezone based on the given index and offset
      # Hash.
      def define_offset(index, offset)
        utc_total_offset = offset[:utc_total_offset]
        utc_offset = offset[:utc_offset]

        if utc_offset
          # DST offset with base utc_offset derived by derive_offsets.
          std_offset = utc_total_offset - utc_offset
        elsif offset[:is_dst]
          # DST offset unreferenced by a transition (offset in use before the
          # first transition). No derived base UTC offset, so assume 1 hour
          # DST.
          utc_offset = utc_total_offset - 3600
          std_offset = 3600
        else
          # Non-DST offset.
          utc_offset = utc_total_offset
          std_offset = 0
        end

        offset index, utc_offset, std_offset, offset[:abbr].untaint.to_sym
      end
      
      # Parses a zoneinfo file and intializes the DataTimezoneInfo structures.
      def parse(file)
        magic, version, ttisgmtcnt, ttisstdcnt, leapcnt, timecnt, typecnt, charcnt =
          check_read(file, 44).unpack('a4 a x15 NNNNNN')

        if magic != 'TZif'
          raise InvalidZoneinfoFile, "The file '#{file.path}' does not start with the expected header."
        end

        if (version == '2' || version == '3') && RubyCoreSupport.time_supports_64bit
          # Skip the first 32-bit section and read the header of the second 64-bit section
          file.seek(timecnt * 5 + typecnt * 6 + charcnt + leapcnt * 8 + ttisgmtcnt + ttisstdcnt, IO::SEEK_CUR)
          
          prev_version = version
          
          magic, version, ttisgmtcnt, ttisstdcnt, leapcnt, timecnt, typecnt, charcnt =
            check_read(file, 44).unpack('a4 a x15 NNNNNN')
            
          unless magic == 'TZif' && (version == prev_version)
            raise InvalidZoneinfoFile, "The file '#{file.path}' contains an invalid 64-bit section header."
          end
          
          using_64bit = true
        elsif version != '3' && version != '2' && version != "\0"
          raise InvalidZoneinfoFile, "The file '#{file.path}' contains a version of the zoneinfo format that is not currently supported."
        else
          using_64bit = false
        end
        
        unless leapcnt == 0
          raise InvalidZoneinfoFile, "The zoneinfo file '#{file.path}' contains leap second data. TZInfo requires zoneinfo files that omit leap seconds."
        end
        
        transitions = []
        
        if using_64bit
          timecnt.times do |i|
            high, low = check_read(file, 8).unpack('NN'.freeze)
            transition_time = make_signed_int64(high, low)
            transitions << {:at => transition_time}          
          end
        else
          timecnt.times do |i|
            transition_time = make_signed_int32(check_read(file, 4).unpack('N'.freeze)[0])
            transitions << {:at => transition_time}          
          end
        end
        
        timecnt.times do |i|
          localtime_type = check_read(file, 1).unpack('C'.freeze)[0]
          transitions[i][:offset] = localtime_type
        end
        
        offsets = []
        
        typecnt.times do |i|
          gmtoff, isdst, abbrind = check_read(file, 6).unpack('NCC'.freeze)
          gmtoff = make_signed_int32(gmtoff)
          isdst = isdst == 1
          offset = {:utc_total_offset => gmtoff, :is_dst => isdst, :abbr_index => abbrind}
          
          unless isdst
            offset[:utc_offset] = gmtoff
            offset[:std_offset] = 0
          end
          
          offsets << offset
        end
        
        abbrev = check_read(file, charcnt)

        offsets.each do |o|
          abbrev_start = o[:abbr_index]         
          raise InvalidZoneinfoFile, "Abbreviation index is out of range in file '#{file.path}'" unless abbrev_start < abbrev.length
          
          abbrev_end = abbrev.index("\0", abbrev_start)
          raise InvalidZoneinfoFile, "Missing abbreviation null terminator in file '#{file.path}'" unless abbrev_end

          o[:abbr] = RubyCoreSupport.force_encoding(abbrev[abbrev_start...abbrev_end], 'UTF-8')
        end
        
        transitions.each do |t|
          if t[:offset] < 0 || t[:offset] >= offsets.length
            raise InvalidZoneinfoFile, "Invalid offset referenced by transition in file '#{file.path}'."
          end
        end
        
        # Derive the offsets from standard time (std_offset).
        first_offset_index = derive_offsets(transitions, offsets)
        
        define_offset(first_offset_index, offsets[first_offset_index])
        
        offsets.each_with_index do |o, i|
          define_offset(i, o) unless i == first_offset_index
        end

        if !using_64bit && !RubyCoreSupport.time_supports_negative
          # Filter out transitions that are not supported by Time on this
          # platform.

          # Move the last transition before the epoch up to the epoch. This
          # allows for accurate conversions for all supported timestamps on the
          # platform.

          before_epoch, after_epoch = transitions.partition {|t| t[:at] < 0}

          if before_epoch.length > 0 && after_epoch.length > 0 && after_epoch.first[:at] != 0
            last_before = before_epoch.last
            last_before[:at] = 0
            transitions = [last_before] + after_epoch
          else
            transitions = after_epoch
          end
        end
        
        # Ignore transitions that occur outside of a defined window. The
        # transition index cannot handle a large range of transition times.
        #
        # This is primarily intended to ignore the far in the past transition
        # added in zic 2014c (at timestamp -2**63 in zic 2014c and at the
        # approximate time of the big bang from zic 2014d).
        transitions.each do |t|
          at = t[:at]
          if at >= MIN_TIMESTAMP && at < MAX_TIMESTAMP
            time = Time.at(at).utc
            transition time.year, time.mon, t[:offset], at
          end
        end
      end
  end
end
