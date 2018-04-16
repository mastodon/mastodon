# encoding: utf-8
# frozen_string_literal: true
require 'mail/parsers/message_ids_parser'

module Mail
  class MessageIdsElement
    attr_reader :message_ids

    def initialize(string)
      @message_ids = Mail::Parsers::MessageIdsParser.parse(string).message_ids.map { |msg_id| clean_msg_id(msg_id) }
    end

    def message_id
      message_ids.first
    end

    private
    def clean_msg_id(val)
      val =~ /.*<(.*)>.*/ ? $1 : val
    end
  end
end
