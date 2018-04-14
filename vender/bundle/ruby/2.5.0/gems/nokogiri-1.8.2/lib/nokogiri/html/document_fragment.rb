module Nokogiri
  module HTML
    class DocumentFragment < Nokogiri::XML::DocumentFragment
      ####
      # Create a Nokogiri::XML::DocumentFragment from +tags+, using +encoding+
      def self.parse tags, encoding = nil
        doc = HTML::Document.new

        encoding ||= tags.respond_to?(:encoding) ? tags.encoding.name : 'UTF-8'
        doc.encoding = encoding

        new(doc, tags)
      end

      def initialize document, tags = nil, ctx = nil
        return self unless tags

        if ctx
          preexisting_errors = document.errors.dup
          node_set = ctx.parse("<div>#{tags}</div>")
          node_set.first.children.each { |child| child.parent = self } unless node_set.empty?
          self.errors = document.errors - preexisting_errors
        else
          # This is a horrible hack, but I don't care
          if tags.strip =~ /^<body/i
            path = "/html/body"
          else
            path = "/html/body/node()"
          end

          temp_doc = HTML::Document.parse "<html><body>#{tags}", nil, document.encoding
          temp_doc.xpath(path).each { |child| child.parent = self }
          self.errors = temp_doc.errors
        end
        children
      end
    end
  end
end
