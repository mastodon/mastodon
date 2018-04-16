# encoding: utf-8
# frozen_string_literal: true
#
# = Date Field
#
# The Date field inherits from StructuredField and handles the Date: header
# field in the email.
#
# Sending date to a mail message will instantiate a Mail::Field object that
# has a DateField as its field type.  This includes all Mail::CommonAddress
# module instance methods.
#
# There must be excatly one Date field in an RFC2822 email.
#
# == Examples:
#
#  mail = Mail.new
#  mail.date = 'Mon, 24 Nov 1997 14:22:01 -0800'
#  mail.date       #=> #<DateTime: 211747170121/86400,-1/3,2299161>
#  mail.date.to_s  #=> 'Mon, 24 Nov 1997 14:22:01 -0800'
#  mail[:date]     #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::DateField:0x180e1c4
#  mail['date']    #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::DateField:0x180e1c4
#  mail['Date']    #=> '#<Mail::Field:0x180e5e8 @field=#<Mail::DateField:0x180e1c4
#
require 'mail/fields/common/common_date'

module Mail
  class DateField < StructuredField

    include Mail::CommonDate

    FIELD_NAME = 'date'
    CAPITALIZED_FIELD = "Date"

    def initialize(value = nil, charset = 'utf-8')
      self.charset = charset
      if Utilities.blank?(value)
        value = ::DateTime.now.strftime('%a, %d %b %Y %H:%M:%S %z')
      else
        value = value.to_s.gsub(/\(.*?\)/, '').squeeze(' ')
        value = ::DateTime.parse(value).strftime('%a, %d %b %Y %H:%M:%S %z')
      end
      super(CAPITALIZED_FIELD, value, charset)
    rescue ArgumentError => e
      raise e unless "invalid date"==e.message
    end

    def encoded
      do_encode(CAPITALIZED_FIELD)
    end

    def decoded
      do_decode
    end

  end
end
