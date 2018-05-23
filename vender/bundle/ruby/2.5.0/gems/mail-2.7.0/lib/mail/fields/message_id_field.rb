# encoding: utf-8
# frozen_string_literal: true
# 
# = Message-ID Field
# 
# The Message-ID field inherits from StructuredField and handles the 
# Message-ID: header field in the email.
# 
# Sending message_id to a mail message will instantiate a Mail::Field object that
# has a MessageIdField as its field type.  This includes all Mail::CommonMessageId
# module instance metods.
# 
# Only one MessageId field can appear in a header, and syntactically it can only have
# one Message ID.  The message_ids method call has been left in however as it will only
# return the one message id, ie, an array of length 1.
# 
# Note that, the #message_ids method will return an array of message IDs without the
# enclosing angle brackets which per RFC are not syntactically part of the message id.
# 
# == Examples:
# 
#  mail = Mail.new
#  mail.message_id = '<F6E2D0B4-CC35-4A91-BA4C-C7C712B10C13@test.me.dom>'
#  mail.message_id    #=> '<F6E2D0B4-CC35-4A91-BA4C-C7C712B10C13@test.me.dom>'
#  mail[:message_id]  #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::MessageIdField:0x180e1c4
#  mail['message_id'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::MessageIdField:0x180e1c4
#  mail['Message-ID'] #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::MessageIdField:0x180e1c4
# 
#  mail[:message_id].message_id   #=> 'F6E2D0B4-CC35-4A91-BA4C-C7C712B10C13@test.me.dom'
#  mail[:message_id].message_ids  #=> ['F6E2D0B4-CC35-4A91-BA4C-C7C712B10C13@test.me.dom']
# 
require 'mail/fields/common/common_message_id'

module Mail
  class MessageIdField < StructuredField
    
    include Mail::CommonMessageId
    
    FIELD_NAME = 'message-id'
    CAPITALIZED_FIELD = 'Message-ID'
    
    def initialize(value = nil, charset = 'utf-8')
      self.charset = charset
      @uniq = 1
      if Utilities.blank?(value)
        self.name = CAPITALIZED_FIELD
        self.value = generate_message_id
      else
        super(CAPITALIZED_FIELD, value, charset)
      end
      self.parse
      self

    end
    
    def name
      'Message-ID'
    end
    
    def message_ids
      [message_id]
    end
    
    def to_s
      "<#{message_id}>"
    end
    
    def encoded
      do_encode(CAPITALIZED_FIELD)
    end
    
    def decoded
      do_decode
    end
    
    private
    
    def generate_message_id
      "<#{Mail.random_tag}@#{::Socket.gethostname}.mail>"
    end
    
  end
end
