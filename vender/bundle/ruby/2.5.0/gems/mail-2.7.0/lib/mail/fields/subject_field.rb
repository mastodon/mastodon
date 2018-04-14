# encoding: utf-8
# frozen_string_literal: true
# 
# subject         =       "Subject:" unstructured CRLF
module Mail
  class SubjectField < UnstructuredField
    
    FIELD_NAME = 'subject'
    CAPITALIZED_FIELD = "Subject"
    
    def initialize(value = nil, charset = 'utf-8')
      self.charset = charset
      super(CAPITALIZED_FIELD, value, charset)
    end
    
  end
end
