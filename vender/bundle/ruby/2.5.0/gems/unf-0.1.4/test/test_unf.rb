# -*- coding: utf-8 -*-
require 'helper'
require 'pathname'

class TestUNF < Test::Unit::TestCase
  should "raise ArgumentError if an unknown normalization form is given" do
    normalizer = UNF::Normalizer.instance
    assert_raises(ArgumentError) { normalizer.normalize("が", :nfck) }
  end

  should "pass all tests bundled with the original unf" do
    normalizer = UNF::Normalizer.instance
    open(Pathname(__FILE__).dirname + 'normalization-test.txt', 'r:utf-8').each_slice(6) { |lines|
      flunk "broken test file" if lines.size != 6 || lines.pop !~ /^$/
      str, nfd, nfc, nfkd, nfkc = lines
      assert nfd,  normalizer.normalize(str,  :nfd)
      assert nfd,  normalizer.normalize(nfd,  :nfd)
      assert nfd,  normalizer.normalize(nfc,  :nfd)
      assert nfkd, normalizer.normalize(nfkc, :nfd)
      assert nfkd, normalizer.normalize(nfkc, :nfd)

      assert nfc,  normalizer.normalize(str,  :nfd)
      assert nfc,  normalizer.normalize(nfd,  :nfc)
      assert nfc,  normalizer.normalize(nfc,  :nfc)
      assert nfkc, normalizer.normalize(nfkc, :nfc)
      assert nfkc, normalizer.normalize(nfkd, :nfc)

      assert nfkd, normalizer.normalize(str,  :nfkd)
      assert nfkd, normalizer.normalize(nfd,  :nfkd)
      assert nfkd, normalizer.normalize(nfc,  :nfkd)
      assert nfkd, normalizer.normalize(nfkc, :nfkd)
      assert nfkd, normalizer.normalize(nfkd, :nfkd)

      assert nfkc, normalizer.normalize(str,  :nfkc)
      assert nfkc, normalizer.normalize(nfd,  :nfkc)
      assert nfkc, normalizer.normalize(nfc,  :nfkc)
      assert nfkc, normalizer.normalize(nfkc, :nfkc)
      assert nfkc, normalizer.normalize(nfkd, :nfkc)
    }
  end
end
