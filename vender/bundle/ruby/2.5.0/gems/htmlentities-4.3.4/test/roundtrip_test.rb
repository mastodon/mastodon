# encoding: UTF-8
require_relative "./test_helper"

class HTMLEntities::RoundtripTest < Test::Unit::TestCase

  attr_reader :xhtml1_entities, :html4_entities

  def setup
    @xhtml1_entities = HTMLEntities.new('xhtml1')
    @html4_entities = HTMLEntities.new('html4')
  end

  def test_should_roundtrip_xhtml1_entities_via_named_encoding
    each_mapping 'xhtml1' do |name, string|
      assert_equal string, xhtml1_entities.decode(xhtml1_entities.encode(string, :named))
    end
  end

  def test_should_roundtrip_xhtml1_entities_via_basic_and_named_encoding
    each_mapping 'xhtml1' do |name, string|
      assert_equal string, xhtml1_entities.decode(xhtml1_entities.encode(string, :basic, :named))
    end
  end

  def test_should_roundtrip_xhtml1_entities_via_basic_named_and_decimal_encoding
    each_mapping 'xhtml1' do |name, string|
      assert_equal string, xhtml1_entities.decode(xhtml1_entities.encode(string, :basic, :named, :decimal))
    end
  end

  def test_should_roundtrip_xhtml1_entities_via_hexadecimal_encoding
    each_mapping 'xhtml1' do |name, string|
      assert_equal string, xhtml1_entities.decode(xhtml1_entities.encode(string, :hexadecimal))
    end
  end

  def test_should_roundtrip_html4_entities_via_named_encoding
    each_mapping 'html4' do |name, string|
      assert_equal string, html4_entities.decode(html4_entities.encode(string, :named))
    end
  end

  def test_should_roundtrip_html4_entities_via_basic_and_named_encoding
    each_mapping 'html4' do |name, string|
      assert_equal string, html4_entities.decode(html4_entities.encode(string, :basic, :named))
    end
  end

  def test_should_roundtrip_html4_entities_via_basic_named_and_decimal_encoding
    each_mapping 'html4' do |name, string|
      assert_equal string, html4_entities.decode(html4_entities.encode(string, :basic, :named, :decimal))
    end
  end

  def test_should_roundtrip_html4_entities_via_hexadecimal_encoding
    each_mapping 'html4' do |name, string|
      assert_equal string, html4_entities.decode(html4_entities.encode(string, :hexadecimal))
    end
  end

  def each_mapping(flavor)
    HTMLEntities::MAPPINGS[flavor].each do |name, codepoint|
      yield name, [codepoint].pack('U')
    end
  end

end
