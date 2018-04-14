require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # This storage handles either an array of strings/symbols
      # or a hash with `includes` and `excludes` keys and
      # arrays of strings/symbols as values. Any other key is ignored.
      #
      # @see Chewy::Search::Request#source
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-source-filtering.html
      class Source < Storage
        self.param_name = :_source

        # If array or simple string/symbol is passed, it is treated
        # as a part of `includes` array and gets concatenated with it.
        # In case of hash, respective values are concatenated as well.
        #
        # @see Chewy::Search::Parameters::Storage#update!
        # @param other_value [true, false, {Symbol => Array<String, Symbol>, String, Symbol}, Array<String, Symbol>, String, Symbol] any acceptable storage value
        # @return [{Symbol => Array<String>, true, false}] updated value
        def update!(other_value)
          new_value = normalize(other_value)
          new_value[:includes] = value[:includes] | new_value[:includes]
          new_value[:excludes] = value[:excludes] | new_value[:excludes]
          @value = new_value
        end

        # Requires an additional logic to merge `enabled` value.
        #
        # @see Chewy::Search::Parameters::Storage#merge!
        # @param other [Chewy::Search::Parameters::Storage] other storage
        # @return [{Symbol => Array<String>, true, false}] updated value
        def merge!(other)
          super
          update!(other.value[:enabled])
        end

        # Renders `false` if `source` is disabled, otherwise renders the
        # contents of `includes` value or even the entire hash if `excludes`
        # also specified.
        #
        # @see Chewy::Search::Parameters::Storage#render
        # @return [{Symbol => Object}, nil] rendered value with the parameter name
        def render
          if !value[:enabled]
            {self.class.param_name => false}
          elsif value[:excludes].present?
            {self.class.param_name => value.slice(:includes, :excludes).reject { |_, v| v.blank? }}
          elsif value[:includes].present?
            {self.class.param_name => value[:includes]}
          end
        end

      private

        def normalize(value)
          includes, excludes, enabled = case value
          when TrueClass, FalseClass
            [[], [], value]
          when Hash
            [*value.values_at(:includes, :excludes), true]
          else
            [value, [], true]
          end
          {includes: Array.wrap(includes).reject(&:blank?).map(&:to_s),
           excludes: Array.wrap(excludes).reject(&:blank?).map(&:to_s),
           enabled: enabled}
        end
      end
    end
  end
end
