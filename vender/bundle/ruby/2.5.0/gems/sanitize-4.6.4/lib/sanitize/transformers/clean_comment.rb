# encoding: utf-8

class Sanitize; module Transformers

  CleanComment = lambda do |env|
    node = env[:node]

    if node.type == Nokogiri::XML::Node::COMMENT_NODE
      node.unlink unless env[:is_whitelisted]
    end
  end

end; end
