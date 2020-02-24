require 'rails_helper'

RSpec.describe ActivityPub::Adapter do
  class TestObject < ActiveModelSerializers::Model
    attributes :foo
  end

  class TestWithBasicContextSerializer < ActivityPub::Serializer
    attributes :foo
  end

  class TestWithNamedContextSerializer < ActivityPub::Serializer
    context :security
    attributes :foo
  end

  class TestWithNestedNamedContextSerializer < ActivityPub::Serializer
    attributes :foo

    has_one :virtual_object, key: :baz, serializer: TestWithNamedContextSerializer

    def virtual_object
      object
    end
  end

  class TestWithContextExtensionSerializer < ActivityPub::Serializer
    context_extensions :sensitive
    attributes :foo
  end

  class TestWithNestedContextExtensionSerializer < ActivityPub::Serializer
    context_extensions :manually_approves_followers
    attributes :foo

    has_one :virtual_object, key: :baz, serializer: TestWithContextExtensionSerializer

    def virtual_object
      object
    end
  end

  describe '#serializable_hash' do
    let(:serializer_class) {}

    subject { ActiveModelSerializers::SerializableResource.new(TestObject.new(foo: 'bar'), serializer: serializer_class, adapter: described_class).as_json }

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
