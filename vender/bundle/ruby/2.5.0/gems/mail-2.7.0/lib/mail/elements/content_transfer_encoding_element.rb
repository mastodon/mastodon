# encoding: utf-8
# frozen_string_literal: true
require 'mail/parsers/content_transfer_encoding_parser'

module Mail
  class ContentTransferEncodingElement
    attr_reader :encoding

    def initialize(string)
      @encoding = Mail::Parsers::ContentTransferEncodingParser.parse(string).encoding
    end
  end
end
