require "helper"

module Nokogiri
  module XML
    class TestAdditionalNamespacesInBuilderDoc < Nokogiri::TestCase
      def test_builder_namespaced_root_node_ns
        b = Nokogiri::XML::Builder.new do |x|
          x[:foo].RDF(:'xmlns:foo' => 'http://foo.io')
        end
        assert_equal 'http://foo.io', b.doc.root.namespace.href
      end
    end
  end
end
