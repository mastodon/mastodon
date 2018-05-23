require 'test_helper'

module ActiveModel
  class Serializer
    class AttributeTest < ActiveSupport::TestCase
      def setup
        @blog = Blog.new(id: 1, name: 'AMS Hints', type: 'stuff')
        @blog_serializer = AlternateBlogSerializer.new(@blog)
      end

      def test_attributes_definition
        assert_equal([:id, :title],
          @blog_serializer.class._attributes)
      end

      def test_json_serializable_hash
        adapter = ActiveModelSerializers::Adapter::Json.new(@blog_serializer)
        assert_equal({ blog: { id: 1, title: 'AMS Hints' } }, adapter.serializable_hash)
      end

      def test_attribute_inheritance_with_key
        inherited_klass = Class.new(AlternateBlogSerializer)
        blog_serializer = inherited_klass.new(@blog)
        adapter = ActiveModelSerializers::Adapter::Attributes.new(blog_serializer)
        assert_equal({ id: 1, title: 'AMS Hints' }, adapter.serializable_hash)
      end

      def test_multiple_calls_with_the_same_attribute
        serializer_class = Class.new(ActiveModel::Serializer) do
          attribute :title
          attribute :title
        end

        assert_equal([:title], serializer_class._attributes)
      end

      def test_id_attribute_override
        serializer = Class.new(ActiveModel::Serializer) do
          attribute :name, key: :id
        end

        adapter = ActiveModelSerializers::Adapter::Json.new(serializer.new(@blog))
        assert_equal({ blog: { id: 'AMS Hints' } }, adapter.serializable_hash)
      end

      def test_object_attribute_override
        serializer = Class.new(ActiveModel::Serializer) do
          attribute :name, key: :object
        end

        adapter = ActiveModelSerializers::Adapter::Json.new(serializer.new(@blog))
        assert_equal({ blog: { object: 'AMS Hints' } }, adapter.serializable_hash)
      end

      def test_type_attribute
        attribute_serializer = Class.new(ActiveModel::Serializer) do
          attribute :id, key: :type
        end
        attributes_serializer = Class.new(ActiveModel::Serializer) do
          attributes :type
        end

        adapter = ActiveModelSerializers::Adapter::Json.new(attribute_serializer.new(@blog))
        assert_equal({ blog: { type: 1 } }, adapter.serializable_hash)

        adapter = ActiveModelSerializers::Adapter::Json.new(attributes_serializer.new(@blog))
        assert_equal({ blog: { type: 'stuff' } }, adapter.serializable_hash)
      end

      def test_id_attribute_override_before
        serializer = Class.new(ActiveModel::Serializer) do
          def id
            'custom'
          end

          attribute :id
        end

        hash = ActiveModelSerializers::SerializableResource.new(@blog, adapter: :json, serializer: serializer).serializable_hash

        assert_equal('custom', hash[:blog][:id])
      end

      class PostWithVirtualAttribute < ::Model; attributes :first_name, :last_name end
      class PostWithVirtualAttributeSerializer < ActiveModel::Serializer
        attribute :name do
          "#{object.first_name} #{object.last_name}"
        end
      end

      def test_virtual_attribute_block
        post = PostWithVirtualAttribute.new(first_name: 'Lucas', last_name: 'Hosseini')
        hash = serializable(post).serializable_hash
        expected = { name: 'Lucas Hosseini' }

        assert_equal(expected, hash)
      end

      # rubocop:disable Metrics/AbcSize
      def test_conditional_associations
        model = Class.new(::Model) do
          attributes :true, :false, :attribute
        end.new(true: true, false: false)

        scenarios = [
          { options: { if:     :true  }, included: true  },
          { options: { if:     :false }, included: false },
          { options: { unless: :false }, included: true  },
          { options: { unless: :true  }, included: false },
          { options: { if:     'object.true'  }, included: true  },
          { options: { if:     'object.false' }, included: false },
          { options: { unless: 'object.false' }, included: true  },
          { options: { unless: 'object.true'  }, included: false },
          { options: { if:     -> { object.true }  }, included: true  },
          { options: { if:     -> { object.false } }, included: false },
          { options: { unless: -> { object.false } }, included: true  },
          { options: { unless: -> { object.true }  }, included: false },
          { options: { if:     -> (s) { s.object.true }  }, included: true  },
          { options: { if:     -> (s) { s.object.false } }, included: false },
          { options: { unless: -> (s) { s.object.false } }, included: true  },
          { options: { unless: -> (s) { s.object.true }  }, included: false }
        ]

        scenarios.each do |s|
          serializer = Class.new(ActiveModel::Serializer) do
            attribute :attribute, s[:options]

            def true
              true
            end

            def false
              false
            end
          end

          hash = serializable(model, serializer: serializer).serializable_hash
          assert_equal(s[:included], hash.key?(:attribute), "Error with #{s[:options]}")
        end
      end

      def test_illegal_conditional_attributes
        exception = assert_raises(TypeError) do
          Class.new(ActiveModel::Serializer) do
            attribute :x, if: nil
          end
        end

        assert_match(/:if should be a Symbol, String or Proc/, exception.message)
      end
    end
  end
end
