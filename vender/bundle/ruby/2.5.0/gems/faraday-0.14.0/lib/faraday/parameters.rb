require "forwardable"

module Faraday
  module NestedParamsEncoder
    class << self
      extend Forwardable
      def_delegators :'Faraday::Utils', :escape, :unescape
    end

    def self.encode(params)
      return nil if params == nil

      if !params.is_a?(Array)
        if !params.respond_to?(:to_hash)
          raise TypeError,
            "Can't convert #{params.class} into Hash."
        end
        params = params.to_hash
        params = params.map do |key, value|
          key = key.to_s if key.kind_of?(Symbol)
          [key, value]
        end
        # Useful default for OAuth and caching.
        # Only to be used for non-Array inputs. Arrays should preserve order.
        params.sort!
      end

      # Helper lambda
      to_query = lambda do |parent, value|
        if value.is_a?(Hash)
          value = value.map do |key, val|
            key = escape(key)
            [key, val]
          end
          value.sort!
          buffer = ""
          value.each do |key, val|
            new_parent = "#{parent}%5B#{key}%5D"
            buffer << "#{to_query.call(new_parent, val)}&"
          end
          return buffer.chop
        elsif value.is_a?(Array)
          buffer = ""
          value.each_with_index do |val, i|
            new_parent = "#{parent}%5B%5D"
            buffer << "#{to_query.call(new_parent, val)}&"
          end
          return buffer.chop
        elsif value.nil?
          return parent
        else
          encoded_value = escape(value)
          return "#{parent}=#{encoded_value}"
        end
      end

      # The params have form [['key1', 'value1'], ['key2', 'value2']].
      buffer = ''
      params.each do |parent, value|
        encoded_parent = escape(parent)
        buffer << "#{to_query.call(encoded_parent, value)}&"
      end
      return buffer.chop
    end

    def self.decode(query)
      return nil if query == nil

      params = {}
      query.split("&").each do |pair|
        next if pair.empty?
        key, value = pair.split("=", 2)
        key = unescape(key)
        value = unescape(value.gsub(/\+/, ' ')) if value

        subkeys = key.scan(/[^\[\]]+(?:\]?\[\])?/)
        context = params
        subkeys.each_with_index do |subkey, i|
          is_array = subkey =~ /[\[\]]+\Z/
          subkey = $` if is_array
          last_subkey = i == subkeys.length - 1

          if !last_subkey || is_array
            value_type = is_array ? Array : Hash
            if context[subkey] && !context[subkey].is_a?(value_type)
              raise TypeError, "expected %s (got %s) for param `%s'" % [
                value_type.name,
                context[subkey].class.name,
                subkey
              ]
            end
            context = (context[subkey] ||= value_type.new)
          end

          if context.is_a?(Array) && !is_array
            if !context.last.is_a?(Hash) || context.last.has_key?(subkey)
              context << {}
            end
            context = context.last
          end

          if last_subkey
            if is_array
              context << value
            else
              context[subkey] = value
            end
          end
        end
      end

      dehash(params, 0)
    end

    # Internal: convert a nested hash with purely numeric keys into an array.
    # FIXME: this is not compatible with Rack::Utils.parse_nested_query
    def self.dehash(hash, depth)
      hash.each do |key, value|
        hash[key] = dehash(value, depth + 1) if value.kind_of?(Hash)
      end

      if depth > 0 && !hash.empty? && hash.keys.all? { |k| k =~ /^\d+$/ }
        hash.keys.sort.inject([]) { |all, key| all << hash[key] }
      else
        hash
      end
    end
  end

  module FlatParamsEncoder
    class << self
      extend Forwardable
      def_delegators :'Faraday::Utils', :escape, :unescape
    end

    def self.encode(params)
      return nil if params == nil

      if !params.is_a?(Array)
        if !params.respond_to?(:to_hash)
          raise TypeError,
            "Can't convert #{params.class} into Hash."
        end
        params = params.to_hash
        params = params.map do |key, value|
          key = key.to_s if key.kind_of?(Symbol)
          [key, value]
        end
        # Useful default for OAuth and caching.
        # Only to be used for non-Array inputs. Arrays should preserve order.
        params.sort!
      end

      # The params have form [['key1', 'value1'], ['key2', 'value2']].
      buffer = ''
      params.each do |key, value|
        encoded_key = escape(key)
        value = value.to_s if value == true || value == false
        if value == nil
          buffer << "#{encoded_key}&"
        elsif value.kind_of?(Array)
          value.each do |sub_value|
            encoded_value = escape(sub_value)
            buffer << "#{encoded_key}=#{encoded_value}&"
          end
        else
          encoded_value = escape(value)
          buffer << "#{encoded_key}=#{encoded_value}&"
        end
      end
      return buffer.chop
    end

    def self.decode(query)
      empty_accumulator = {}
      return nil if query == nil
      split_query = (query.split('&').map do |pair|
        pair.split('=', 2) if pair && !pair.empty?
      end).compact
      return split_query.inject(empty_accumulator.dup) do |accu, pair|
        pair[0] = unescape(pair[0])
        pair[1] = true if pair[1].nil?
        if pair[1].respond_to?(:to_str)
          pair[1] = unescape(pair[1].to_str.gsub(/\+/, " "))
        end
        if accu[pair[0]].kind_of?(Array)
          accu[pair[0]] << pair[1]
        elsif accu[pair[0]]
          accu[pair[0]] = [accu[pair[0]], pair[1]]
        else
          accu[pair[0]] = pair[1]
        end
        accu
      end
    end
  end
end
