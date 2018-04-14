# -*- ruby encoding: utf-8 -*-
require 'stringio'

# Implements Basic Encoding Rules parsing to be mixed into types as needed.
module Net::BER::BERParser
  primitive = {
    1 => :boolean,
    2 => :integer,
    4 => :string,
    5 => :null,
    6 => :oid,
    10 => :integer,
    13 => :string # (relative OID)
  }
  constructed = {
    16 => :array,
    17 => :array,
  }
  universal = { :primitive => primitive, :constructed => constructed }

  primitive = { 10 => :integer }
  context =  { :primitive => primitive }

  # The universal, built-in ASN.1 BER syntax.
  BuiltinSyntax = Net::BER.compile_syntax(:universal => universal,
                                          :context_specific => context)

  ##
  # This is an extract of our BER object parsing to simplify our
  # understanding of how we parse basic BER object types.
  def parse_ber_object(syntax, id, data)
    # Find the object type from either the provided syntax lookup table or
    # the built-in syntax lookup table.
    #
    # This exceptionally clever bit of code is verrrry slow.
    object_type = (syntax && syntax[id]) || BuiltinSyntax[id]

    # == is expensive so sort this so the common cases are at the top.
    if object_type == :string
      s = Net::BER::BerIdentifiedString.new(data || "")
      s.ber_identifier = id
      s
    elsif object_type == :integer
      neg = !(data.unpack("C").first & 0x80).zero?
      int = 0

      data.each_byte do |b|
        int = (int << 8) + (neg ? 255 - b : b)
      end

      if neg
        (int + 1) * -1
      else
        int
      end
    elsif object_type == :oid
      # See X.690 pgh 8.19 for an explanation of this algorithm.
      # This is potentially not good enough. We may need a
      # BerIdentifiedOid as a subclass of BerIdentifiedArray, to
      # get the ber identifier and also a to_s method that produces
      # the familiar dotted notation.
      oid = data.unpack("w*")
      f = oid.shift
      g = if f < 40
            [0, f]
          elsif f < 80
            [1, f - 40]
          else
            # f - 80 can easily be > 80. What a weird optimization.
            [2, f - 80]
          end
      oid.unshift g.last
      oid.unshift g.first
      # Net::BER::BerIdentifiedOid.new(oid)
      oid
    elsif object_type == :array
      seq = Net::BER::BerIdentifiedArray.new
      seq.ber_identifier = id
      sio = StringIO.new(data || "")
      # Interpret the subobject, but note how the loop is built:
      # nil ends the loop, but false (a valid BER value) does not!
      while (e = sio.read_ber(syntax)) != nil
        seq << e
      end
      seq
    elsif object_type == :boolean
      data != "\000"
    elsif object_type == :null
      n = Net::BER::BerIdentifiedNull.new
      n.ber_identifier = id
      n
    else
      raise Net::BER::BerError, "Unsupported object type: id=#{id}"
    end
  end
  private :parse_ber_object

  ##
  # This is an extract of how our BER object length parsing is done to
  # simplify the primary call. This is defined in X.690 section 8.1.3.
  #
  # The BER length will either be a single byte or up to 126 bytes in
  # length. There is a special case of a BER length indicating that the
  # content-length is undefined and will be identified by the presence of
  # two null values (0x00 0x00).
  #
  # <table>
  # <tr>
  # <th>Range</th>
  # <th>Length</th>
  # </tr>
  # <tr>
  # <th>0x00 -- 0x7f<br />0b00000000 -- 0b01111111</th>
  # <td>0 - 127 bytes</td>
  # </tr>
  # <tr>
  # <th>0x80<br />0b10000000</th>
  # <td>Indeterminate (end-of-content marker required)</td>
  # </tr>
  # <tr>
  # <th>0x81 -- 0xfe<br />0b10000001 -- 0b11111110</th>
  # <td>1 - 126 bytes of length as an integer value</td>
  # </tr>
  # <tr>
  # <th>0xff<br />0b11111111</th>
  # <td>Illegal (reserved for future expansion)</td>
  # </tr>
  # </table>
  #
  #--
  # This has been modified from the version that was previously inside
  # #read_ber to handle both the indeterminate terminator case and the
  # invalid BER length case. Because the "lengthlength" value was not used
  # inside of #read_ber, we no longer return it.
  def read_ber_length
    n = getbyte

    if n <= 0x7f
      n
    elsif n == 0x80
      -1
    elsif n == 0xff
      raise Net::BER::BerError, "Invalid BER length 0xFF detected."
    else
      v = 0
      read(n & 0x7f).each_byte do |b|
        v = (v << 8) + b
      end

      v
    end
  end
  private :read_ber_length

  ##
  # Reads a BER object from the including object. Requires that #getbyte is
  # implemented on the including object and that it returns a Fixnum value.
  # Also requires #read(bytes) to work.
  #
  # Yields the object type `id` and the data `content_length` if a block is
  # given. This is namely to support instrumentation.
  #
  # This does not work with non-blocking I/O.
  def read_ber(syntax = nil)
    # TODO: clean this up so it works properly with partial packets coming
    # from streams that don't block when we ask for more data (like
    # StringIOs). At it is, this can throw TypeErrors and other nasties.

    id = getbyte or return nil  # don't trash this value, we'll use it later
    content_length = read_ber_length

    yield id, content_length if block_given?

    if -1 == content_length
      raise Net::BER::BerError,
            "Indeterminite BER content length not implemented."
    end
    data = read(content_length)

    parse_ber_object(syntax, id, data)
  end
end
