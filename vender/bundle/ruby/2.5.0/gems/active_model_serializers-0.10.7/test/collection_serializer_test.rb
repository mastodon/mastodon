require 'test_helper'

module ActiveModel
  class Serializer
    class CollectionSerializerTest < ActiveSupport::TestCase
      class SingularModel < ::Model; end
      class SingularModelSerializer < ActiveModel::Serializer
      end
      class HasManyModel < ::Model
        associations :singular_models
      end
      class HasManyModelSerializer < ActiveModel::Serializer
        has_many :singular_models

        def custom_options
          instance_options
        end
      end
      class MessagesSerializer < ActiveModel::Serializer
        type 'messages'
      end

      def setup
        @singular_model = SingularModel.new
        @has_many_model = HasManyModel.new
        @resource = build_named_collection @singular_model, @has_many_model
        @serializer = collection_serializer.new(@resource, some: :options)
      end

      def collection_serializer
        CollectionSerializer
      end

      def build_named_collection(*resource)
        resource.define_singleton_method(:name) { 'MeResource' }
        resource
      end

      def test_has_object_reader_serializer_interface
        assert_equal @serializer.object, @resource
      end

      def test_respond_to_each
        assert_respond_to @serializer, :each
      end

      def test_each_object_should_be_serialized_with_appropriate_serializer
        serializers =  @serializer.to_a

        assert_kind_of SingularModelSerializer, serializers.first
        assert_kind_of SingularModel, serializers.first.object

        assert_kind_of HasManyModelSerializer, serializers.last
        assert_kind_of HasManyModel, serializers.last.object

        assert_equal :options, serializers.last.custom_options[:some]
      end

      def test_serializer_option_not_passed_to_each_serializer
        serializers = collection_serializer.new([@has_many_model], serializer: HasManyModelSerializer).to_a

        refute serializers.first.custom_options.key?(:serializer)
      end

      def test_root_default
        @serializer = collection_serializer.new([@singular_model, @has_many_model])
        assert_nil @serializer.root
      end

      def test_root
        expected =  'custom_root'
        @serializer = collection_serializer.new([@singular_model, @has_many_model], root: expected)
        assert_equal expected, @serializer.root
      end

      def test_root_with_no_serializers
        expected =  'custom_root'
        @serializer = collection_serializer.new([], root: expected)
        assert_equal expected, @serializer.root
      end

      def test_json_key_with_resource_with_serializer
        singular_key = @serializer.send(:serializers).first.json_key
        assert_equal singular_key.pluralize, @serializer.json_key
      end

      def test_json_key_with_resource_with_name_and_no_serializers
        serializer = collection_serializer.new(build_named_collection)
        assert_equal 'me_resources', serializer.json_key
      end

      def test_json_key_with_resource_with_nil_name_and_no_serializers
        resource = []
        resource.define_singleton_method(:name) { nil }
        serializer = collection_serializer.new(resource)
        assert_raise ArgumentError do
          serializer.json_key
        end
      end

      def test_json_key_with_resource_without_name_and_no_serializers
        serializer = collection_serializer.new([])
        assert_raise ArgumentError do
          serializer.json_key
        end
      end

      def test_json_key_with_empty_resources_with_serializer
        resource = []
        serializer = collection_serializer.new(resource, serializer: MessagesSerializer)
        assert_equal 'messages', serializer.json_key
      end

      def test_json_key_with_root
        expected = 'custom_root'
        serializer = collection_serializer.new(@resource, root: expected)
        assert_equal expected, serializer.json_key
      end

      def test_json_key_with_root_and_no_serializers
        expected = 'custom_root'
        serializer = collection_serializer.new(build_named_collection, root: expected)
        assert_equal expected, serializer.json_key
      end
    end
  end
end
