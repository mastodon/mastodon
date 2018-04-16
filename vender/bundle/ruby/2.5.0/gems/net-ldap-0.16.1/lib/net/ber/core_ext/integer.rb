# -*- ruby encoding: utf-8 -*-
##
# BER extensions to the Integer class, affecting Fixnum and Bignum objects.
module Net::BER::Extensions::Integer
  ##
  # Converts the Integer to BER format.
  def to_ber
    "\002#{to_ber_internal}"
  end

  ##
  # Converts the Integer to BER enumerated format.
  def to_ber_enumerated
    "\012#{to_ber_internal}"
  end

  ##
  # Converts the Integer to BER length encoding format.
  def to_ber_length_encoding
    if self <= 127
      [self].pack('C')
    else
      i = [self].pack('N').sub(/^[\0]+/, "")
      [0x80 + i.length].pack('C') + i
    end
  end

  ##
  # Generate a BER-encoding for an application-defined INTEGER. Examples of
  # such integers are SNMP's Counter, Gauge, and TimeTick types.
  def to_ber_application(tag)
    [0x40 + tag].pack("C") + to_ber_internal
  end

  ##
  # Used to BER-encode the length and content bytes of an Integer. Callers
  # must prepend the tag byte for the contained value.
  def to_ber_internal
    # Compute the byte length, accounting for negative values requiring two's
    # complement.
    size  = 1
    size += 1 until (((self < 0) ? ~self : self) >> (size * 8)).zero?

    # Padding for positive, negative values. See section 8.5 of ITU-T X.690:
    # http://www.itu.int/ITU-T/studygroups/com17/languages/X.690-0207.pdf

    # For positive integers, if most significant bit in an octet is set to one,
    # pad the result (otherwise it's decoded as a negative value).
    if self > 0 && (self & (0x80 << (size - 1) * 8)) > 0
      size += 1
    end

    # And for negative integers, pad if the most significant bit in the octet
    # is not set to one (othwerise, it's decoded as positive value).
    if self < 0 && (self & (0x80 << (size - 1) * 8)) == 0
      size += 1
    end

    # Store the size of the Integer in the result
    result = [size]

    # Appends bytes to result, starting with higher orders first. Extraction
    # of bytes is done by right shifting the original Integer by an amount
    # and then masking that with 0xff.
    while size > 0
      # right shift size - 1 bytes, mask with 0xff
      result << ((self >> ((size - 1) * 8)) & 0xff)
      size -= 1
    end

    result.pack('C*')
  end
  private :to_ber_internal
end
