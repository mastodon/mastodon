# encoding: UTF-8
require_relative "./test_helper"

class HTMLEntities::StringEncodingsTest < Test::Unit::TestCase

  def test_should_encode_ascii_to_ascii
    s = "<elan>".encode(Encoding::US_ASCII)
    assert_equal Encoding::US_ASCII, s.encoding

    t = HTMLEntities.new.encode(s)
    assert_equal "&lt;elan&gt;", t
    assert_equal Encoding::US_ASCII, t.encoding
  end

  def test_should_encode_utf8_to_utf8_if_needed
    s = "<élan>"
    assert_equal Encoding::UTF_8, s.encoding

    t = HTMLEntities.new.encode(s)
    assert_equal "&lt;élan&gt;", t
    assert_equal Encoding::UTF_8, t.encoding
  end

  def test_should_encode_utf8_to_ascii_if_possible
    s = "<elan>"
    assert_equal Encoding::UTF_8, s.encoding

    t = HTMLEntities.new.encode(s)
    assert_equal "&lt;elan&gt;", t
    assert_equal Encoding::US_ASCII, t.encoding
  end

  def test_should_encode_other_encoding_to_utf8
    s = "<élan>".encode(Encoding::ISO_8859_1)
    assert_equal Encoding::ISO_8859_1, s.encoding

    t = HTMLEntities.new.encode(s)
    assert_equal "&lt;élan&gt;", t
    assert_equal Encoding::UTF_8, t.encoding
  end

  def test_should_decode_ascii_to_utf8
    s = "&lt;&eacute;lan&gt;".encode(Encoding::US_ASCII)
    assert_equal Encoding::US_ASCII, s.encoding

    t = HTMLEntities.new.decode(s)
    assert_equal "<élan>", t
    assert_equal Encoding::UTF_8, t.encoding
  end

  def test_should_decode_utf8_to_utf8
    s = "&lt;&eacute;lan&gt;".encode(Encoding::UTF_8)
    assert_equal Encoding::UTF_8, s.encoding

    t = HTMLEntities.new.decode(s)
    assert_equal "<élan>", t
    assert_equal Encoding::UTF_8, t.encoding
  end

  def test_should_decode_other_encoding_to_utf8
    s = "&lt;&eacute;lan&gt;".encode(Encoding::ISO_8859_1)
    assert_equal Encoding::ISO_8859_1, s.encoding

    t = HTMLEntities.new.decode(s)
    assert_equal "<élan>", t
    assert_equal Encoding::UTF_8, t.encoding
  end
end
