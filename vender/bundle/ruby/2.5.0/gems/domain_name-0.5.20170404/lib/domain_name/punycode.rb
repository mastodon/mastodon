# -*- coding: utf-8 -*-
#--
# punycode.rb - PunyCode encoder for the Domain Name library
#
# Copyright (C) 2011-2017 Akinori MUSHA, All rights reserved.
#
# Ported from puny.c, a part of VeriSign XCode (encode/decode) IDN
# Library.
#
# Copyright (C) 2000-2002 Verisign Inc., All rights reserved.
#
# Redistribution and use in source and binary forms, with or
# without modification, are permitted provided that the following
# conditions are met:
#
#  1) Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#
#  2) Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
#
#  3) Neither the name of the VeriSign Inc. nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
# OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
# AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# This software is licensed under the BSD open source license. For more
# information visit www.opensource.org.
#
# Authors:
#  John Colosi (VeriSign)
#  Srikanth Veeramachaneni (VeriSign)
#  Nagesh Chigurupati (Verisign)
#  Praveen Srinivasan(Verisign)
#++

class DomainName
  module Punycode
    BASE = 36
    TMIN = 1
    TMAX = 26
    SKEW = 38
    DAMP = 700
    INITIAL_BIAS = 72
    INITIAL_N = 0x80
    DELIMITER = '-'.freeze

    MAXINT = (1 << 32) - 1

    LOBASE = BASE - TMIN
    CUTOFF = LOBASE * TMAX / 2

    RE_NONBASIC = /[^\x00-\x7f]/

    # Returns the numeric value of a basic code point (for use in
    # representing integers) in the range 0 to base-1, or nil if cp
    # is does not represent a value.
    DECODE_DIGIT = {}.tap { |map|
      # ASCII A..Z map to 0..25
      # ASCII a..z map to 0..25
      (0..25).each { |i| map[65 + i] = map[97 + i] = i }
      # ASCII 0..9 map to 26..35
      (26..35).each { |i| map[22 + i] = i }
    }

    # Returns the basic code point whose value (when used for
    # representing integers) is d, which must be in the range 0 to
    # BASE-1.  The lowercase form is used unless flag is true, in
    # which case the uppercase form is used.  The behavior is
    # undefined if flag is nonzero and digit d has no uppercase
    # form.
    ENCODE_DIGIT = proc { |d, flag|
      (d + 22 + (d < 26 ? 75 : 0) - (flag ? (1 << 5) : 0)).chr
      #  0..25 map to ASCII a..z or A..Z
      # 26..35 map to ASCII 0..9
    }

    DOT = '.'.freeze
    PREFIX = 'xn--'.freeze

    # Most errors we raise are basically kind of ArgumentError.
    class ArgumentError < ::ArgumentError; end
    class BufferOverflowError < ArgumentError; end

    class << self
      # Encode a +string+ in Punycode
      def encode(string)
        input = string.unpack('U*')
        output = ''

        # Initialize the state
        n = INITIAL_N
        delta = 0
        bias = INITIAL_BIAS

        # Handle the basic code points
        input.each { |cp| output << cp.chr if cp < 0x80 }

        h = b = output.length

        # h is the number of code points that have been handled, b is the
        # number of basic code points, and out is the number of characters
        # that have been output.

        output << DELIMITER if b > 0

        # Main encoding loop

        while h < input.length
          # All non-basic code points < n have been handled already.  Find
          # the next larger one

          m = MAXINT
          input.each { |cp|
            m = cp if (n...m) === cp
          }

          # Increase delta enough to advance the decoder's <n,i> state to
          # <m,0>, but guard against overflow

          delta += (m - n) * (h + 1)
          raise BufferOverflowError if delta > MAXINT
          n = m

          input.each { |cp|
            # AMC-ACE-Z can use this simplified version instead
            if cp < n
              delta += 1
              raise BufferOverflowError if delta > MAXINT
            elsif cp == n
              # Represent delta as a generalized variable-length integer
              q = delta
              k = BASE
              loop {
                t = k <= bias ? TMIN : k - bias >= TMAX ? TMAX : k - bias
                break if q < t
                q, r = (q - t).divmod(BASE - t)
                output << ENCODE_DIGIT[t + r, false]
                k += BASE
              }

              output << ENCODE_DIGIT[q, false]

              # Adapt the bias
              delta = h == b ? delta / DAMP : delta >> 1
              delta += delta / (h + 1)
              bias = 0
              while delta > CUTOFF
                delta /= LOBASE
                bias += BASE
              end
              bias += (LOBASE + 1) * delta / (delta + SKEW)

              delta = 0
              h += 1
            end
          }

          delta += 1
          n += 1
        end

        output
      end

      # Encode a hostname using IDN/Punycode algorithms
      def encode_hostname(hostname)
        hostname.match(RE_NONBASIC) or return hostname

        hostname.split(DOT).map { |name|
          if name.match(RE_NONBASIC)
            PREFIX + encode(name)
          else
            name
          end
        }.join(DOT)
      end

      # Decode a +string+ encoded in Punycode
      def decode(string)
        # Initialize the state
        n = INITIAL_N
        i = 0
        bias = INITIAL_BIAS

        if j = string.rindex(DELIMITER)
          b = string[0...j]

          b.match(RE_NONBASIC) and
            raise ArgumentError, "Illegal character is found in basic part: #{string.inspect}"

          # Handle the basic code points

          output = b.unpack('U*')
          u = string[(j + 1)..-1]
        else
          output = []
          u = string
        end

        # Main decoding loop: Start just after the last delimiter if any
        # basic code points were copied; start at the beginning
        # otherwise.

        input = u.unpack('C*')
        input_length = input.length
        h = 0
        out = output.length

        while h < input_length
          # Decode a generalized variable-length integer into delta,
          # which gets added to i.  The overflow checking is easier
          # if we increase i as we go, then subtract off its starting
          # value at the end to obtain delta.

          oldi = i
          w = 1
          k = BASE

          loop {
            digit = DECODE_DIGIT[input[h]] or
            raise ArgumentError, "Illegal character is found in non-basic part: #{string.inspect}"
            h += 1
            i += digit * w
            raise BufferOverflowError if i > MAXINT
            t = k <= bias ? TMIN : k - bias >= TMAX ? TMAX : k - bias
            break if digit < t
            w *= BASE - t
            raise BufferOverflowError if w > MAXINT
            k += BASE
            h < input_length or raise ArgumentError, "Malformed input given: #{string.inspect}"
          }

          # Adapt the bias
          delta = oldi == 0 ? i / DAMP : (i - oldi) >> 1
          delta += delta / (out + 1)
          bias = 0
          while delta > CUTOFF
            delta /= LOBASE
            bias += BASE
          end
          bias += (LOBASE + 1) * delta / (delta + SKEW)

          # i was supposed to wrap around from out+1 to 0, incrementing
          # n each time, so we'll fix that now:

          q, i = i.divmod(out + 1)
          n += q
          raise BufferOverflowError if n > MAXINT

          # Insert n at position i of the output:

          output[i, 0] = n

          out += 1
          i += 1
        end
        output.pack('U*')
      end

      # Decode a hostname using IDN/Punycode algorithms
      def decode_hostname(hostname)
        hostname.gsub(/(\A|#{Regexp.quote(DOT)})#{Regexp.quote(PREFIX)}([^#{Regexp.quote(DOT)}]*)/o) {
          $1 << decode($2)
        }
      end
    end
  end
end
