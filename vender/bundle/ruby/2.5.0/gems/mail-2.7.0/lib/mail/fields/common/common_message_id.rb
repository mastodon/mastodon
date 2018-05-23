# encoding: utf-8
# frozen_string_literal: true
module Mail
  module CommonMessageId # :nodoc:
    def element
      @element ||= Mail::MessageIdsElement.new(value) unless Utilities.blank?(value)
    end

    def parse(val = value)
      unless Utilities.blank?(val)
        @element = Mail::MessageIdsElement.new(val)
      else
        nil
      end
    end
    
    def message_id
      element.message_id if element
    end
    
    def message_ids
      element.message_ids if element
    end
    
    def default
      return nil unless message_ids
      if message_ids.length == 1
        message_ids[0]
      else
        message_ids
      end
    end

    private

    def do_encode(field_name)
      %Q{#{field_name}: #{formated_message_ids("\r\n ")}\r\n}
    end

    def do_decode
      formated_message_ids(' ')
    end

    def formated_message_ids(join)
      message_ids.map{ |m| "<#{m}>" }.join(join) if message_ids
    end

  end
end
