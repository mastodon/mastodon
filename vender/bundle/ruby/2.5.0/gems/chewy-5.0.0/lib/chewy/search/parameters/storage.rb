module Chewy
  module Search
    class Parameters
      # Base parameter storage, defines a conventional API and
      # its default behavior.
      class Storage
        class << self
          attr_writer :param_name

          # @!attribute [rw] param_name
          # The parameter name is used on rendering, derived from the class
          # name by default, but can be easily redefined for child classes.
          #
          # @example
          #   class Limit < Storage
          #     self.param_name = :size
          #   end
          # @return [Symbol] parameter name
          def param_name
            @param_name ||= name.demodulize.underscore.to_sym
          end
        end

        # Returns normalized storage value.
        attr_reader :value

        # @param value [Object] any acceptable storage value
        def initialize(value = nil)
          replace!(value)
        end

        # Compares two storages, basically, classes and values should
        # be identical.
        #
        # @param other [Chewy::Search::Parameters::Storage] any storage instance
        # @return [true, false] the result of comparision
        def ==(other)
          super || other.class == self.class && other.value == value
        end

        # Replaces current value with normalized provided one. Doesn't
        # make sense to redefine it in child classes, the replacement
        # logic should be kept as is.
        #
        # @see Chewy::Search::Request
        # @param new_value [Object] any acceptable storage value
        # @return [Object] new normalized value
        def replace!(new_value)
          @value = normalize(new_value)
        end

        # Implements the storage update logic, picks the first present
        # value by default, but can be redefined if necessary.
        #
        # @see Chewy::Search::Request
        # @param other_value [Object] any acceptable storage value
        # @return [Object] updated value
        def update!(other_value)
          replace!([value, normalize(other_value)].compact.last)
        end

        # Merges one storage with another one using update by default.
        # Requires redefinition sometimes.
        #
        # @see Chewy::Search::Parameters#merge!
        # @see Chewy::Search::Request#merge
        # @param other [Chewy::Search::Parameters::Storage] other storage
        # @return [Object] updated value
        def merge!(other)
          update!(other.value)
        end

        # Basic parameter rendering logic, don't need to return anything
        # if parameter doesn't require rendering for the current value.
        #
        # @see Chewy::Search::Parameters#render
        # @see Chewy::Search::Request#render
        # @return [{Symbol => Object}, nil] rendered value with the parameter name
        def render
          {self.class.param_name => value} if value.present?
        end

      private

        def initialize_clone(origin)
          @value = origin.value.deep_dup
        end

        def normalize(value)
          value
        end
      end
    end
  end
end
