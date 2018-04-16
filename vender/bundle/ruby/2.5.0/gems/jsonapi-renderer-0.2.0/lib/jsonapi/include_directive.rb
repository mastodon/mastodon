require 'jsonapi/include_directive/parser'

module JSONAPI
  # Represent a recursive set of include directives
  # (c.f. http://jsonapi.org/format/#fetching-includes)
  #
  # Addition to the spec: two wildcards, namely '*' and '**'.
  # The former stands for any one level of relationship, and the latter stands
  # for any number of levels of relationships.
  # @example 'posts.*' # => Include related posts, and all the included posts'
  #   related resources.
  # @example 'posts.**' # => Include related posts, and all the included
  #   posts' related resources, and their related resources, recursively.
  class IncludeDirective
    # @param include_args (see Parser.parse_include_args)
    def initialize(include_args, options = {})
      include_hash = Parser.parse_include_args(include_args)
      @hash = include_hash.each_with_object({}) do |(key, value), hash|
        hash[key] = self.class.new(value, options)
      end
      @options = options
    end

    # @param key [Symbol, String]
    def key?(key)
      @hash.key?(key.to_sym) ||
        (@options[:allow_wildcard] && (@hash.key?(:*) || @hash.key?(:**)))
    end

    # @return [Array<Symbol>]
    def keys
      @hash.keys
    end

    # @param key [Symbol, String]
    # @return [IncludeDirective, nil]
    def [](key)
      case
      when @hash.key?(key.to_sym)
        @hash[key.to_sym]
      when @options[:allow_wildcard] && @hash.key?(:**)
        self.class.new({ :** => {} }, @options)
      when @options[:allow_wildcard] && @hash.key?(:*)
        @hash[:*]
      end
    end

    # @return [Hash{Symbol => Hash}]
    def to_hash
      @hash.each_with_object({}) do |(key, value), hash|
        hash[key] = value.to_hash
      end
    end

    # @return [String]
    def to_string
      string_array = @hash.map do |(key, value)|
        string_value = value.to_string
        if string_value == ''
          key.to_s
        else
          string_value
            .split(',')
            .map { |x| key.to_s + '.' + x }
            .join(',')
        end
      end

      string_array.join(',')
    end
  end
end
