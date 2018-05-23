# encoding: utf-8

class Sanitize; module Transformers

  CleanCDATA = lambda do |env|
    node = env[:node]

    if node.type == Nokogiri::XML::Node::CDATA_SECTION_NODE
      node.replace(Nokogiri::XML::Text.new(node.text, node.document))
    end
  end

end; end
