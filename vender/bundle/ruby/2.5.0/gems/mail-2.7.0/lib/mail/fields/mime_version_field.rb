# encoding: utf-8
# frozen_string_literal: true
# 
# 
# 
module Mail
  class MimeVersionField < StructuredField
    
    FIELD_NAME = 'mime-version'
    CAPITALIZED_FIELD = 'Mime-Version'

    def initialize(value = nil, charset = 'utf-8')
      self.charset = charset
      if Utilities.blank?(value)
        value = '1.0'
      end
      super(CAPITALIZED_FIELD, value, charset)
      self.parse
      self

    end
    
    def parse(val = value)
      unless Utilities.blank?(val)
        @element = Mail::MimeVersionElement.new(val)
      end
    end
    
    def element
      @element ||= Mail::MimeVersionElement.new(value)
    end
    
    def version
      "#{element.major}.#{element.minor}"
    end

    def major
      element.major.to_i
    end

    def minor
      element.minor.to_i
    end
    
    def encoded
      "#{CAPITALIZED_FIELD}: #{version}\r\n"
    end
    
    def decoded
      version
    end
    
  end
end
