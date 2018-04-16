# encoding: utf-8
# frozen_string_literal: true
module Mail
  
  # = Body
  # 
  # The body is where the text of the email is stored.  Mail treats the body
  # as a single object.  The body itself has no information about boundaries
  # used in the MIME standard, it just looks at its content as either a single
  # block of text, or (if it is a multipart message) as an array of blocks of text.
  # 
  # A body has to be told to split itself up into a multipart message by calling
  # #split with the correct boundary.  This is because the body object has no way
  # of knowing what the correct boundary is for itself (there could be many
  # boundaries in a body in the case of a nested MIME text).
  # 
  # Once split is called, Mail::Body will slice itself up on this boundary,
  # assigning anything that appears before the first part to the preamble, and
  # anything that appears after the closing boundary to the epilogue, then
  # each part gets initialized into a Mail::Part object.
  # 
  # The boundary that is used to split up the Body is also stored in the Body
  # object for use on encoding itself back out to a string.  You can 
  # overwrite this if it needs to be changed.
  # 
  # On encoding, the body will return the preamble, then each part joined by
  # the boundary, followed by a closing boundary string and then the epilogue.
  class Body

    def initialize(string = '')
      @boundary = nil
      @preamble = nil
      @epilogue = nil
      @charset  = nil
      @part_sort_order = [ "text/plain", "text/enriched", "text/html", "multipart/alternative" ]
      @parts = Mail::PartsList.new
      if Utilities.blank?(string)
        @raw_source = ''
      else
        # Do join first incase we have been given an Array in Ruby 1.9
        if string.respond_to?(:join)
          @raw_source = string.join('')
        elsif string.respond_to?(:to_s)
          @raw_source = string.to_s
        else
          raise "You can only assign a string or an object that responds_to? :join or :to_s to a body."
        end
      end
      @encoding = default_encoding
      set_charset
    end

    # Matches this body with another body.  Also matches the decoded value of this
    # body with a string.
    # 
    # Examples:
    # 
    #   body = Mail::Body.new('The body')
    #   body == body #=> true
    #   
    #   body = Mail::Body.new('The body')
    #   body == 'The body' #=> true
    #   
    #   body = Mail::Body.new("VGhlIGJvZHk=\n")
    #   body.encoding = 'base64'
    #   body == "The body" #=> true
    def ==(other)
      if other.class == String
        self.decoded == other
      else
        super
      end
    end
    
    # Accepts a string and performs a regular expression against the decoded text
    # 
    # Examples:
    # 
    #   body = Mail::Body.new('The body')
    #   body =~ /The/ #=> 0
    #   
    #   body = Mail::Body.new("VGhlIGJvZHk=\n")
    #   body.encoding = 'base64'
    #   body =~ /The/ #=> 0
    def =~(regexp)
      self.decoded =~ regexp
    end
    
    # Accepts a string and performs a regular expression against the decoded text
    # 
    # Examples:
    # 
    #   body = Mail::Body.new('The body')
    #   body.match(/The/) #=> #<MatchData "The">
    #   
    #   body = Mail::Body.new("VGhlIGJvZHk=\n")
    #   body.encoding = 'base64'
    #   body.match(/The/) #=> #<MatchData "The">
    def match(regexp)
      self.decoded.match(regexp)
    end

    # Accepts anything that responds to #to_s and checks if it's a substring of the decoded text
    #
    # Examples:
    #
    #   body = Mail::Body.new('The body')
    #   body.include?('The') #=> true
    #
    #   body = Mail::Body.new("VGhlIGJvZHk=\n")
    #   body.encoding = 'base64'
    #   body.include?('The') #=> true
    def include?(other)
      self.decoded.include?(other.to_s)
    end

    # Allows you to set the sort order of the parts, overriding the default sort order.
    # Defaults to 'text/plain', then 'text/enriched', then 'text/html', then 'multipart/alternative'
    # with any other content type coming after.
    def set_sort_order(order)
      @part_sort_order = order
    end
    
    # Allows you to sort the parts according to the default sort order, or the sort order you
    # set with :set_sort_order.
    #
    # sort_parts! is also called from :encode, so there is no need for you to call this explicitly
    def sort_parts!
      @parts.each do |p|
        p.body.set_sort_order(@part_sort_order)
        p.body.sort_parts!
      end
      @parts.sort!(@part_sort_order)
    end
    
    # Returns the raw source that the body was initialized with, without
    # any tampering
    def raw_source
      @raw_source
    end

    def negotiate_best_encoding(message_encoding, allowed_encodings = nil)
      Mail::Encodings::TransferEncoding.negotiate(message_encoding, encoding, raw_source, allowed_encodings)
    end

    # Returns a body encoded using transfer_encoding.  Multipart always uses an
    # identiy encoding (i.e. no encoding).
    # Calling this directly is not a good idea, but supported for compatibility
    # TODO: Validate that preamble and epilogue are valid for requested encoding
    def encoded(transfer_encoding = nil)
      if multipart?
        self.sort_parts!
        encoded_parts = parts.map { |p| p.encoded }
        ([preamble] + encoded_parts).join(crlf_boundary) + end_boundary + epilogue.to_s
      else
        dec = Mail::Encodings.get_encoding(encoding)
        enc = negotiate_best_encoding(transfer_encoding)
        if dec.nil?
          # Cannot decode, so skip normalization
          raw_source
        else
          # Decode then encode to normalize and allow transforming 
          # from base64 to Q-P and vice versa
          decoded = dec.decode(raw_source)
          if defined?(Encoding) && charset && charset != "US-ASCII"
            decoded = decoded.encode(charset)
            decoded.force_encoding('BINARY') unless Encoding.find(charset).ascii_compatible?
          end
          enc.encode(decoded)
        end
      end
    end

    def decoded
      if !Encodings.defined?(encoding)
        raise UnknownEncodingType, "Don't know how to decode #{encoding}, please call #encoded and decode it yourself."
      else
        Encodings.get_encoding(encoding).decode(raw_source)
      end
    end
    
    def to_s
      decoded
    end
    
    def charset
      @charset
    end
    
    def charset=( val )
      @charset = val
    end

    def encoding(val = nil)
      if val
        self.encoding = val
      else
        @encoding
      end
    end

    def encoding=( val )
      @encoding =
        if val == "text" || Utilities.blank?(val)
          default_encoding
        else
          val
        end
    end

    # Returns the preamble (any text that is before the first MIME boundary)
    def preamble
      @preamble
    end

    # Sets the preamble to a string (adds text before the first MIME boundary)
    def preamble=( val )
      @preamble = val
    end
    
    # Returns the epilogue (any text that is after the last MIME boundary)
    def epilogue
      @epilogue
    end
    
    # Sets the epilogue to a string (adds text after the last MIME boundary)
    def epilogue=( val )
      @epilogue = val
    end
    
    # Returns true if there are parts defined in the body
    def multipart?
      true unless parts.empty?
    end
    
    # Returns the boundary used by the body
    def boundary
      @boundary
    end
    
    # Allows you to change the boundary of this Body object
    def boundary=( val )
      @boundary = val
    end

    def parts
      @parts
    end
    
    def <<( val )
      if @parts
        @parts << val
      else
        @parts = Mail::PartsList.new[val]
      end
    end

    def split!(boundary)
      self.boundary = boundary
      parts = extract_parts

      # Make the preamble equal to the preamble (if any)
      self.preamble = parts[0].to_s.strip
      # Make the epilogue equal to the epilogue (if any)
      self.epilogue = parts[-1].to_s.strip
      parts[1...-1].to_a.each { |part| @parts << Mail::Part.new(part) }
      self
    end

    def ascii_only?
      unless defined? @ascii_only
        @ascii_only = raw_source.ascii_only?
      end
      @ascii_only
    end

    def empty?
      !!raw_source.to_s.empty?
    end

    def default_encoding
      ascii_only? ? '7bit' : '8bit'
    end

    private

    # split parts by boundary, ignore first part if empty, append final part when closing boundary was missing
    def extract_parts
      parts_regex = /
        (?:                    # non-capturing group
          \A                |  # start of string OR
          \r\n                 # line break
         )
        (
          --#{Regexp.escape(boundary || "")}  # boundary delimiter
          (?:--)?                             # with non-capturing optional closing
        )
        (?=\s*$)                              # lookahead matching zero or more spaces followed by line-ending
      /x
      parts = raw_source.split(parts_regex).each_slice(2).to_a
      parts.each_with_index { |(part, _), index| parts.delete_at(index) if index > 0 && Utilities.blank?(part) }

      if parts.size > 1
        final_separator = parts[-2][1]
        parts << [""] if final_separator != "--#{boundary}--"
      end
      parts.map(&:first)
    end
    
    def crlf_boundary
      "\r\n--#{boundary}\r\n"
    end
    
    def end_boundary
      "\r\n--#{boundary}--\r\n"
    end

    def set_charset
      @charset = ascii_only? ? 'US-ASCII' : nil
    end
  end
end
