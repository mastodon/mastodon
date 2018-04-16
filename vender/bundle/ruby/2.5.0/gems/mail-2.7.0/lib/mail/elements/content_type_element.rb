# encoding: utf-8
# frozen_string_literal: true
require 'mail/parsers/content_type_parser'

module Mail
  class ContentTypeElement # :nodoc:
    attr_reader :main_type, :sub_type, :parameters

    def initialize(string)
      content_type = Mail::Parsers::ContentTypeParser.parse(cleaned(string))
      @main_type = content_type.main_type
      @sub_type = content_type.sub_type
      @parameters = content_type.parameters
    end

    private
    def cleaned(string)
      string =~ /(.+);\s*$/ ? $1 : string
    end
  end
end
