# encoding: utf-8
# frozen_string_literal: true
# 
# = To Field
# 
# The To field inherits to StructuredField and handles the To: header
# field in the email.
# 
# Sending to to a mail message will instantiate a Mail::Field object that
# has a ToField as its field type.  This includes all Mail::CommonAddress
# module instance metods.
# 
# Only one To field can appear in a header, though it can have multiple
# addresses and groups of addresses.
# 
# == Examples:
# 
#  mail = Mail.new
#  mail.to = 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail.to    #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail[:to]  #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ToField:0x180e1c4
#  mail['to'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ToField:0x180e1c4
#  mail['To'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ToField:0x180e1c4
# 
#  mail[:to].encoded   #=> 'To: Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net\r\n'
#  mail[:to].decoded   #=> 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail[:to].addresses #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail[:to].formatted #=> ['Mikel Lindsaar <mikel@test.lindsaar.net>', 'ada@test.lindsaar.net']
# 
require 'mail/fields/common/common_address'

module Mail
  class ToField < StructuredField
    
    include Mail::CommonAddress
    
    FIELD_NAME = 'to'
    CAPITALIZED_FIELD = 'To'
    
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
