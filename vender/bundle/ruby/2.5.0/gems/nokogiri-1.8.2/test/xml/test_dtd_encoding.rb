# -*- coding: utf-8 -*-

require "helper"

module Nokogiri
  module XML
    class TestDTDEncoding < Nokogiri::TestCase
      def setup
        super
        @xml = Nokogiri::XML(File.read(XML_FILE), XML_FILE, 'UTF-8')
        assert @dtd = @xml.internal_subset
      end

      def test_entities
        @dtd.entities.each do |k,v|
          assert_equal @xml.encoding, k.encoding.name
        end
      end

      def test_notations
        @dtd.notations.each do |k,notation|
          assert_equal 'UTF-8', k.encoding.name
          %w{ name public_id system_id }.each do |attribute|
            v = notation.send(:"#{attribute}") || next
            assert_equal 'UTF-8', v.encoding.name
          end
        end
      end
    end
  end
end
