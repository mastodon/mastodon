# encoding: UTF-8
require 'htmlentities/flavors'
require 'htmlentities/encoder'
require 'htmlentities/decoder'
require 'htmlentities/version'

#
# HTML entity encoding and decoding for Ruby
#
class HTMLEntities
  UnknownFlavor = Class.new(RuntimeError)

  #
  # Create a new HTMLEntities coder for the specified flavor.
  # Available flavors are 'html4', 'expanded' and 'xhtml1' (the default).
  #
  # The only difference in functionality between html4 and xhtml1 is in the
  # handling of the apos (apostrophe) named entity, which is not defined in
  # HTML4.
  #
  # 'expanded' includes a large number of additional SGML entities drawn from
  #   ftp://ftp.unicode.org/Public/MAPPINGS/VENDORS/MISC/SGML.TXT
  # it "maps SGML character entities from various public sets (namely, ISOamsa,
  # ISOamsb, ISOamsc, ISOamsn, ISOamso, ISOamsr, ISObox, ISOcyr1, ISOcyr2,
  # ISOdia, ISOgrk1, ISOgrk2, ISOgrk3, ISOgrk4, ISOlat1, ISOlat2, ISOnum,
  # ISOpub, ISOtech, HTMLspecial, HTMLsymbol) to corresponding Unicode
  # characters." (sgml.txt).
  #
  # 'expanded' is a strict superset of the XHTML entities: every xhtml named
  # entity encodes and decodes the same under :expanded as under :xhtml1
  #
  def initialize(flavor='xhtml1')
    @flavor = flavor.to_s.downcase
    raise UnknownFlavor, "Unknown flavor #{flavor}" unless FLAVORS.include?(@flavor)
  end

  #
  # Decode entities in a string into their UTF-8
  # equivalents. The string should already be in UTF-8 encoding.
  #
  # Unknown named entities will not be converted
  #
  def decode(source)
    (@decoder ||= Decoder.new(@flavor)).decode(source)
  end

  #
  # Encode codepoints into their corresponding entities.  Various operations
  # are possible, and may be specified in order:
  #
  # :basic :: Convert the five XML entities ('"<>&)
  # :named :: Convert non-ASCII characters to their named HTML 4.01 equivalent
  # :decimal :: Convert non-ASCII characters to decimal entities (e.g. &#1234;)
  # :hexadecimal :: Convert non-ASCII characters to hexadecimal entities (e.g. # &#x12ab;)
  #
  # You can specify the commands in any order, but they will be executed in
  # the order listed above to ensure that entity ampersands are not
  # clobbered and that named entities are replaced before numeric ones.
  #
  # If no instructions are specified, :basic will be used.
  #
  # Examples:
  #   encode(str) - XML-safe
  #   encode(str, :basic, :decimal) - XML-safe and 7-bit clean
  #   encode(str, :basic, :named, :decimal) - 7-bit clean, with all
  #   non-ASCII characters replaced with their named entity where possible, and
  #   decimal equivalents otherwise.
  #
  # Note: It is the program's responsibility to ensure that the source
  # contains valid UTF-8 before calling this method.
  #
  def encode(source, *instructions)
    Encoder.new(@flavor, instructions).encode(source)
  end
end
