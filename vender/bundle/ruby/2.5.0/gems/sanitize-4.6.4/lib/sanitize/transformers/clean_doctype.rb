# encoding: utf-8

class Sanitize; module Transformers

  CleanDoctype = lambda do |env|
    return if env[:is_whitelisted]

    node = env[:node]

    if node.type == Nokogiri::XML::Node::DTD_NODE
      if env[:config][:allow_doctype]
        node.name = 'html'
      else
        node.unlink
      end
    end
  end

end; end
