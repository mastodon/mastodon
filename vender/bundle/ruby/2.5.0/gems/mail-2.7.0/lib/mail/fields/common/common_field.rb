# encoding: utf-8
# frozen_string_literal: true
module Mail
  module CommonField # :nodoc:
    include Mail::Constants

    def name=(value)
      @name = value
    end

    def name
      @name ||= nil
    end

    def value=(value)
      @length = nil
      @element = nil
      @value = value.is_a?(Array) ? value : value.to_s
    end

    def value
      @value
    end

    def to_s
      decoded.to_s
    end

    def default
      decoded
    end

    def field_length
      @length ||= "#{name}: #{encode(decoded)}".length
    end

    def responsible_for?( val )
      name.to_s.casecmp(val.to_s) == 0
    end

    private

    FILENAME_RE = /\b(filename|name)=([^;"\r\n]+\s[^;"\r\n]+)/
    def ensure_filename_quoted(value)
      if value.is_a?(String)
        value.sub FILENAME_RE, '\1="\2"'
      else
        value
      end
    end
  end
end
