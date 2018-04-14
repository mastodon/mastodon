# encoding: utf-8
# frozen_string_literal: true
# 
# = Resent-Sender Field
# 
# The Resent-Sender field inherits resent-sender StructuredField and handles the Resent-Sender: header
# field in the email.
# 
# Sending resent_sender to a mail message will instantiate a Mail::Field object that
# has a ResentSenderField as its field type.  This includes all Mail::CommonAddress
# module instance metods.
# 
# Only one Resent-Sender field can appear in a header, though it can have multiple
# addresses and groups of addresses.
# 
# == Examples:
# 
#  mail = Mail.new
#  mail.resent_sender = 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail.resent_sender    #=> ['mikel@test.lindsaar.net']
#  mail[:resent_sender]  #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ResentSenderField:0x180e1c4
#  mail['resent-sender'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ResentSenderField:0x180e1c4
#  mail['Resent-Sender'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ResentSenderField:0x180e1c4
# 
#  mail.resent_sender.to_s  #=> 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail.resent_sender.addresses #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail.resent_sender.formatted #=> ['Mikel Lindsaar <mikel@test.lindsaar.net>', 'ada@test.lindsaar.net']
# 
require 'mail/fields/common/common_address'

module Mail
  class ResentSenderField < StructuredField
    
    include Mail::CommonAddress
    
    FIELD_NAME = 'resent-sender'
    CAPITALIZED_FIELD = 'Resent-Sender'

    def initialize(value = nil, charset = 'utf-8')
      self.charset = charset
      super(CAPITALIZED_FIELD, value, charset)
      self
    end

    def addresses
      [address.address]
    end

    def address
      address_list.addresses.first
    end
    
    def encoded
      do_encode(CAPITALIZED_FIELD)
    end
    
    def decoded
      do_decode
    end
    
  end
end
