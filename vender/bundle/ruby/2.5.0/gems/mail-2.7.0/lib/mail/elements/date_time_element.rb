# encoding: utf-8
# frozen_string_literal: true
require 'mail/parsers/date_time_parser'

module Mail
  class DateTimeElement # :nodoc:
    attr_reader :date_string, :time_string

    def initialize(string)
      date_time = Mail::Parsers::DateTimeParser.parse(string)
      @date_string = date_time.date_string
      @time_string = date_time.time_string
    end
  end
end
