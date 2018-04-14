
module Ox
  # Represents an XML document. It has a fixed set of attributes which form
  # the XML prolog. A Document includes Elements.
  class Document < Element
    # Create a new Document.
    # - +prolog+ [Hash] prolog attributes
    #   - _:version_ [String] version, typically '1.0' or '1.1'
    #   - _:encoding_ [String] encoding for the document, currently included but ignored
    #   - _:standalone_ [String] indicates the document is standalone
    def initialize(prolog={})
      super(nil)
      @attributes = { }
      @attributes[:version] = prolog[:version] unless prolog[:version].nil?
      @attributes[:encoding] = prolog[:encoding] unless prolog[:encoding].nil?
      @attributes[:standalone] = prolog[:standalone] unless prolog[:standalone].nil?
    end
    
    # Returns the first Element in the document.
    def root()
      unless !instance_variable_defined?(:@nodes) || @nodes.nil?
        @nodes.each do |n|
          return n if n.is_a?(::Ox::Element)
        end
      end
      nil
    end

  end # Document
end # Ox
