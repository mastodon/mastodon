# encoding: utf-8

begin
  require 'erubis/tiny'
rescue LoadError
  require 'erb'
end
require 'set'
require 'stringio'
require 'strscan'

module Hamlit
  # A module containing various useful functions.
  module HamlUtil
    extend self

    # Silence all output to STDERR within a block.
    #
    # @yield A block in which no output will be printed to STDERR
    def silence_warnings
      the_real_stderr, $stderr = $stderr, StringIO.new
      yield
    ensure
      $stderr = the_real_stderr
    end

    ## Rails XSS Safety

    # Whether or not ActionView's XSS protection is available and enabled,
    # as is the default for Rails 3.0+, and optional for version 2.3.5+.
    # Overridden in haml/template.rb if this is the case.
    #
    # @return [Boolean]
    def rails_xss_safe?
      false
    end

    # Returns the given text, marked as being HTML-safe.
    # With older versions of the Rails XSS-safety mechanism,
    # this destructively modifies the HTML-safety of `text`.
    #
    # It only works if you are using ActiveSupport or the parameter `text`
    # implements the #html_safe method.
    #
    # @param text [String, nil]
    # @return [String, nil] `text`, marked as HTML-safe
    def html_safe(text)
      return unless text
      text.html_safe
    end

    # Checks that the encoding of a string is valid
    # and cleans up potential encoding gotchas like the UTF-8 BOM.
    # If it's not, yields an error string describing the invalid character
    # and the line on which it occurs.
    #
    # @param str [String] The string of which to check the encoding
    # @yield [msg] A block in which an encoding error can be raised.
    #   Only yields if there is an encoding error
    # @yieldparam msg [String] The error message to be raised
    # @return [String] `str`, potentially with encoding gotchas like BOMs removed
    def check_encoding(str)
      if str.valid_encoding?
        # Get rid of the Unicode BOM if possible
        # Shortcut for UTF-8 which might be the majority case
        if str.encoding == Encoding::UTF_8
          return str.gsub(/\A\uFEFF/, '')
        elsif str.encoding.name =~ /^UTF-(16|32)(BE|LE)?$/
          return str.gsub(Regexp.new("\\A\uFEFF".encode(str.encoding)), '')
        else
          return str
        end
      end

      encoding = str.encoding
      newlines = Regexp.new("\r\n|\r|\n".encode(encoding).force_encoding(Encoding::ASCII_8BIT))
      str.force_encoding(Encoding::ASCII_8BIT).split(newlines).each_with_index do |line, i|
        begin
          line.encode(encoding)
        rescue Encoding::UndefinedConversionError => e
          yield <<MSG.rstrip, i + 1
Invalid #{encoding.name} character #{e.error_char.dump}
MSG
        end
      end
      return str
    end

    # Like {\#check\_encoding}, but also checks for a Ruby-style `-# coding:` comment
    # at the beginning of the template and uses that encoding if it exists.
    #
    # The Haml encoding rules are simple.
    # If a `-# coding:` comment exists,
    # we assume that that's the original encoding of the document.
    # Otherwise, we use whatever encoding Ruby has.
    #
    # Haml uses the same rules for parsing coding comments as Ruby.
    # This means that it can understand Emacs-style comments
    # (e.g. `-*- encoding: "utf-8" -*-`),
    # and also that it cannot understand non-ASCII-compatible encodings
    # such as `UTF-16` and `UTF-32`.
    #
    # @param str [String] The Haml template of which to check the encoding
    # @yield [msg] A block in which an encoding error can be raised.
    #   Only yields if there is an encoding error
    # @yieldparam msg [String] The error message to be raised
    # @return [String] The original string encoded properly
    # @raise [ArgumentError] if the document declares an unknown encoding
    def check_haml_encoding(str, &block)
      str = str.dup if str.frozen?

      bom, encoding = parse_haml_magic_comment(str)
      if encoding; str.force_encoding(encoding)
      elsif bom; str.force_encoding(Encoding::UTF_8)
      end

      return check_encoding(str, &block)
    end

    # Like `Object#inspect`, but preserves non-ASCII characters rather than escaping them.
    # This is necessary so that the precompiled Haml template can be `#encode`d into `@options[:encoding]`
    # before being evaluated.
    #
    # @param obj {Object}
    # @return {String}
    def inspect_obj(obj)
      case obj
      when String
        %Q!"#{obj.gsub(/[\x00-\x7F]+/) {|s| s.inspect[1...-1]}}"!
      when Symbol
        ":#{inspect_obj(obj.to_s)}"
      else
        obj.inspect
      end
    end

    # Scans through a string looking for the interoplation-opening `#{`
    # and, when it's found, yields the scanner to the calling code
    # so it can handle it properly.
    #
    # The scanner will have any backslashes immediately in front of the `#{`
    # as the second capture group (`scan[2]`),
    # and the text prior to that as the first (`scan[1]`).
    #
    # @yieldparam scan [StringScanner] The scanner scanning through the string
    # @return [String] The text remaining in the scanner after all `#{`s have been processed
    def handle_interpolation(str)
      scan = StringScanner.new(str)
      yield scan while scan.scan(/(.*?)(\\*)#([\{@$])/)
      scan.rest
    end

    # Moves a scanner through a balanced pair of characters.
    # For example:
    #
    #     Foo (Bar (Baz bang) bop) (Bang (bop bip))
    #     ^                       ^
    #     from                    to
    #
    # @param scanner [StringScanner] The string scanner to move
    # @param start [String] The character opening the balanced pair.
    # @param finish [String] The character closing the balanced pair.
    # @param count [Fixnum] The number of opening characters matched
    #   before calling this method
    # @return [(String, String)] The string matched within the balanced pair
    #   and the rest of the string.
    #   `["Foo (Bar (Baz bang) bop)", " (Bang (bop bip))"]` in the example above.
    def balance(scanner, start, finish, count = 0)
      str = ''
      scanner = StringScanner.new(scanner) unless scanner.is_a? StringScanner
      regexp = Regexp.new("(.*?)[\\#{start.chr}\\#{finish.chr}]", Regexp::MULTILINE)
      while scanner.scan(regexp)
        str << scanner.matched
        count += 1 if scanner.matched[-1] == start
        count -= 1 if scanner.matched[-1] == finish
        return [str.strip, scanner.rest] if count == 0
      end
    end

    # Formats a string for use in error messages about indentation.
    #
    # @param indentation [String] The string used for indentation
    # @return [String] The name of the indentation (e.g. `"12 spaces"`, `"1 tab"`)
    def human_indentation(indentation)
      if !indentation.include?(?\t)
        noun = 'space'
      elsif !indentation.include?(?\s)
        noun = 'tab'
      else
        return indentation.inspect
      end

      singular = indentation.length == 1
      "#{indentation.length} #{noun}#{'s' unless singular}"
    end

    def contains_interpolation?(str)
      /#[\{$@]/ === str
    end

    # Original Haml::Util.unescape_interpolation
    # ex) slow_unescape_interpolation('foo#{bar}baz"', escape_html: true)
    #   #=> "\"foo\#{::Hamlit::HamlHelpers.html_escape((bar))}baz\\\"\""
    def slow_unescape_interpolation(str, escape_html = nil)
      res = ''
      rest = ::Hamlit::HamlUtil.handle_interpolation str.dump do |scan|
        escapes = (scan[2].size - 1) / 2
        char = scan[3] # '{', '@' or '$'
        res << scan.matched[0...-3 - escapes]
        if escapes % 2 == 1
          res << "\##{char}"
        else
          interpolated = if char == '{'
            balance(scan, ?{, ?}, 1)[0][0...-1]
          else
            scan.scan(/\w+/)
          end
          content = eval('"' + interpolated + '"')
          content.prepend(char) if char == '@' || char == '$'
          content = "::Hamlit::HamlHelpers.html_escape((#{content}))" if escape_html

          res << "\#{#{content}}"
        end
      end
      res + rest
    end

    # Customized Haml::Util.unescape_interpolation to handle escape by Hamlit.
    # It wraps double quotes to given `str` with escaping `"`.
    #
    # ex) unescape_interpolation('foo#{bar}baz"') #=> "\"foo\#{bar}baz\\\"\""
    def unescape_interpolation(str)
      res = ''
      rest = ::Hamlit::HamlUtil.handle_interpolation str.dump do |scan|
        escapes = (scan[2].size - 1) / 2
        char = scan[3] # '{', '@' or '$'
        res << scan.matched[0...-3 - escapes]
        if escapes % 2 == 1
          res << "\##{char}"
        else
          interpolated = if char == '{'
            balance(scan, ?{, ?}, 1)[0][0...-1]
          else
            scan.scan(/\w+/)
          end
          content = eval('"' + interpolated + '"')
          content.prepend(char) if char == '@' || char == '$'

          res << "\#{#{content}}"
        end
      end
      res + rest
    end

    private

    # Parses a magic comment at the beginning of a Haml file.
    # The parsing rules are basically the same as Ruby's.
    #
    # @return [(Boolean, String or nil)]
    #   Whether the document begins with a UTF-8 BOM,
    #   and the declared encoding of the document (or nil if none is declared)
    def parse_haml_magic_comment(str)
      scanner = StringScanner.new(str.dup.force_encoding(Encoding::ASCII_8BIT))
      bom = scanner.scan(/\xEF\xBB\xBF/n)
      return bom unless scanner.scan(/-\s*#\s*/n)
      if coding = try_parse_haml_emacs_magic_comment(scanner)
        return bom, coding
      end

      return bom unless scanner.scan(/.*?coding[=:]\s*([\w-]+)/in)
      return bom, scanner[1]
    end

    def try_parse_haml_emacs_magic_comment(scanner)
      pos = scanner.pos
      return unless scanner.scan(/.*?-\*-\s*/n)
      # From Ruby's parse.y
      return unless scanner.scan(/([^\s'":;]+)\s*:\s*("(?:\\.|[^"])*"|[^"\s;]+?)[\s;]*-\*-/n)
      name, val = scanner[1], scanner[2]
      return unless name =~ /(en)?coding/in
      val = $1 if val =~ /^"(.*)"$/n
      return val
    ensure
      scanner.pos = pos
    end
  end
end
