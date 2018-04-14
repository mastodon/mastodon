# encoding: utf-8
# frozen_string_literal: true
# 
# = Resent-Cc Field
# 
# The Resent-Cc field inherits resent-cc StructuredField and handles the Resent-Cc: header
# field in the email.
# 
# Sending resent_cc to a mail message will instantiate a Mail::Field object that
# has a ResentCcField as its field type.  This includes all Mail::CommonAddress
# module instance metods.
# 
# Only one Resent-Cc field can appear in a header, though it can have multiple
# addresses and groups of addresses.
# 
# == Examples:
# 
#  mail = Mail.new
#  mail.resent_cc = 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail.resent_cc    #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail[:resent_cc]  #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ResentCcField:0x180e1c4
#  mail['resent-cc'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ResentCcField:0x180e1c4
#  mail['Resent-Cc'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ResentCcField:0x180e1c4
# 
#  mail[:resent_cc].encoded   #=> 'Resent-Cc: Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net\r\n'
#  mail[:resent_cc].decoded   #=> 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail[:resent_cc].addresses #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail[:resent_cc].formatted #=> ['Mikel Lindsaar <mikel@test.lindsaar.net>', 'ada@test.lindsaar.net']
# 
require 'mail/fields/common/common_address'

module Mail
  class ResentCcField < StructuredField
    
    include Mail::CommonAddress
    
    FIELD_NAME = 'resent-cc'
    CAPITALIZED_FIELD = 'Resent-Cc'
    
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
