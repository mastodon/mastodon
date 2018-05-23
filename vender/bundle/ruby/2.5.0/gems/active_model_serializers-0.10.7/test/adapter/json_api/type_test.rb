require 'test_helper'

module ActiveModelSerializers
  module Adapter
    class JsonApi
      class TypeTest < ActiveSupport::TestCase
        class StringTypeSerializer < ActiveModel::Serializer
          attribute :name
          type 'profile'
        end

        class SymbolTypeSerializer < ActiveModel::Serializer
          attribute :name
          type :profile
        end

        setup do
          @author = Author.new(id: 1, name: 'Steve K.')
        end

        def test_config_plural
          with_jsonapi_inflection :plural do
            assert_type(@author, 'authors')
          end
        end

        def test_config_singular
          with_jsonapi_inflection :singular do
            assert_type(@author, 'author')
          end
        end

        def test_explicit_string_type_value
          assert_type(@author, 'profile', serializer: StringTypeSerializer)
        end

        def test_explicit_symbol_type_value
          assert_type(@author, 'profile', serializer: SymbolTypeSerializer)
        end

        private

        def assert_type(resource, expected_type, opts = {})
          opts = opts.reverse_merge(adapter: :json_api)
          hash = serializable(resource, opts).serializable_hash
          assert_equal(expected_type, hash.fetch(:data).fetch(:type))
        end
      end
      class ResourceIdentifierTest < ActiveSupport::TestCase
        class WithDefinedTypeSerializer < ActiveModel::Serializer
          type 'with_defined_types'
        end

        class WithDefinedIdSerializer < ActiveModel::Serializer
          def id
            'special_id'
          end
        end

        class FragmentedSerializer < ActiveModel::Serializer
          cache only: :id

          def id
            'special_id'
          end
        end

        setup do
          @model = Author.new(id: 1, name: 'Steve K.')
          ActionController::Base.cache_store.clear
        end

        def test_defined_type
          actual = with_jsonapi_inflection :plural do
            actual_resource_identifier_object(WithDefinedTypeSerializer, @model)
          end
          expected = { id: expected_model_id(@model), type: 'with-defined-types' }
          assert_equal actual, expected
        end

        def test_defined_type_not_inflected
          actual = with_jsonapi_inflection :singular do
            actual_resource_identifier_object(WithDefinedTypeSerializer, @model)
          end
          expected = { id: expected_model_id(@model), type: 'with-defined-types' }
          assert_equal actual, expected
        end

        def test_singular_type
          actual = with_jsonapi_inflection :singular do
            actual_resource_identifier_object(AuthorSerializer, @model)
          end
          expected = { id: expected_model_id(@model), type: 'author' }
          assert_equal actual, expected
        end

        def test_plural_type
          actual = with_jsonapi_inflection :plural do
            actual_resource_identifier_object(AuthorSerializer, @model)
          end
          expected = { id: expected_model_id(@model), type: 'authors' }
          assert_equal actual, expected
        end

        def test_type_with_namespace
          Object.const_set(:Admin, Module.new)
          model = Class.new(::Model)
          Admin.const_set(:PowerUser, model)
          serializer = Class.new(ActiveModel::Serializer)
          Admin.const_set(:PowerUserSerializer, serializer)
          with_namespace_separator '--' do
            admin_user = Admin::PowerUser.new
            serializer = Admin::PowerUserSerializer.new(admin_user)
            expected = {
              id: admin_user.id,
              type: 'admin--power-users'
            }

            identifier = ResourceIdentifier.new(serializer, {})
            actual = identifier.as_json
            assert_equal(expected, actual)
          end
        end

        def test_id_defined_on_object
          actual = actual_resource_identifier_object(AuthorSerializer, @model)
          expected = { id: @model.id.to_s, type: expected_model_type(@model) }
          assert_equal actual, expected
        end

        def test_blank_id
          model = Author.new(id: nil, name: 'Steve K.')
          actual = actual_resource_identifier_object(AuthorSerializer, model)
          expected = { type: expected_model_type(model) }
          assert_equal actual, expected
        end

        def test_for_type_with_id
          id = 1
          actual = ResourceIdentifier.for_type_with_id('admin_user', id, {})
          expected = { id: '1', type: 'admin-users' }
          assert_equal actual, expected
        end

        def test_for_type_with_id_given_blank_id
          id = ''
          actual = ResourceIdentifier.for_type_with_id('admin_user', id, {})
          expected = { type: 'admin-users' }
          assert_equal actual, expected
        end

        def test_for_type_with_id_inflected
          id = 2
          actual = with_jsonapi_inflection :singular do
            ResourceIdentifier.for_type_with_id('admin_users', id, {})
          end
          expected = { id: '2', type: 'admin-user' }
          assert_equal actual, expected
        end

        def test_id_defined_on_serializer
          actual = actual_resource_identifier_object(WithDefinedIdSerializer, @model)
          expected = { id: 'special_id', type: expected_model_type(@model) }
          assert_equal actual, expected
        end

        def test_id_defined_on_fragmented
          actual = actual_resource_identifier_object(FragmentedSerializer, @model)
          expected = { id: 'special_id', type: expected_model_type(@model) }
          assert_equal actual, expected
        end

        private

        def actual_resource_identifier_object(serializer_class, model)
          serializer = serializer_class.new(model)
          resource_identifier = ResourceIdentifier.new(serializer, nil)
          resource_identifier.as_json
        end

        def expected_model_type(model, inflection = ActiveModelSerializers.config.jsonapi_resource_type)
          with_jsonapi_inflection inflection do
            model.class.model_name.send(inflection)
          end
        end

        def expected_model_id(model)
          model.id.to_s
        end
      end
    end
  end
end
