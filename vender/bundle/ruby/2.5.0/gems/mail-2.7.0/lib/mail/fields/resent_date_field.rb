# encoding: utf-8
# frozen_string_literal: true
# 
# resent-date     =       "Resent-Date:" date-time CRLF
require 'mail/fields/common/common_date'

module Mail
  class ResentDateField < StructuredField
    
    include Mail::CommonDate
    
    FIELD_NAME = 'resent-date'
    CAPITALIZED_FIELD = 'Resent-Date'
    
    def initialize(value = nil, charset = 'utf-8')
      self.charset = charset
      if Utilities.blank?(value)
        value = ::DateTime.now.strftime('%a, %d %b %Y %H:%M:%S %z')
      else
        value = ::DateTime.parse(value.to_s).strftime('%a, %d %b %Y %H:%M:%S %z')
      end
      super(CAPITALIZED_FIELD, value, charset)
      self
    end
    
    def encoded
      do_encode(CAPITALIZED_FIELD)
    end
    
    def decoded
      do_decode
    end
    
  end
end
