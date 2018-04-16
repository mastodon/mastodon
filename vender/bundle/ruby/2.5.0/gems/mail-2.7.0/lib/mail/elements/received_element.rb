# encoding: utf-8
# frozen_string_literal: true
require 'mail/parsers/received_parser'
require 'date'

module Mail
  class ReceivedElement
    include Mail::Utilities
    attr_reader :date_time, :info

    def initialize(string)
      received = Mail::Parsers::ReceivedParser.parse(string)
      @date_time = ::DateTime.parse("#{received.date} #{received.time}")
      @info = received.info
    end

    def to_s(*args)
      "#{info}; #{date_time.to_s(*args)}"
    end
  end
end
