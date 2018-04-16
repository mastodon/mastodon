# encoding: utf-8
# frozen_string_literal: true
module Mail
  
  # Provides access to a header object.
  # 
  # ===Per RFC2822
  # 
  #  2.2. Header Fields
  # 
  #   Header fields are lines composed of a field name, followed by a colon
  #   (":"), followed by a field body, and terminated by CRLF.  A field
  #   name MUST be composed of printable US-ASCII characters (i.e.,
  #   characters that have values between 33 and 126, inclusive), except
  #   colon.  A field body may be composed of any US-ASCII characters,
  #   except for CR and LF.  However, a field body may contain CRLF when
  #   used in header "folding" and  "unfolding" as described in section
  #   2.2.3.  All field bodies MUST conform to the syntax described in
  #   sections 3 and 4 of this standard.
  class Header
    include Constants
    include Utilities
    include Enumerable
    
    @@maximum_amount = 1000

    # Large amount of headers in Email might create extra high CPU load
    # Use this parameter to limit number of headers that will be parsed by 
    # mail library.
    # Default: 1000
    def self.maximum_amount
      @@maximum_amount
    end

    def self.maximum_amount=(value)
      @@maximum_amount = value
    end

    # Creates a new header object.
    # 
    # Accepts raw text or nothing.  If given raw text will attempt to parse
    # it and split it into the various fields, instantiating each field as
    # it goes.
    # 
    # If it finds a field that should be a structured field (such as content
    # type), but it fails to parse it, it will simply make it an unstructured
    # field and leave it alone.  This will mean that the data is preserved but
    # no automatic processing of that field will happen.  If you find one of
    # these cases, please make a patch and send it in, or at the least, send
    # me the example so we can fix it.
    def initialize(header_text = nil, charset = nil)
      @charset = charset
      self.raw_source = header_text
      split_header if header_text
    end

    def initialize_copy(original)
      super
      @fields = @fields.dup
      @fields.map!(&:dup)
    end
    
    # The preserved raw source of the header as you passed it in, untouched
    # for your Regexing glory.
    def raw_source
      @raw_source
    end
    
    # Returns an array of all the fields in the header in order that they
    # were read in.
    def fields
      @fields ||= FieldList.new
    end
    
    #  3.6. Field definitions
    #  
    #   It is important to note that the header fields are not guaranteed to
    #   be in a particular order.  They may appear in any order, and they
    #   have been known to be reordered occasionally when transported over
    #   the Internet.  However, for the purposes of this standard, header
    #   fields SHOULD NOT be reordered when a message is transported or
    #   transformed.  More importantly, the trace header fields and resent
    #   header fields MUST NOT be reordered, and SHOULD be kept in blocks
    #   prepended to the message.  See sections 3.6.6 and 3.6.7 for more
    #   information.
    # 
    # Populates the fields container with Field objects in the order it
    # receives them in.
    #
    # Acceps an array of field string values, for example:
    # 
    #  h = Header.new
    #  h.fields = ['From: mikel@me.com', 'To: bob@you.com']
    def fields=(unfolded_fields)
      @fields = Mail::FieldList.new
      Kernel.warn "WARNING: More than #{self.class.maximum_amount} header fields; only using the first #{self.class.maximum_amount} and ignoring the rest" if unfolded_fields.length > self.class.maximum_amount
      unfolded_fields[0..(self.class.maximum_amount-1)].each do |field|

        if field = Field.parse(field, charset)
          if limited_field?(field.name) && (selected = select_field_for(field.name)) && selected.any?
            selected.first.update(field.name, field.value)
          else
            @fields << field
          end
        end
      end

    end
    
    def errors
      @fields.map(&:errors).flatten(1)
    end
    
    #  3.6. Field definitions
    #  
    #   The following table indicates limits on the number of times each
    #   field may occur in a message header as well as any special
    #   limitations on the use of those fields.  An asterisk next to a value
    #   in the minimum or maximum column indicates that a special restriction
    #   appears in the Notes column.
    #
    #   <snip table from 3.6>
    #
    # As per RFC, many fields can appear more than once, we will return a string
    # of the value if there is only one header, or if there is more than one 
    # matching header, will return an array of values in order that they appear
    # in the header ordered from top to bottom.
    # 
    # Example:
    # 
    #  h = Header.new
    #  h.fields = ['To: mikel@me.com', 'X-Mail-SPAM: 15', 'X-Mail-SPAM: 20']
    #  h['To']          #=> 'mikel@me.com'
    #  h['X-Mail-SPAM'] #=> ['15', '20']
    def [](name)
      name = dasherize(name)
      name.downcase!
      selected = select_field_for(name)
      case
      when selected.length > 1
        selected.map { |f| f }
      when !Utilities.blank?(selected)
        selected.first
      else
        nil
      end
    end
    
    # Sets the FIRST matching field in the header to passed value, or deletes
    # the FIRST field matched from the header if passed nil
    # 
    # Example:
    # 
    #  h = Header.new
    #  h.fields = ['To: mikel@me.com', 'X-Mail-SPAM: 15', 'X-Mail-SPAM: 20']
    #  h['To'] = 'bob@you.com'
    #  h['To']    #=> 'bob@you.com'
    #  h['X-Mail-SPAM'] = '10000'
    #  h['X-Mail-SPAM'] # => ['15', '20', '10000']
    #  h['X-Mail-SPAM'] = nil
    #  h['X-Mail-SPAM'] # => nil
    def []=(name, value)
      name = dasherize(name)
      if name.include?(':')
        raise ArgumentError, "Header names may not contain a colon: #{name.inspect}"
      end
      fn = name.downcase
      selected = select_field_for(fn)
      
      case
      # User wants to delete the field
      when !Utilities.blank?(selected) && value == nil
        fields.delete_if { |f| selected.include?(f) }
        
      # User wants to change the field
      when !Utilities.blank?(selected) && limited_field?(fn)
        selected.first.update(fn, value)
        
      # User wants to create the field
      else
        # Need to insert in correct order for trace fields
        self.fields << Field.new(name.to_s, value, charset)
      end
      if dasherize(fn) == "content-type"
        # Update charset if specified in Content-Type
        params = self[:content_type].parameters rescue nil
        @charset = params[:charset] if params && params[:charset]
      end
    end
    
    def charset
      @charset
    end
    
    def charset=(val)
      params = self[:content_type].parameters rescue nil
      if params
        params[:charset] = val
      end
      @charset = val
    end
    
    LIMITED_FIELDS   = %w[ date from sender reply-to to cc bcc 
                           message-id in-reply-to references subject
                           return-path content-type mime-version
                           content-transfer-encoding content-description 
                           content-id content-disposition content-location]

    def encoded
      buffer = String.new
      buffer.force_encoding('us-ascii') if buffer.respond_to?(:force_encoding)
      fields.each do |field|
        buffer << field.encoded
      end
      buffer
    end

    def to_s
      encoded
    end
    
    def decoded
      raise NoMethodError, 'Can not decode an entire header as there could be character set conflicts, try calling #decoded on the various fields.'
    end

    def field_summary
      fields.map { |f| "<#{f.name}: #{f.value}>" }.join(", ")
    end

    # Returns true if the header has a Message-ID defined (empty or not)
    def has_message_id?
      !fields.select { |f| f.responsible_for?('Message-ID') }.empty?
    end

    # Returns true if the header has a Content-ID defined (empty or not)
    def has_content_id?
      !fields.select { |f| f.responsible_for?('Content-ID') }.empty?
    end

    # Returns true if the header has a Date defined (empty or not)
    def has_date?
      !fields.select { |f| f.responsible_for?('Date') }.empty?
    end

    # Returns true if the header has a MIME version defined (empty or not)
    def has_mime_version?
      !fields.select { |f| f.responsible_for?('Mime-Version') }.empty?
    end

    private
    
    def raw_source=(val)
      @raw_source = ::Mail::Utilities.to_crlf(val).lstrip
    end
    
    # Splits an unfolded and line break cleaned header into individual field
    # strings.
    def split_header
      self.fields = raw_source.split(HEADER_SPLIT)
    end
    
    def select_field_for(name)
      fields.select { |f| f.responsible_for?(name) }
    end
    
    def limited_field?(name)
      LIMITED_FIELDS.include?(name.to_s.downcase)
    end

    # Enumerable support; yield each field in order to the block if there is one,
    # or return an Enumerator for them if there isn't.
    def each( &block )
      return self.fields.each( &block ) if block
      self.fields.each
    end

  end
end
