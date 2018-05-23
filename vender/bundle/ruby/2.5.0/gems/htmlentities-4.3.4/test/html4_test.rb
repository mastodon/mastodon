# encoding: UTF-8
require_relative "./test_helper"

class HTML4Test < Test::Unit::TestCase

  attr_reader :html_entities

  def setup
    @html_entities = HTMLEntities.new('html4')
  end

  # Found by Marcos Kuhns
  def test_should_not_encode_apos_entity
    assert_equal "'", html_entities.encode("'", :basic)
  end

  def test_should_not_decode_apos_entity
    assert_equal "é&apos;", html_entities.decode("&eacute;&apos;")
  end

  def test_should_not_decode_dotted_entity
    assert_equal "&b.Theta;", html_entities.decode("&b.Theta;")
  end

end
