# encoding: UTF-8
require_relative "./test_helper"

class HTMLEntities::XHTML1Test < Test::Unit::TestCase

  attr_reader :html_entities

  def setup
    @html_entities = HTMLEntities.new('xhtml1')
  end

  def test_should_encode_apos_entity
    assert_equal "&apos;", html_entities.encode("'", :basic)
  end

  def test_should_decode_apos_entity
    assert_equal "é'", html_entities.decode("&eacute;&apos;")
  end

  def test_should_not_decode_dotted_entity
    assert_equal "&b.Theta;", html_entities.decode("&b.Theta;")
  end

end
