module Loofah
  module XML # :nodoc:
    #
    #  Subclass of Nokogiri::XML::Document.
    #
    #  See Loofah::ScrubBehavior and Loofah::DocumentDecorator for additional methods.
    #
    class Document < Nokogiri::XML::Document
      include Loofah::ScrubBehavior::Node
      include Loofah::DocumentDecorator
    end
  end
end
