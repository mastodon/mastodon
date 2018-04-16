# encoding: utf-8
# frozen_string_literal: true
require 'mail/multibyte/chars'

module Mail #:nodoc:
  module Multibyte
    # Raised when a problem with the encoding was found.
    class EncodingError < StandardError; end

    class << self
      # The proxy class returned when calling mb_chars. You can use this accessor to configure your own proxy
      # class so you can support other encodings. See the Mail::Multibyte::Chars implementation for
      # an example how to do this.
      #
      # Example:
      #   Mail::Multibyte.proxy_class = CharsForUTF32
      attr_accessor :proxy_class
    end

    self.proxy_class = Mail::Multibyte::Chars

    if RUBY_VERSION >= "1.9"
      # == Multibyte proxy
      #
      # +mb_chars+ is a multibyte safe proxy for string methods.
      #
      # In Ruby 1.8 and older it creates and returns an instance of the Mail::Multibyte::Chars class which
      # encapsulates the original string. A Unicode safe version of all the String methods are defined on this proxy
      # class. If the proxy class doesn't respond to a certain method, it's forwarded to the encapsuled string.
      #
      #   name = 'Claus Müller'
      #   name.reverse # => "rell??M sualC"
      #   name.length  # => 13
      #
      #   name.mb_chars.reverse.to_s # => "rellüM sualC"
      #   name.mb_chars.length       # => 12
      #
      # In Ruby 1.9 and newer +mb_chars+ returns +self+ because String is (mostly) encoding aware. This means that
      # it becomes easy to run one version of your code on multiple Ruby versions.
      #
      # == Method chaining
      #
      # All the methods on the Chars proxy which normally return a string will return a Chars object. This allows
      # method chaining on the result of any of these methods.
      #
      #   name.mb_chars.reverse.length # => 12
      #
      # == Interoperability and configuration
      #
      # The Chars object tries to be as interchangeable with String objects as possible: sorting and comparing between
      # String and Char work like expected. The bang! methods change the internal string representation in the Chars
      # object. Interoperability problems can be resolved easily with a +to_s+ call.
      #
      # For more information about the methods defined on the Chars proxy see Mail::Multibyte::Chars. For
      # information about how to change the default Multibyte behaviour see Mail::Multibyte.
      def self.mb_chars(str)
        if proxy_class.consumes?(str)
          proxy_class.new(str)
        else
          str
        end
      end
    else
      def self.mb_chars(str)
        if proxy_class.wants?(str)
          proxy_class.new(str)
        else
          str
        end
      end
    end

    # Regular expressions that describe valid byte sequences for a character
    VALID_CHARACTER = {
      # Borrowed from the Kconv library by Shinji KONO - (also as seen on the W3C site)
      'UTF-8' => /\A(?:
                  [\x00-\x7f]                                         |
                  [\xc2-\xdf] [\x80-\xbf]                             |
                  \xe0        [\xa0-\xbf] [\x80-\xbf]                 |
                  [\xe1-\xef] [\x80-\xbf] [\x80-\xbf]                 |
                  \xf0        [\x90-\xbf] [\x80-\xbf] [\x80-\xbf]     |
                  [\xf1-\xf3] [\x80-\xbf] [\x80-\xbf] [\x80-\xbf]     |
                  \xf4        [\x80-\x8f] [\x80-\xbf] [\x80-\xbf])\z /xn,
      # Quick check for valid Shift-JIS characters, disregards the odd-even pairing
      'Shift_JIS' => /\A(?:
                  [\x00-\x7e\xa1-\xdf]                                     |
                  [\x81-\x9f\xe0-\xef] [\x40-\x7e\x80-\x9e\x9f-\xfc])\z /xn
    }
  end
end

require 'mail/multibyte/utils'
