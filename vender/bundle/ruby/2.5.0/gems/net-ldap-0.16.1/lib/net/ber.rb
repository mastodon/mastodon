# -*- ruby encoding: utf-8 -*-
require 'net/ldap/version'

module Net # :nodoc:
  ##
  # == Basic Encoding Rules (BER) Support Module
  #
  # Much of the text below is cribbed from Wikipedia:
  # http://en.wikipedia.org/wiki/Basic_Encoding_Rules
  #
  # The ITU Specification is also worthwhile reading:
  # http://www.itu.int/ITU-T/studygroups/com17/languages/X.690-0207.pdf
  #
  # The Basic Encoding Rules were the original rules laid out by the ASN.1
  # standard for encoding abstract information into a concrete data stream.
  # The rules, collectively referred to as a transfer syntax in ASN.1
  # parlance, specify the exact octet sequences which are used to encode a
  # given data item. The syntax defines such elements as: the
  # representations for basic data types, the structure of length
  # information, and the means for defining complex or compound types based
  # on more primitive types. The BER syntax, along with two subsets of BER
  # (the Canonical Encoding Rules and the Distinguished Encoding Rules), are
  # defined by the ITU-T's X.690 standards document, which is part of the
  # ASN.1 document series.
  #
  # == Encoding
  # The BER format specifies a self-describing and self-delimiting format
  # for encoding ASN.1 data structures. Each data element is encoded as a
  # type identifier, a length description, the actual data elements, and
  # where necessary, an end-of-content marker. This format allows a receiver
  # to decode the ASN.1 information from an incomplete stream, without
  # requiring any pre-knowledge of the size, content, or semantic meaning of
  # the data.
  #
  #   <Type | Length | Value [| End-of-Content]>
  #
  # == Protocol Data Units (PDU)
  # Protocols are defined with schema represented in BER, such that a PDU
  # consists of cascaded type-length-value encodings.
  #
  # === Type Tags
  # BER type tags are represented as single octets (bytes). The lower five
  # bits of the octet are tag identifier numbers and the upper three bits of
  # the octet are used to distinguish the type as native to ASN.1,
  # application-specific, context-specific, or private. See
  # Net::BER::TAG_CLASS and Net::BER::ENCODING_TYPE for more information.
  #
  # If Class is set to Universal (0b00______), the value is of a type native
  # to ASN.1 (e.g. INTEGER). The Application class (0b01______) is only
  # valid for one specific application. Context_specific (0b10______)
  # depends on the context and private (0b11_______) can be defined in
  # private specifications
  #
  # If the primitive/constructed bit is zero (0b__0_____), it specifies that
  # the value is primitive like an INTEGER. If it is one (0b__1_____), the
  # value is a constructed value that contains type-length-value encoded
  # types like a SET or a SEQUENCE.
  #
  # === Defined Universal (ASN.1 Native) Types
  # There are a number of pre-defined universal (native) types.
  #
  # <table>
  # <tr><th>Name</th><th>Primitive<br />Constructed</th><th>Number</th></tr>
  # <tr><th>EOC (End-of-Content)</th><th>P</th><td>0: 0 (0x0, 0b00000000)</td></tr>
  # <tr><th>BOOLEAN</th><th>P</th><td>1: 1 (0x01, 0b00000001)</td></tr>
  # <tr><th>INTEGER</th><th>P</th><td>2: 2 (0x02, 0b00000010)</td></tr>
  # <tr><th>BIT STRING</th><th>P</th><td>3: 3 (0x03, 0b00000011)</td></tr>
  # <tr><th>BIT STRING</th><th>C</th><td>3: 35 (0x23, 0b00100011)</td></tr>
  # <tr><th>OCTET STRING</th><th>P</th><td>4: 4 (0x04, 0b00000100)</td></tr>
  # <tr><th>OCTET STRING</th><th>C</th><td>4: 36 (0x24, 0b00100100)</td></tr>
  # <tr><th>NULL</th><th>P</th><td>5: 5 (0x05, 0b00000101)</td></tr>
  # <tr><th>OBJECT IDENTIFIER</th><th>P</th><td>6: 6 (0x06, 0b00000110)</td></tr>
  # <tr><th>Object Descriptor</th><th>P</th><td>7: 7 (0x07, 0b00000111)</td></tr>
  # <tr><th>EXTERNAL</th><th>C</th><td>8: 40 (0x28, 0b00101000)</td></tr>
  # <tr><th>REAL (float)</th><th>P</th><td>9: 9 (0x09, 0b00001001)</td></tr>
  # <tr><th>ENUMERATED</th><th>P</th><td>10: 10 (0x0a, 0b00001010)</td></tr>
  # <tr><th>EMBEDDED PDV</th><th>C</th><td>11: 43 (0x2b, 0b00101011)</td></tr>
  # <tr><th>UTF8String</th><th>P</th><td>12: 12 (0x0c, 0b00001100)</td></tr>
  # <tr><th>UTF8String</th><th>C</th><td>12: 44 (0x2c, 0b00101100)</td></tr>
  # <tr><th>RELATIVE-OID</th><th>P</th><td>13: 13 (0x0d, 0b00001101)</td></tr>
  # <tr><th>SEQUENCE and SEQUENCE OF</th><th>C</th><td>16: 48 (0x30, 0b00110000)</td></tr>
  # <tr><th>SET and SET OF</th><th>C</th><td>17: 49 (0x31, 0b00110001)</td></tr>
  # <tr><th>NumericString</th><th>P</th><td>18: 18 (0x12, 0b00010010)</td></tr>
  # <tr><th>NumericString</th><th>C</th><td>18: 50 (0x32, 0b00110010)</td></tr>
  # <tr><th>PrintableString</th><th>P</th><td>19: 19 (0x13, 0b00010011)</td></tr>
  # <tr><th>PrintableString</th><th>C</th><td>19: 51 (0x33, 0b00110011)</td></tr>
  # <tr><th>T61String</th><th>P</th><td>20: 20 (0x14, 0b00010100)</td></tr>
  # <tr><th>T61String</th><th>C</th><td>20: 52 (0x34, 0b00110100)</td></tr>
  # <tr><th>VideotexString</th><th>P</th><td>21: 21 (0x15, 0b00010101)</td></tr>
  # <tr><th>VideotexString</th><th>C</th><td>21: 53 (0x35, 0b00110101)</td></tr>
  # <tr><th>IA5String</th><th>P</th><td>22: 22 (0x16, 0b00010110)</td></tr>
  # <tr><th>IA5String</th><th>C</th><td>22: 54 (0x36, 0b00110110)</td></tr>
  # <tr><th>UTCTime</th><th>P</th><td>23: 23 (0x17, 0b00010111)</td></tr>
  # <tr><th>UTCTime</th><th>C</th><td>23: 55 (0x37, 0b00110111)</td></tr>
  # <tr><th>GeneralizedTime</th><th>P</th><td>24: 24 (0x18, 0b00011000)</td></tr>
  # <tr><th>GeneralizedTime</th><th>C</th><td>24: 56 (0x38, 0b00111000)</td></tr>
  # <tr><th>GraphicString</th><th>P</th><td>25: 25 (0x19, 0b00011001)</td></tr>
  # <tr><th>GraphicString</th><th>C</th><td>25: 57 (0x39, 0b00111001)</td></tr>
  # <tr><th>VisibleString</th><th>P</th><td>26: 26 (0x1a, 0b00011010)</td></tr>
  # <tr><th>VisibleString</th><th>C</th><td>26: 58 (0x3a, 0b00111010)</td></tr>
  # <tr><th>GeneralString</th><th>P</th><td>27: 27 (0x1b, 0b00011011)</td></tr>
  # <tr><th>GeneralString</th><th>C</th><td>27: 59 (0x3b, 0b00111011)</td></tr>
  # <tr><th>UniversalString</th><th>P</th><td>28: 28 (0x1c, 0b00011100)</td></tr>
  # <tr><th>UniversalString</th><th>C</th><td>28: 60 (0x3c, 0b00111100)</td></tr>
  # <tr><th>CHARACTER STRING</th><th>P</th><td>29: 29 (0x1d, 0b00011101)</td></tr>
  # <tr><th>CHARACTER STRING</th><th>C</th><td>29: 61 (0x3d, 0b00111101)</td></tr>
  # <tr><th>BMPString</th><th>P</th><td>30: 30 (0x1e, 0b00011110)</td></tr>
  # <tr><th>BMPString</th><th>C</th><td>30: 62 (0x3e, 0b00111110)</td></tr>
  # <tr><th>ExtendedResponse</th><th>C</th><td>107: 139 (0x8b, 0b010001011)</td></tr>
  # </table>
  module BER
    VERSION = Net::LDAP::VERSION

    ##
    # Used for BER-encoding the length and content bytes of a Fixnum integer
    # values.
    MAX_FIXNUM_SIZE = 0.size

    ##
    # BER tag classes are kept in bits seven and eight of the tag type
    # octet.
    #
    # <table>
    # <tr><th>Bitmask</th><th>Definition</th></tr>
    # <tr><th><tt>0b00______</tt></th><td>Universal (ASN.1 Native) Types</td></tr>
    # <tr><th><tt>0b01______</tt></th><td>Application Types</td></tr>
    # <tr><th><tt>0b10______</tt></th><td>Context-Specific Types</td></tr>
    # <tr><th><tt>0b11______</tt></th><td>Private Types</td></tr>
    # </table>
    TAG_CLASS = {
      :universal        => 0b00000000, # 0
      :application      => 0b01000000, # 64
      :context_specific => 0b10000000, # 128
      :private          => 0b11000000, # 192
    }

    ##
    # BER encoding type is kept in bit 6 of the tag type octet.
    #
    # <table>
    # <tr><th>Bitmask</th><th>Definition</th></tr>
    # <tr><th><tt>0b__0_____</tt></th><td>Primitive</td></tr>
    # <tr><th><tt>0b__1_____</tt></th><td>Constructed</td></tr>
    # </table>
    ENCODING_TYPE = {
      :primitive    => 0b00000000,  # 0
      :constructed  => 0b00100000,  # 32
    }

    ##
    # Accepts a hash of hashes describing a BER syntax and converts it into
    # a byte-keyed object for fast BER conversion lookup. The resulting
    # "compiled" syntax is used by Net::BER::BERParser.
    #
    # This method should be called only by client classes of Net::BER (e.g.,
    # Net::LDAP and Net::SNMP) and not by clients of those classes.
    #
    # The hash-based syntax uses TAG_CLASS keys that contain hashes of
    # ENCODING_TYPE keys that contain tag numbers with object type markers.
    #
    #   :<TAG_CLASS> => {
    #     :<ENCODING_TYPE> => {
    #       <number> => <object-type>
    #     },
    #   },
    #
    # === Permitted Object Types
    # <tt>:string</tt>::  A string value, represented as BerIdentifiedString.
    # <tt>:integer</tt>:: An integer value, represented with Fixnum.
    # <tt>:oid</tt>::     An Object Identifier value; see X.690 section
    #                     8.19. Currently represented with a standard array,
    #                     but may be better represented as a
    #                     BerIdentifiedOID object.
    # <tt>:array</tt>::   A sequence, represented as BerIdentifiedArray.
    # <tt>:boolean</tt>:: A boolean value, represented as +true+ or +false+.
    # <tt>:null</tt>::    A null value, represented as BerIdentifiedNull.
    #
    # === Example
    # Net::LDAP defines its ASN.1 BER syntax something like this:
    #
    #   class Net::LDAP
    #     AsnSyntax = Net::BER.compile_syntax({
    #       :application => {
    #         :primitive => {
    #           2 => :null,
    #         },
    #         :constructed => {
    #           0 => :array,
    #           # ...
    #         },
    #       },
    #       :context_specific => {
    #         :primitive => {
    #           0 => :string,
    #           # ...
    #         },
    #         :constructed => {
    #           0 => :array,
    #           # ...
    #         },
    #       }
    #       })
    #   end
    #
    # NOTE:: For readability and formatting purposes, Net::LDAP and its
    #        siblings actually construct their syntaxes more deliberately,
    #        as shown below. Since a hash is passed in the end in any case,
    #        the format does not matter.
    #
    #   primitive = { 2 => :null }
    #   constructed = {
    #     0 => :array,
    #     # ...
    #   }
    #   application = {
    #     :primitive => primitive,
    #     :constructed => constructed
    #   }
    #
    #   primitive = {
    #     0 => :string,
    #     # ...
    #   }
    #   constructed = {
    #     0 => :array,
    #     # ...
    #   }
    #   context_specific = {
    #     :primitive => primitive,
    #     :constructed => constructed
    #   }
    #   AsnSyntax = Net::BER.compile_syntax(:application => application,
    #                                       :context_specific => context_specific)
    def self.compile_syntax(syntax)
      # TODO 20100327 AZ: Should we be allocating an array of 256 values
      # that will either be +nil+ or an object type symbol, or should we
      # allocate an empty Hash since unknown values return +nil+ anyway?
      out = [nil] * 256
      syntax.each do |tag_class_id, encodings|
        tag_class = TAG_CLASS[tag_class_id]
        encodings.each do |encoding_id, classes|
          encoding = ENCODING_TYPE[encoding_id]
          object_class = tag_class + encoding
          classes.each do |number, object_type|
            out[object_class + number] = object_type
          end
        end
      end
      out
    end
  end
end

class Net::BER::BerError < RuntimeError; end

##
# An Array object with a BER identifier attached.
class Net::BER::BerIdentifiedArray < Array
  attr_accessor :ber_identifier

  def initialize(*args)
    super
  end
end

##
# A BER object identifier.
class Net::BER::BerIdentifiedOid
  attr_accessor :ber_identifier

  def initialize(oid)
    if oid.is_a?(String)
      oid = oid.split(/\./).map(&:to_i)
    end
    @value = oid
  end

  def to_ber
    to_ber_oid
  end

  def to_ber_oid
    @value.to_ber_oid
  end

  def to_s
    @value.join(".")
  end

  def to_arr
    @value.dup
  end
end

##
# A String object with a BER identifier attached.
#
class Net::BER::BerIdentifiedString < String
  attr_accessor :ber_identifier

  # The binary data provided when parsing the result of the LDAP search
  # has the encoding 'ASCII-8BIT' (which is basically 'BINARY', or 'unknown').
  #
  # This is the kind of a backtrace showing how the binary `data` comes to
  # BerIdentifiedString.new(data):
  #
  #  @conn.read_ber(syntax)
  #     -> StringIO.new(self).read_ber(syntax), i.e. included from module
  #     -> Net::BER::BERParser.read_ber(syntax)
  #        -> (private)Net::BER::BERParser.parse_ber_object(syntax, id, data)
  #
  # In the `#parse_ber_object` method `data`, according to its OID, is being
  # 'casted' to one of the Net::BER:BerIdentifiedXXX classes.
  #
  # As we are using LDAP v3 we can safely assume that the data is encoded
  # in UTF-8 and therefore the only thing to be done when instantiating is to
  # switch the encoding from 'ASCII-8BIT' to 'UTF-8'.
  #
  # Unfortunately, there are some ActiveDirectory specific attributes
  # (like `objectguid`) that should remain binary (do they really?).
  # Using the `#valid_encoding?` we can trap this cases. Special cases like
  # Japanese, Korean, etc. encodings might also profit from this. However
  # I have no clue how this encodings function.
  def initialize args
    super
    #
    # Check the encoding of the newly created String and set the encoding
    # to 'UTF-8' (NOTE: we do NOT change the bytes, but only set the
    # encoding to 'UTF-8').
    return unless encoding == Encoding::BINARY
    current_encoding = encoding
    force_encoding('UTF-8')
    force_encoding(current_encoding) unless valid_encoding?
  end
end

module Net::BER
  ##
  # A BER null object.
  class BerIdentifiedNull
    attr_accessor :ber_identifier
    def to_ber
    "\005\000"
    end
  end

  ##
  # The default BerIdentifiedNull object.
  Null = Net::BER::BerIdentifiedNull.new
end

require 'net/ber/core_ext'
