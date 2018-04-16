# encoding: utf-8
# frozen_string_literal: true
# 
# = References Field
# 
# The References field inherits references StructuredField and handles the References: header
# field in the email.
# 
# Sending references to a mail message will instantiate a Mail::Field object that
# has a ReferencesField as its field type.  This includes all Mail::CommonAddress
# module instance metods.
# 
# Note that, the #message_ids method will return an array of message IDs without the
# enclosing angle brackets which per RFC are not syntactically part of the message id.
# 
# Only one References field can appear in a header, though it can have multiple
# Message IDs.
# 
# == Examples:
# 
#  mail = Mail.new
#  mail.references = '<F6E2D0B4-CC35-4A91-BA4C-C7C712B10C13@test.me.dom>'
#  mail.references    #=> '<F6E2D0B4-CC35-4A91-BA4C-C7C712B10C13@test.me.dom>'
#  mail[:references]  #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ReferencesField:0x180e1c4
#  mail['references'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ReferencesField:0x180e1c4
#  mail['References'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::ReferencesField:0x180e1c4
# 
#  mail[:references].message_ids #=> ['F6E2D0B4-CC35-4A91-BA4C-C7C712B10C13@test.me.dom']
# 
require 'mail/fields/common/common_message_id'

module Mail
  class ReferencesField < StructuredField
    
    include CommonMessageId
    
    FIELD_NAME = 'references'
    CAPITALIZED_FIELD = 'References'
    
    def initialize(value = nil, charset = 'utf-8')
      self.charset = charset
      value = value.join("\r\n\s") if value.is_a?(Array)
      super(CAPITALIZED_FIELD, value, charset)
      self.parse
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
