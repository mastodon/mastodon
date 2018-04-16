require "helper"

module Nokogiri
  module XML
    class TestAliasedDefaultNamespaces < Nokogiri::TestCase
      def setup
        super
      end

      def test_alised_default_namespace_on_parse
        doc = Nokogiri::XML('<apple xmlns="ns:fruit" xmlns:fruit="ns:fruit" />')
        ns = doc.root.namespaces
        assert_equal  "ns:fruit", ns["xmlns:fruit"], "Should have parsed aliased default namespace"
      end

      def test_add_aliased_default_namespace
        doc = Nokogiri::XML('<apple xmlns="ns:fruit" />')
        doc.root.add_namespace_definition("fruit", "ns:fruit")
        ns = doc.root.namespaces
        assert_equal  "ns:fruit", ns["xmlns:fruit"],"Should have added aliased default namespace"
      end
    end
  end
end
