# encoding: utf-8
# frozen_string_literal: true
# 
# = Blind Carbon Copy Field
# 
# The Bcc field inherits from StructuredField and handles the Bcc: header
# field in the email.
# 
# Sending bcc to a mail message will instantiate a Mail::Field object that
# has a BccField as its field type.  This includes all Mail::CommonAddress
# module instance metods.
# 
# Only one Bcc field can appear in a header, though it can have multiple
# addresses and groups of addresses.
# 
# == Examples:
# 
#  mail = Mail.new
#  mail.bcc = 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail.bcc    #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail[:bcc]  #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::BccField:0x180e1c4
#  mail['bcc'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::BccField:0x180e1c4
#  mail['Bcc'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::BccField:0x180e1c4
# 
#  mail[:bcc].encoded   #=> ''      # Bcc field does not get output into an email
#  mail[:bcc].decoded   #=> 'Mikel Lindsaar <mikel@test.lindsaar.net>, ada@test.lindsaar.net'
#  mail[:bcc].addresses #=> ['mikel@test.lindsaar.net', 'ada@test.lindsaar.net']
#  mail[:bcc].formatted #=> ['Mikel Lindsaar <mikel@test.lindsaar.net>', 'ada@test.lindsaar.net']
# 
require 'mail/fields/common/common_address'

module Mail
  class BccField < StructuredField
    
    include Mail::CommonAddress
    
    FIELD_NAME = 'bcc'
    CAPITALIZED_FIELD = 'Bcc'
    
    def initialize(value = nil, charset = 'utf-8')
      @charset = charset
      super(CAPITALIZED_FIELD, value, charset)
      self
    end
    
    def include_in_headers=(include_in_headers)
      @include_in_headers = include_in_headers
    end

    def include_in_headers
      defined?(@include_in_headers) ? @include_in_headers : self.include_in_headers = false
    end

    # Bcc field should not be :encoded by default
    def encoded
      if include_in_headers
        do_encode(CAPITALIZED_FIELD)
      else
        ''
      end
    end
    
    def decoded
      do_decode
    end
    
  end
end
