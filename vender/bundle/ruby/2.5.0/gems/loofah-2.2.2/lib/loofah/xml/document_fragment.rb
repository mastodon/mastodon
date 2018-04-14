module Loofah
  module XML # :nodoc:
    #
    #  Subclass of Nokogiri::XML::DocumentFragment.
    #
    #  See Loofah::ScrubBehavior for additional methods.
    #
    class DocumentFragment < Nokogiri::XML::DocumentFragment
      class << self
        #
        #  Overridden Nokogiri::XML::DocumentFragment
        #  constructor. Applications should use Loofah.fragment to
        #  parse a fragment.
        #
        def parse tags
          doc = Loofah::XML::Document.new
          doc.encoding = tags.encoding.name if tags.respond_to?(:encoding)
          self.new(doc, tags)
        end
      end
    end
  end
end
