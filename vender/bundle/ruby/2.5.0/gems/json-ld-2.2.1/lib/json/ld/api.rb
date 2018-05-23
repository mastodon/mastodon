# -*- encoding: utf-8 -*-
# frozen_string_literal: true
require 'openssl'
require 'json/ld/expand'
require 'json/ld/compact'
require 'json/ld/flatten'
require 'json/ld/frame'
require 'json/ld/to_rdf'
require 'json/ld/from_rdf'

begin
  require 'jsonlint'
rescue LoadError
end

module JSON::LD
  ##
  # A JSON-LD processor based on the JsonLdProcessor interface.
  #
  # This API provides a clean mechanism that enables developers to convert JSON-LD data into a a variety of output formats that are easier to work with in various programming languages. If a JSON-LD API is provided in a programming environment, the entirety of the following API must be implemented.
  #
  # Note that the API method signatures are somewhat different than what is specified, as the use of Futures and explicit callback parameters is not as relevant for Ruby-based interfaces.
  #
  # @see http://json-ld.org/spec/latest/json-ld-api/#the-application-programming-interface
  # @author [Gregg Kellogg](http://greggkellogg.net/)
  class API
    include Expand
    include Compact
    include ToRDF
    include Flatten
    include FromRDF
    include Frame
    include RDF::Util::Logger

    # Options used for open_file
    OPEN_OPTS = {
      headers: {"Accept" => "application/ld+json, application/json"}
    }

    # Current input
    # @!attribute [rw] input
    # @return [String, #read, Hash, Array]
    attr_accessor :value

    # Input evaluation context
    # @!attribute [rw] context
    # @return [JSON::LD::Context]
    attr_accessor :context

    # Current Blank Node Namer
    # @!attribute [r] namer
    # @return [JSON::LD::BlankNodeNamer]
    attr_reader :namer

    ##
    # Initialize the API, reading in any document and setting global options
    #
    # @param [String, #read, Hash, Array] input
    # @param [String, #read, Hash, Array, JSON::LD::Context] context
    #   An external context to use additionally to the context embedded in input when expanding the input.
    # @param  [Hash{Symbol => Object}] options
    # @option options [String, #to_s] :base
    #   The Base IRI to use when expanding the document. This overrides the value of `input` if it is a _IRI_. If not specified and `input` is not an _IRI_, the base IRI defaults to the current document IRI if in a browser context, or the empty string if there is no document context. If not specified, and a base IRI is found from `input`, options[:base] will be modified with this value.
    # @option options [Boolean] :compactArrays (true)
    #   If set to `true`, the JSON-LD processor replaces arrays with just one element with that element during compaction. If set to `false`, all arrays will remain arrays even if they have just one element.
    # @option options [Boolean] :compactToRelative (true)
    #   Creates document relative IRIs when compacting, if `true`, otherwise leaves expanded.
    # @option options [Proc] :documentLoader
    #   The callback of the loader to be used to retrieve remote documents and contexts. If specified, it must be used to retrieve remote documents and contexts; otherwise, if not specified, the processor's built-in loader must be used. See {documentLoader} for the method signature.
    # @option options [String, #read, Hash, Array, JSON::LD::Context] :expandContext
    #   A context that is used to initialize the active context when expanding a document.
    # @option options [Boolean, String, RDF::URI] :flatten
    #   If set to a value that is not `false`, the JSON-LD processor must modify the output of the Compaction Algorithm or the Expansion Algorithm by coalescing all properties associated with each subject via the Flattening Algorithm. The value of `flatten must` be either an _IRI_ value representing the name of the graph to flatten, or `true`. If the value is `true`, then the first graph encountered in the input document is selected and flattened.
    # @option options [String] :processingMode
    #   Processing mode, json-ld-1.0 or json-ld-1.1. Also can have other values:
    #
    #   * json-ld-1.1-expand-frame – special frame expansion mode.
    #
    #   If `processingMode` is not specified, a mode of `json-ld-1.0` or `json-ld-1.1` is set, the context used for `expansion` or `compaction`.
    # @option options [Boolean] :rename_bnodes (true)
    #   Rename bnodes as part of expansion, or keep them the same.
    # @option options [Boolean]  :unique_bnodes   (false)
    #   Use unique bnode identifiers, defaults to using the identifier which the node was originally initialized with (if any).
    # @option options [Symbol] :adapter used with MultiJson
    # @option options [Boolean] :validate Validate input, if a string or readable object.
    # @yield [api]
    # @yieldparam [API]
    # @raise [JsonLdError]
    def initialize(input, context, options = {}, &block)
      @options = {
        compactArrays:      true,
        rename_bnodes:      true,
        documentLoader:     self.class.method(:documentLoader)
      }.merge(options)
      @namer = options[:unique_bnodes] ? BlankNodeUniqer.new : (@options[:rename_bnodes] ? BlankNodeNamer.new("b") : BlankNodeMapper.new)

      # For context via Link header
      remote_base, context_ref = nil, nil

      @value = case input
      when Array, Hash then input.dup
      when IO, StringIO
        @options = {base: input.base_uri}.merge(@options) if input.respond_to?(:base_uri)

        # if input impelements #links, attempt to get a contextUrl from that link
        content_type = input.respond_to?(:content_type) ? input.content_type : "application/json"
        context_ref = if content_type.start_with?('application/json') && input.respond_to?(:links)
          link = input.links.find_link(%w(rel http://www.w3.org/ns/json-ld#context))
          link.href if link
        end

        validate_input(input) if options[:validate]

        MultiJson.load(input.read, options)
      when String
        remote_doc = @options[:documentLoader].call(input, @options)

        remote_base = remote_doc.documentUrl
        context_ref = remote_doc.contextUrl
        @options = {base: remote_doc.documentUrl}.merge(@options) unless @options[:no_default_base]

        case remote_doc.document
        when String
          validate_input(remote_doc.document) if options[:validate]
          MultiJson.load(remote_doc.document, options)
        else
          remote_doc.document
        end
      end

      # If not provided, first use context from document, or from a Link header
      context ||= (@value['@context'] if @value.is_a?(Hash)) || context_ref
      @context = Context.parse(context || {}, @options)

      # If not set explicitly, the context figures out the processing mode
      @options[:processingMode] ||= @context.processingMode || "json-ld-1.0"
      @options[:validate] ||= %w(json-ld-1.0 json-ld-1.1).include?(@options[:processingMode])

      if block_given?
        case block.arity
          when 0, -1 then instance_eval(&block)
          else block.call(self)
        end
      end
    end

    # This is used internally only
    private :initialize
    
    ##
    # Expands the given input according to the steps in the Expansion Algorithm. The input must be copied, expanded and returned if there are no errors. If the expansion fails, an appropriate exception must be thrown.
    #
    # The resulting `Array` either returned or yielded
    #
    # @param [String, #read, Hash, Array] input
    #   The JSON-LD object to copy and perform the expansion upon.
    # @param  [Hash{Symbol => Object}] options
    # @option options (see #initialize)
    # @raise [JsonLdError]
    # @yield jsonld, base_iri
    # @yieldparam [Array<Hash>] jsonld
    #   The expanded JSON-LD document
    # @yieldparam [RDF::URI] base_iri
    #   The document base as determined during expansion
    # @yieldreturn [Object] returned object
    # @return [Object, Array<Hash>]
    #   If a block is given, the result of evaluating the block is returned, otherwise, the expanded JSON-LD document
    # @see http://json-ld.org/spec/latest/json-ld-api/#expansion-algorithm
    def self.expand(input, options = {}, &block)
      result, doc_base = nil
      API.new(input, options[:expandContext], options) do
        result = self.expand(self.value, nil, self.context, ordered: options.fetch(:ordered, true))
        doc_base = @options[:base]
      end

      # If, after the algorithm outlined above is run, the resulting element is an JSON object with just a @graph property, element is set to the value of @graph's value.
      result = result['@graph'] if result.is_a?(Hash) && result.length == 1 && result.key?('@graph')

      # Finally, if element is a JSON object, it is wrapped into an array.
      result = [result].compact unless result.is_a?(Array)

      if block_given?
        case block.arity
        when 1 then yield(result)
        when 2 then yield(result, doc_base)
        else
          raise "Unexpected number of yield parameters to expand"
        end
      else
        result
      end
    end

    ##
    # Compacts the given input according to the steps in the Compaction Algorithm. The input must be copied, compacted and returned if there are no errors. If the compaction fails, an appropirate exception must be thrown.
    #
    # If no context is provided, the input document is compacted using the top-level context of the document
    #
    # The resulting `Hash` is either returned or yielded, if a block is given.
    #
    # @param [String, #read, Hash, Array] input
    #   The JSON-LD object to copy and perform the compaction upon.
    # @param [String, #read, Hash, Array, JSON::LD::Context] context
    #   The base context to use when compacting the input.
    # @param  [Hash{Symbol => Object}] options
    # @option options (see #initialize)
    # @option options [Boolean] :expanded Input is already expanded
    # @yield jsonld
    # @yieldparam [Hash] jsonld
    #   The compacted JSON-LD document
    # @yieldreturn [Object] returned object
    # @return [Object, Hash]
    #   If a block is given, the result of evaluating the block is returned, otherwise, the compacted JSON-LD document
    # @raise [JsonLdError]
    # @see http://json-ld.org/spec/latest/json-ld-api/#compaction-algorithm
    def self.compact(input, context, options = {})
      result = nil
      options = {compactToRelative:  true}.merge(options)

      # 1) Perform the Expansion Algorithm on the JSON-LD input.
      #    This removes any existing context to allow the given context to be cleanly applied.
      expanded_input = options[:expanded] ? input : API.expand(input, options) do |result, base_iri|
        options[:base] ||= base_iri if options[:compactToRelative]
        result
      end

      API.new(expanded_input, context, options.merge(no_default_base: true)) do
        log_debug(".compact") {"expanded input: #{expanded_input.to_json(JSON_STATE) rescue 'malformed json'}"}
        result = compact(value)

        # xxx) Add the given context to the output
        ctx = self.context.serialize
        if result.is_a?(Array)
          kwgraph = self.context.compact_iri('@graph', vocab: true, quiet: true)
          result = result.empty? ? {} : {kwgraph => result}
        end
        result = ctx.merge(result) unless ctx.empty?
      end
      block_given? ? yield(result) : result
    end

    ##
    # This algorithm flattens an expanded JSON-LD document by collecting all properties of a node in a single JSON object and labeling all blank nodes with blank node identifiers. This resulting uniform shape of the document, may drastically simplify the code required to process JSON-LD data in certain applications.
    #
    # The resulting `Array` is either returned, or yielded if a block is given.
    #
    # @param [String, #read, Hash, Array] input
    #   The JSON-LD object or array of JSON-LD objects to flatten or an IRI referencing the JSON-LD document to flatten.
    # @param [String, #read, Hash, Array, JSON::LD::EvaluationContext] context
    #   An optional external context to use additionally to the context embedded in input when expanding the input.
    # @param  [Hash{Symbol => Object}] options
    # @option options (see #initialize)
    # @option options [Boolean] :expanded Input is already expanded
    # @yield jsonld
    # @yieldparam [Hash] jsonld
    #   The flattened JSON-LD document
    # @yieldreturn [Object] returned object
    # @return [Object, Hash]
    #   If a block is given, the result of evaluating the block is returned, otherwise, the flattened JSON-LD document
    # @see http://json-ld.org/spec/latest/json-ld-api/#framing-algorithm
    def self.flatten(input, context, options = {})
      flattened = []
      options = {compactToRelative:  true}.merge(options)

      # Expand input to simplify processing
      expanded_input = options[:expanded] ? input : API.expand(input, options) do |result, base_iri|
        options[:base] ||= base_iri if options[:compactToRelative]
        result
      end

      # Initialize input using
      API.new(expanded_input, context, options.merge(no_default_base: true)) do
        log_debug(".flatten") {"expanded input: #{value.to_json(JSON_STATE) rescue 'malformed json'}"}

        # Initialize node map to a JSON object consisting of a single member whose key is @default and whose value is an empty JSON object.
        graph_maps = {'@default' => {}}
        create_node_map(value, graph_maps)

        default_graph = graph_maps['@default']
        graph_maps.keys.kw_sort.each do |graph_name|
          next if graph_name == '@default'

          graph = graph_maps[graph_name]
          entry = default_graph[graph_name] ||= {'@id' => graph_name}
          nodes = entry['@graph'] ||= []
          graph.keys.kw_sort.each do |id|
            nodes << graph[id] unless node_reference?(graph[id])
          end
        end
        default_graph.keys.kw_sort.each do |id|
          flattened << default_graph[id] unless node_reference?(default_graph[id])
        end

        if context && !flattened.empty?
          # Otherwise, return the result of compacting flattened according the Compaction algorithm passing context ensuring that the compaction result uses the @graph keyword (or its alias) at the top-level, even if the context is empty or if there is only one element to put in the @graph array. This ensures that the returned document has a deterministic structure.
          compacted = compact(flattened)
          compacted = [compacted] unless compacted.is_a?(Array)
          kwgraph = self.context.compact_iri('@graph', quiet: true)
          flattened = self.context.serialize.merge(kwgraph => compacted)
        end
      end

      block_given? ? yield(flattened) : flattened
    end

    ##
    # Frames the given input using the frame according to the steps in the Framing Algorithm. The input is used to build the framed output and is returned if there are no errors. If there are no matches for the frame, null must be returned. Exceptions must be thrown if there are errors.
    #
    # The resulting `Array` is either returned, or yielded if a block is given.
    #
    # @param [String, #read, Hash, Array] input
    #   The JSON-LD object to copy and perform the framing on.
    # @param [String, #read, Hash, Array] frame
    #   The frame to use when re-arranging the data.
    # @option options (see #initialize)
    # @option options ['@last', '@always', '@never', '@link'] :embed ('@last')
    #   a flag specifying that objects should be directly embedded in the output, instead of being referred to by their IRI.
    # @option options [Boolean] :explicit (false)
    #   a flag specifying that for properties to be included in the output, they must be explicitly declared in the framing context.
    # @option options [Boolean] :requireAll (true)
    #   A flag specifying that all properties present in the input frame must either have a default value or be present in the JSON-LD input for the frame to match.
    # @option options [Boolean] :omitDefault (false)
    #   a flag specifying that properties that are missing from the JSON-LD input should be omitted from the output.
    # @option options [Boolean] :expanded Input is already expanded
    # @option options [Boolean] :pruneBlankNodeIdentifiers (true) removes blank node identifiers that are only used once.
    # @yield jsonld
    # @yieldparam [Hash] jsonld
    #   The framed JSON-LD document
    # @yieldreturn [Object] returned object
    # @return [Object, Hash]
    #   If a block is given, the result of evaluating the block is returned, otherwise, the framed JSON-LD document
    # @raise [InvalidFrame]
    # @see http://json-ld.org/spec/latest/json-ld-api/#framing-algorithm
    def self.frame(input, frame, options = {})
      result = nil
      options = {
        base:                       (input if input.is_a?(String)),
        compactArrays:              true,
        compactToRelative:          true,
        embed:                      '@last',
        explicit:                   false,
        requireAll:                 true,
        omitDefault:                false,
        pruneBlankNodeIdentifiers:  true,
        documentLoader:             method(:documentLoader)
      }.merge(options)

      framing_state = {
        graphMap:     {},
        graphStack:   [],
        subjectStack: [],
        link:         {},
      }

      # de-reference frame to create the framing object
      frame = case frame
      when Hash then frame.dup
      when IO, StringIO then MultiJson.load(frame.read)
      when String
        remote_doc = options[:documentLoader].call(frame)
        case remote_doc.document
        when String then MultiJson.load(remote_doc.document)
        else remote_doc.document
        end
      end

      # Expand input to simplify processing
      expanded_input = options[:expanded] ? input : API.expand(input, options) do |result, base_iri|
        options[:base] ||= base_iri if options[:compactToRelative]
        result
      end

      # Expand frame to simplify processing
      expanded_frame = API.expand(frame, options.merge(processingMode: "json-ld-1.1-expand-frame"))

      # Initialize input using frame as context
      API.new(expanded_input, nil, options.merge(no_default_base: true)) do
        log_debug(".frame") {"expanded frame: #{expanded_frame.to_json(JSON_STATE) rescue 'malformed json'}"}

        # Get framing nodes from expanded input, replacing Blank Node identifiers as necessary
        create_node_map(value, framing_state[:graphMap], graph: '@default')

        frame_keys = frame.keys.map {|k| context.expand_iri(k, vocab: true, quiet: true)}
        if frame_keys.include?('@graph')
          # If frame contains @graph, it matches the default graph.
          framing_state[:graph] = '@default'
        else
          # If frame does not contain @graph used the merged graph.
          framing_state[:graph] = '@merged'
          framing_state[:link]['@merged'] = {}
          framing_state[:graphMap]['@merged'] = merge_node_map_graphs(framing_state[:graphMap])
        end

        framing_state[:subjects] = framing_state[:graphMap][framing_state[:graph]]

        result = []
        frame(framing_state, framing_state[:subjects].keys.sort, (expanded_frame.first || {}), options.merge(parent: result))

        # Count blank node identifiers used in the document, if pruning
        bnodes_to_clear = if options[:pruneBlankNodeIdentifiers]
          count_blank_node_identifiers(result).collect {|k, v| k if v == 1}.compact
        end

        # Initalize context from frame
        @context = @context.parse(frame['@context'])
        # Compact result
        compacted = compact(result)
        compacted = [compacted] unless compacted.is_a?(Array)

        # Add the given context to the output
        kwgraph = context.compact_iri('@graph', quiet: true)
        result = context.serialize.merge({kwgraph => compacted})
        log_debug(".frame") {"after compact: #{result.to_json(JSON_STATE) rescue 'malformed json'}"}
        result = cleanup_preserve(result, bnodes_to_clear || [])
      end

      block_given? ? yield(result) : result
    end

    ##
    # Processes the input according to the RDF Conversion Algorithm, calling the provided callback for each triple generated.
    #
    # @param [String, #read, Hash, Array] input
    #   The JSON-LD object to process when outputting statements.
    # @option options (see #initialize)
    # @option options [Boolean] :produceGeneralizedRdf (false)
    #   If true, output will include statements having blank node predicates, otherwise they are dropped.
    # @option options [Boolean] :expanded Input is already expanded
    # @raise [JsonLdError]
    # @yield statement
    # @yieldparam [RDF::Statement] statement
    # @return [RDF::Enumerable] set of statements, unless a block is given.
    def self.toRdf(input, options = {}, &block)
      unless block_given?
        results = []
        results.extend(RDF::Enumerable)
        self.toRdf(input, options) do |stmt|
          results << stmt
        end
        return results
      end

      # Expand input to simplify processing
      expanded_input = options[:expanded] ? input : API.expand(input, options.merge(ordered: false))

      API.new(expanded_input, nil, options) do
        # 1) Perform the Expansion Algorithm on the JSON-LD input.
        #    This removes any existing context to allow the given context to be cleanly applied.
        log_debug(".toRdf") {"expanded input: #{expanded_input.to_json(JSON_STATE) rescue 'malformed json'}"}

        # Recurse through input
        expanded_input.each do |node|
          item_to_rdf(node) do |statement|
            next if statement.predicate.node? && !options[:produceGeneralizedRdf]

            # Drop results with relative IRIs
            relative = statement.to_a.any? do |r|
              case r
              when RDF::URI
                r.relative?
              when RDF::Literal
                r.has_datatype? && r.datatype.relative?
              else
                false
              end
            end
            if relative
              log_debug(".toRdf") {"drop statement with relative IRIs: #{statement.to_ntriples}"}
              next
            end

            yield statement
          end
        end
      end
    end
    
    ##
    # Take an ordered list of RDF::Statements and turn them into a JSON-LD document.
    #
    # The resulting `Array` is either returned or yielded, if a block is given.
    #
    # @param [Array<RDF::Statement>] input
    # @param  [Hash{Symbol => Object}] options
    # @option options (see #initialize)
    # @option options [Boolean] :useRdfType (false)
    #   If set to `true`, the JSON-LD processor will treat `rdf:type` like a normal property instead of using `@type`.
    # @option options [Boolean] :useNativeTypes (false) use native representations
    # @yield jsonld
    # @yieldparam [Hash] jsonld
    #   The JSON-LD document in expanded form
    # @yieldreturn [Object] returned object
    # @return [Object, Hash]
    #   If a block is given, the result of evaluating the block is returned, otherwise, the expanded JSON-LD document
    def self.fromRdf(input, options = {}, &block)
      useRdfType = options.fetch(:useRdfType, false)
      useNativeTypes = options.fetch(:useNativeTypes, false)
      result = nil

      API.new(nil, nil, options) do |api|
        result = api.from_statements(input, useRdfType: useRdfType, useNativeTypes: useNativeTypes)
      end

      block_given? ? yield(result) : result
    end

    ##
    # Default document loader.
    # @param [RDF::URI, String] url
    # @param [Hash<Symbol => Object>] options
    # @option options [Boolean] :validate
    #   Allow only appropriate content types
    # @yield remote_document
    # @yieldparam [RemoteDocument] remote_document
    # @yieldreturn [Object] returned object
    # @return [Object, RemoteDocument]
    #   If a block is given, the result of evaluating the block is returned, otherwise, the retrieved remote document and context information unless block given
    # @raise [JsonLdError]
    def self.documentLoader(url, options = {})
      options = OPEN_OPTS.merge(options)
      RDF::Util::File.open_file(url, options) do |remote_doc|
        content_type = remote_doc.content_type if remote_doc.respond_to?(:content_type)
        # If the passed input is a DOMString representing the IRI of a remote document, dereference it. If the retrieved document's content type is neither application/json, nor application/ld+json, nor any other media type using a +json suffix as defined in [RFC6839], reject the promise passing an loading document failed error.
        if content_type && options[:validate]
          main, sub = content_type.split("/")
          raise JSON::LD::JsonLdError::LoadingDocumentFailed, "url: #{url}, content_type: #{content_type}" if
            main != 'application' ||
            sub !~ /^(.*\+)?json$/
        end

        # If the input has been retrieved, the response has an HTTP Link Header [RFC5988] using the http://www.w3.org/ns/json-ld#context link relation and a content type of application/json or any media type with a +json suffix as defined in [RFC6839] except application/ld+json, update the active context using the Context Processing algorithm, passing the context referenced in the HTTP Link Header as local context. The HTTP Link Header is ignored for documents served as application/ld+json If multiple HTTP Link Headers using the http://www.w3.org/ns/json-ld#context link relation are found, the promise is rejected with a JsonLdError whose code is set to multiple context link headers and processing is terminated.
        contextUrl = unless content_type.nil? || content_type.start_with?("application/ld+json")
          # Get context link(s)
          # Note, we can't simply use #find_link, as we need to detect multiple
          links = remote_doc.links.links.select do |link|
            link.attr_pairs.include?(%w(rel http://www.w3.org/ns/json-ld#context))
          end
          raise JSON::LD::JsonLdError::MultipleContextLinkHeaders,
            "expected at most 1 Link header with rel=jsonld:context, got #{links.length}" if links.length > 1
          Array(links.first).first
        end

        doc_uri = remote_doc.base_uri rescue url
        doc = RemoteDocument.new(doc_uri, remote_doc.read, contextUrl)
        block_given? ? yield(doc) : doc
      end
    rescue IOError => e
      raise JSON::LD::JsonLdError::LoadingDocumentFailed, e.message
    end

    # Add class method aliases for backwards compatibility
    class << self
      alias :toRDF :toRdf
      alias :fromRDF :fromRdf
    end

    private
    def validate_input(input)
      return unless defined?(JsonLint)
      jsonlint = JsonLint::Linter.new
      input = StringIO.new(input) unless input.respond_to?(:read)
      unless jsonlint.check_stream(input)
        raise JsonLdError::LoadingDocumentFailed, jsonlint.errors[''].join("\n")
      end
      input.rewind
    end

    ##
    # A {RemoteDocument} is returned from a {documentLoader}.
    class RemoteDocument
      # @return [String] URL of the loaded document, after redirects
      attr_reader :documentUrl

      # @return [String, Array<Hash>, Hash]
      #   The retrieved document, either as raw text or parsed JSON
      attr_reader :document

      # @return [String]
      #   The URL of a remote context as specified by an HTTP Link header with rel=`http://www.w3.org/ns/json-ld#context`
      attr_accessor :contextUrl

      # @param [String] url URL of the loaded document, after redirects
      # @param [String, Array<Hash>, Hash] document
      #   The retrieved document, either as raw text or parsed JSON
      # @param [String] context_url (nil)
      #   The URL of a remote context as specified by an HTTP Link header with rel=`http://www.w3.org/ns/json-ld#context`
      def initialize(url, document, context_url = nil)
        @documentUrl = url
        @document = document
        @contextUrl = context_url
      end
    end
  end
end

