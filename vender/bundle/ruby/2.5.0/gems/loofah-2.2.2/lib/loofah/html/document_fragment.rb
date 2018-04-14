module Loofah
  module HTML # :nodoc:
    #
    #  Subclass of Nokogiri::HTML::DocumentFragment.
    #
    #  See Loofah::ScrubBehavior and Loofah::TextBehavior for additional methods.
    #
    class DocumentFragment < Nokogiri::HTML::DocumentFragment
      include Loofah::TextBehavior

      class << self
        #
        #  Overridden Nokogiri::HTML::DocumentFragment
        #  constructor. Applications should use Loofah.fragment to
        #  parse a fragment.
        #
        def parse tags, encoding = nil
          doc = Loofah::HTML::Document.new

          encoding ||= tags.respond_to?(:encoding) ? tags.encoding.name : 'UTF-8'
          doc.encoding = encoding

          new(doc, tags)
        end
      end

      #
      #  Returns the HTML markup contained by the fragment
      #
      def to_s
        serialize_root.children.to_s
      end
      alias :serialize :to_s

      def serialize_root
        at_xpath("./body") || self
      end
    end
  end
end
