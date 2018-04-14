require 'http/cookie'
require 'strscan'
require 'time'

class HTTP::Cookie::Scanner < StringScanner
  # Whitespace.
  RE_WSP = /[ \t]+/

  # A pattern that matches a cookie name or attribute name which may
  # be empty, capturing trailing whitespace.
  RE_NAME = /(?!#{RE_WSP})[^,;\\"=]*/

  RE_BAD_CHAR = /([\x00-\x20\x7F",;\\])/

  # A pattern that matches the comma in a (typically date) value.
  RE_COOKIE_COMMA = /,(?=#{RE_WSP}?#{RE_NAME}=)/

  def initialize(string, logger = nil)
    @logger = logger
    super(string)
  end

  class << self
    def quote(s)
      return s unless s.match(RE_BAD_CHAR)
      '"' << s.gsub(/([\\"])/, "\\\\\\1") << '"'
    end
  end

  def skip_wsp
    skip(RE_WSP)
  end

  def scan_dquoted
    ''.tap { |s|
      case
      when skip(/"/)
        break
      when skip(/\\/)
        s << getch
      when scan(/[^"\\]+/)
        s << matched
      end until eos?
    }
  end

  def scan_name
    scan(RE_NAME).tap { |s|
      s.rstrip! if s
    }
  end

  def scan_value(comma_as_separator = false)
    ''.tap { |s|
      case
      when scan(/[^,;"]+/)
        s << matched
      when skip(/"/)
        # RFC 6265 2.2
        # A cookie-value may be DQUOTE'd.
        s << scan_dquoted
      when check(/;/)
        break
      when comma_as_separator && check(RE_COOKIE_COMMA)
        break
      else
        s << getch
      end until eos?
      s.rstrip!
    }
  end

  def scan_name_value(comma_as_separator = false)
    name = scan_name
    if skip(/\=/)
      value = scan_value(comma_as_separator)
    else
      scan_value(comma_as_separator)
      value = nil
    end
    [name, value]
  end

  if Time.respond_to?(:strptime)
    def tuple_to_time(day_of_month, month, year, time)
      Time.strptime(
        '%02d %s %04d %02d:%02d:%02d UTC' % [day_of_month, month, year, *time],
        '%d %b %Y %T %Z'
      ).tap { |date|
        date.day == day_of_month or return nil
      }
    end
  else
    def tuple_to_time(day_of_month, month, year, time)
      Time.parse(
        '%02d %s %04d %02d:%02d:%02d UTC' % [day_of_month, month, year, *time]
      ).tap { |date|
        date.day == day_of_month or return nil
      }
    end
  end
  private :tuple_to_time

  def parse_cookie_date(s)
    # RFC 6265 5.1.1
    time = day_of_month = month = year = nil

    s.split(/[\x09\x20-\x2F\x3B-\x40\x5B-\x60\x7B-\x7E]+/).each { |token|
      case
      when time.nil? && token.match(/\A(\d{1,2}):(\d{1,2})(?::(\d{1,2}))?(?=\D|\z)/)
        sec =
          if $3
            $3.to_i
          else
            # violation of the RFC
            @logger.warn("Time lacks the second part: #{token}") if @logger
            0
          end
        time = [$1.to_i, $2.to_i, sec]
      when day_of_month.nil? && token.match(/\A(\d{1,2})(?=\D|\z)/)
        day_of_month = $1.to_i
      when month.nil? && token.match(/\A(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)/i)
        month = $1.capitalize
      when year.nil? && token.match(/\A(\d{2,4})(?=\D|\z)/)
        year = $1.to_i
      end
    }

    if day_of_month.nil? || month.nil? || year.nil? || time.nil?
      return nil
    end

    case day_of_month
    when 1..31
    else
      return nil
    end

    case year
    when 100..1600
      return nil
    when 70..99
      year += 1900
    when 0..69
      year += 2000
    end

    hh, mm, ss = time
    if hh > 23 || mm > 59 || ss > 59
      return nil
    end

    tuple_to_time(day_of_month, month, year, time)
  end

  def scan_set_cookie
    # RFC 6265 4.1.1 & 5.2
    until eos?
      start = pos
      len = nil

      skip_wsp

      name, value = scan_name_value(true)
      if value.nil?
        @logger.warn("Cookie definition lacks a name-value pair.") if @logger
      elsif name.empty?
        @logger.warn("Cookie definition has an empty name.") if @logger
        value = nil
      end
      attrs = {}

      case
      when skip(/,/)
        # The comma is used as separator for concatenating multiple
        # values of a header.
        len = (pos - 1) - start
        break
      when skip(/;/)
        skip_wsp
        aname, avalue = scan_name_value(true)
        next if aname.empty? || value.nil?
        aname.downcase!
        case aname
        when 'expires'
          # RFC 6265 5.2.1
          avalue &&= parse_cookie_date(avalue) or next
        when 'max-age'
          # RFC 6265 5.2.2
          next unless /\A-?\d+\z/.match(avalue)
        when 'domain'
          # RFC 6265 5.2.3
          # An empty value SHOULD be ignored.
          next if avalue.nil? || avalue.empty?
        when 'path'
          # RFC 6265 5.2.4
          # A relative path must be ignored rather than normalizing it
          # to "/".
          next unless /\A\//.match(avalue)
        when 'secure', 'httponly'
          # RFC 6265 5.2.5, 5.2.6
          avalue = true
        end
        attrs[aname] = avalue
      end until eos?

      len ||= pos - start

      if len > HTTP::Cookie::MAX_LENGTH
        @logger.warn("Cookie definition too long: #{name}") if @logger
        next
      end

      yield name, value, attrs if value
    end
  end

  def scan_cookie
    # RFC 6265 4.1.1 & 5.4
    until eos?
      skip_wsp

      # Do not treat comma in a Cookie header value as separator; see CVE-2016-7401
      name, value = scan_name_value(false)

      yield name, value if value

      skip(/;/)
    end
  end
end
