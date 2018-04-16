module RDF; class Literal
  ##
  # A date literal.
  #
  # @see   http://www.w3.org/TR/xmlschema11-2/#date
  # @since 0.2.1
  class Date < Literal
    DATATYPE = RDF::XSD.date
    GRAMMAR  = %r(\A(-?\d{4}-\d{2}-\d{2})((?:[\+\-]\d{2}:\d{2})|UTC|GMT|Z)?\Z).freeze
    FORMAT   = '%Y-%m-%d'.freeze

    ##
    # @param  [String, Date, #to_date] value
    # @param  (see Literal#initialize)
    def initialize(value, datatype: nil, lexical: nil, **options)
      @datatype = RDF::URI(datatype || self.class.const_get(:DATATYPE))
      @string   = lexical || (value if value.is_a?(String))
      @object   = case
        when value.is_a?(::Date)         then value
        when value.respond_to?(:to_date) then value.to_date
        else ::Date.parse(value.to_s)
      end rescue ::Date.new
    end

    ##
    # Converts this literal into its canonical lexical representation.
    #
    # Note that the timezone is recoverable for xsd:date, where it is not for xsd:dateTime and xsd:time, which are both transformed relative to Z, if a timezone is provided.
    #
    # @return [RDF::Literal] `self`
    # @see    http://www.w3.org/TR/xmlschema11-2/#date
    def canonicalize!
      @string = @object.strftime(FORMAT) + self.tz.to_s if self.valid?
      self
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
      super && object && value !~ %r(\A0000)
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
    #
    # @return [String]
    def to_s
      @string || @object.strftime(FORMAT)
    end

    ##
    # Returns a human-readable value for the literal
    #
    # @return [String]
    # @since 1.1.6
    def humanize(lang = :en)
      d = object.strftime("%A, %d %B %Y")
      if has_timezone?
        d += if self.tz == 'Z'
          " UTC"
        else
          " #{self.tz}"
        end
      end
      d
    end

    ##
    # Returns the timezone part of arg as a simple literal. Returns the empty string if there is no timezone.
    #
    # @return [RDF::Literal]
    # @since 1.1.6
    def tz
      md = self.to_s.match(GRAMMAR)
      zone =  md[2].to_s
      zone = "Z" if zone == "+00:00"
      RDF::Literal(zone)
    end

    ##
    # Equal compares as Date objects
    def ==(other)
      # If lexically invalid, use regular literal testing
      return super unless self.valid?

      case other
      when Literal::Date
        return super unless other.valid?
        self.object == other.object
      when Literal::Time, Literal::DateTime
        false
      else
        super
      end
    end
  end # Date
end; end # RDF::Literal
