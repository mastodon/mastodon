module Seahorse
  module Client
    module Http

      # Provides a Hash-like interface for HTTP headers.  Header names
      # are treated indifferently as lower-cased strings.  Header values
      # are cast to strings.
      #
      #     headers = Http::Headers.new
      #     headers['Content-Length'] = 100
      #     headers[:Authorization] = 'Abc'
      #
      #     headers.keys
      #     #=> ['content-length', 'authorization']
      #
      #     headers.values
      #     #=> ['100', 'Abc']
      #
      # You can get the header values as a vanilla hash by calling {#to_h}:
      #
      #     headers.to_h
      #     #=> { 'content-length' => '100', 'authorization' => 'Abc' }
      #
      class Headers

        include Enumerable

        # @api private
        def initialize(headers = {})
          @data = {}
          headers.each_pair do |key, value|
            self[key] = value
          end
        end

        # @param [String] key
        # @return [String]
        def [](key)
          @data[key.to_s.downcase]
        end

        # @param [String] key
        # @param [String] value
        def []=(key, value)
          @data[key.to_s.downcase] = value.to_s
        end

        # @param [Hash] headers
        # @return [Headers]
        def update(headers)
          headers.each_pair do |k, v|
            self[k] = v
          end
          self
        end

        # @param [String] key
        def delete(key)
          @data.delete(key.to_s.downcase)
        end

        def clear
          @data = {}
        end

        # @return [Array<String>]
        def keys
          @data.keys
        end

        # @return [Array<String>]
        def values
          @data.values
        end

        # @return [Array<String>]
        def values_at(*keys)
          @data.values_at(*keys.map{ |key| key.to_s.downcase })
        end

        # @yield [key, value]
        # @yieldparam [String] key
        # @yieldparam [String] value
        # @return [nil]
        def each(&block)
          if block_given?
            @data.each_pair do |key, value|
              yield(key, value)
            end
            nil
          else
            @data.enum_for(:each)
          end
        end
        alias each_pair each

        # @return [Boolean] Returns `true` if the header is set.
        def key?(key)
          @data.key?(key.to_s.downcase)
        end
        alias has_key? key?
        alias include? key?

        # @return [Hash]
        def to_hash
          @data.dup
        end
        alias to_h to_hash

        # @api private
        def inspect
          @data.inspect
        end

      end
    end
  end
end
