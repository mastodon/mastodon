# encoding: utf-8
# frozen_string_literal: true
require 'net/imap' # for decode_utf7

module Mail
  class Ruby18
    require 'base64'
    require 'iconv'

    # Escapes any parenthesis in a string that are unescaped. This can't
    # use the Ruby 1.9.1 regexp feature of negative look behind so we have
    # to do two replacement, first unescape everything, then re-escape it
    def Ruby18.escape_paren( str )
      re = /\\\)/
      str = str.gsub(re) { |s| ')'}
      re = /\\\(/
      str = str.gsub(re) { |s| '('}
      re = /([\(\)])/          # Only match unescaped parens
      str.gsub(re) { |s| '\\' + s }
    end

    def Ruby18.paren( str )
      str = $1 if str =~ /^\((.*)?\)$/
      str = escape_paren( str )
      '(' + str + ')'
    end

    def Ruby18.escape_bracket( str )
      re = /\\\>/
      str = str.gsub(re) { |s| '>'}
      re = /\\\</
      str = str.gsub(re) { |s| '<'}
      re = /([\<\>])/          # Only match unescaped parens
      str.gsub(re) { |s| '\\' + s }
    end

    def Ruby18.bracket( str )
      str = $1 if str =~ /^\<(.*)?\>$/
      str = escape_bracket( str )
      '<' + str + '>'
    end

    def Ruby18.decode_base64(str)
      Base64.decode64(str) if str
    end

    def Ruby18.encode_base64(str)
      Base64.encode64(str)
    end

    def Ruby18.has_constant?(klass, string)
      klass.constants.include?( string )
    end

    def Ruby18.get_constant(klass, string)
      klass.const_get( string )
    end

    def Ruby18.transcode_charset(str, from_encoding, to_encoding = 'UTF-8')
      case from_encoding
      when /utf-?7/i
        decode_utf7(str)
      else
        retried = false
        begin
          Iconv.conv("#{normalize_iconv_charset_encoding(to_encoding)}//IGNORE", normalize_iconv_charset_encoding(from_encoding), str)
        rescue Iconv::InvalidEncoding
          if retried
            raise
          else
            from_encoding = 'ASCII'
            retried = true
            retry
          end
        end
      end
    end

    def Ruby18.decode_utf7(str)
      Net::IMAP.decode_utf7(str)
    end

    def Ruby18.b_value_encode(str, encoding)
      # Ruby 1.8 requires an encoding to work
      raise ArgumentError, "Must supply an encoding" if encoding.nil?
      encoding = encoding.to_s.upcase.gsub('_', '-')
      [Encodings::Base64.encode(str), normalize_iconv_charset_encoding(encoding)]
    end

    def Ruby18.b_value_decode(str)
      match = str.match(/\=\?(.+)?\?[Bb]\?(.*)\?\=/m)
      if match
        encoding = match[1]
        str = Ruby18.decode_base64(match[2])
        str = transcode_charset(str, encoding)
      end
      str
    end

    def Ruby18.q_value_encode(str, encoding)
      # Ruby 1.8 requires an encoding to work
      raise ArgumentError, "Must supply an encoding" if encoding.nil?
      encoding = encoding.to_s.upcase.gsub('_', '-')
      [Encodings::QuotedPrintable.encode(str), encoding]
    end

    def Ruby18.q_value_decode(str)
      match = str.match(/\=\?(.+)?\?[Qq]\?(.*)\?\=/m)
      if match
        encoding = match[1]
        string = match[2].gsub(/_/, '=20')
        # Remove trailing = if it exists in a Q encoding
        string = string.sub(/\=$/, '')
        str = Encodings::QuotedPrintable.decode(string)
        str = transcode_charset(str, encoding)
      end
      str
    end

    def Ruby18.param_decode(str, encoding)
      str = URI.unescape(str)
      if encoding
        transcode_charset(str, encoding)
      else
        str
      end
    end

    def Ruby18.param_encode(str)
      encoding = $KCODE.to_s.downcase
      language = Configuration.instance.param_encode_language
      "#{encoding}'#{language}'#{URI.escape(str)}"
    end

    def Ruby18.string_byteslice(str, *args)
      str.slice(*args)
    end

    private

    def Ruby18.normalize_iconv_charset_encoding(encoding)
      case encoding.upcase
      when 'UTF8', 'UTF_8'
        'UTF-8'
      when 'UTF16', 'UTF-16'
        'UTF-16BE'
      when 'UTF32', 'UTF-32'
        'UTF-32BE'
      when 'KS_C_5601-1987'
        'CP949'
      else
        # Fall back to ASCII for charsets that Iconv doesn't recognize
        begin
          Iconv.new('UTF-8', encoding)
        rescue Iconv::InvalidEncoding => e
          'ASCII'
        else
          encoding
        end
      end
    end
  end
end
