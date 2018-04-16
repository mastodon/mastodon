# encoding: utf-8
# frozen_string_literal: true
require 'mail/parsers/content_location_parser'

module Mail
  class ContentLocationElement # :nodoc:
    attr_reader :location

    def initialize(string)
      @location = Mail::Parsers::ContentLocationParser.parse(string).location
    end

    def to_s(*args)
      location.to_s
    end
  end
end
