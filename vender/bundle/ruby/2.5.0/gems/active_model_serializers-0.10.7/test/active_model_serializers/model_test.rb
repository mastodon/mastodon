require 'test_helper'

module ActiveModelSerializers
  class ModelTest < ActiveSupport::TestCase
    include ActiveModel::Serializer::Lint::Tests

    setup do
      @resource = ActiveModelSerializers::Model.new
    end

    def test_initialization_with_string_keys
      klass = Class.new(ActiveModelSerializers::Model) do
        attributes :key
      end
      value = 'value'

      model_instance = klass.new('key' => value)

      assert_equal model_instance.read_attribute_for_serialization(:key), value
    end

    def test_attributes_can_be_read_for_serialization
      klass = Class.new(ActiveModelSerializers::Model) do
        attributes :one, :two, :three
      end
      original_attributes = { one: 1, two: 2, three: 3 }
      original_instance = klass.new(original_attributes)

      # Initial value
      instance = original_instance
      expected_attributes = { one: 1, two: 2, three: 3 }.with_indifferent_access
      assert_equal expected_attributes, instance.attributes
      assert_equal 1, instance.one
      assert_equal 1, instance.read_attribute_for_serialization(:one)

      # FIXME: Change via accessor has no effect on attributes.
      instance = original_instance.dup
      instance.one = :not_one
      assert_equal expected_attributes, instance.attributes
      assert_equal :not_one, instance.one
      assert_equal :not_one, instance.read_attribute_for_serialization(:one)

      # FIXME: Change via mutating attributes
      instance = original_instance.dup
      instance.attributes[:one] = :not_one
      expected_attributes = { one: :not_one, two: 2, three: 3 }.with_indifferent_access
      assert_equal expected_attributes, instance.attributes
      assert_equal 1, instance.one
      assert_equal 1, instance.read_attribute_for_serialization(:one)
    end

    def test_attributes_can_be_read_for_serialization_with_attributes_accessors_fix
      klass = Class.new(ActiveModelSerializers::Model) do
        derive_attributes_from_names_and_fix_accessors
        attributes :one, :two, :three
      end
      original_attributes = { one: 1, two: 2, three: 3 }
      original_instance = klass.new(original_attributes)

      # Initial value
      instance = original_instance
      expected_attributes = { one: 1, two: 2, three: 3 }.with_indifferent_access
      assert_equal expected_attributes, instance.attributes
      assert_equal 1, instance.one
      assert_equal 1, instance.read_attribute_for_serialization(:one)

      expected_attributes = { one: :not_one, two: 2, three: 3 }.with_indifferent_access
      # Change via accessor
      instance = original_instance.dup
      instance.one = :not_one
      assert_equal expected_attributes, instance.attributes
      assert_equal :not_one, instance.one
      assert_equal :not_one, instance.read_attribute_for_serialization(:one)

      # Attributes frozen
      assert instance.attributes.frozen?
    end

    def test_id_attribute_can_be_read_for_serialization
      klass = Class.new(ActiveModelSerializers::Model) do
        attributes :id, :one, :two, :three
      end
      self.class.const_set(:SomeTestModel, klass)
      original_attributes = { id: :ego, one: 1, two: 2, three: 3 }
      original_instance = klass.new(original_attributes)

      # Initial value
      instance = original_instance.dup
      expected_attributes = { id: :ego, one: 1, two: 2, three: 3 }.with_indifferent_access
      assert_equal expected_attributes, instance.attributes
      assert_equal :ego, instance.id
      assert_equal :ego, instance.read_attribute_for_serialization(:id)

      # FIXME: Change via accessor has no effect on attributes.
      instance = original_instance.dup
      instance.id = :superego
      assert_equal expected_attributes, instance.attributes
      assert_equal :superego, instance.id
      assert_equal :superego, instance.read_attribute_for_serialization(:id)

      # FIXME: Change via mutating attributes
      instance = original_instance.dup
      instance.attributes[:id] = :superego
      expected_attributes = { id: :superego, one: 1, two: 2, three: 3 }.with_indifferent_access
      assert_equal expected_attributes, instance.attributes
      assert_equal :ego, instance.id
      assert_equal :ego, instance.read_attribute_for_serialization(:id)
    ensure
      self.class.send(:remove_const, :SomeTestModel)
    end

    def test_id_attribute_can_be_read_for_serialization_with_attributes_accessors_fix
      klass = Class.new(ActiveModelSerializers::Model) do
        derive_attributes_from_names_and_fix_accessors
        attributes :id, :one, :two, :three
      end
      self.class.const_set(:SomeTestModel, klass)
      original_attributes = { id: :ego, one: 1, two: 2, three: 3 }
      original_instance = klass.new(original_attributes)

      # Initial value
      instance = original_instance.dup
      expected_attributes = { id: :ego, one: 1, two: 2, three: 3 }.with_indifferent_access
      assert_equal expected_attributes, instance.attributes
      assert_equal :ego, instance.id
      assert_equal :ego, instance.read_attribute_for_serialization(:id)

      expected_attributes = { id: :superego, one: 1, two: 2, three: 3 }.with_indifferent_access
      # Change via accessor
      instance = original_instance.dup
      instance.id = :superego
      assert_equal expected_attributes, instance.attributes
      assert_equal :superego, instance.id
      assert_equal :superego, instance.read_attribute_for_serialization(:id)

      # Attributes frozen
      assert instance.attributes.frozen?
    ensure
      self.class.send(:remove_const, :SomeTestModel)
    end
  end
end
