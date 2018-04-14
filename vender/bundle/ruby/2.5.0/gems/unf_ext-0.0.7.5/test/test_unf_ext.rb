# -*- coding: utf-8 -*-
require 'helper'
require 'pathname'

class TestUnf < Test::Unit::TestCase
  test "raise ArgumentError if an unknown normalization form is given" do
    normalizer = UNF::Normalizer.new
    assert_raises(ArgumentError) { normalizer.normalize("が", :nfck) }
  end

  test "pass all tests bundled with the original unf" do
    normalizer = UNF::Normalizer.new
    open(Pathname(__FILE__).dirname + 'normalization-test.txt', 'r:utf-8').each_slice(6) { |lines|
      flunk "broken test file" if lines.size != 6 || lines.pop !~ /^$/
      str, nfc, nfd, nfkc, nfkd = lines
      assert_equal nfd,  normalizer.normalize(str,  :nfd)
      assert_equal nfd,  normalizer.normalize(nfd,  :nfd)
      assert_equal nfd,  normalizer.normalize(nfc,  :nfd)
      assert_equal nfkd, normalizer.normalize(nfkc, :nfd)
      assert_equal nfkd, normalizer.normalize(nfkc, :nfd)

      assert_equal nfc,  normalizer.normalize(str,  :nfc)
      assert_equal nfc,  normalizer.normalize(nfd,  :nfc)
      assert_equal nfc,  normalizer.normalize(nfc,  :nfc)
      assert_equal nfkc, normalizer.normalize(nfkc, :nfc)
      assert_equal nfkc, normalizer.normalize(nfkd, :nfc)

      assert_equal nfkd, normalizer.normalize(str,  :nfkd)
      assert_equal nfkd, normalizer.normalize(nfd,  :nfkd)
      assert_equal nfkd, normalizer.normalize(nfc,  :nfkd)
      assert_equal nfkd, normalizer.normalize(nfkc, :nfkd)
      assert_equal nfkd, normalizer.normalize(nfkd, :nfkd)

      assert_equal nfkc, normalizer.normalize(str,  :nfkc)
      assert_equal nfkc, normalizer.normalize(nfd,  :nfkc)
      assert_equal nfkc, normalizer.normalize(nfc,  :nfkc)
      assert_equal nfkc, normalizer.normalize(nfkc, :nfkc)
      assert_equal nfkc, normalizer.normalize(nfkd, :nfkc)
    }
  end
end
