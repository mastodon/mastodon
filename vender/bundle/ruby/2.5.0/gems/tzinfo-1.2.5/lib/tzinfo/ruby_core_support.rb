require 'date'
require 'rational' unless defined?(Rational)

module TZInfo
  
  # Methods to support different versions of Ruby.
  #
  # @private
  module RubyCoreSupport #:nodoc:
  
    # Use Rational.new! for performance reasons in Ruby 1.8.
    # This has been removed from 1.9, but Rational performs better.        
    if Rational.respond_to? :new!
      def self.rational_new!(numerator, denominator = 1)
        Rational.new!(numerator, denominator)
      end
    else
      def self.rational_new!(numerator, denominator = 1)
        Rational(numerator, denominator)
      end
    end
    
    # Ruby 1.8.6 introduced new! and deprecated new0.
    # Ruby 1.9.0 removed new0.
    # Ruby trunk revision 31668 removed the new! method.
    # Still support new0 for better performance on older versions of Ruby (new0 indicates
    # that the rational has already been reduced to its lowest terms).
    # Fallback to jd with conversion from ajd if new! and new0 are unavailable.
    if DateTime.respond_to? :new!
      def self.datetime_new!(ajd = 0, of = 0, sg = Date::ITALY)
        DateTime.new!(ajd, of, sg)
      end
    elsif DateTime.respond_to? :new0
      def self.datetime_new!(ajd = 0, of = 0, sg = Date::ITALY)
        DateTime.new0(ajd, of, sg)
      end
    else
      HALF_DAYS_IN_DAY = rational_new!(1, 2)

      def self.datetime_new!(ajd = 0, of = 0, sg = Date::ITALY)
        # Convert from an Astronomical Julian Day number to a civil Julian Day number.
        jd = ajd + of + HALF_DAYS_IN_DAY
        
        # Ruby trunk revision 31862 changed the behaviour of DateTime.jd so that it will no
        # longer accept a fractional civil Julian Day number if further arguments are specified.
        # Calculate the hours, minutes and seconds to pass to jd.
        
        jd_i = jd.to_i
        jd_i -= 1 if jd < 0
        hours = (jd - jd_i) * 24
        hours_i = hours.to_i
        minutes = (hours - hours_i) * 60
        minutes_i = minutes.to_i
        seconds = (minutes - minutes_i) * 60
        
        DateTime.jd(jd_i, hours_i, minutes_i, seconds, of, sg)
      end
    end
    
    # DateTime in Ruby 1.8.6 doesn't consider times within the 60th second to be
    # valid. When attempting to specify such a DateTime, subtract the fractional
    # part and then add it back later
    if Date.respond_to?(:valid_time?) && !Date.valid_time?(0, 0, rational_new!(59001, 1000)) # 0:0:59.001
      def self.datetime_new(y=-4712, m=1, d=1, h=0, min=0, s=0, of=0, sg=Date::ITALY)
        if !s.kind_of?(Integer) && s > 59
          dt = DateTime.new(y, m, d, h, min, 59, of, sg)
          dt + (s - 59) / 86400
        else
          DateTime.new(y, m, d, h, min, s, of, sg)
        end
      end
    else
      def self.datetime_new(y=-4712, m=1, d=1, h=0, min=0, s=0, of=0, sg=Date::ITALY)
        DateTime.new(y, m, d, h, min, s, of, sg)
      end    
    end    
    
    # Returns true if Time on the runtime platform supports Times defined
    # by negative 32-bit timestamps, otherwise false.
    begin
      Time.at(-1)
      Time.at(-2147483648)
      
      def self.time_supports_negative
        true
      end
    rescue ArgumentError
      def self.time_supports_negative
        false
      end
    end
    
    # Returns true if Time on the runtime platform supports Times defined by
    # 64-bit timestamps, otherwise false.
    begin
      Time.at(-2147483649)
      Time.at(2147483648)
      
      def self.time_supports_64bit
        true
      end
    rescue RangeError
      def self.time_supports_64bit
        false
      end
    end
    
    # Return the result of Time#nsec if it exists, otherwise return the
    # result of Time#usec * 1000.
    if Time.method_defined?(:nsec)
      def self.time_nsec(time)
        time.nsec
      end
    else
      def self.time_nsec(time)
        time.usec * 1000
      end
    end
    
    # Call String#force_encoding if this version of Ruby has encoding support
    # otherwise treat as a no-op.
    if String.method_defined?(:force_encoding)
      def self.force_encoding(str, encoding)
        str.force_encoding(encoding)
      end
    else
      def self.force_encoding(str, encoding)
        str
      end
    end
    
    
    # Wrapper for File.open that supports passing hash options for specifying
    # encodings on Ruby 1.9+. The options are ignored on earlier versions of
    # Ruby.
    if RUBY_VERSION =~ /\A1\.[0-8]\./
      def self.open_file(file_name, mode, opts, &block)
        File.open(file_name, mode, &block)
      end
    else
      def self.open_file(file_name, mode, opts, &block)
        File.open(file_name, mode, opts, &block)
      end
    end
  end
end
