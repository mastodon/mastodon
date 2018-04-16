# encoding: utf-8
# frozen_string_literal: true
# 
# = Resent-To Field
# 
# The Resent-To field inherits resent-to StructuredField and handles the Resent-To: header
# field in the email.
# 
# Sending resent_to to a mail message will instantiate a Mail::Field object that
# has a ResentToField as its field type.  This includes all Mail::CommonAddress
# module instance metods.
# 
# Only one Resent-To field can appear in a header, though it can have multiple
# addresses and groups of addresses.
# 
# == Examples:
# 
#  mail = Mail.new
#  mail.resent_to = 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail.resent_to    #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail[:resent_to]  #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ResentToField:0x180e1c4
#  mail['resent-to'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ResentToField:0x180e1c4
#  mail['Resent-To'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ResentToField:0x180e1c4
# 
#  mail[:resent_to].encoded   #=> 'Resent-To: Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net\r\n'
#  mail[:resent_to].decoded   #=> 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail[:resent_to].addresses #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail[:resent_to].formatted #=> ['Mikel Lindsaar <mikel@test.lindsaar.net>', 'ada@test.lindsaar.net']
# 
require 'mail/fields/common/common_address'

module Mail
  class ResentToField < StructuredField
    
    include Mail::CommonAddress
    
    FIELD_NAME = 'resent-to'
    CAPITALIZED_FIELD = 'Resent-To'
    
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
