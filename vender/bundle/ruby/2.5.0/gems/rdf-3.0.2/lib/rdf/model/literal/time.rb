# coding: utf-8
module RDF; class Literal
  ##
  # A time literal.
  #
  # The lexical representation for time is the left truncated lexical
  # representation for `xsd:dateTime`: "hh:mm:ss.sss" with an optional
  # following time zone indicator.
  #
  # @see   http://www.w3.org/TR/xmlschema11-2/#time
  # @since 0.2.1
  class Time < Literal
    DATATYPE = RDF::XSD.time
    GRAMMAR  = %r(\A(\d{2}:\d{2}:\d{2}(?:\.\d+)?)((?:[\+\-]\d{2}:\d{2})|UTC|GMT|Z)?\Z).freeze
    FORMAT   = '%H:%M:%S%:z'.freeze

    ##
    # @param  [String, DateTime, #to_datetime] value
    # @param  (see Literal#initialize)
    def initialize(value, datatype: nil, lexical: nil, **options)
      @datatype = RDF::URI(datatype || self.class.const_get(:DATATYPE))
      @string   = lexical || (value if value.is_a?(String))
      @object   = case
        when value.is_a?(::DateTime)         then value
        when value.respond_to?(:to_datetime) then value.to_datetime rescue ::DateTime.parse(value.to_s)
        else ::DateTime.parse(value.to_s)
      end rescue ::DateTime.new
    end

    ##
    # Converts this literal into its canonical lexical representation.
    #
    # §3.2.8.2 Canonical representation
    #
    # The canonical representation for time is defined by prohibiting
    # certain options from the Lexical representation (§3.2.8.1).
    # Specifically, either the time zone must be omitted or, if present, the
    # time zone must be Coordinated Universal Time (UTC) indicated by a "Z".
    # Additionally, the canonical representation for midnight is 00:00:00.
    #
    # @return [RDF::Literal] `self`
    # @see    http://www.w3.org/TR/xmlschema11-2/#time
    def canonicalize!
      if self.valid?
        @string = if has_timezone?
          @object.new_offset.new_offset.strftime(FORMAT[0..-4] + 'Z')
        else
          @object.strftime(FORMAT[0..-4])
        end
      end
      self
    end

    ##
    # Returns the timezone part of arg as a simple literal. Returns the empty string if there is no timezone.
    #
    # @return [RDF::Literal]
    # @see http://www.w3.org/TR/sparql11-query/#func-tz
    def tz
      zone =  has_timezone? ? object.zone : ""
      zone = "Z" if zone == "+00:00"
      RDF::Literal(zone)
    end

    ##
    # Returns `true` if the value adheres to the defined grammar of the
    # datatype.
    #
    # Special case for date and dateTime, for which '0000' is not a valid year
    #
    # @return [Boolean]
    # @since  0.2.1
    def valid?
      super && !object.nil?
    end

    ##
    # Does the literal representation include a timezone? Note that this is only possible if initialized using a string, or `:lexical` option.
    #
    # @return [Boolean]
    # @since 1.1.6
    def has_timezone?
      md = self.to_s.match(GRAMMAR)
      md && !!md[2]
    end
    alias_method :has_tz?, :has_timezone?

    ##
    # Returns the value as a string.
    # Does not normalize timezone
    #
    # @return [String]
    def to_s
      @string || @object.strftime(FORMAT).sub("+00:00", 'Z')
    end

    ##
    # Returns a human-readable value for the literal
    #
    # @return [String]
    # @since 1.1.6
    def humanize(lang = :en)
      t = object.strftime("%r")
      if has_timezone?
        t += if self.tz == 'Z'
          " UTC"
        else
          " #{self.tz}"
        end
      end
      t
    end

    ##
    # Equal compares as Time objects
    def ==(other)
      # If lexically invalid, use regular literal testing
      return super unless self.valid?

      case other
      when Literal::Time
        return super unless other.valid?
        # Compare as strings, as time includes a date portion, and adjusting for UTC
        # can create a mismatch in the date portion.
        self.object.new_offset.strftime('%H%M%S') == other.object.new_offset.strftime('%H%M%S')
      when Literal::DateTime, Literal::Date
        false
      else
        super
      end
    end
  end # Time
end; end # RDF::Literal
