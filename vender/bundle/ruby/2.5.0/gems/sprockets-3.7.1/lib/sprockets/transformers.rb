require 'sprockets/http_utils'
require 'sprockets/processor_utils'
require 'sprockets/utils'

module Sprockets
  module Transformers
    include HTTPUtils, ProcessorUtils, Utils

    # Public: Two level mapping of a source mime type to a target mime type.
    #
    #   environment.transformers
    #   # => { 'text/coffeescript' => {
    #            'application/javascript' => ConvertCoffeeScriptToJavaScript
    #          }
    #        }
    #
    def transformers
      config[:transformers]
    end

    # Public: Register a transformer from and to a mime type.
    #
    # from - String mime type
    # to   - String mime type
    # proc - Callable block that accepts an input Hash.
    #
    # Examples
    #
    #   register_transformer 'text/coffeescript', 'application/javascript',
    #     ConvertCoffeeScriptToJavaScript
    #
    #   register_transformer 'image/svg+xml', 'image/png', ConvertSvgToPng
    #
    # Returns nothing.
    def register_transformer(from, to, proc)
      self.config = hash_reassoc(config, :registered_transformers, from) do |transformers|
        transformers.merge(to => proc)
      end
      compute_transformers!
    end

    # Internal: Resolve target mime type that the source type should be
    # transformed to.
    #
    # type   - String from mime type
    # accept - String accept type list (default: '*/*')
    #
    # Examples
    #
    #   resolve_transform_type('text/plain', 'text/plain')
    #   # => 'text/plain'
    #
    #   resolve_transform_type('image/svg+xml', 'image/png, image/*')
    #   # => 'image/png'
    #
    #   resolve_transform_type('text/css', 'image/png')
    #   # => nil
    #
    # Returns String mime type or nil is no type satisfied the accept value.
    def resolve_transform_type(type, accept)
      find_best_mime_type_match(accept || '*/*', [type].compact + config[:transformers][type].keys)
    end

    # Internal: Expand accept type list to include possible transformed types.
    #
    # parsed_accepts - Array of accept q values
    #
    # Examples
    #
    #   expand_transform_accepts([['application/javascript', 1.0]])
    #   # => [['application/javascript', 1.0], ['text/coffeescript', 0.8]]
    #
    # Returns an expanded Array of q values.
    def expand_transform_accepts(parsed_accepts)
      accepts = []
      parsed_accepts.each do |(type, q)|
        accepts.push([type, q])
        config[:inverted_transformers][type].each do |subtype|
          accepts.push([subtype, q * 0.8])
        end
      end
      accepts
    end

    # Internal: Compose multiple transformer steps into a single processor
    # function.
    #
    # transformers - Two level Hash of a source mime type to a target mime type
    # types - Array of mime type steps
    #
    # Returns Processor.
    def compose_transformers(transformers, types)
      if types.length < 2
        raise ArgumentError, "too few transform types: #{types.inspect}"
      end

      i = 0
      processors = []

      loop do
        src = types[i]
        dst = types[i+1]
        break unless src && dst

        unless processor = transformers[src][dst]
          raise ArgumentError, "missing transformer for type: #{src} to #{dst}"
        end
        processors.concat config[:postprocessors][src]
        processors << processor
        processors.concat config[:preprocessors][dst]

        i += 1
      end

      if processors.size > 1
        compose_processors(*processors.reverse)
      elsif processors.size == 1
        processors.first
      end
    end

    private
      def compute_transformers!
        registered_transformers = self.config[:registered_transformers]
        transformers = Hash.new { {} }
        inverted_transformers = Hash.new { Set.new }

        registered_transformers.keys.flat_map do |key|
          dfs_paths([key]) { |k| registered_transformers[k].keys }
        end.each do |types|
          src, dst = types.first, types.last
          processor = compose_transformers(registered_transformers, types)

          transformers[src] = {} unless transformers.key?(src)
          transformers[src][dst] = processor

          inverted_transformers[dst] = Set.new unless inverted_transformers.key?(dst)
          inverted_transformers[dst] << src
        end

        self.config = hash_reassoc(config, :transformers) { transformers }
        self.config = hash_reassoc(config, :inverted_transformers) { inverted_transformers }
      end
  end
end
