require 'test_helper'

module ActiveModel
  class Serializer
    class LintTest < ActiveSupport::TestCase
      include ActiveModel::Serializer::Lint::Tests

      class CompliantResource
        def serializable_hash(options = nil)
        end

        def read_attribute_for_serialization(name)
        end

        def as_json(options = nil)
        end

        def to_json(options = nil)
        end

        def cache_key
        end

        def id
        end

        def updated_at
        end

        def errors
        end

        def self.human_attribute_name(_, _ = {})
        end

        def self.lookup_ancestors
        end

        def self.model_name
          @_model_name ||= ActiveModel::Name.new(self)
        end
      end

      def setup
        @resource = CompliantResource.new
      end
    end
  end
end
