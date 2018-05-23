module RDF
  ##
  # **`RDF::NTriples`** provides support for the N-Triples serialization
  # format.
  #
  # N-Triples is a line-based plain-text format for encoding an RDF graph.
  # It is a very restricted, explicit and well-defined subset of both
  # [Turtle](http://www.w3.org/TeamSubmission/turtle/) and
  # [Notation3](http://www.w3.org/TeamSubmission/n3/) (N3).
  #
  # The MIME content type for N-Triples files is `text/plain` and the
  # recommended file extension is `.nt`.
  #
  # An example of an RDF statement in N-Triples format:
  #
  #     <http://rubygems.org/gems/rdf> <http://purl.org/dc/terms/title> "rdf" .
  #
  # Installation
  # ------------
  #
  # This is the only RDF serialization format that is directly supported by
  # RDF.rb. Support for other formats is available in the form of add-on
  # gems, e.g. 'rdf-xml' or 'rdf-json'.
  #
  # Documentation
  # -------------
  #
  # * {RDF::NTriples::Format}
  # * {RDF::NTriples::Reader}
  # * {RDF::NTriples::Writer}
  #
  # @example Requiring the `RDF::NTriples` module explicitly
  #   require 'rdf/ntriples'
  #
  # @see http://www.w3.org/TR/n-triples/
  # @see http://en.wikipedia.org/wiki/N-Triples
  #
  # @author [Arto Bendiken](http://ar.to/)
  module NTriples
    require 'rdf/ntriples/format'
    autoload :Reader, 'rdf/ntriples/reader'
    autoload :Writer, 'rdf/ntriples/writer'

    ##
    # Reconstructs an RDF value from its serialized N-Triples
    # representation.
    #
    # @param  [String] data
    # @return [RDF::Value]
    # @see    RDF::NTriples::Reader.unserialize
    # @since  0.1.5
    def self.unserialize(data)
      Reader.unserialize(data)
    end

    ##
    # Returns the serialized N-Triples representation of the given RDF
    # value.
    #
    # @param  [RDF::Value] value
    # @return [String]
    # @see    RDF::NTriples::Writer.serialize
    # @since  0.1.5
    def self.serialize(value)
      Writer.for(:ntriples).serialize(value)
    end

    ##
    # @param  [String] string
    # @return [String]
    # @see    RDF::NTriples::Reader.unescape
    # @since  0.2.2
    def self.unescape(string)
      Reader.unescape(string)
    end

    ##
    # @param  [String] string
    # @return [String]
    # @see    RDF::NTriples::Writer.escape
    # @since  0.2.2
    def self.escape(string)
      Writer.escape(string)
    end
  end # NTriples

  ##
  # Extensions for `RDF::Value`.
  module Value
    ##
    # Returns the N-Triples representation of this value.
    #
    # This method is only available when the 'rdf/ntriples' serializer has
    # been explicitly required.
    #
    # @return [String]
    # @since  0.2.1
    def to_ntriples
      RDF::NTriples.serialize(self)
    end
  end # Value
end # RDF
