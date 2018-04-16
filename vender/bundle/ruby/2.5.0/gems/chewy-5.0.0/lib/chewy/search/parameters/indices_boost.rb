require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # Stores provided values as a string-float hash, but also takes
      # keys order into account.
      #
      # @see Chewy::Search::Request#indices_boost
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-index-boost.html
      class IndicesBoost < Storage
        # Merges two hashes, but puts keys from the second hash
        # at the end of the result hash.
        #
        # @see Chewy::Search::Parameters::Storage#update!
        # @param other_value [{String, Symbol => String, Integer, Float}] any acceptable storage value
        # @return [{String => Float}] updated value
        def update!(other_value)
          new_value = normalize(other_value)
          value.except!(*new_value.keys).merge!(new_value)
        end

        # Renders the value hash as an array of hashes for
        # each key-value pair.
        #
        # @see Chewy::Search::Parameters::Storage#render
        # @return [Array<{String => Float}>] updated value
        def render
          {self.class.param_name => value.map { |k, v| {k => v} }} if value.present?
        end

        # Comparison also reqires additional logic. Since indexes boost
        # is sensitive to the order index templates are provided, we have
        # to compare stored hashes keys as well.
        #
        # @see Chewy::Search::Parameters::Storage#==
        # @return [true, false]
        def ==(other)
          super && value.keys == other.value.keys
        end

      private

        def normalize(value)
          value = (value || {}).stringify_keys
          value.each { |k, v| value[k] = Float(v) }
          value
        end
      end
    end
  end
end
