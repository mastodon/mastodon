# encoding: utf-8
# frozen_string_literal: true
require 'mail/fields/common/parameter_hash'

module Mail
  class ContentTypeField < StructuredField

    FIELD_NAME = 'content-type'
    CAPITALIZED_FIELD = 'Content-Type'

    def initialize(value = nil, charset = 'utf-8')
      self.charset = charset
      if value.class == Array
        @main_type = value[0]
        @sub_type = value[1]
        @parameters = ParameterHash.new.merge!(value.last)
      else
        @main_type = nil
        @sub_type = nil
        @parameters = nil
        value = value.to_s
      end
      value = ensure_filename_quoted(value)
      super(CAPITALIZED_FIELD, value, charset)
      self.parse
      self
    end

    def parse(val = value)
      unless Utilities.blank?(val)
        self.value = val
        @element = nil
        element
      end
    end

    def element
      begin
        @element ||= Mail::ContentTypeElement.new(value)
      rescue
        attempt_to_clean
      end
    end

    def attempt_to_clean
      # Sanitize the value, handle special cases
      @element ||= Mail::ContentTypeElement.new(sanatize(value))
    rescue
      # All else fails, just get the MIME media type
      @element ||= Mail::ContentTypeElement.new(get_mime_type(value))
    end

    def main_type
      @main_type ||= element.main_type
    end

    def sub_type
      @sub_type ||= element.sub_type
    end

    def string
      "#{main_type}/#{sub_type}"
    end

    def default
      decoded
    end

    alias :content_type :string

    def parameters
      unless @parameters
        @parameters = ParameterHash.new
        element.parameters.each { |p| @parameters.merge!(p) }
      end
      @parameters
    end

    def ContentTypeField.with_boundary(type)
      new("#{type}; boundary=#{generate_boundary}")
    end

    def ContentTypeField.generate_boundary
      "--==_mimepart_#{Mail.random_tag}"
    end

    def value
      if @value.class == Array
        "#{@main_type}/#{@sub_type}; #{stringify(parameters)}"
      else
        @value
      end
    end

    def stringify(params)
      params.map { |k,v| "#{k}=#{Encodings.param_encode(v)}" }.join("; ")
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
        p = ";\r\n\s#{parameters.encoded}"
      else
        p = ""
      end
      "#{CAPITALIZED_FIELD}: #{content_type}#{p}\r\n"
    end

    def decoded
      if parameters.length > 0
        p = "; #{parameters.decoded}"
      else
        p = ""
      end
      "#{content_type}" + p
    end

    private

    def method_missing(name, *args, &block)
      if name.to_s =~ /(\w+)=/
        self.parameters[$1] = args.first
        @value = "#{content_type}; #{stringify(parameters)}"
      else
        super
      end
    end

    # Various special cases from random emails found that I am not going to change
    # the parser for
    def sanatize( val )

      # TODO: check if there are cases where whitespace is not a separator
      val = val.
        gsub(/\s*=\s*/,'='). # remove whitespaces around equal sign
        gsub(/[; ]+/, '; '). #use '; ' as a separator (or EOL)
        gsub(/;\s*$/,'') #remove trailing to keep examples below

      if val =~ /(boundary=(\S*))/i
        val = "#{$`.downcase}boundary=#{$2}#{$'.downcase}"
      else
        val.downcase!
      end

      case
      when val.chomp =~ /^\s*([\w\-]+)\/([\w\-]+)\s*;\s?(ISO[\w\-]+)$/i
        # Microsoft helper:
        # Handles 'type/subtype;ISO-8559-1'
        "#{$1}/#{$2}; charset=#{quote_atom($3)}"
      when val.chomp =~ /^text;?$/i
        # Handles 'text;' and 'text'
        "text/plain;"
      when val.chomp =~ /^(\w+);\s(.*)$/i
        # Handles 'text; <parameters>'
        "text/plain; #{$2}"
      when val =~ /([\w\-]+\/[\w\-]+);\scharset="charset="(\w+)""/i
        # Handles text/html; charset="charset="GB2312""
        "#{$1}; charset=#{quote_atom($2)}"
      when val =~ /([\w\-]+\/[\w\-]+);\s+(.*)/i
        type = $1
        # Handles misquoted param values
        # e.g: application/octet-stream; name=archiveshelp1[1].htm
        # and: audio/x-midi;\r\n\sname=Part .exe
        params = $2.to_s.split(/\s+/)
        params = params.map { |i| i.to_s.chomp.strip }
        params = params.map { |i| i.split(/\s*\=\s*/) }
        params = params.map { |i| "#{i[0]}=#{dquote(i[1].to_s.gsub(/;$/,""))}" }.join('; ')
        "#{type}; #{params}"
      when val =~ /^\s*$/
        'text/plain'
      else
        val
      end
    end

    def get_mime_type( val )
      case
      when val =~ /^([\w\-]+)\/([\w\-]+);.+$/i
        "#{$1}/#{$2}"
      else
        'text/plain'
      end
    end
  end
end
