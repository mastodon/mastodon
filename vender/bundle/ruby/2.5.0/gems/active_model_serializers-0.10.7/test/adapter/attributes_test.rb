require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class AttributesTest < ActiveSupport::TestCase
      class Person < ActiveModelSerializers::Model
        attributes :first_name, :last_name
      end

      class PersonSerializer < ActiveModel::Serializer
        attributes :first_name, :last_name
      end

      def setup
        ActionController::Base.cache_store.clear
      end

      def test_serializable_hash
        person = Person.new(first_name: 'Arthur', last_name: 'Dent')
        serializer = PersonSerializer.new(person)
        adapter = ActiveModelSerializers::Adapter::Attributes.new(serializer)

        assert_equal({ first_name: 'Arthur', last_name: 'Dent' },
          adapter.serializable_hash)
      end

      def test_serializable_hash_with_transform_key_casing
        person = Person.new(first_name: 'Arthur', last_name: 'Dent')
        serializer = PersonSerializer.new(person)
        adapter = ActiveModelSerializers::Adapter::Attributes.new(
          serializer,
          key_transform: :camel_lower
        )

        assert_equal({ firstName: 'Arthur', lastName: 'Dent' },
          adapter.serializable_hash)
      end
    end
  end
end
