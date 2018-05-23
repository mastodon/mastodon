# -*- coding: utf-8 -*-

require "helper"

class TestEncodingHandler < Nokogiri::TestCase
  def teardown
    Nokogiri::EncodingHandler.clear_aliases!
    #Replace default aliases removed by clear_aliases!
    Nokogiri.install_default_aliases
  end

  def test_get
    assert_not_nil Nokogiri::EncodingHandler['UTF-8']
    assert_nil Nokogiri::EncodingHandler['alsdkjfhaldskjfh']
  end

  def test_name
    eh = Nokogiri::EncodingHandler['UTF-8']
    assert_equal "UTF-8", eh.name
  end

  def test_alias
    Nokogiri::EncodingHandler.alias('UTF-8', 'UTF-18')
    assert_equal 'UTF-8', Nokogiri::EncodingHandler['UTF-18'].name
  end

  def test_cleanup_aliases
    assert_nil Nokogiri::EncodingHandler['UTF-9']
    Nokogiri::EncodingHandler.alias('UTF-8', 'UTF-9')
    assert_not_nil Nokogiri::EncodingHandler['UTF-9']

    Nokogiri::EncodingHandler.clear_aliases!
    assert_nil Nokogiri::EncodingHandler['UTF-9']
  end

  def test_delete
    assert_nil Nokogiri::EncodingHandler['UTF-9']
    Nokogiri::EncodingHandler.alias('UTF-8', 'UTF-9')
    assert_not_nil Nokogiri::EncodingHandler['UTF-9']

    Nokogiri::EncodingHandler.delete 'UTF-9'
    assert_nil Nokogiri::EncodingHandler['UTF-9']
  end

  def test_delete_non_existent
    assert_nil Nokogiri::EncodingHandler.delete('UTF-9')
  end
end
