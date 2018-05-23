# encoding: utf-8
# frozen_string_literal: true
require 'mail/fields/common/parameter_hash'

module Mail
  class ContentDispositionField < StructuredField

    FIELD_NAME = 'content-disposition'
    CAPITALIZED_FIELD = 'Content-Disposition'

    def initialize(value = nil, charset = 'utf-8')
      self.charset = charset
      value = ensure_filename_quoted(value)
      super(CAPITALIZED_FIELD, value, charset)
      self.parse
      self
    end

    def parse(val = value)
      unless Utilities.blank?(val)
        @element = Mail::ContentDispositionElement.new(val)
      end
    end

    def element
      @element ||= Mail::ContentDispositionElement.new(value)
    end

    def disposition_type
      element.disposition_type
    end

    def parameters
      @parameters = ParameterHash.new
      element.parameters.each { |p| @parameters.merge!(p) } unless element.parameters.nil?
      @parameters
    end

    def filename
      case
      when parameters['filename']
        @filename = parameters['filename']
      when parameters['name']
        @filename = parameters['name']
      else
        @filename = nil
      end
      @filename
    end

    # TODO: Fix this up
    def encoded
      if parameters.length > 0
        p = ";\r\n\s#{parameters.encoded}\r\n"
      else
        p = "\r\n"
      end
      "#{CAPITALIZED_FIELD}: #{disposition_type}" + p
    end

    def decoded
      if parameters.length > 0
        p = "; #{parameters.decoded}"
      else
        p = ""
      end
      "#{disposition_type}" + p
    end

  end
end
