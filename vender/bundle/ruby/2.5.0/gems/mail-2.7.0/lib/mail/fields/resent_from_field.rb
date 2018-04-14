# encoding: utf-8
# frozen_string_literal: true
# 
# = Resent-From Field
# 
# The Resent-From field inherits resent-from StructuredField and handles the Resent-From: header
# field in the email.
# 
# Sending resent_from to a mail message will instantiate a Mail::Field object that
# has a ResentFromField as its field type.  This includes all Mail::CommonAddress
# module instance metods.
# 
# Only one Resent-From field can appear in a header, though it can have multiple
# addresses and groups of addresses.
# 
# == Examples:
#
#  mail = Mail.new
#  mail.resent_from = 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail.resent_from    #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail[:resent_from]  #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ResentFromField:0x180e1c4
#  mail['resent-from'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ResentFromField:0x180e1c4
#  mail['Resent-From'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ResentFromField:0x180e1c4
# 
#  mail[:resent_from].encoded   #=> 'Resent-From: Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net\r\n'
#  mail[:resent_from].decoded   #=> 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail[:resent_from].addresses #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail[:resent_from].formatted #=> ['Mikel Lindsaar <mikel@test.lindsaar.net>', 'ada@test.lindsaar.net']
# 
require 'mail/fields/common/common_address'

module Mail
  class ResentFromField < StructuredField
    
    include Mail::CommonAddress
    
    FIELD_NAME = 'resent-from'
    CAPITALIZED_FIELD = 'Resent-From'
    
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
