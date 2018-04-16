# -*- encoding: utf-8 -*-
# frozen_string_literal: true
module JSON::LD
  ##
  # A JSON-LD parser in Ruby.
  #
  # @see http://json-ld.org/spec/ED/20110507/
  # @author [Gregg Kellogg](http://greggkellogg.net/)
  class Reader < RDF::Reader
    format Format

    ##
    # JSON-LD Reader options
    # @see http://www.rubydoc.info/github/ruby-rdf/rdf/RDF/Reader#options-class_method
    def self.options
      super + [
        RDF::CLI::Option.new(
          symbol: :expandContext,
          control: :url2,
          datatype: RDF::URI,
          on: ["--expand-context CONTEXT"],
          description: "Context to use when expanding.") {|arg| RDF::URI(arg)},
        RDF::CLI::Option.new(
          symbol: :processing_mode,
          datatype: %w(json-ld-1.0 json-ld-1.1),
          control: :radio,
          on: ["--processingMode MODE", %w(json-ld-1.0 json-ld-1.1)],
          description: "Set Processing Mode (json-ld-1.0 or json-ld-1.1)"),
      ]
    end

    ##
    # Initializes the RDF/JSON reader instance.
    #
    # @param  [IO, File, String]       input
    # @param  [Hash{Symbol => Object}] options
    #   any additional options (see `RDF::Reader#initialize` and {JSON::LD::API.initialize})
    # @yield  [reader] `self`
    # @yieldparam  [RDF::Reader] reader
    # @yieldreturn [void] ignored
    # @raise [RDF::ReaderError] if the JSON document cannot be loaded
    def initialize(input = $stdin, options = {}, &block)
      options[:base_uri] ||= options[:base]
      super do
        @options[:base] ||= base_uri.to_s if base_uri
        begin
          # Trim non-JSON stuff in script.
          @doc = if input.respond_to?(:read)
            input
          else
            StringIO.new(input.to_s.sub(%r(\A[^{\[]*)m, '').sub(%r([^}\]]*\Z)m, ''))
          end
        end

        if block_given?
          case block.arity
            when 0 then instance_eval(&block)
            else block.call(self)
          end
        end
      end
    end

    ##
    # @private
    # @see   RDF::Reader#each_statement
    def each_statement(&block)
      JSON::LD::API.toRdf(@doc, @options, &block)
    rescue ::JSON::ParserError, ::JSON::LD::JsonLdError => e
      log_fatal("Failed to parse input document: #{e.message}", exception: RDF::ReaderError)
    end

    ##
    # @private
    # @see   RDF::Reader#each_triple
    def each_triple(&block)
      if block_given?
        JSON::LD::API.toRdf(@doc, @options) do |statement|
          yield *statement.to_triple
        end
      end
      enum_for(:each_triple)
    end
  end
end

