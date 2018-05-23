# encoding: UTF-8
require_relative "./test_helper"

class HTMLEntities::EntitiesTest < Test::Unit::TestCase

  def test_should_raise_exception_when_unknown_flavor_specified
    assert_raises HTMLEntities::UnknownFlavor do
      HTMLEntities.new('foo')
    end
  end

  def test_should_allow_symbol_for_flavor
    assert_nothing_raised do
      HTMLEntities.new(:xhtml1)
    end
  end

  def test_should_allow_upper_case_flavor
    assert_nothing_raised do
      HTMLEntities.new('XHTML1')
    end
  end

end
