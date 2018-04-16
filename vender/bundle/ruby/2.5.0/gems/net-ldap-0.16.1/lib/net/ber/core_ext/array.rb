# -*- ruby encoding: utf-8 -*-
##
# BER extensions to the Array class.
module Net::BER::Extensions::Array
  ##
  # Converts an Array to a BER sequence. All values in the Array are
  # expected to be in BER format prior to calling this method.
  def to_ber(id = 0)
    # The universal sequence tag 0x30 is composed of the base tag value
    # (0x10) and the constructed flag (0x20).
    to_ber_seq_internal(0x30 + id)
  end
  alias_method :to_ber_sequence, :to_ber

  ##
  # Converts an Array to a BER set. All values in the Array are expected to
  # be in BER format prior to calling this method.
  def to_ber_set(id = 0)
    # The universal set tag 0x31 is composed of the base tag value (0x11)
    # and the constructed flag (0x20).
    to_ber_seq_internal(0x31 + id)
  end

  ##
  # Converts an Array to an application-specific sequence, assigned a tag
  # value that is meaningful to the particular protocol being used. All
  # values in the Array are expected to be in BER format pr prior to calling
  # this method.
  #--
  # Implementor's note 20100320(AZ): RFC 4511 (the LDAPv3 protocol) as well
  # as earlier RFCs 1777 and 2559 seem to indicate that LDAP only has
  # application constructed sequences (0x60). However, ldapsearch sends some
  # context-specific constructed sequences (0xA0); other clients may do the
  # same. This behaviour appears to violate the RFCs. In real-world
  # practice, we may need to change calls of #to_ber_appsequence to
  # #to_ber_contextspecific for full LDAP server compatibility.
  #
  # This note probably belongs elsewhere.
  #++
  def to_ber_appsequence(id = 0)
    # The application sequence tag always starts from the application flag
    # (0x40) and the constructed flag (0x20).
    to_ber_seq_internal(0x60 + id)
  end

  ##
  # Converts an Array to a context-specific sequence, assigned a tag value
  # that is meaningful to the particular context of the particular protocol
  # being used. All values in the Array are expected to be in BER format
  # prior to calling this method.
  def to_ber_contextspecific(id = 0)
    # The application sequence tag always starts from the context flag
    # (0x80) and the constructed flag (0x20).
    to_ber_seq_internal(0xa0 + id)
  end

  ##
  # The internal sequence packing routine. All values in the Array are
  # expected to be in BER format prior to calling this method.
  def to_ber_seq_internal(code)
    s = self.join
    [code].pack('C') + s.length.to_ber_length_encoding + s
  end
  private :to_ber_seq_internal

  ##
  # SNMP Object Identifiers (OID) are special arrays
  #--
  # 20100320 AZ: I do not think that this method should be in BER, since
  # this appears to be SNMP-specific. This should probably be subsumed by a
  # proper SNMP OID object.
  #++
  def to_ber_oid
    ary = self.dup
    first = ary.shift
    raise Net::BER::BerError, "Invalid OID" unless [0, 1, 2].include?(first)
    first = first * 40 + ary.shift
    ary.unshift first
    oid = ary.pack("w*")
    [6, oid.length].pack("CC") + oid
  end

  ##
  # Converts an array into a set of ber control codes
  # The expected format is [[control_oid, criticality, control_value(optional)]]
  #   [['1.2.840.113556.1.4.805',true]]
  #
  def to_ber_control
    #if our array does not contain at least one array then wrap it in an array before going forward
    ary = self[0].kind_of?(Array) ? self : [self]
    ary = ary.collect do |control_sequence|
      control_sequence.collect(&:to_ber).to_ber_sequence.reject_empty_ber_arrays
    end
    ary.to_ber_sequence.reject_empty_ber_arrays
  end
end
