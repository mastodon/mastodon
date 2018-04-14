require 'set'

module SidekiqScheduler
  module Utils

    # Stringify keys belonging to a hash.
    #
    # Also stringifies nested keys and keys of hashes inside arrays, and sets
    #
    # @param [Object] object
    #
    # @return [Object]
    def self.stringify_keys(object)
      if object.is_a?(Hash)
        Hash[[*object.map { |k, v| [k.to_s, stringify_keys(v) ]} ]]

      elsif object.is_a?(Array) || object.is_a?(Set)
        object.map { |v| stringify_keys(v) }

      else
        object
      end
    end

    # Symbolize keys belonging to a hash.
    #
    # Also symbolizes nested keys and keys of hashes inside arrays, and sets
    #
    # @param [Object] object
    #
    # @return [Object]
    def self.symbolize_keys(object)
      if object.is_a?(Hash)
        Hash[[*object.map { |k, v| [k.to_sym, symbolize_keys(v) ]} ]]

      elsif object.is_a?(Array) || object.is_a?(Set)
        object.map { |v| symbolize_keys(v) }

      else
        object
      end
    end
  end
end
