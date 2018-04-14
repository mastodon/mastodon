# encoding:utf-8
#--
# Copyright (C) Bob Aman
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#++


module Addressable
  module IDNA
    # This module is loosely based on idn_actionmailer by Mick Staugaard,
    # the unicode library by Yoshida Masato, and the punycode implementation
    # by Kazuhiro Nishiyama.  Most of the code was copied verbatim, but
    # some reformatting was done, and some translation from C was done.
    #
    # Without their code to work from as a base, we'd all still be relying
    # on the presence of libidn.  Which nobody ever seems to have installed.
    #
    # Original sources:
    # http://github.com/staugaard/idn_actionmailer
    # http://www.yoshidam.net/Ruby.html#unicode
    # http://rubyforge.org/frs/?group_id=2550


    UNICODE_TABLE = File.expand_path(
      File.join(File.dirname(__FILE__), '../../..', 'data/unicode.data')
    )

    ACE_PREFIX = "xn--"

    UTF8_REGEX = /\A(?:
      [\x09\x0A\x0D\x20-\x7E]               # ASCII
      | [\xC2-\xDF][\x80-\xBF]              # non-overlong 2-byte
      | \xE0[\xA0-\xBF][\x80-\xBF]          # excluding overlongs
      | [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}   # straight 3-byte
      | \xED[\x80-\x9F][\x80-\xBF]          # excluding surrogates
      | \xF0[\x90-\xBF][\x80-\xBF]{2}       # planes 1-3
      | [\xF1-\xF3][\x80-\xBF]{3}           # planes 4nil5
      | \xF4[\x80-\x8F][\x80-\xBF]{2}       # plane 16
      )*\z/mnx

    UTF8_REGEX_MULTIBYTE = /(?:
      [\xC2-\xDF][\x80-\xBF]                # non-overlong 2-byte
      | \xE0[\xA0-\xBF][\x80-\xBF]          # excluding overlongs
      | [\xE1-\xEC\xEE\xEF][\x80-\xBF]{2}   # straight 3-byte
      | \xED[\x80-\x9F][\x80-\xBF]          # excluding surrogates
      | \xF0[\x90-\xBF][\x80-\xBF]{2}       # planes 1-3
      | [\xF1-\xF3][\x80-\xBF]{3}           # planes 4nil5
      | \xF4[\x80-\x8F][\x80-\xBF]{2}       # plane 16
      )/mnx

    # :startdoc:

    # Converts from a Unicode internationalized domain name to an ASCII
    # domain name as described in RFC 3490.
    def self.to_ascii(input)
      input = input.to_s unless input.is_a?(String)
      input = input.dup
      if input.respond_to?(:force_encoding)
        input.force_encoding(Encoding::ASCII_8BIT)
      end
      if input =~ UTF8_REGEX && input =~ UTF8_REGEX_MULTIBYTE
        parts = unicode_downcase(input).split('.')
        parts.map! do |part|
          if part.respond_to?(:force_encoding)
            part.force_encoding(Encoding::ASCII_8BIT)
          end
          if part =~ UTF8_REGEX && part =~ UTF8_REGEX_MULTIBYTE
            ACE_PREFIX + punycode_encode(unicode_normalize_kc(part))
          else
            part
          end
        end
        parts.join('.')
      else
        input
      end
    end

    # Converts from an ASCII domain name to a Unicode internationalized
    # domain name as described in RFC 3490.
    def self.to_unicode(input)
      input = input.to_s unless input.is_a?(String)
      parts = input.split('.')
      parts.map! do |part|
        if part =~ /^#{ACE_PREFIX}(.+)/
          begin
            punycode_decode(part[/^#{ACE_PREFIX}(.+)/, 1])
          rescue Addressable::IDNA::PunycodeBadInput
            # toUnicode is explicitly defined as never-fails by the spec
            part
          end
        else
          part
        end
      end
      output = parts.join('.')
      if output.respond_to?(:force_encoding)
        output.force_encoding(Encoding::UTF_8)
      end
      output
    end

    # Unicode normalization form KC.
    def self.unicode_normalize_kc(input)
      input = input.to_s unless input.is_a?(String)
      unpacked = input.unpack("U*")
      unpacked =
        unicode_compose(unicode_sort_canonical(unicode_decompose(unpacked)))
      return unpacked.pack("U*")
    end

    ##
    # Unicode aware downcase method.
    #
    # @api private
    # @param [String] input
    #   The input string.
    # @return [String] The downcased result.
    def self.unicode_downcase(input)
      input = input.to_s unless input.is_a?(String)
      unpacked = input.unpack("U*")
      unpacked.map! { |codepoint| lookup_unicode_lowercase(codepoint) }
      return unpacked.pack("U*")
    end
    (class <<self; private :unicode_downcase; end)

    def self.unicode_compose(unpacked)
      unpacked_result = []
      length = unpacked.length

      return unpacked if length == 0

      starter = unpacked[0]
      starter_cc = lookup_unicode_combining_class(starter)
      starter_cc = 256 if starter_cc != 0
      for i in 1...length
        ch = unpacked[i]
        cc = lookup_unicode_combining_class(ch)

        if (starter_cc == 0 &&
            (composite = unicode_compose_pair(starter, ch)) != nil)
          starter = composite
          startercc = lookup_unicode_combining_class(composite)
        else
          unpacked_result << starter
          starter = ch
          startercc = cc
        end
      end
      unpacked_result << starter
      return unpacked_result
    end
    (class <<self; private :unicode_compose; end)

    def self.unicode_compose_pair(ch_one, ch_two)
      if ch_one >= HANGUL_LBASE && ch_one < HANGUL_LBASE + HANGUL_LCOUNT &&
          ch_two >= HANGUL_VBASE && ch_two < HANGUL_VBASE + HANGUL_VCOUNT
        # Hangul L + V
        return HANGUL_SBASE + (
          (ch_one - HANGUL_LBASE) * HANGUL_VCOUNT + (ch_two - HANGUL_VBASE)
        ) * HANGUL_TCOUNT
      elsif ch_one >= HANGUL_SBASE &&
          ch_one < HANGUL_SBASE + HANGUL_SCOUNT &&
          (ch_one - HANGUL_SBASE) % HANGUL_TCOUNT == 0 &&
          ch_two >= HANGUL_TBASE && ch_two < HANGUL_TBASE + HANGUL_TCOUNT
           # Hangul LV + T
        return ch_one + (ch_two - HANGUL_TBASE)
      end

      p = []
      ucs4_to_utf8 = lambda do |ch|
        if ch < 128
          p << ch
        elsif ch < 2048
          p << (ch >> 6 | 192)
          p << (ch & 63 | 128)
        elsif ch < 0x10000
          p << (ch >> 12 | 224)
          p << (ch >> 6 & 63 | 128)
          p << (ch & 63 | 128)
        elsif ch < 0x200000
          p << (ch >> 18 | 240)
          p << (ch >> 12 & 63 | 128)
          p << (ch >> 6 & 63 | 128)
          p << (ch & 63 | 128)
        elsif ch < 0x4000000
          p << (ch >> 24 | 248)
          p << (ch >> 18 & 63 | 128)
          p << (ch >> 12 & 63 | 128)
          p << (ch >> 6 & 63 | 128)
          p << (ch & 63 | 128)
        elsif ch < 0x80000000
          p << (ch >> 30 | 252)
          p << (ch >> 24 & 63 | 128)
          p << (ch >> 18 & 63 | 128)
          p << (ch >> 12 & 63 | 128)
          p << (ch >> 6 & 63 | 128)
          p << (ch & 63 | 128)
        end
      end

      ucs4_to_utf8.call(ch_one)
      ucs4_to_utf8.call(ch_two)

      return lookup_unicode_composition(p)
    end
    (class <<self; private :unicode_compose_pair; end)

    def self.unicode_sort_canonical(unpacked)
      unpacked = unpacked.dup
      i = 1
      length = unpacked.length

      return unpacked if length < 2

      while i < length
        last = unpacked[i-1]
        ch = unpacked[i]
        last_cc = lookup_unicode_combining_class(last)
        cc = lookup_unicode_combining_class(ch)
        if cc != 0 && last_cc != 0 && last_cc > cc
          unpacked[i] = last
          unpacked[i-1] = ch
          i -= 1 if i > 1
        else
          i += 1
        end
      end
      return unpacked
    end
    (class <<self; private :unicode_sort_canonical; end)

    def self.unicode_decompose(unpacked)
      unpacked_result = []
      for cp in unpacked
        if cp >= HANGUL_SBASE && cp < HANGUL_SBASE + HANGUL_SCOUNT
          l, v, t = unicode_decompose_hangul(cp)
          unpacked_result << l
          unpacked_result << v if v
          unpacked_result << t if t
        else
          dc = lookup_unicode_compatibility(cp)
          unless dc
            unpacked_result << cp
          else
            unpacked_result.concat(unicode_decompose(dc.unpack("U*")))
          end
        end
      end
      return unpacked_result
    end
    (class <<self; private :unicode_decompose; end)

    def self.unicode_decompose_hangul(codepoint)
      sindex = codepoint - HANGUL_SBASE;
      if sindex < 0 || sindex >= HANGUL_SCOUNT
        l = codepoint
        v = t = nil
        return l, v, t
      end
      l = HANGUL_LBASE + sindex / HANGUL_NCOUNT
      v = HANGUL_VBASE + (sindex % HANGUL_NCOUNT) / HANGUL_TCOUNT
      t = HANGUL_TBASE + sindex % HANGUL_TCOUNT
      if t == HANGUL_TBASE
        t = nil
      end
      return l, v, t
    end
    (class <<self; private :unicode_decompose_hangul; end)

    def self.lookup_unicode_combining_class(codepoint)
      codepoint_data = UNICODE_DATA[codepoint]
      (codepoint_data ?
        (codepoint_data[UNICODE_DATA_COMBINING_CLASS] || 0) :
        0)
    end
    (class <<self; private :lookup_unicode_combining_class; end)

    def self.lookup_unicode_compatibility(codepoint)
      codepoint_data = UNICODE_DATA[codepoint]
      (codepoint_data ?
        codepoint_data[UNICODE_DATA_COMPATIBILITY] : nil)
    end
    (class <<self; private :lookup_unicode_compatibility; end)

    def self.lookup_unicode_lowercase(codepoint)
      codepoint_data = UNICODE_DATA[codepoint]
      (codepoint_data ?
        (codepoint_data[UNICODE_DATA_LOWERCASE] || codepoint) :
        codepoint)
    end
    (class <<self; private :lookup_unicode_lowercase; end)

    def self.lookup_unicode_composition(unpacked)
      return COMPOSITION_TABLE[unpacked]
    end
    (class <<self; private :lookup_unicode_composition; end)

    HANGUL_SBASE =  0xac00
    HANGUL_LBASE =  0x1100
    HANGUL_LCOUNT = 19
    HANGUL_VBASE =  0x1161
    HANGUL_VCOUNT = 21
    HANGUL_TBASE =  0x11a7
    HANGUL_TCOUNT = 28
    HANGUL_NCOUNT = HANGUL_VCOUNT * HANGUL_TCOUNT # 588
    HANGUL_SCOUNT = HANGUL_LCOUNT * HANGUL_NCOUNT # 11172

    UNICODE_DATA_COMBINING_CLASS = 0
    UNICODE_DATA_EXCLUSION = 1
    UNICODE_DATA_CANONICAL = 2
    UNICODE_DATA_COMPATIBILITY = 3
    UNICODE_DATA_UPPERCASE = 4
    UNICODE_DATA_LOWERCASE = 5
    UNICODE_DATA_TITLECASE = 6

    begin
      if defined?(FakeFS)
        fakefs_state = FakeFS.activated?
        FakeFS.deactivate!
      end
      # This is a sparse Unicode table.  Codepoints without entries are
      # assumed to have the value: [0, 0, nil, nil, nil, nil, nil]
      UNICODE_DATA = File.open(UNICODE_TABLE, "rb") do |file|
        Marshal.load(file.read)
      end
    ensure
      if defined?(FakeFS)
        FakeFS.activate! if fakefs_state
      end
    end

    COMPOSITION_TABLE = {}
    for codepoint, data in UNICODE_DATA
      canonical = data[UNICODE_DATA_CANONICAL]
      exclusion = data[UNICODE_DATA_EXCLUSION]

      if canonical && exclusion == 0
        COMPOSITION_TABLE[canonical.unpack("C*")] = codepoint
      end
    end

    UNICODE_MAX_LENGTH = 256
    ACE_MAX_LENGTH = 256

    PUNYCODE_BASE = 36
    PUNYCODE_TMIN = 1
    PUNYCODE_TMAX = 26
    PUNYCODE_SKEW = 38
    PUNYCODE_DAMP = 700
    PUNYCODE_INITIAL_BIAS = 72
    PUNYCODE_INITIAL_N = 0x80
    PUNYCODE_DELIMITER = 0x2D

    PUNYCODE_MAXINT = 1 << 64

    PUNYCODE_PRINT_ASCII =
      "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" +
      "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" +
      " !\"\#$%&'()*+,-./" +
      "0123456789:;<=>?" +
      "@ABCDEFGHIJKLMNO" +
      "PQRSTUVWXYZ[\\]^_" +
      "`abcdefghijklmno" +
      "pqrstuvwxyz{|}~\n"

    # Input is invalid.
    class PunycodeBadInput < StandardError; end
    # Output would exceed the space provided.
    class PunycodeBigOutput < StandardError; end
    # Input needs wider integers to process.
    class PunycodeOverflow < StandardError; end

    def self.punycode_encode(unicode)
      unicode = unicode.to_s unless unicode.is_a?(String)
      input = unicode.unpack("U*")
      output = [0] * (ACE_MAX_LENGTH + 1)
      input_length = input.size
      output_length = [ACE_MAX_LENGTH]

      # Initialize the state
      n = PUNYCODE_INITIAL_N
      delta = out = 0
      max_out = output_length[0]
      bias = PUNYCODE_INITIAL_BIAS

      # Handle the basic code points:
      input_length.times do |j|
        if punycode_basic?(input[j])
          if max_out - out < 2
            raise PunycodeBigOutput,
              "Output would exceed the space provided."
          end
          output[out] = input[j]
          out += 1
        end
      end

      h = b = out

      # h is the number of code points that have been handled, b is the
      # number of basic code points, and out is the number of characters
      # that have been output.

      if b > 0
        output[out] = PUNYCODE_DELIMITER
        out += 1
      end

      # Main encoding loop:

      while h < input_length
        # All non-basic code points < n have been
        # handled already.  Find the next larger one:

        m = PUNYCODE_MAXINT
        input_length.times do |j|
          m = input[j] if (n...m) === input[j]
        end

        # Increase delta enough to advance the decoder's
        # <n,i> state to <m,0>, but guard against overflow:

        if m - n > (PUNYCODE_MAXINT - delta) / (h + 1)
          raise PunycodeOverflow, "Input needs wider integers to process."
        end
        delta += (m - n) * (h + 1)
        n = m

        input_length.times do |j|
          # Punycode does not need to check whether input[j] is basic:
          if input[j] < n
            delta += 1
            if delta == 0
              raise PunycodeOverflow,
                "Input needs wider integers to process."
            end
          end

          if input[j] == n
            # Represent delta as a generalized variable-length integer:

            q = delta; k = PUNYCODE_BASE
            while true
              if out >= max_out
                raise PunycodeBigOutput,
                  "Output would exceed the space provided."
              end
              t = (
                if k <= bias
                  PUNYCODE_TMIN
                elsif k >= bias + PUNYCODE_TMAX
                  PUNYCODE_TMAX
                else
                  k - bias
                end
              )
              break if q < t
              output[out] =
                punycode_encode_digit(t + (q - t) % (PUNYCODE_BASE - t))
              out += 1
              q = (q - t) / (PUNYCODE_BASE - t)
              k += PUNYCODE_BASE
            end

            output[out] = punycode_encode_digit(q)
            out += 1
            bias = punycode_adapt(delta, h + 1, h == b)
            delta = 0
            h += 1
          end
        end

        delta += 1
        n += 1
      end

      output_length[0] = out

      outlen = out
      outlen.times do |j|
        c = output[j]
        unless c >= 0 && c <= 127
          raise StandardError, "Invalid output char."
        end
        unless PUNYCODE_PRINT_ASCII[c]
          raise PunycodeBadInput, "Input is invalid."
        end
      end

      output[0..outlen].map { |x| x.chr }.join("").sub(/\0+\z/, "")
    end
    (class <<self; private :punycode_encode; end)

    def self.punycode_decode(punycode)
      input = []
      output = []

      if ACE_MAX_LENGTH * 2 < punycode.size
        raise PunycodeBigOutput, "Output would exceed the space provided."
      end
      punycode.each_byte do |c|
        unless c >= 0 && c <= 127
          raise PunycodeBadInput, "Input is invalid."
        end
        input.push(c)
      end

      input_length = input.length
      output_length = [UNICODE_MAX_LENGTH]

      # Initialize the state
      n = PUNYCODE_INITIAL_N

      out = i = 0
      max_out = output_length[0]
      bias = PUNYCODE_INITIAL_BIAS

      # Handle the basic code points:  Let b be the number of input code
      # points before the last delimiter, or 0 if there is none, then
      # copy the first b code points to the output.

      b = 0
      input_length.times do |j|
        b = j if punycode_delimiter?(input[j])
      end
      if b > max_out
        raise PunycodeBigOutput, "Output would exceed the space provided."
      end

      b.times do |j|
        unless punycode_basic?(input[j])
          raise PunycodeBadInput, "Input is invalid."
        end
        output[out] = input[j]
        out+=1
      end

      # Main decoding loop:  Start just after the last delimiter if any
      # basic code points were copied; start at the beginning otherwise.

      in_ = b > 0 ? b + 1 : 0
      while in_ < input_length

        # in_ is the index of the next character to be consumed, and
        # out is the number of code points in the output array.

        # Decode a generalized variable-length integer into delta,
        # which gets added to i.  The overflow checking is easier
        # if we increase i as we go, then subtract off its starting
        # value at the end to obtain delta.

        oldi = i; w = 1; k = PUNYCODE_BASE
        while true
          if in_ >= input_length
            raise PunycodeBadInput, "Input is invalid."
          end
          digit = punycode_decode_digit(input[in_])
          in_+=1
          if digit >= PUNYCODE_BASE
            raise PunycodeBadInput, "Input is invalid."
          end
          if digit > (PUNYCODE_MAXINT - i) / w
            raise PunycodeOverflow, "Input needs wider integers to process."
          end
          i += digit * w
          t = (
            if k <= bias
              PUNYCODE_TMIN
            elsif k >= bias + PUNYCODE_TMAX
              PUNYCODE_TMAX
            else
              k - bias
            end
          )
          break if digit < t
          if w > PUNYCODE_MAXINT / (PUNYCODE_BASE - t)
            raise PunycodeOverflow, "Input needs wider integers to process."
          end
          w *= PUNYCODE_BASE - t
          k += PUNYCODE_BASE
        end

        bias = punycode_adapt(i - oldi, out + 1, oldi == 0)

        # I was supposed to wrap around from out + 1 to 0,
        # incrementing n each time, so we'll fix that now:

        if i / (out + 1) > PUNYCODE_MAXINT - n
          raise PunycodeOverflow, "Input needs wider integers to process."
        end
        n += i / (out + 1)
        i %= out + 1

        # Insert n at position i of the output:

        # not needed for Punycode:
        # raise PUNYCODE_INVALID_INPUT if decode_digit(n) <= base
        if out >= max_out
          raise PunycodeBigOutput, "Output would exceed the space provided."
        end

        #memmove(output + i + 1, output + i, (out - i) * sizeof *output)
        output[i + 1, out - i] = output[i, out - i]
        output[i] = n
        i += 1

        out += 1
      end

      output_length[0] = out

      output.pack("U*")
    end
    (class <<self; private :punycode_decode; end)

    def self.punycode_basic?(codepoint)
      codepoint < 0x80
    end
    (class <<self; private :punycode_basic?; end)

    def self.punycode_delimiter?(codepoint)
      codepoint == PUNYCODE_DELIMITER
    end
    (class <<self; private :punycode_delimiter?; end)

    def self.punycode_encode_digit(d)
      d + 22 + 75 * ((d < 26) ? 1 : 0)
    end
    (class <<self; private :punycode_encode_digit; end)

    # Returns the numeric value of a basic codepoint
    # (for use in representing integers) in the range 0 to
    # base - 1, or PUNYCODE_BASE if codepoint does not represent a value.
    def self.punycode_decode_digit(codepoint)
      if codepoint - 48 < 10
        codepoint - 22
      elsif codepoint - 65 < 26
        codepoint - 65
      elsif codepoint - 97 < 26
        codepoint - 97
      else
        PUNYCODE_BASE
      end
    end
    (class <<self; private :punycode_decode_digit; end)

    # Bias adaptation method
    def self.punycode_adapt(delta, numpoints, firsttime)
      delta = firsttime ? delta / PUNYCODE_DAMP : delta >> 1
      # delta >> 1 is a faster way of doing delta / 2
      delta += delta / numpoints
      difference = PUNYCODE_BASE - PUNYCODE_TMIN

      k = 0
      while delta > (difference * PUNYCODE_TMAX) / 2
        delta /= difference
        k += PUNYCODE_BASE
      end

      k + (difference + 1) * delta / (delta + PUNYCODE_SKEW)
    end
    (class <<self; private :punycode_adapt; end)
  end
  # :startdoc:
end
