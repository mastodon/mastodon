require 'thread'

module Faraday
  module Utils
    extend self

    # Adapted from Rack::Utils::HeaderHash
    class Headers < ::Hash
      def self.from(value)
        new(value)
      end

      def self.allocate
        new_self = super
        new_self.initialize_names
        new_self
      end

      def initialize(hash = nil)
        super()
        @names = {}
        self.update(hash || {})
      end

      def initialize_names
        @names = {}
      end

      # on dup/clone, we need to duplicate @names hash
      def initialize_copy(other)
        super
        @names = other.names.dup
      end

      # need to synchronize concurrent writes to the shared KeyMap
      keymap_mutex = Mutex.new

      # symbol -> string mapper + cache
      KeyMap = Hash.new do |map, key|
        value = if key.respond_to?(:to_str)
          key
        else
          key.to_s.split('_').            # :user_agent => %w(user agent)
            each { |w| w.capitalize! }.   # => %w(User Agent)
            join('-')                     # => "User-Agent"
        end
        keymap_mutex.synchronize { map[key] = value }
      end
      KeyMap[:etag] = "ETag"

      def [](k)
        k = KeyMap[k]
        super(k) || super(@names[k.downcase])
      end

      def []=(k, v)
        k = KeyMap[k]
        k = (@names[k.downcase] ||= k)
        # join multiple values with a comma
        v = v.to_ary.join(', ') if v.respond_to? :to_ary
        super(k, v)
      end

      def fetch(k, *args, &block)
        k = KeyMap[k]
        key = @names.fetch(k.downcase, k)
        super(key, *args, &block)
      end

      def delete(k)
        k = KeyMap[k]
        if k = @names[k.downcase]
          @names.delete k.downcase
          super(k)
        end
      end

      def include?(k)
        @names.include? k.downcase
      end

      alias_method :has_key?, :include?
      alias_method :member?, :include?
      alias_method :key?, :include?

      def merge!(other)
        other.each { |k, v| self[k] = v }
        self
      end
      alias_method :update, :merge!

      def merge(other)
        hash = dup
        hash.merge! other
      end

      def replace(other)
        clear
        @names.clear
        self.update other
        self
      end

      def to_hash() ::Hash.new.update(self) end

      def parse(header_string)
        return unless header_string && !header_string.empty?

        headers = header_string.split(/\r\n/)

        # Find the last set of response headers.
        start_index = headers.rindex { |x| x.match(/^HTTP\//) } || 0
        last_response = headers.slice(start_index, headers.size)

        last_response.
          tap  { |a| a.shift if a.first.index('HTTP/') == 0 }. # drop the HTTP status line
          map  { |h| h.split(/:\s*/, 2) }.reject { |p| p[0].nil? }. # split key and value, ignore blank lines
          each { |key, value|
            # join multiple values with a comma
            if self[key]
              self[key] << ', ' << value
            else
              self[key] = value
            end
          }
      end

      protected

      def names
        @names
      end
    end

    # hash with stringified keys
    class ParamsHash < Hash
      def [](key)
        super(convert_key(key))
      end

      def []=(key, value)
        super(convert_key(key), value)
      end

      def delete(key)
        super(convert_key(key))
      end

      def include?(key)
        super(convert_key(key))
      end

      alias_method :has_key?, :include?
      alias_method :member?, :include?
      alias_method :key?, :include?

      def update(params)
        params.each do |key, value|
          self[key] = value
        end
        self
      end
      alias_method :merge!, :update

      def merge(params)
        dup.update(params)
      end

      def replace(other)
        clear
        update(other)
      end

      def merge_query(query, encoder = nil)
        if query && !query.empty?
          update((encoder || Utils.default_params_encoder).decode(query))
        end
        self
      end

      def to_query(encoder = nil)
        (encoder || Utils.default_params_encoder).encode(self)
      end

      private

      def convert_key(key)
        key.to_s
      end
    end

    def build_query(params)
      FlatParamsEncoder.encode(params)
    end

    def build_nested_query(params)
      NestedParamsEncoder.encode(params)
    end

    ESCAPE_RE = /[^a-zA-Z0-9 .~_-]/

    def escape(s)
      s.to_s.gsub(ESCAPE_RE) {|match|
        '%' + match.unpack('H2' * match.bytesize).join('%').upcase
      }.tr(' ', '+')
    end

    def unescape(s) CGI.unescape s.to_s end

    DEFAULT_SEP = /[&;] */n

    # Adapted from Rack
    def parse_query(query)
      FlatParamsEncoder.decode(query)
    end

    def parse_nested_query(query)
      NestedParamsEncoder.decode(query)
    end

    def default_params_encoder
      @default_params_encoder ||= NestedParamsEncoder
    end

    class << self
      attr_writer :default_params_encoder
    end

    # Stolen from Rack
    def normalize_params(params, name, v = nil)
      name =~ %r(\A[\[\]]*([^\[\]]+)\]*)
      k = $1 || ''
      after = $' || ''

      return if k.empty?

      if after == ""
        if params[k]
          params[k] = Array[params[k]] unless params[k].kind_of?(Array)
          params[k] << v
        else
          params[k] = v
        end
      elsif after == "[]"
        params[k] ||= []
        raise TypeError, "expected Array (got #{params[k].class.name}) for param `#{k}'" unless params[k].is_a?(Array)
        params[k] << v
      elsif after =~ %r(^\[\]\[([^\[\]]+)\]$) || after =~ %r(^\[\](.+)$)
        child_key = $1
        params[k] ||= []
        raise TypeError, "expected Array (got #{params[k].class.name}) for param `#{k}'" unless params[k].is_a?(Array)
        if params[k].last.is_a?(Hash) && !params[k].last.key?(child_key)
          normalize_params(params[k].last, child_key, v)
        else
          params[k] << normalize_params({}, child_key, v)
        end
      else
        params[k] ||= {}
        raise TypeError, "expected Hash (got #{params[k].class.name}) for param `#{k}'" unless params[k].is_a?(Hash)
        params[k] = normalize_params(params[k], after, v)
      end

      return params
    end

    # Normalize URI() behavior across Ruby versions
    #
    # url - A String or URI.
    #
    # Returns a parsed URI.
    def URI(url)
      if url.respond_to?(:host)
        url
      elsif url.respond_to?(:to_str)
        default_uri_parser.call(url)
      else
        raise ArgumentError, "bad argument (expected URI object or URI string)"
      end
    end

    def default_uri_parser
      @default_uri_parser ||= begin
        require 'uri'
        Kernel.method(:URI)
      end
    end

    def default_uri_parser=(parser)
      @default_uri_parser = if parser.respond_to?(:call) || parser.nil?
        parser
      else
        parser.method(:parse)
      end
    end

    # Receives a String or URI and returns just the path with the query string sorted.
    def normalize_path(url)
      url = URI(url)
      (url.path.start_with?('/') ? url.path : '/' + url.path) +
      (url.query ? "?#{sort_query_params(url.query)}" : "")
    end

    # Recursive hash update
    def deep_merge!(target, hash)
      hash.each do |key, value|
        if Hash === value and Hash === target[key]
          target[key] = deep_merge(target[key], value)
        else
          target[key] = value
        end
      end
      target
    end

    # Recursive hash merge
    def deep_merge(source, hash)
      deep_merge!(source.dup, hash)
    end

    protected

    def sort_query_params(query)
      query.split('&').sort.join('&')
    end
  end
end
