# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActivityPub::Adapter do
  before do
    test_object_class = Class.new(ActiveModelSerializers::Model) do
      attributes :foo
    end
    stub_const('TestObject', test_object_class)

    test_with_basic_context_serializer = Class.new(ActivityPub::Serializer) do
      attributes :foo
    end
    stub_const('TestWithBasicContextSerializer', test_with_basic_context_serializer)

    test_with_named_context_serializer = Class.new(ActivityPub::Serializer) do
      context :security
      attributes :foo
    end
    stub_const('TestWithNamedContextSerializer', test_with_named_context_serializer)

    test_with_nested_named_context_serializer = Class.new(ActivityPub::Serializer) do
      attributes :foo

      has_one :virtual_object, key: :baz, serializer: TestWithNamedContextSerializer

      def virtual_object
        object
      end
    end
    stub_const('TestWithNestedNamedContextSerializer', test_with_nested_named_context_serializer)

    test_with_context_extension_serializer = Class.new(ActivityPub::Serializer) do
      context_extensions :sensitive
      attributes :foo
    end
    stub_const('TestWithContextExtensionSerializer', test_with_context_extension_serializer)

    test_with_nested_context_extension_serializer = Class.new(ActivityPub::Serializer) do
      context_extensions :manually_approves_followers
      attributes :foo

      has_one :virtual_object, key: :baz, serializer: TestWithContextExtensionSerializer

      def virtual_object
        object
      end
    end
    stub_const('TestWithNestedContextExtensionSerializer', test_with_nested_context_extension_serializer)
  end

  describe '#serializable_hash' do
    subject { ActiveModelSerializers::SerializableResource.new(TestObject.new(foo: 'bar'), serializer: serializer_class, adapter: described_class).as_json }

    let(:serializer_class) {}

    context 'when serializer defines no context' do
      let(:serializer_class) { TestWithBasicContextSerializer }

      it 'renders a basic @context' do
        expect(subject).to include({ '@context' => 'https://www.w3.org/ns/activitystreams' })
      end
    end

    context 'when serializer defines a named context' do
      let(:serializer_class) { TestWithNamedContextSerializer }

      it 'renders a @context with both items' do
        expect(subject).to include({ '@context' => ['https://www.w3.org/ns/activitystreams', 'https://w3id.org/security/v1'] })
      end
    end

    context 'when serializer has children that define a named context' do
      let(:serializer_class) { TestWithNestedNamedContextSerializer }

      it 'renders a @context with both items' do
        expect(subject).to include({ '@context' => ['https://www.w3.org/ns/activitystreams', 'https://w3id.org/security/v1'] })
      end
    end

    context 'when serializer defines context extensions' do
      let(:serializer_class) { TestWithContextExtensionSerializer }

      it 'renders a @context with the extension' do
        expect(subject).to include({ '@context' => ['https://www.w3.org/ns/activitystreams', { 'sensitive' => 'as:sensitive' }] })
      end
    end

    context 'when serializer has children that define context extensions' do
      let(:serializer_class) { TestWithNestedContextExtensionSerializer }

      it 'renders a @context with both extensions' do
        expect(subject).to include({ '@context' => ['https://www.w3.org/ns/activitystreams', { 'manuallyApprovesFollowers' => 'as:manuallyApprovesFollowers', 'sensitive' => 'as:sensitive' }] })
      end
    end
  end
end
