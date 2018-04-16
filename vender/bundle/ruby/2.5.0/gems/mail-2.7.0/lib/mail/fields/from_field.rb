# encoding: utf-8
# frozen_string_literal: true
# 
# = From Field
# 
# The From field inherits from StructuredField and handles the From: header
# field in the email.
# 
# Sending from to a mail message will instantiate a Mail::Field object that
# has a FromField as its field type.  This includes all Mail::CommonAddress
# module instance metods.
# 
# Only one From field can appear in a header, though it can have multiple
# addresses and groups of addresses.
# 
# == Examples:
# 
#  mail = Mail.new
#  mail.from = 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail.from    #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail[:from]  #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::FromField:0x180e1c4
#  mail['from'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::FromField:0x180e1c4
#  mail['From'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::FromField:0x180e1c4
# 
#  mail[:from].encoded   #=> 'from: Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net\r\n'
#  mail[:from].decoded   #=> 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail[:from].addresses #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail[:from].formatted #=> ['Mikel Lindsaar <mikel@test.lindsaar.net>', 'ada@test.lindsaar.net']
# 
require 'mail/fields/common/common_address'

module Mail
  class FromField < StructuredField
    
    include Mail::CommonAddress
    
    FIELD_NAME = 'from'
    CAPITALIZED_FIELD = 'From'
    
    def initialize(value = nil, charset = 'utf-8')
      self.charset = charset
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
