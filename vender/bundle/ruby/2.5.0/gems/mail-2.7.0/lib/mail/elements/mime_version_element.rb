# encoding: utf-8
# frozen_string_literal: true
require 'mail/parsers/mime_version_parser'

module Mail
  class MimeVersionElement
    attr_reader :major, :minor

    def initialize(string)
      mime_version = Mail::Parsers::MimeVersionParser.parse(string)
      @major = mime_version.major
      @minor = mime_version.minor
    end
  end
end
