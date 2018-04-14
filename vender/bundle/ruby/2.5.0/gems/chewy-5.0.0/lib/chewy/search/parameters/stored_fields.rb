require 'chewy/search/parameters/storage'

module Chewy
  module Search
    class Parameters
      # This storage is basically an array storage, but with an
      # additional ability to pass `enabled` option.
      #
      # @see Chewy::Search::Request#stored_fields
      # @see https://www.elastic.co/guide/en/elasticsearch/reference/5.4/search-request-stored-fields.html
      class StoredFields < Storage
        # If array or just a field name is passed - it gets concatenated
        # to the storage array. `true` or `false` values are modifying
        # `enabled` parameter.
        #
        # @see Chewy::Search::Parameters::Storage#update!
        # @param other_value [true, false, String, Symbol, Array<String, Symbol>] any acceptable storage value
        # @return [{Symbol => Array<String>, true, false}] updated value
        def update!(other_value)
          new_value = normalize(other_value)
          new_value[:stored_fields] = value[:stored_fields] | new_value[:stored_fields]
          @value = new_value
        end

        # Requires an additional logic to merge `enabled` value.
        #
        # @see Chewy::Search::Parameters::Storage#merge!
        # @param other [Chewy::Search::Parameters::Storage] other storage
        # @return [{Symbol => Array<String>, true, false}] updated value
        def merge!(other)
          update!(other.value[:stored_fields])
          update!(other.value[:enabled])
        end

        # Renders `_none_` if `stored_fields` are disabled, otherwise renders the
        # array of stored field names.
        #
        # @see Chewy::Search::Parameters::Storage#render
        # @return [{Symbol => Object}, nil] rendered value with the parameter name
        def render
          if !value[:enabled]
            {self.class.param_name => '_none_'}
          elsif value[:stored_fields].present?
            {self.class.param_name => value[:stored_fields]}
          end
        end

      private

        def normalize(raw_value)
          stored_fields, enabled = case raw_value
          when TrueClass, FalseClass
            [[], raw_value]
          else
            [raw_value, true]
          end
          {stored_fields: Array.wrap(stored_fields).reject(&:blank?).map(&:to_s),
           enabled: enabled}
        end
      end
    end
  end
end
