module RDF::NTriples
  ##
  # N-Triples format specification.
  #
  # Note: Latest standards activities treat N-Triples as a subset
  # of Turtle. This includes application/n-triples mime type and a
  # new default encoding of utf-8.
  #
  # @example Obtaining an NTriples format class
  #   RDF::Format.for(:ntriples)     #=> RDF::NTriples::Format
  #   RDF::Format.for("etc/doap.nt")
  #   RDF::Format.for(file_name:      "etc/doap.nt")
  #   RDF::Format.for(file_extension: "nt")
  #   RDF::Format.for(content_type:   "application/n-triples")
  #
  # @see http://www.w3.org/TR/rdf-testcases/#ntriples
  # @see http://www.w3.org/TR/n-triples/
  class Format < RDF::Format
    content_type     'application/n-triples', extension: :nt, alias: 'text/plain;q=0.2'
    content_encoding 'utf-8'

    reader { RDF::NTriples::Reader }
    writer { RDF::NTriples::Writer }
    
    ##
    # Sample detection to see if it matches N-Triples
    #
    # Use a text sample to detect the format of an input file. Sub-classes implement
    # a matcher sufficient to detect probably format matches, including disambiguating
    # between other similar formats.
    #
    # @param [String] sample Beginning several bytes (about 1K) of input.
    # @return [Boolean]
    def self.detect(sample)
      !!sample.match(%r(
        (?:(?:<[^>]*>) | (?:_:\w+))                             # Subject
        \s*
        (?:<[^>]*>)                                             # Predicate
        \s*
        (?:(?:<[^>]*>) | (?:_:\w+) | (?:"[^"\n]*"(?:^^|@\S+)?)) # Object
        \s*\.
      )x) && !(
        sample.match(%r(@(base|prefix|keywords)|\{)) ||         # Not Turtle/N3/TriG
        sample.match(%r(<(html|rdf))i)                          # Not HTML or XML
      ) && !RDF::NQuads::Format.detect(sample)
    end

    # Human readable name for this format
    def self.name; "N-Triples"; end
  end
end
