# encoding: utf-8
# frozen_string_literal: true
# 
# 4.4.3.  REPLY-TO / RESENT-REPLY-TO
# 
#    Note:  The "Return-Path" field is added by the mail  transport
#           service,  at the time of final deliver.  It is intended
#           to identify a path back to the orginator  of  the  mes-
#           sage.   The  "Reply-To"  field  is added by the message
#           originator and is intended to direct replies.
# 
# trace           =       [return]
#                         1*received
# 
# return          =       "Return-Path:" path CRLF
# 
# path            =       ([CFWS] "<" ([CFWS] / addr-spec) ">" [CFWS]) /
#                         obs-path
# 
# received        =       "Received:" name-val-list ";" date-time CRLF
# 
# name-val-list   =       [CFWS] [name-val-pair *(CFWS name-val-pair)]
# 
# name-val-pair   =       item-name CFWS item-value
# 
# item-name       =       ALPHA *(["-"] (ALPHA / DIGIT))
# 
# item-value      =       1*angle-addr / addr-spec /
#                          atom / domain / msg-id
# 
require 'mail/fields/common/common_address'

module Mail
  class ReturnPathField < StructuredField
    
    include Mail::CommonAddress
    
    FIELD_NAME = 'return-path'
    CAPITALIZED_FIELD = 'Return-Path'
    
    def initialize(value = nil, charset = 'utf-8')
      value = nil if value == '<>'
      self.charset = charset
      super(CAPITALIZED_FIELD, value, charset)
      self
    end
    
    def encoded
      "#{CAPITALIZED_FIELD}: <#{address}>\r\n"
    end
    
    def decoded
      do_decode
    end
    
    def address
      addresses.first
    end
    
    def default
      address
    end
    
  end
end
