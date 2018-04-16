# encoding: utf-8
# frozen_string_literal: true
require 'mail/parsers/content_disposition_parser'

module Mail
  class ContentDispositionElement # :nodoc:
    attr_reader :disposition_type, :parameters

    def initialize(string)
      content_disposition = Mail::Parsers::ContentDispositionParser.parse(cleaned(string))
      @disposition_type = content_disposition.disposition_type
      @parameters = content_disposition.parameters
    end

    private
    def cleaned(string)
      string =~ /(.+);\s*$/ ? $1 : string
    end
  end
end
