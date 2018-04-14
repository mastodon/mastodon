module MultiJson
  module ConvertibleHashKeys
  private

    def symbolize_keys(hash)
      prepare_hash(hash) do |key|
        key.respond_to?(:to_sym) ? key.to_sym : key
      end
    end

    def stringify_keys(hash)
      prepare_hash(hash) do |key|
        key.respond_to?(:to_s) ? key.to_s : key
      end
    end

    def prepare_hash(hash, &key_modifier)
      return hash unless block_given?
      case hash
      when Array
        hash.map do |value|
          prepare_hash(value, &key_modifier)
        end
      when Hash
        hash.inject({}) do |result, (key, value)|
          new_key   = key_modifier.call(key)
          new_value = prepare_hash(value, &key_modifier)
          result.merge! new_key => new_value
        end
      when String, Numeric, true, false, nil
        hash
      else
        if hash.respond_to?(:to_json)
          hash
        elsif hash.respond_to?(:to_s)
          hash.to_s
        else
          hash
        end
      end
    end
  end
end
