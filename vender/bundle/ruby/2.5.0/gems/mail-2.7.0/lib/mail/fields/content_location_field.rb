# encoding: utf-8
# frozen_string_literal: true
# 
# 
# 
module Mail
  class ContentLocationField < StructuredField
    
    FIELD_NAME = 'content-location'
    CAPITALIZED_FIELD = 'Content-Location'
    
    def initialize(value = nil, charset = 'utf-8')
      self.charset = charset
      super(CAPITALIZED_FIELD, value, charset)
      self.parse
      self
    end
    
    def parse(val = value)
      unless Utilities.blank?(val)
        @element = Mail::ContentLocationElement.new(val)
      end
    end
    
    def element
      @element ||= Mail::ContentLocationElement.new(value)
    end

    def location
      element.location
    end

    # TODO: Fix this up
    def encoded
      "#{CAPITALIZED_FIELD}: #{location}\r\n"
    end
    
    def decoded
      location 
    end

  end
end
